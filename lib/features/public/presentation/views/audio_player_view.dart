import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:new_azkar_app/core/constants/routes.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:new_azkar_app/core/providers/global_audio_provider.dart';
import 'package:new_azkar_app/core/services/isar_helper.dart';

class AudioPlayerView extends ConsumerStatefulWidget {
  const AudioPlayerView({super.key});

  @override
  ConsumerState<AudioPlayerView> createState() => _AudioPlayerViewState();
}

class _AudioPlayerViewState extends ConsumerState<AudioPlayerView>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  double _dragPosition = -1.0;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    );

    // If already playing, start animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(globalAudioProvider);
      if (state.isPlaying) {
        _rotationController.repeat();
      }
      // If queue is empty, initialize queue with all audio items so user can immediately play
      if (state.queue.isEmpty) {
        final allItems = IsarHelper.getAllAudioItems();
        if (allItems.isNotEmpty) {
          ref.read(globalAudioProvider.notifier).playQueue(allItems, initialIndex: 0);
        }
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _showSpeedSelector(BuildContext context, double currentRate) {
    final speeds = [0.75, 1.0, 1.25, 1.5, 2.0];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'سرعة التشغيل',
                style: TextStyles.bold.copyWith(color: AppColors.gold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: speeds.map((speed) {
                    final isSelected = currentRate == speed;
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        ref.read(globalAudioProvider.notifier).setPlaybackRate(speed);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.gold : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.gold : Colors.white24,
                          ),
                        ),
                        child: Text(
                          '${speed}x',
                          style: TextStyles.bold.copyWith(
                            color: isSelected ? AppColors.secondaryColor : Colors.white,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showQueueBottomSheet(BuildContext context, GlobalAudioState audioState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.secondaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final queue = audioState.queue.isNotEmpty
            ? audioState.queue
            : IsarHelper.getAllAudioItems();

        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'قائمة التشغيل (${queue.length})',
                        style: TextStyles.bold.copyWith(color: AppColors.gold, fontSize: 18),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12, height: 1),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: queue.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = queue[index];
                      final isCurrent = audioState.voiceFile == item.voiceFile;

                      return Container(
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppColors.gold.withOpacity(0.15)
                              : Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isCurrent ? AppColors.gold : Colors.white10,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                          leading: Icon(
                            isCurrent
                                ? (audioState.isPlaying
                                    ? Icons.graphic_eq_rounded
                                    : Icons.play_arrow_rounded)
                                : Icons.music_note_rounded,
                            color: isCurrent ? AppColors.gold : Colors.white54,
                          ),
                          title: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyles.mediumBold.copyWith(
                              color: isCurrent ? AppColors.gold : Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: item.category != null
                              ? Text(
                                  item.category!,
                                  style: TextStyles.regular.copyWith(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                )
                              : null,
                          trailing: isCurrent && audioState.isPlaying
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'يعمل الآن',
                                    style: TextStyles.bold.copyWith(
                                      color: AppColors.secondaryColor,
                                      fontSize: 11,
                                    ),
                                  ),
                                )
                              : null,
                          onTap: () {
                            ref.read(globalAudioProvider.notifier).playQueue(
                                  queue,
                                  initialIndex: index,
                                );
                            Navigator.pop(ctx);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(globalAudioProvider);
    final audioNotifier = ref.read(globalAudioProvider.notifier);

    // Control disc rotation animation
    if (audioState.isPlaying) {
      if (!_rotationController.isAnimating) {
        _rotationController.repeat();
      }
    } else {
      if (_rotationController.isAnimating) {
        _rotationController.stop();
      }
    }

    final totalSeconds = audioState.duration.inSeconds.toDouble();
    final currentSeconds = _dragPosition >= 0
        ? _dragPosition
        : audioState.position.inSeconds.toDouble();
    final safeTotal = totalSeconds > 0 ? totalSeconds : 1.0;
    final safeCurrent = currentSeconds.clamp(0.0, safeTotal);

    final title = audioState.title ?? 'مشغل الصوتيات والأذكار';
    final currentItem = audioState.currentAudioItem;
    final category = currentItem?.category ?? 'أذكار وأدعية مختارة';

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.gold,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'المشغل الصوتي',
          style: TextStyles.bold.copyWith(color: AppColors.gold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_music_rounded, color: AppColors.gold),
            tooltip: 'قائمة التشغيل',
            onPressed: () => _showQueueBottomSheet(context, audioState),
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded, color: AppColors.gold),
            tooltip: 'التحميلات',
            onPressed: () => context.pushNamed(Routes.downloads),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Rotating Vinyl / Islamic Artwork Disc
              Center(
                child: RotationTransition(
                  turns: _rotationController,
                  child: Container(
                    width: 230,
                    height: 230,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.secondaryColor,
                          Colors.black87,
                        ],
                        stops: const [0.3, 0.7, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withOpacity(audioState.isPlaying ? 0.35 : 0.15),
                          blurRadius: audioState.isPlaying ? 28 : 14,
                          spreadRadius: audioState.isPlaying ? 4 : 1,
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.8),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.secondaryColor,
                          border: Border.all(color: AppColors.gold, width: 2),
                        ),
                        child: Icon(
                          audioState.isPlaying
                              ? Icons.headphones_rounded
                              : Icons.music_note_rounded,
                          color: AppColors.gold,
                          size: 42,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Title and Category Info
              Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.bold.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                    ),
                    child: Text(
                      category,
                      style: TextStyles.regular.copyWith(
                        color: AppColors.gold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

              // Scrubber Slider
              Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.gold,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: AppColors.gold,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                      overlayColor: AppColors.gold.withOpacity(0.2),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: safeCurrent,
                      min: 0.0,
                      max: safeTotal,
                      onChanged: (val) {
                        setState(() {
                          _dragPosition = val;
                        });
                      },
                      onChangeEnd: (val) {
                        setState(() {
                          _dragPosition = -1.0;
                        });
                        audioNotifier.seek(Duration(seconds: val.toInt()));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(Duration(seconds: safeCurrent.toInt())),
                          style: TextStyles.regular.copyWith(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatDuration(audioState.duration),
                          style: TextStyles.regular.copyWith(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Primary Playback Controls
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Shuffle Toggle
                    IconButton(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.shuffle_rounded,
                        color: audioState.isShuffle ? AppColors.gold : Colors.white38,
                        size: 24,
                      ),
                      tooltip: 'تشغيل عشوائي',
                      onPressed: audioNotifier.toggleShuffle,
                    ),
                    const SizedBox(width: 8),

                    // Previous Track
                    IconButton(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.skip_previous_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      tooltip: 'السابق',
                      onPressed: audioState.hasPrevious
                          ? () => audioNotifier.playPrevious()
                          : null,
                    ),
                    const SizedBox(width: 8),

                    // Rewind 10 Seconds
                    IconButton(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.replay_10_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                      tooltip: 'تقديم 10 ثوان',
                      onPressed: () => audioNotifier.seekRelative(-10),
                    ),
                    const SizedBox(width: 12),

                    // Play / Pause / Loading Button
                    GestureDetector(
                      onTap: () {
                        if (audioState.voiceFile == null && audioState.audioUrl == null) {
                          final all = IsarHelper.getAllAudioItems();
                          if (all.isNotEmpty) {
                            audioNotifier.playQueue(all, initialIndex: 0);
                          }
                          return;
                        }
                        if (audioState.isPlaying) {
                          audioNotifier.pause();
                        } else {
                          audioNotifier.resume();
                        }
                      },
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: audioState.isLoading || audioState.isDownloading
                            ? const Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    color: AppColors.secondaryColor,
                                    strokeWidth: 3,
                                  ),
                                ),
                              )
                            : Icon(
                                audioState.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: AppColors.secondaryColor,
                                size: 36,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Forward 10 Seconds
                    IconButton(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.forward_10_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                      tooltip: 'تأخير 10 ثوان',
                      onPressed: () => audioNotifier.seekRelative(10),
                    ),
                    const SizedBox(width: 8),

                    // Next Track
                    IconButton(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.skip_next_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      tooltip: 'التالي',
                      onPressed: audioState.hasNext
                          ? () => audioNotifier.playNext()
                          : null,
                    ),
                    const SizedBox(width: 8),

                    // Repeat Mode Toggle
                    IconButton(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        audioState.repeatMode == AudioRepeatMode.repeatOne
                            ? Icons.repeat_one_rounded
                            : Icons.repeat_rounded,
                        color: audioState.repeatMode != AudioRepeatMode.off
                            ? AppColors.gold
                            : Colors.white38,
                        size: 24,
                      ),
                      tooltip: audioState.repeatMode == AudioRepeatMode.repeatOne
                          ? 'تكرار المقطع الحالي'
                          : audioState.repeatMode == AudioRepeatMode.repeatAll
                              ? 'تكرار الكل'
                              : 'إيقاف التكرار',
                      onPressed: audioNotifier.toggleRepeatMode,
                    ),
                  ],
                ),
              ),

              // Bottom Actions: Playback Speed and Queue Button
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Speed Selector Chip
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _showSpeedSelector(context, audioState.playbackRate),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.speed_rounded, color: AppColors.gold, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '${audioState.playbackRate}x',
                              style: TextStyles.bold.copyWith(color: Colors.white, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Queue / Playlist Button
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _showQueueBottomSheet(context, audioState),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.format_list_bulleted_rounded, color: AppColors.gold, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'القائمة (${audioState.queue.length})',
                              style: TextStyles.bold.copyWith(color: Colors.white, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
