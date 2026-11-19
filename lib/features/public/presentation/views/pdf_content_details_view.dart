import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:new_azkar_app/features/home/entities/content.dart';
import 'package:new_azkar_app/features/public/providers/contents_provider.dart';
import 'package:new_azkar_app/core/providers/settings_provider.dart';
import 'package:new_azkar_app/core/providers/global_audio_provider.dart';

class PdfContentDetailsParams {
  final Content? content;
  final String? title;
  final String? pdfPath; // Can be asset path (assets/...) or file path or URL
  final String? voiceFile; // Google drive ID or audio file name
  final bool isLiked;

  PdfContentDetailsParams({
    this.content,
    this.title,
    this.pdfPath,
    this.voiceFile,
    this.isLiked = false,
  });
}

class PdfContentDetailsView extends ConsumerStatefulWidget {
  final PdfContentDetailsParams params;

  const PdfContentDetailsView({super.key, required this.params});

  @override
  ConsumerState<PdfContentDetailsView> createState() =>
      _PdfContentDetailsViewState();
}

class _PdfContentDetailsViewState extends ConsumerState<PdfContentDetailsView> {
  // Audio Player State
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoadingAudio = false;
  bool _isDownloadingAudio = false;
  double _downloadProgress = 0.0;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _audioSpeed = 1.0;
  String? _localAudioPath;
  bool _autoPlayStopped = false;

  // Stream Subscriptions
  StreamSubscription? _playerStateSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _playerCompleteSub;

  // PDF State
  String? _localPdfPath;
  bool _isLoadingPdf = true;
  String? _pdfError;
  int _totalPages = 0;
  int _currentPage = 0;
  PDFViewController? _pdfViewController;

  Content? get content => widget.params.content;
  String get voiceFile => widget.params.voiceFile ?? content?.voiceFile ?? '';
  bool get hasVoice =>
      (widget.params.voiceFile != null && widget.params.voiceFile!.isNotEmpty) ||
      (content?.hasVoice ?? false);
  String get displayTitle =>
      widget.params.title ?? content?.text ?? 'عرض المستند PDF';

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initPdf();
    if (hasVoice && voiceFile.isNotEmpty) {
      _initAudio();
    }
  }

  // --- PDF Logic ---
  Future<void> _initPdf() async {
    final rawPath = widget.params.pdfPath ?? content?.text ?? '';
    if (rawPath.isEmpty) {
      setState(() {
        _isLoadingPdf = false;
        _pdfError = 'لم يتم تحديد ملف PDF';
      });
      return;
    }

    try {
      if (rawPath.startsWith('assets/')) {
        // Load asset to temporary file for PDFView
        final bytes = await rootBundle.load(rawPath);
        final dir = await getTemporaryDirectory();
        final filename = rawPath.split('/').last;
        final file = File('${dir.path}/$filename');
        await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
        if (mounted) {
          setState(() {
            _localPdfPath = file.path;
            _isLoadingPdf = false;
          });
        }
      } else if (rawPath.startsWith('http://') ||
          rawPath.startsWith('https://')) {
        // Handle Google Drive link formatting
        String downloadUrl = rawPath;
        String fileId = 'temp_${rawPath.hashCode}';
        if (rawPath.contains('drive.google.com')) {
          final RegExp regExp =
              RegExp(r'(?:file\/d\/|id=)([a-zA-Z0-9_-]+)');
          final match = regExp.firstMatch(rawPath);
          if (match != null && match.groupCount >= 1) {
            fileId = match.group(1)!;
            downloadUrl =
                'https://drive.usercontent.google.com/download?id=$fileId&export=download&confirm=t';
          }
        }

        // Store permanently in Application Documents Directory (like audio files)
        final baseDir = await getApplicationDocumentsDirectory();
        final pdfDir = Directory('${baseDir.path}/pdfs');
        if (!await pdfDir.exists()) {
          await pdfDir.create(recursive: true);
        }
        final file = File('${pdfDir.path}/$fileId.pdf');

        // Permanent Cache check: If PDF file already exists locally and is valid, load instantly (offline mode)
        if (await file.exists() && await file.length() > 100) {
          try {
            final header = await file.openRead(0, 5).first;
            final headerString = String.fromCharCodes(header);
            if (headerString.startsWith('%PDF')) {
              if (mounted) {
                setState(() {
                  _localPdfPath = file.path;
                  _isLoadingPdf = false;
                });
              }
              return;
            }
          } catch (_) {
            // Re-download if file corrupted
          }
        }

        // Perform robust HTTP Download for initial download
        final client = HttpClient();
        client.autoUncompress = true;

        Uri currentUri = Uri.parse(downloadUrl);
        HttpClientResponse? response;
        int redirectCount = 0;

        while (redirectCount < 5) {
          final request = await client.getUrl(currentUri);
          request.followRedirects = false;
          response = await request.close();
          if (response.statusCode >= 300 &&
              response.statusCode < 400 &&
              response.headers.value('location') != null) {
            final loc = response.headers.value('location')!;
            currentUri = Uri.parse(
                loc.startsWith('http') ? loc : currentUri.resolve(loc).toString());
            redirectCount++;
          } else {
            break;
          }
        }

        if (response != null && response.statusCode == 200) {
          final sink = file.openWrite();
          await response.pipe(sink);

          // Verify downloaded content is a valid PDF
          if (await file.exists() && await file.length() > 5) {
            final headerBytes = await file.openRead(0, 5).first;
            final headerString = String.fromCharCodes(headerBytes);
            if (!headerString.startsWith('%PDF')) {
              await file.delete();
              throw Exception('الملف المحمّل ليس بصيغة PDF صالحة');
            }
          }

          if (mounted) {
            setState(() {
              _localPdfPath = file.path;
              _isLoadingPdf = false;
            });
          }
        } else {
          throw Exception(
              'فشل تحميل ملف PDF (رمز ${response?.statusCode ?? 0})');
        }
      } else {
        // Local File Path
        final file = File(rawPath);
        if (await file.exists()) {
          setState(() {
            _localPdfPath = file.path;
            _isLoadingPdf = false;
          });
        } else {
          // Fallback check in docs
          final docsDir = await getApplicationDocumentsDirectory();
          final docFile = File('${docsDir.path}/$rawPath');
          if (await docFile.exists()) {
            setState(() {
              _localPdfPath = docFile.path;
              _isLoadingPdf = false;
            });
          } else {
            setState(() {
              _localPdfPath = rawPath; // Let PDFView attempt opening it directly
              _isLoadingPdf = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPdf = false;
          _pdfError = 'خطأ في فتح ملف PDF: $e';
        });
      }
    }
  }

  // --- Audio Logic ---
  Future<void> _initAudio() async {
    _playerStateSub = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _durationSub = _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) {
        setState(() {
          _duration = d;
        });
      }
    });

    _positionSub = _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) {
        setState(() {
          _position = p;
        });
      }
    });

    _playerCompleteSub = _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });

    await _checkAndPrepareAudio();
  }

  Future<String> _getAudioLocalPath() async {
    final Directory baseDir = await getApplicationDocumentsDirectory();
    final Directory audioDir = Directory('${baseDir.path}/audios');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return '${audioDir.path}/$voiceFile.mp3';
  }

  Future<bool> _localAudioExists() async {
    final path = await _getAudioLocalPath();
    final file = File(path);
    if (await file.exists() && await file.length() > 0) {
      _localAudioPath = path;
      return true;
    }
    return false;
  }

  Future<void> _downloadAudio() async {
    if (_isDownloadingAudio) return;
    setState(() {
      _isDownloadingAudio = true;
      _downloadProgress = 0.0;
    });

    final String url =
        'https://drive.google.com/uc?export=download&id=$voiceFile&confirm=t';
    final String path = await _getAudioLocalPath();
    final file = File(path);

    HttpClient? httpClient;
    try {
      httpClient = HttpClient();
      httpClient.autoUncompress = true;
      Uri currentUri = Uri.parse(url);
      HttpClientResponse? res;
      int redirectCount = 0;

      while (redirectCount < 5) {
        final req = await httpClient.getUrl(currentUri);
        req.followRedirects = false;
        res = await req.close();
        if (res.statusCode >= 300 &&
            res.statusCode < 400 &&
            res.headers.value('location') != null) {
          final loc = res.headers.value('location')!;
          currentUri = Uri.parse(
              loc.startsWith('http') ? loc : currentUri.resolve(loc).toString());
          redirectCount++;
        } else {
          break;
        }
      }

      if (res == null || res.statusCode != 200) {
        throw HttpException('status ${res?.statusCode}');
      }

      final total = res.contentLength > 0 ? res.contentLength : null;
      final sink = file.openWrite();
      int received = 0;

      await for (final chunk in res) {
        sink.add(chunk);
        received += chunk.length;
        if (total != null && mounted) {
          setState(() {
            _downloadProgress = received / total;
          });
        }
      }
      await sink.close();

      _localAudioPath = path;
      if (mounted) {
        setState(() {
          _isDownloadingAudio = false;
          _downloadProgress = 1.0;
        });
      }
    } catch (e) {
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }
      if (mounted) {
        setState(() {
          _isDownloadingAudio = false;
          _downloadProgress = 0.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل تنزيل الملف الصوتي')),
        );
      }
    } finally {
      httpClient?.close(force: true);
    }
  }

  Future<void> _checkAndPrepareAudio() async {
    setState(() => _isLoadingAudio = true);
    try {
      if (await _localAudioExists()) {
        await _audioPlayer.setSource(DeviceFileSource(_localAudioPath!));
        final settings = ref.read(settingsProvider);
        if (settings.autoPlayAudio && !_autoPlayStopped) {
          _playAudio();
        }
      } else {
        await _downloadAudio();
        if (_localAudioPath != null) {
          await _audioPlayer.setSource(DeviceFileSource(_localAudioPath!));
          final settings = ref.read(settingsProvider);
          if (settings.autoPlayAudio && !_autoPlayStopped) {
            _playAudio();
          }
        }
      }
    } catch (e) {
      debugPrint('Error preparing audio: $e');
    } finally {
      if (mounted) setState(() => _isLoadingAudio = false);
    }
  }

  Future<void> _playAudio() async {
    if (!hasVoice || voiceFile.isEmpty) return;
    await ref.read(globalAudioProvider.notifier).playAudio(
      voiceFile: voiceFile,
      title: displayTitle,
      navigationTarget: widget.params,
    );
  }

  Future<void> _pauseAudio() async {
    await ref.read(globalAudioProvider.notifier).pause();
  }

  Future<void> _seekAudio(Duration position) async {
    await ref.read(globalAudioProvider.notifier).seek(position);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void onShare() {
    String message = displayTitle;
    message +=
        '\n\n تمت مشاركة الملف بواسطة تطبيق عمل اليوم والليلة\n'
        'https://play.google.com/store/apps/details?id=com.Letterspd.amal_alyoum';
    SharePlus.instance.share(ShareParams(text: message));
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _playerCompleteSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final favorite = ref.read(contentsListProvider.notifier);

    return Scaffold(
      backgroundColor: settings.nightMode
          ? AppColors.fourthColor[900]
          : AppColors.fourthColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: AppColors.gold,
        elevation: 0,
        title: Text(
          displayTitle,
          style: TextStyles.bold.copyWith(color: AppColors.gold, fontSize: 18),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              settings.nightMode ? Icons.dark_mode : Icons.light_mode,
              color: settings.nightMode
                  ? Colors.white
                  : AppColors.secondaryColor[100],
            ),
            tooltip: 'وضع القراءة الليلي',
            onPressed: () {
              ref
                  .read(settingsProvider.notifier)
                  .setNightMode(!settings.nightMode);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.gold),
            onPressed: onShare,
          ),
        ],
      ),
      body: Column(
        children: [
          // Page header / page indicator bar
          if (_totalPages > 0)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: settings.nightMode
                  ? AppColors.secondaryColor[900]?.withOpacity(0.5)
                  : AppColors.secondaryColor.withOpacity(0.08),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'صفحة ${_currentPage + 1} من $_totalPages',
                    style: TextStyles.mediumBold.copyWith(
                      color: settings.nightMode
                          ? AppColors.secondaryColor[100]
                          : AppColors.secondaryColor,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _currentPage > 0
                            ? () {
                                _pdfViewController?.setPage(_currentPage - 1);
                              }
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _currentPage < _totalPages - 1
                            ? () {
                                _pdfViewController?.setPage(_currentPage + 1);
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          // PDF Content View
          Expanded(
            child: _isLoadingPdf
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.secondaryColor,
                    ),
                  )
                : _pdfError != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            _pdfError!,
                            style: TextStyles.medium.copyWith(
                              color: AppColors.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : PDFView(
                        filePath: _localPdfPath,
                        enableSwipe: true,
                        swipeHorizontal: false,
                        autoSpacing: true,
                        pageFling: true,
                        pageSnap: true,
                        fitPolicy: FitPolicy.BOTH,
                        preventLinkNavigation: false,
                        onRender: (pages) {
                          setState(() {
                            _totalPages = pages ?? 0;
                          });
                        },
                        onError: (error) {
                          setState(() {
                            _pdfError = error.toString();
                          });
                        },
                        onPageError: (page, error) {
                          debugPrint('PDF Page $page error: $error');
                        },
                        onViewCreated: (PDFViewController controller) {
                          _pdfViewController = controller;
                        },
                        onPageChanged: (int? page, int? total) {
                          if (page != null && mounted) {
                            setState(() {
                              _currentPage = page;
                            });
                          }
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: content != null
          ? FloatingActionButton(
              backgroundColor: settings.nightMode
                  ? AppColors.fourthColor[800]
                  : Colors.white,
              child: content!.isLiked
                  ? Icon(Icons.favorite, color: AppColors.error)
                  : Icon(
                      Icons.favorite_border,
                      color: settings.nightMode
                          ? AppColors.secondaryColor[100]
                          : AppColors.secondaryColor,
                    ),
              onPressed: () async {
                await favorite.changeStats(content!.id, !content!.isLiked);
                content!.isLiked = !content!.isLiked;
                setState(() {});
              },
            )
          : null,
      bottomNavigationBar: (hasVoice && voiceFile.isNotEmpty)
          ? SafeArea(
              top: false,
              bottom: true,
              child: Container(
                decoration: BoxDecoration(
                  color: settings.nightMode
                      ? AppColors.fourthColor[900]
                      : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                child: _buildAudioControls(settings),
              ),
            )
          : null,
    );
  }

  Widget _buildAudioControls(SettingsState settings) {
    final globalAudioState = ref.watch(globalAudioProvider);
    final isCurrentPlaying = globalAudioState.voiceFile == voiceFile;
    final isPlaying = isCurrentPlaying && globalAudioState.isPlaying;
    final isLoadingAudio = isCurrentPlaying && globalAudioState.isLoading;
    final isDownloadingAudio = isCurrentPlaying && globalAudioState.isDownloading;
    final downloadProgress = isCurrentPlaying ? globalAudioState.downloadProgress : 0.0;
    final position = isCurrentPlaying ? globalAudioState.position : Duration.zero;
    final duration = isCurrentPlaying ? globalAudioState.duration : Duration.zero;
    final audioSpeed = globalAudioState.playbackRate;

    final Color iconColor = settings.nightMode
        ? AppColors.secondaryColor[100]!
        : AppColors.secondaryColor;
    final Color activeTrackColor = settings.nightMode
        ? AppColors.secondaryColor[100]!
        : AppColors.secondaryColor;
    final Color inactiveTrackColor =
        settings.nightMode ? Colors.grey[700]! : Colors.grey[300]!;
    final Color thumbColor = settings.nightMode
        ? AppColors.secondaryColor[100]!
        : AppColors.secondaryColor;
    final Color overlayColor = settings.nightMode
        ? AppColors.secondaryColor[100]!.withOpacity(0.2)
        : AppColors.secondaryColor.withOpacity(0.2);
    final Color textColor =
        settings.nightMode ? Colors.white : Colors.grey[600]!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isDownloadingAudio) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  value: downloadProgress > 0 && downloadProgress < 1.0
                      ? downloadProgress
                      : null,
                  strokeWidth: 3,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                downloadProgress > 0
                    ? 'جارٍ تنزيل الصوت ${(100 * downloadProgress).toStringAsFixed(0)}%'
                    : 'جارٍ تنزيل الصوت...',
                style: TextStyles.medium.copyWith(
                  color: textColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],

        // Progress Slider
        if (duration.inSeconds > 0)
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
              activeTrackColor: activeTrackColor,
              inactiveTrackColor: inactiveTrackColor,
              thumbColor: thumbColor,
              overlayColor: overlayColor,
            ),
            child: Slider(
              value: position.inSeconds
                  .toDouble()
                  .clamp(0.0, duration.inSeconds.toDouble()),
              min: 0,
              max: duration.inSeconds.toDouble(),
              onChanged: (value) {
                _seekAudio(Duration(seconds: value.toInt()));
              },
            ),
          ),

        // Time indicators
        if (duration.inSeconds > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: TextStyles.medium.copyWith(
                    color: textColor,
                    fontSize: 12,
                  ),
                ),
                Text(
                  _formatDuration(duration),
                  style: TextStyles.medium.copyWith(
                    color: textColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

        // Controls bar
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (duration.inSeconds > 0) ...[
              IconButton(
                icon: Icon(Icons.replay_10, color: iconColor, size: 28),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                onPressed: isDownloadingAudio
                    ? null
                    : () {
                        final newPosition =
                            position - const Duration(seconds: 10);
                        if (newPosition.inSeconds >= 0) {
                          _seekAudio(newPosition);
                        }
                      },
              ),
              const SizedBox(width: 10),
            ],

            // Play / Pause button
            GestureDetector(
              onTap: () {
                if (isDownloadingAudio) return;
                isLoadingAudio
                    ? null
                    : (isPlaying ? _pauseAudio() : _playAudio());
              },
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withValues(alpha: 0.1),
                ),
                child: Icon(
                  isDownloadingAudio
                      ? Icons.downloading
                      : isLoadingAudio
                          ? Icons.hourglass_empty
                          : (isPlaying ? Icons.pause : Icons.play_arrow),
                  color: iconColor,
                  size: 28,
                ),
              ),
            ),

            // Speed Control
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: iconColor.withValues(alpha: 0.15),
                foregroundColor: iconColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                minimumSize: const Size(36, 36),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: isDownloadingAudio
                  ? null
                  : () async {
                      double nextSpeed = 1.0;
                      if (audioSpeed == 1.0) {
                        nextSpeed = 1.25;
                      } else if (audioSpeed == 1.25) {
                        nextSpeed = 1.5;
                      } else if (audioSpeed == 1.5) {
                        nextSpeed = 2.0;
                      } else {
                        nextSpeed = 1.0;
                      }
                      ref.read(globalAudioProvider.notifier).setPlaybackRate(nextSpeed);
                    },
              child: Text(
                '${audioSpeed}x',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            if (duration.inSeconds > 0) ...[
              const SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.forward_10, color: iconColor, size: 28),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                onPressed: isDownloadingAudio
                    ? null
                    : () {
                        final newPosition =
                            position + const Duration(seconds: 10);
                        if (newPosition.inSeconds <= duration.inSeconds) {
                          _seekAudio(newPosition);
                        }
                      },
              ),
            ],
          ],
        ),
      ],
    );
  }
}
