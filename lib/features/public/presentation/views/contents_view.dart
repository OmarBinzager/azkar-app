import 'dart:convert';
// import 'dart:ffi';

import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:new_azkar_app/core/constants/layout_constants.dart';
import 'package:new_azkar_app/core/constants/routes.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:new_azkar_app/core/widgets/item_content.dart';
import 'package:new_azkar_app/features/home/entities/content.dart';
import 'package:new_azkar_app/features/home/entities/header.dart';
import 'package:new_azkar_app/features/public/models/header_model.dart';
import 'package:new_azkar_app/features/public/providers/contents_provider.dart';
import 'package:new_azkar_app/features/public/providers/headers_provider.dart';
import 'package:new_azkar_app/features/quran/views/quran_page.dart';
import 'package:flutter/gestures.dart';
import 'package:new_azkar_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:new_azkar_app/core/services/isar_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:quran/quran.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:string_validator/string_validator.dart';
import 'package:new_azkar_app/core/providers/settings_provider.dart';

// Add available fonts
const List<Map<String, String>> quranFonts = [
  {'name': 'خط نبي القرآن', 'code': TextStyles.nabiQuranFont},
  {'name': 'الخط العثماني', 'code': TextStyles.uthmanicQuranFont},
  {'name': 'خط أميري', 'code': 'Amiri'},
  {'name': 'خط لوتس', 'code': 'mylotus'},
  {'name': 'خط لوتس لينو', 'code': 'Lotus Linotype'},
];
const List<Map<String, String>> contentFonts = [
  {'name': 'خط أميري', 'code': 'Amiri-Regular'},
  {'name': 'خط المسيري', 'code': 'ElMessiri'},
  {'name': 'خط النسخ', 'code': 'Traditional Naskh'},
  {'name': 'خط الثلث', 'code': 'A Thuluth'},
  {'name': 'خط لوتس', 'code': 'mylotus'},
  {'name': 'خط لوتس لينو', 'code': 'Lotus Linotype'},
];

class ContentsView extends ConsumerStatefulWidget {
  final Header header;

  const ContentsView({super.key, required this.header});

  @override
  ConsumerState<ContentsView> createState() => _ContentsViewState();
}

class _ContentsViewState extends ConsumerState<ContentsView>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _firstBuild = true;
  bool _autoPlayStopped = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Content? content;
  double fontSize = 22;
  double _currentSessionFontSize = 22;
  double _audioSpeed = 1.0;
  bool _showAudioControls = true;
  Timer? _hideAudioControlsTimer;
  final ScrollController _scrollController = ScrollController();
  double _overscrollPixels = 0.0;
  bool _showNextHeaderOverlay = false;
  bool _pulledFarEnough = false;
  bool _wasPulledFarEnough = false;
  static const double _pullThreshold = 100.0;
  late List<Content> _headerContents;
  int _currentContentIndex = 0;
  Header? _nextHeader;
  String? _nextHeaderName;
  bool _atEndOfHeaders = false;
  late AnimationController _overscrollResetController;
  late Animation<double> _overscrollResetAnimation;

  // Download state
  bool _isDownloading = false;
  double _downloadProgress = 0.0; // 0.0 -> 1.0
  String? _localAudioPath;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _currentSessionFontSize = settings.fontSize;
    _initializeContent();
    _scrollController.addListener(_handleScroll);
    _setupAudioListeners();
    _startHideAudioControlsTimer();
    _overscrollResetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _overscrollResetAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(_overscrollResetController)..addListener(() {
      setState(() {
        _overscrollPixels = _overscrollResetAnimation.value;
      });
    });
  }

  void _initializeContent() {
    final settings = ref.read(settingsProvider);
    final contents = ref.read(contentsListProvider.notifier);
    final headerProvider = ref.read(headersProvider);
    _headerContents = contents.getHeaderContents(widget.header.id);
    _currentContentIndex = 0;
    setState(() {
      content = _headerContents[_currentContentIndex];
    });
    // Find next header (if any)
    final allHeaders = IsarHelper.headers.length;
    final currentHeaderId = widget.header.id;
    final nextHeaderId = widget.header.id == 12 ? 14 : widget.header.id + 1;
    if (currentHeaderId >= 1 && currentHeaderId < allHeaders) {
      _nextHeader = headerProvider[nextHeaderId - 1];
      _nextHeaderName = _nextHeader?.name;
      _atEndOfHeaders = false;
    } else {
      _nextHeader = null;
      _nextHeaderName = null;
      _atEndOfHeaders = true;
    }
    // Initialize audio if available
    if (content!.hasVoice && content!.voiceFile != null) {
      _initializeAudio().then((_) {
        if (settings.autoPlayAudio) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && !_autoPlayStopped) {
              _playAudio();
            }
          });
        }
      });
    }
  }

  void _setupAudioListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          // Reset auto-play stopped flag when audio finishes naturally
          if (state == PlayerState.completed) {
            _autoPlayStopped = false;
          }
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });
  }

  Future<String> _getLocalAudioFilePath() async {
    final Directory baseDir = await getApplicationDocumentsDirectory();
    final Directory audioDir = Directory('${baseDir.path}/audios');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    final String fileName = '${content!.voiceFile!}.mp3';
    return '${audioDir.path}/$fileName';
  }

  Future<bool> _localAudioExists() async {
    if (!content!.hasVoice || content!.voiceFile == null) return false;
    final String path = await _getLocalAudioFilePath();
    final file = File(path);
    final exists = await file.exists();
    if (exists) {
      _localAudioPath = path;
    }
    return exists;
  }

  Future<void> _downloadAudio() async {
    if (_isDownloading) return;
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _isLoading = true;
    });

    final String url =
        'https://drive.google.com/uc?export=download&id=${content!.voiceFile!}';
    final String filePath = await _getLocalAudioFilePath();

    final file = File(filePath);
    HttpClient? httpClient;
    try {
      httpClient = HttpClient();
      final Uri uri = Uri.parse(url);
      final HttpClientRequest request = await httpClient.getUrl(uri);
      final HttpClientResponse response = await request.close();

      if (response.statusCode != 200) {
        throw HttpException('Failed to download file: ${response.statusCode}');
      }

      final int? totalBytes =
          response.contentLength > 0 ? response.contentLength : null;

      final IOSink sink = file.openWrite();
      int receivedBytes = 0;

      await for (final List<int> chunk in response) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes != null) {
          setState(() {
            _downloadProgress = receivedBytes / totalBytes;
          });
        }
      }
      await sink.flush();
      await sink.close();

      _localAudioPath = filePath;

      // After download, set local source
      await _audioPlayer.setSource(DeviceFileSource(filePath));
      await _audioPlayer.setVolume(1.0);

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _isLoading = false;
          _downloadProgress = 1.0;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تنزيل الملف الصوتي وحفظه للتشغيل دون إنترنت'),
          ),
        );
      }
    } catch (e) {
      // Clean up partial file if any
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _isLoading = false;
          _downloadProgress = 0.0;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('تعذّر تنزيل الملف الصوتي')));
      }
    } finally {
      httpClient?.close(force: true);
    }
  }

  Future<void> _initializeAudio() async {
    if (!content!.hasVoice || content!.voiceFile == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      // Prefer local if exists
      if (await _localAudioExists()) {
        await _audioPlayer.setSource(DeviceFileSource(_localAudioPath!));
      } else {
        // No local file: start download but do not auto-play yet
        await _downloadAudio();
      }

      await _audioPlayer.setVolume(1.0);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing audio: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _playAudio() async {
    if (!content!.hasVoice || content!.voiceFile == null) return;

    try {
      // Ensure local file available
      if (!await _localAudioExists()) {
        await _downloadAudio();
      }
      if (_localAudioPath == null) return;

      setState(() {
        _isLoading = true;
      });

      await _audioPlayer.play(DeviceFileSource(_localAudioPath!));

      setState(() {
        _isLoading = false;
        _isPlaying = true;
        _autoPlayStopped =
            false; // Reset auto-play stopped flag when manually playing
      });
    } catch (e) {
      print('Error playing audio: $e');
      setState(() {
        _isLoading = false;
        _isPlaying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تشغيل الملف الصوتي'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _pauseAudio() async {
    try {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
        _autoPlayStopped = true; // Mark that user manually stopped auto-play
      });
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }

  Future<void> _seekAudio(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      print('Error seeking audio: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Widget _buildAudioControls() {
    if (!content!.hasVoice || content!.voiceFile == null) {
      return const SizedBox.shrink();
    }

    final settings = ref.watch(settingsProvider);

    final Color iconColor =
        settings.nightMode
            ? AppColors.secondaryColor[100]!
            : AppColors.secondaryColor;
    final Color activeTrackColor =
        settings.nightMode
            ? AppColors.secondaryColor[100]!
            : AppColors.secondaryColor;
    final Color inactiveTrackColor =
        settings.nightMode ? Colors.grey[700]! : Colors.grey[300]!;
    final Color thumbColor =
        settings.nightMode
            ? AppColors.secondaryColor[100]!
            : AppColors.secondaryColor;
    final Color overlayColor =
        settings.nightMode
            ? AppColors.secondaryColor[100]!.withOpacity(0.2)
            : AppColors.secondaryColor.withOpacity(0.2);
    final Color textColor =
        settings.nightMode ? Colors.white : Colors.grey[600]!;

    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isDownloading) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    value:
                        _downloadProgress > 0 && _downloadProgress < 1.0
                            ? _downloadProgress
                            : null,
                    strokeWidth: 3,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _downloadProgress > 0
                      ? 'جارٍ تنزيل الصوت ${(100 * _downloadProgress).toStringAsFixed(0)}%'
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
          // Auto-play indicator
          if (settings.autoPlayAudio &&
              !_isPlaying &&
              !_isLoading &&
              !_autoPlayStopped &&
              !_isDownloading)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_circle_outline, color: iconColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'تشغيل تلقائي',
                    style: TextStyles.medium.copyWith(
                      color: iconColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          // Progress bar
          if (_duration.inSeconds > 0)
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: activeTrackColor,
                inactiveTrackColor: inactiveTrackColor,
                thumbColor: thumbColor,
                overlayColor: overlayColor,
              ),
              child: Slider(
                value: _position.inSeconds.toDouble().clamp(
                  0.0,
                  _duration.inSeconds.toDouble(),
                ),
                min: 0,
                max: _duration.inSeconds.toDouble(),
                onChanged: (value) {
                  _seekAudio(Duration(seconds: value.toInt()));
                  _startHideAudioControlsTimer();
                },
              ),
            ),

          // Duration and position
          if (_duration.inSeconds > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(_position),
                    style: TextStyles.medium.copyWith(
                      color: textColor,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _formatDuration(_duration),
                    style: TextStyles.medium.copyWith(
                      color: textColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // Playback controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_duration.inSeconds > 0) ...[
                IconButton(
                  icon: Icon(Icons.replay_10, color: iconColor, size: 30),
                  onPressed:
                      _isDownloading
                          ? null
                          : () {
                            final newPosition =
                                _position - const Duration(seconds: 10);
                            if (newPosition.inSeconds >= 0) {
                              _seekAudio(newPosition);
                            }
                            _startHideAudioControlsTimer();
                          },
                ),
                const SizedBox(width: 16),
              ],

              GestureDetector(
                onTap: () {
                  if (_isDownloading) return;
                  _isLoading
                      ? null
                      : (_isPlaying ? _pauseAudio() : _playAudio());
                  _showControlsAndRestartTimer();
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconColor.withOpacity(0.1),
                  ),
                  child: Icon(
                    _isDownloading
                        ? Icons.downloading
                        : _isLoading
                        ? Icons.hourglass_empty
                        : (_isPlaying ? Icons.pause : Icons.play_arrow),
                    color: iconColor,
                    size: 30,
                  ),
                ),
              ),
              // --- Speed control button ---
              const SizedBox(width: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor.withOpacity(0.15),
                  foregroundColor: iconColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: const Size(40, 40),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed:
                    _isDownloading
                        ? null
                        : () async {
                          setState(() {
                            // Cycle through common speeds: 1.0, 1.25, 1.5, 2.0
                            if (_audioSpeed == 1.0) {
                              _audioSpeed = 1.25;
                            } else if (_audioSpeed == 1.25) {
                              _audioSpeed = 1.5;
                            } else if (_audioSpeed == 1.5) {
                              _audioSpeed = 2.0;
                            } else {
                              _audioSpeed = 1.0;
                            }
                          });
                          await _audioPlayer.setPlaybackRate(_audioSpeed);
                          _startHideAudioControlsTimer();
                        },
                child: Text(
                  '${_audioSpeed}x',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              // --- End speed control button ---
              if (_duration.inSeconds > 0) ...[
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.forward_10, color: iconColor, size: 30),
                  onPressed:
                      _isDownloading
                          ? null
                          : () {
                            final newPosition =
                                _position + const Duration(seconds: 10);
                            if (newPosition.inSeconds <= _duration.inSeconds) {
                              _seekAudio(newPosition);
                            }
                            _startHideAudioControlsTimer();
                          },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _startHideAudioControlsTimer() {
    _hideAudioControlsTimer?.cancel();
    _hideAudioControlsTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _showAudioControls) {
        setState(() {
          _showAudioControls = false;
        });
      }
    });
  }

  void _showControlsAndRestartTimer() {
    setState(() {
      _showAudioControls = true;
    });
    _startHideAudioControlsTimer();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;
    if (offset > maxScroll) {
      setState(() {
        _overscrollResetController.stop();
        _overscrollPixels = offset - maxScroll;
        _showNextHeaderOverlay = true;
        _pulledFarEnough = _overscrollPixels > _pullThreshold;
        if (!_wasPulledFarEnough && _pulledFarEnough) {
          HapticFeedback.vibrate();
        }
        _wasPulledFarEnough = _pulledFarEnough;
      });
    } else {
      if (_showNextHeaderOverlay) {
        // Animate back to zero
        _overscrollResetAnimation = Tween<double>(
          begin: _overscrollPixels,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: _overscrollResetController,
            curve: Curves.easeOut,
          ),
        );
        _overscrollResetController.forward(from: 0);
        setState(() {
          _showNextHeaderOverlay = false;
          _pulledFarEnough = false;
        });
      }
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_showNextHeaderOverlay && _pulledFarEnough) {
      if (!_atEndOfHeaders && _nextHeader != null) {
        // Animate to next header
        context.pushReplacementNamed(Routes.contents, extra: _nextHeader);
      } else {
        // At end of headers, show checkmark or do nothing
        // Optionally show a dialog or snackbar
      }
    }
    // Always animate overscroll back to zero on pointer up
    _overscrollResetAnimation = Tween<double>(
      begin: _overscrollPixels,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _overscrollResetController,
        curve: Curves.easeOut,
      ),
    );
    _overscrollResetController.forward(from: 0);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _hideAudioControlsTimer?.cancel();
    _scrollController.dispose();
    _overscrollResetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorite = ref.read(contentsListProvider.notifier);
    final settings = ref.watch(settingsProvider);

    if (settings.fontSize != fontSize) {
      fontSize = settings.fontSize;
      if (_firstBuild) {
        _currentSessionFontSize = fontSize;
        _firstBuild = false;
      }
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor:
            settings.nightMode
                ? AppColors.fourthColor[900]
                : AppColors.fourthColor,
        body: Listener(
          onPointerUp: _onPointerUp,
          child: Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is OverscrollNotification &&
                      notification.overscroll > 0) {
                    _handleScroll();
                  }
                  return false;
                },
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (_showAudioControls) {
                      setState(() {
                        _showAudioControls = false;
                      });
                      _hideAudioControlsTimer?.cancel();
                    } else {
                      _showControlsAndRestartTimer();
                    }
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      // Add a spacer at the top for distance from the screen top
                      SliverToBoxAdapter(child: SizedBox(height: 20)),
                      SliverAppBar(
                        floating: true,
                        toolbarHeight: 75,
                        snap: true,
                        backgroundColor:
                            settings.nightMode
                                ? AppColors.fourthColor[900]
                                : AppColors.fourthColor,
                        elevation: 0,
                        leading: BackButton(
                          color:
                              settings.nightMode
                                  ? Colors.white
                                  : AppColors.secondaryColor,
                        ),
                        title: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            widget.header.name,
                            style: TextStyles.bold.copyWith(
                              color:
                                  settings.nightMode
                                      ? Colors.white
                                      : AppColors.secondaryColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        actions: [
                          IconButton(
                            icon: Icon(
                              settings.nightMode
                                  ? Icons.dark_mode
                                  : Icons.light_mode,
                              color:
                                  settings.nightMode
                                      ? Colors.white
                                      : AppColors.secondaryColor,
                            ),
                            tooltip: 'وضع القراءة الليلي',
                            onPressed: () {
                              ref
                                  .read(settingsProvider.notifier)
                                  .setNightMode(!settings.nightMode);
                            },
                          ),
                        ],
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(
                            LayoutConstants.screenPadding,
                          ),
                          child: _buildHeader(context, settings),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Overlay ellipse with arrow/checkmark
              if (_showNextHeaderOverlay)
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeOut,
                      width:
                          40 +
                          (_overscrollPixels.clamp(0, 30)), // grows up to 160
                      height:
                          40 +
                          (_overscrollPixels.clamp(0, 30)) /
                              2, // grows up to 110
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder:
                              (child, anim) =>
                                  RotationTransition(turns: anim, child: child),
                          child:
                              _atEndOfHeaders
                                  ? Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size:
                                        14 +
                                        (_overscrollPixels / 8).clamp(0, 30),
                                    key: const ValueKey('check'),
                                  )
                                  : Transform.rotate(
                                    angle:
                                        (_overscrollPixels.clamp(
                                              0,
                                              _pullThreshold,
                                            ) /
                                            _pullThreshold) *
                                        3.14,
                                    child: Icon(
                                      Icons.arrow_upward,
                                      color: Colors.white,
                                      size: 32 + (_overscrollPixels / 8),
                                      key: const ValueKey('arrow'),
                                    ),
                                  ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (_showNextHeaderOverlay)
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      _atEndOfHeaders
                          ? 'لقد وصلت إلى نهاية المحتويات'
                          : (!_pulledFarEnough)
                          ? 'اسحب لأعلى للانتقال إلى ${_nextHeaderName!.length > 20 ? '${_nextHeaderName!.substring(0, 20)}...' : _nextHeaderName}'
                          : 'أفلت للأنتقال.',
                      style: TextStyles.regular.copyWith(
                        color:
                            settings.nightMode
                                ? Colors.white.withOpacity(0.8)
                                : Colors.black.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton:
            _showAudioControls
                ? FloatingActionButton(
                  backgroundColor:
                      settings.nightMode
                          ? AppColors.fourthColor[800]
                          : Colors.white,
                  child:
                      content!.isLiked
                          ? Icon(Icons.favorite, color: AppColors.error)
                          : Icon(
                            Icons.favorite_border,
                            color:
                                settings.nightMode
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
        bottomNavigationBar:
            (content != null &&
                    content!.hasVoice &&
                    content!.voiceFile != null &&
                    _showAudioControls)
                ? Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: _buildAudioControls(),
                )
                : null,
      ),
    );
  }

  Column _buildHeader(BuildContext context, SettingsState settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Font size controls
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_currentSessionFontSize > 22) {
                        _currentSessionFontSize -= 1;
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          settings.nightMode
                              ? AppColors.secondaryColor[100]?.withOpacity(0.1)
                              : AppColors.secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.text_decrease,
                      color:
                          settings.nightMode
                              ? AppColors.secondaryColor[100]
                              : AppColors.secondaryColor,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_currentSessionFontSize.toInt()}',
                  style: TextStyles.medium.copyWith(
                    color:
                        settings.nightMode
                            ? AppColors.secondaryColor[100]
                            : AppColors.secondaryColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_currentSessionFontSize < 30) {
                        _currentSessionFontSize += 1;
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          settings.nightMode
                              ? AppColors.secondaryColor[100]?.withOpacity(0.1)
                              : AppColors.secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.text_increase,
                      color:
                          settings.nightMode
                              ? AppColors.secondaryColor[100]
                              : AppColors.secondaryColor,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            // Copy, share, and font buttons
            Row(
              children: [
                GestureDetector(
                  onTap: () => onCopy(context),
                  child: Icon(
                    Icons.copy_all_outlined,
                    color:
                        settings.nightMode
                            ? AppColors.secondaryColor[100]
                            : AppColors.secondaryColor,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onShare,
                  child: Icon(
                    Icons.share,
                    color:
                        settings.nightMode
                            ? AppColors.secondaryColor[100]
                            : AppColors.secondaryColor,
                  ),
                ),
                const SizedBox(width: 10),
                // Font selection buttons (moved here)
                IconButton(
                  icon: Icon(
                    Icons.font_download,
                    color:
                        settings.nightMode
                            ? AppColors.secondaryColor[100]
                            : AppColors.secondaryColor,
                  ),
                  tooltip: 'تغيير خط القرآن',
                  onPressed: () => _showFontPicker(context, true),
                ),
                IconButton(
                  icon: Icon(
                    Icons.font_download_outlined,
                    color:
                        settings.nightMode
                            ? AppColors.secondaryColor[100]
                            : AppColors.secondaryColor,
                  ),
                  tooltip: 'تغيير خط النص',
                  onPressed: () => _showFontPicker(context, false),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text.rich(
          buildStyledText(
            context,
            content!.text,
            _currentSessionFontSize == fontSize
                ? fontSize
                : _currentSessionFontSize,
            settings.quranFontFamily,
            settings.contentFontFamily,
            settings.nightMode, // pass night mode to your builder
          ),
          textAlign: TextAlign.justify,
          style: TextStyle(
            fontSize: _currentSessionFontSize,
            fontFamily: settings.contentFontFamily,
            fontWeight: FontWeight.bold,
            height: 1.9,
            wordSpacing: 1.5,
            color: settings.nightMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  void onShare() {
    String message = content!.text;

    message +=
        '\n\n تمت مشاركة النص بواسطة تطبيق عمل اليوم والليلة\n'
        'https://play.google.com/store/apps/details?id=com.Letterspd.amal_alyoum';

    SharePlus.instance.share(ShareParams(text: message));
  }

  void onCopy(BuildContext context) async {
    String message = content!.text;

    message +=
        '\n\n تم نسخ النص بواسطة تطبيق عمل اليوم والليلة\n'
        'URl in google ply';

    await Clipboard.setData(ClipboardData(text: message));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم نسخ النص')));
    }
  }

  void _showFontPicker(BuildContext context, bool isQuranFont) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final fonts = isQuranFont ? quranFonts : contentFonts;
        final settings = ref.read(settingsProvider);
        final selectedFont =
            isQuranFont ? settings.quranFontFamily : settings.contentFontFamily;
        return ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, right: 10, bottom: 10),
              child: Text(
                isQuranFont ? 'خط الآيات القرآنية' : 'خط محتوى الذكر',
                style: TextStyles.mediumBold.copyWith(
                  color: AppColors.secondaryColor,
                  fontSize: 18,
                ),
              ),
            ),
            SizedBox(height: 10),
            ...fonts.map((font) {
              return ListTile(
                title: Text(
                  font['name']!,
                  style: TextStyle(fontFamily: font['code']),
                ),
                trailing:
                    selectedFont == font['code']
                        ? Icon(Icons.check, color: AppColors.secondaryColor)
                        : null,
                onTap: () {
                  final notifier = ref.read(settingsProvider.notifier);
                  if (isQuranFont) {
                    notifier.setQuranFontFamily(font['code']!);
                  } else {
                    notifier.setContentFontFamily(font['code']!);
                  }
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        );
      },
    );
  }

  TextSpan buildStyledText(
    context,
    String text,
    double fontSize,
    String quranFont,
    String contentFont,
    bool nightMode,
  ) {
    List<TextSpan> spans = renderQuranText(text, quranFont);
    // final spans = renderSpecialCaseLink(text, context, quranSpans);
    List<TextSpan> finalSpans = styleTextBetweenDoubleParentheses(
      spans,
      highlightedStyle: TextStyle(
        color: const Color.fromARGB(255, 255, 72, 0),
        fontWeight: FontWeight.bold,
      ),
      // normalStyle: TextStyle(color: Colors.black),
    );
    finalSpans = styleTextByRegex(
      spans: finalSpans,
      pattern: RegExp(r'"(.*?)"'),
      matchStyle: TextStyle(
        color: AppColors.success,
        fontWeight: FontWeight.bold,
      ),
      // normalStyle: TextStyle(color: Colors.black),
    );
    finalSpans = formatContentTextAndLinks(finalSpans, context);
    return TextSpan(
      children: finalSpans,
      style: TextStyle(fontSize: fontSize, fontFamily: contentFont),
    );
  }

  List<TextSpan> renderSpecialCaseLink(String text, context, spans) {
    final List<TextSpan> spans = [];
    final RegExp matchPattern = RegExp(r'«الدَّلائِلِ»');

    int start = 0;

    // Find all matches
    for (final match in matchPattern.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }

      // Add tappable link
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer:
              TapGestureRecognizer()
                ..onTap =
                    () => context.pushNamed(
                      Routes.headersViewer,
                      extra: HeaderModel(
                        fromHeader: 130,
                        toHeader: 136,
                        label: 'دلائل الخيرات',
                      ),
                    ),
        ),
      );

      start = match.end;
    }

    // Add the remaining text
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }
    return spans;
  }

  List<TextSpan> formatContentTextAndLinks(
    List<TextSpan> spans,
    BuildContext context,
  ) {
    final List<TextSpan> finalSpans = [];

    final parenRegex = RegExp(r'\((.*?)\)');
    final keywordRegex = RegExp(r'«الدَّلائِلِ»');

    for (final span in spans) {
      final subText = span.text!;
      final List<InlineSpan> innerSpans = [];

      int lastMatchEnd = 0;

      // Match both parentheses and keywords in one pass
      final matches = [
        ...parenRegex.allMatches(subText),
        ...keywordRegex.allMatches(subText),
      ]..sort((a, b) => a.start.compareTo(b.start)); // Sort by position

      for (final match in matches) {
        if (match.start > lastMatchEnd) {
          innerSpans.add(
            TextSpan(
              text: subText.substring(lastMatchEnd, match.start),
              style: span.style,
            ),
          );
        }

        final matchText = match.group(0)!;

        if (parenRegex.hasMatch(matchText)) {
          // Handle your existing (sura[name]) logic
          final m = parenRegex.firstMatch(matchText)!;
          final inside = m.group(1)!;

          if (inside.contains('[') && inside.contains(']')) {
            String suraNumber = inside.substring(
              inside.indexOf('[') + 1,
              inside.indexOf(']'),
            );
            String suraName = inside.replaceAll('[$suraNumber]', "");

            innerSpans.add(
              TextSpan(
                text: suraName,
                style:
                    span.style?.copyWith(color: Colors.blue) ??
                    TextStyle(color: Colors.blue),
                recognizer:
                    TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => QuranViewPage(
                                  shouldHighlightText: false,
                                  highlightVerse: "",
                                  pageNumber: getPageNumber(
                                    int.parse(suraNumber),
                                    1,
                                  ),
                                ),
                          ),
                        );
                      },
              ),
            );
          } else if (inside.contains('%')) {
            String headerNumber = inside.substring(
              inside.indexOf('%') + 1,
              inside.lastIndexOf('%'),
            );
            String headerText = inside.replaceAll('%$headerNumber%', "");

            innerSpans.add(
              TextSpan(
                text: headerText,
                style:
                    span.style?.copyWith(color: Colors.blue) ??
                    TextStyle(color: Colors.blue),
                recognizer:
                    TapGestureRecognizer()
                      ..onTap = () async {
                        final header = await ref
                            .watch(headersProvider.notifier)
                            .getHeaderById(int.parse(headerNumber));
                        context.pushNamed(Routes.contents, extra: header);
                      },
              ),
            );
          } else {
            innerSpans.add(
              TextSpan(
                text: inside,
                style: span.style?.copyWith(color: Colors.blue),
              ),
            );
          }
        } else if (keywordRegex.hasMatch(matchText)) {
          // Handle custom keywords like «الدَّلائِلِ»
          innerSpans.add(
            TextSpan(
              text: matchText,
              style:
                  span.style?.copyWith(color: Colors.blue) ??
                  TextStyle(color: Colors.blue),
              recognizer:
                  TapGestureRecognizer()
                    ..onTap =
                        () => context.pushNamed(
                          Routes.headersViewer,
                          extra: HeaderModel(
                            fromHeader: 130,
                            toHeader: 140,
                            label:
                                'دَلَائِلُ الخَيْرَاتِ وَشَوَارِقُ الأَنوَار',
                          ),
                        ),
            ),
          );
        }

        lastMatchEnd = match.end;
      }

      if (lastMatchEnd < subText.length) {
        innerSpans.add(
          TextSpan(text: subText.substring(lastMatchEnd), style: span.style),
        );
      }

      finalSpans.addAll(innerSpans.cast<TextSpan>());
    }

    return finalSpans;
  }

  // List<TextSpan> formatContentTextAndLinks2(List<TextSpan> spans, context) {
  //   final List<TextSpan> finalSpans = [];
  //   for (final span in spans) {
  //     final subSpans = <TextSpan>[];
  //     final subText = span.text!;
  //     final parenRegex = RegExp(r'\((.*?)\)');
  //     int subLastEnd = 0;
  //     for (final m in parenRegex.allMatches(subText)) {
  //       if (m.start > subLastEnd) {
  //         subSpans.add(
  //           TextSpan(
  //             text: subText.substring(subLastEnd, m.start),
  //             style: span.style,
  //           ),
  //         );
  //       }
  //       if ('${m.group(1)}'.contains('[') && '${m.group(1)}'.contains(']')) {
  //         String part = '${m.group(1)}';
  //         String suraNumber = part.substring(
  //           part.indexOf('[') + 1,
  //           part.indexOf(']'),
  //         );
  //         String suraName = part.replaceAll('[$suraNumber]', "");
  //         subSpans.add(
  //           TextSpan(
  //             text: suraName,
  //             style:
  //                 span.style?.copyWith(color: Colors.blue) ??
  //                 TextStyle(color: Colors.blue),
  //             recognizer:
  //                 TapGestureRecognizer()
  //                   ..onTap = () {
  //                     Navigator.push(
  //                       context,
  //                       MaterialPageRoute(
  //                         builder:
  //                             (builder) => QuranViewPage(
  //                               shouldHighlightText: false,
  //                               highlightVerse: "",
  //                               pageNumber: getPageNumber(
  //                                 int.parse(suraNumber),
  //                                 1,
  //                               ),
  //                             ),
  //                       ),
  //                     );
  //                   },
  //           ),
  //         );
  //       } else {
  //         subSpans.add(
  //           TextSpan(
  //             text: '${m.group(1)}',
  //             style:
  //                 span.style?.copyWith(color: Colors.blue) ??
  //                 TextStyle(color: Colors.blue),
  //           ),
  //         );
  //       }
  //       subLastEnd = m.end;
  //     }
  //     if (subLastEnd < subText.length) {
  //       subSpans.add(
  //         TextSpan(text: subText.substring(subLastEnd), style: span.style),
  //       );
  //     }
  //     finalSpans.addAll(subSpans.isNotEmpty ? subSpans : [span]);
  //   }
  //   return finalSpans;
  // }

  List<TextSpan> renderQuranText(String text, String quranFont) {
    final settings = ref.watch(settingsProvider);
    final spans = <TextSpan>[];
    int lastEnd = 0;
    final regex = RegExp(r'﴿(.*?)﴾(\d+)?');
    final matches = regex.allMatches(text);
    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      final quranText = match.group(1) ?? '';
      final quranNumber = match.group(2);
      spans.add(
        TextSpan(
          text: '﴿$quranText﴾',
          style: TextStyles.quranText.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: quranFont,
            color: settings.nightMode ? Colors.brown[200] : Colors.brown[800],
          ),
        ),
      );
      if (quranNumber != null) {
        spans.add(
          TextSpan(
            text: '﴿$quranNumber﴾',
            style: TextStyles.quranText.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: quranFont,
            ),
          ),
        );
      }
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }
    return spans;
  }
}

// class ContentsView extends ConsumerWidget {
//   final Header header;

//   const ContentsView({super.key, required this.header});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final contents = ref.read(contentsListProvider.notifier);
//     List<Content> list = contents.getHeaderContents(header.id);
//     return Scaffold(
//       backgroundColor: AppColors.fourthColor,
//       body: Padding(
//         padding: const EdgeInsets.all(LayoutConstants.screenPadding),
//         child: Column(
//           children: [
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 BackButton(),
//                 const SizedBox(width: 5),
//                 Expanded(child: Text(header.name, style: TextStyles.bold)),
//               ],
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: list.length,
//                 itemBuilder: (context, index) {
//                   return ItemContent(
//                     content: list[index],
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
