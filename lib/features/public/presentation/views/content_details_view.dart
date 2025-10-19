import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:new_azkar_app/core/constants/layout_constants.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:new_azkar_app/features/home/entities/content.dart';
import 'package:new_azkar_app/features/public/providers/contents_provider.dart';
import 'package:new_azkar_app/core/services/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ContentDetailsView extends ConsumerStatefulWidget {
  final Content content;

  const ContentDetailsView({super.key, required this.content});

  @override
  ConsumerState<ContentDetailsView> createState() => _ContentDetailsViewState();
}

class _ContentDetailsViewState extends ConsumerState<ContentDetailsView> {
  late AudioService _audioService;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _audioSource;

  @override
  void initState() {
    super.initState();
    _audioService = AudioService();
    _initAudio();

    // Listen to player state changes
    _audioService.onPlayerStateChanged.listen((state) {
      if (mounted) {
        print('Player state changed: $state');
        setState(() {
          _isPlaying = state == PlayerState.playing;
          if (state == PlayerState.completed) {
            _isPlaying = false;
          }
        });
      }
    });

    // Listen to duration changes
    _audioService.onDurationChanged.listen((d) {
      if (mounted) {
        print('Duration changed: ${d.inSeconds} seconds');
        setState(() {
          _duration = d;
        });
      }
    });

    // Listen to position changes
    _audioService.onPositionChanged.listen((p) {
      if (mounted) {
        print('Position changed: ${p.inSeconds} seconds');
        setState(() {
          _position = p;
        });
      }
    });
  }

  Future<void> _initAudio() async {
    if (!widget.content.hasVoice || widget.content.voiceFile == null) return;

    try {
      // Remove any leading slashes and ensure proper path format
      final audioPath = 'audio/${widget.content.voiceFile!}';
      print('Initializing audio from: $audioPath');

      _audioSource = audioPath;
      print('Audio source set successfully');

      // Set volume to maximum
      await _audioService.setVolume(1.0);

      // Preload the audio with error handling
      try {
        print('Attempting to set audio source...');

        // Reset the player state first
        await _audioService.stop();
        await _audioService.seek(Duration.zero);

        // Set the audio source
        await _audioService.audioPlayer.setSource(AssetSource(audioPath));
        print('Audio source preloaded successfully');

        // Wait for the player to be ready
        await Future.delayed(const Duration(milliseconds: 500));

        // Verify the player state
        final state = _audioService.state;
        print('Player state after loading: $state');

        // Get the duration
        final duration = await _audioService.getDuration();
        print('Audio duration: ${duration?.inSeconds} seconds');
      } catch (e) {
        print('Error preloading audio: $e');
        if (e is PlatformException) {
          print('Platform error details:');
          print('- Message: ${e.message}');
          print('- Code: ${e.code}');
          print('- Details: ${e.details}');
        }
        rethrow;
      }
    } catch (e) {
      print('Error initializing audio: $e');
      if (e is PlatformException) {
        print('Platform error: ${e.message}');
        print('Error code: ${e.code}');
        print('Error details: ${e.details}');
      }
      rethrow;
    }
  }

  @override
  void dispose() {
    // Don't dispose the audio player here - it's a global service
    // that should continue playing in the background
    // Only clean up temporary files
    _cleanupTempFiles();
    super.dispose();
  }

  Future<void> _cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${widget.content.voiceFile}');
      if (await tempFile.exists()) {
        await tempFile.delete();
        print('Temporary audio file cleaned up');
      }
    } catch (e) {
      print('Error cleaning up temporary files: $e');
    }
  }

  Future<void> _playAudio() async {
    if (!widget.content.hasVoice || widget.content.voiceFile == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      if (_audioSource == null) {
        await _initAudio();
      }

      // Ensure volume is set to maximum
      await _audioService.setVolume(1.0);

      // Reset the player state
      await _audioService.stop();
      await _audioService.seek(Duration.zero);

      // Wait for the player to be ready
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _isLoading = false;
        _isPlaying = true;
      });

      // Start playback with error handling
      try {
        print('Attempting to start playback...');
        await _audioService.playAsset(_audioSource!);
        print('Audio playback started successfully');

        // Verify playback started
        final state = _audioService.state;
        print('Initial player state: $state');

        // If not playing, try to restart
        if (state != PlayerState.playing) {
          print('Player not playing, attempting to restart...');
          await _audioService.stop();
          await Future.delayed(const Duration(milliseconds: 500));
          await _audioService.playAsset(_audioSource!);
        }
      } catch (e) {
        print('Error starting playback: $e');
        if (e is PlatformException) {
          print('Platform error details:');
          print('- Message: ${e.message}');
          print('- Code: ${e.code}');
          print('- Details: ${e.details}');
        }
        rethrow;
      }
    } catch (e, stackTrace) {
      print('Error playing audio: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
        _isPlaying = false;
      });

      // Show a more user-friendly error message
      String errorMessage = 'Error playing audio';
      if (e.toString().contains('FileSystemException')) {
        errorMessage = 'Unable to access audio file. Please try again.';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'Audio file format not supported.';
      } else if (e.toString().contains('empty')) {
        errorMessage = 'Audio file is empty or corrupted.';
      } else if (e.toString().contains('not found')) {
        errorMessage = 'Audio file not found.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(label: 'Retry', onPressed: _playAudio),
        ),
      );
    }
  }

  Future<void> _stopAudio() async {
    await _audioService.pause();
    setState(() {
      _isPlaying = false;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Widget _buildAudioControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            activeTrackColor: AppColors.secondaryColor,
            inactiveTrackColor: Colors.grey[300],
            thumbColor: AppColors.secondaryColor,
            overlayColor: AppColors.secondaryColor.withOpacity(0.2),
          ),
          child: Slider(
            value: _position.inSeconds.toDouble(),
            min: 0,
            max: _duration.inSeconds.toDouble(),
            onChanged: (value) {
              _audioService.seek(Duration(seconds: value.toInt()));
            },
          ),
        ),
        // Duration and position
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_position),
                style: TextStyles.medium.copyWith(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                _formatDuration(_duration),
                style: TextStyles.medium.copyWith(
                  color: Colors.grey[600],
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
            IconButton(
              icon: Icon(
                Icons.replay_10,
                color: AppColors.secondaryColor,
                size: 30,
              ),
              onPressed: () {
                final newPosition = _position - const Duration(seconds: 10);
                _audioService.seek(newPosition);
              },
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: _isLoading ? null : (_isPlaying ? _stopAudio : _playAudio),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondaryColor.withOpacity(0.1),
                ),
                child: Icon(
                  _isLoading
                      ? Icons.hourglass_empty
                      : (_isPlaying ? Icons.stop : Icons.play_arrow),
                  color: AppColors.secondaryColor,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: Icon(
                Icons.forward_10,
                color: AppColors.secondaryColor,
                size: 30,
              ),
              onPressed: () {
                final newPosition = _position + const Duration(seconds: 10);
                _audioService.seek(newPosition);
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = 18;
    final favorite = ref.read(contentsListProvider.notifier);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(LayoutConstants.screenPadding),
        child: StatefulBuilder(
          builder:
              (context, setState) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  BackButton(),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Text('حجم الخط', style: TextStyles.medium),
                      Expanded(
                        child: Slider(
                          min: 13,
                          max: 28,
                          value: fontSize,
                          onChanged: (val) {
                            fontSize = val;
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text.rich(
                            buildStyledText(widget.content.text, fontSize),
                            style: TextStyle(fontSize: fontSize).copyWith(
                              height: 1.9,
                              wordSpacing: 1.5,
                              fontFamily: 'Amiri-Regular',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.content.hasVoice &&
                      widget.content.voiceFile != null) ...[
                    const SizedBox(height: 20),
                    _buildAudioControls(),
                  ],
                ],
              ),
        ),
      ),
      floatingActionButton: StatefulBuilder(
        builder: (context, setState) {
          return FloatingActionButton(
            backgroundColor: Colors.white,
            child:
                widget.content.isLiked
                    ? Icon(Icons.favorite, color: AppColors.error)
                    : Icon(
                      Icons.favorite_border,
                      color: AppColors.secondaryColor,
                    ),
            onPressed: () async {
              await favorite.changeStats(
                widget.content.id,
                !widget.content.isLiked,
              );
              widget.content.isLiked = !widget.content.isLiked;
              setState(() {});
            },
          );
        },
      ),
    );
  }

  List<TextSpan> reformatText() {
    List<TextSpan> spans = [];
    final RegExp regExp = RegExp(r'\(([^)]+)\)|﴿([^﴾]+)﴾');
    final matches = regExp.allMatches(widget.content.text);
    int lastMatchEnd = 0;
    String text = widget.content.text;

    for (final match in matches) {
      // أضف النص العادي قبل أي قوس
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: const TextStyle(color: Colors.black),
          ),
        );
      }

      // نص داخل الأقواس العادية ()
      if (match.group(1) != null) {
        spans.add(
          TextSpan(
            text: match.group(1),
            style: const TextStyle(color: Colors.blue),
          ),
        );
      }

      // نص داخل الأقواس القرآنية ﴿﴾
      if (match.group(2) != null) {
        spans.add(
          TextSpan(
            text: '﴿${match.group(2)}﴾',
            style: const TextStyle(
              color: AppColors.secondaryColor,
              fontFamily: 'Amiri', // خط مناسب للنصوص القرآنية
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }

      lastMatchEnd = match.end;
    }

    // أضف النص المتبقي بعد آخر قوس
    if (lastMatchEnd < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastMatchEnd),
          style: const TextStyle(color: Colors.black),
        ),
      );
    }

    return spans;
  }

  TextSpan buildStyledText(String text, double fontSize) {
    // final buffer = StringBuffer();
    final spans = <TextSpan>[];

    // Match Quranic-style patterns
    final regex = RegExp(r'﴿(.*?)﴾(\d+)?'); // Match ﴿text﴾number (optional)
    final matches = regex.allMatches(text);

    int lastEnd = 0;

    for (final match in matches) {
      // Add text before current match
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }

      final quranText = match.group(1) ?? '';
      final quranNumber = match.group(2);

      spans.add(
        TextSpan(
          text: '﴿$quranText﴾',
          style: TextStyle(
            fontFamily: 'Amiri', // or any other Arabic-style font
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            color: Colors.brown[800],
          ),
        ),
      );

      if (quranNumber != null) {
        spans.add(
          TextSpan(
            text: '﴿$quranNumber﴾',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontWeight: FontWeight.bold,
              // color: AppColors.warring,
            ),
          ),
        );
      }

      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    // Handle blue text between ((( ))) - triple parentheses, convert to single ( )
    final tripleParenSpans = <TextSpan>[];
    for (final span in spans) {
      final subSpans = <TextSpan>[];
      final subText = span.text!;
      final tripleParenRegex = RegExp(r'\(\(\((.*?)\)\)\)');
      int subLastEnd = 0;

      for (final m in tripleParenRegex.allMatches(subText)) {
        if (m.start > subLastEnd) {
          subSpans.add(
            TextSpan(
              text: subText.substring(subLastEnd, m.start),
              style: span.style,
            ),
          );
        }
        // Convert ((( text ))) to ( text )
        subSpans.add(
          TextSpan(
            text: '(${m.group(1)})',
            style:
                span.style?.copyWith(color: Colors.blue) ??
                TextStyle(color: Colors.blue),
          ),
        );
        subLastEnd = m.end;
      }

      if (subLastEnd < subText.length) {
        subSpans.add(
          TextSpan(text: subText.substring(subLastEnd), style: span.style),
        );
      }

      tripleParenSpans.addAll(subSpans.isNotEmpty ? subSpans : [span]);
    }

    // Handle blue text between ( )
    final parenSpans = <TextSpan>[];
    for (final span in tripleParenSpans) {
      final subSpans = <TextSpan>[];
      final subText = span.text!;
      final parenRegex = RegExp(r'\((.*?)\)');
      int subLastEnd = 0;

      for (final m in parenRegex.allMatches(subText)) {
        if (m.start > subLastEnd) {
          subSpans.add(
            TextSpan(
              text: subText.substring(subLastEnd, m.start),
              style: span.style,
            ),
          );
        }
        subSpans.add(
          TextSpan(
            text: '(${m.group(1)})',
            style:
                span.style?.copyWith(color: Colors.blue) ??
                TextStyle(color: Colors.blue),
          ),
        );
        subLastEnd = m.end;
      }

      if (subLastEnd < subText.length) {
        subSpans.add(
          TextSpan(text: subText.substring(subLastEnd), style: span.style),
        );
      }

      parenSpans.addAll(subSpans.isNotEmpty ? subSpans : [span]);
    }
    final finalSpans = <TextSpan>[];
    for (final span in parenSpans) {
      final subSpans = <TextSpan>[];
      final subText = span.text!;
      final parenRegex = RegExp(r'\({.*?}\)');
      int subLastEnd = 0;

      for (final m in parenRegex.allMatches(subText)) {
        if (m.start > subLastEnd) {
          subSpans.add(
            TextSpan(
              text: subText.substring(subLastEnd, m.start),
              style: span.style,
            ),
          );
        }
        subSpans.add(
          TextSpan(
            text: '(${m.group(1)})',
            style:
                span.style?.copyWith(color: Colors.blue) ??
                TextStyle(color: Colors.blue),
          ),
        );
        subLastEnd = m.end;
      }

      if (subLastEnd < subText.length) {
        subSpans.add(
          TextSpan(text: subText.substring(subLastEnd), style: span.style),
        );
      }

      finalSpans.addAll(subSpans.isNotEmpty ? subSpans : [span]);
    }

    return TextSpan(children: finalSpans, style: TextStyle(fontSize: fontSize));
  }
}
