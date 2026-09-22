import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/routes.dart';
import '../providers/global_audio_provider.dart';
import '../../features/home/entities/header.dart';
import '../../features/home/entities/content.dart';
import '../../features/public/presentation/views/pdf_content_details_view.dart';

import '../services/router.dart';

class GlobalTopAudioPlayer extends ConsumerStatefulWidget {
  const GlobalTopAudioPlayer({super.key});

  @override
  ConsumerState<GlobalTopAudioPlayer> createState() =>
      _GlobalTopAudioPlayerState();
}

class _GlobalTopAudioPlayerState
    extends ConsumerState<GlobalTopAudioPlayer> {
  @override
  void initState() {
    super.initState();
    router.routerDelegate.addListener(_onRouteChanged);
  }

  @override
  void dispose() {
    router.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _navigateToTarget(BuildContext context, Object? target) {
    if (target == null) {
      context.pushNamed(Routes.audioPlayer);
      return;
    }
    if (target is Header) {
      context.push(Routes.contents, extra: target);
    } else if (target is PdfContentDetailsParams) {
      context.push(Routes.pdfContentDetails, extra: target);
    } else if (target is Content) {
      context.push(Routes.contentDetails, extra: target);
    } else {
      context.pushNamed(Routes.audioPlayer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(globalAudioProvider);
    final audioNotifier = ref.read(globalAudioProvider.notifier);

    final currentRoute = router.routerDelegate.currentConfiguration.uri.path;
    if (currentRoute == '/contents' ||
        currentRoute == '/pdfContentDetails' ||
        currentRoute == '/contentDetails' ||
        currentRoute == '/audioPlayer') {
      return const SizedBox.shrink();
    }

    // Hide if no audio loaded or stopped
    if (!audioState.isLoaded || audioState.title == null) {
      return const SizedBox.shrink();
    }

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      bottom: bottomPadding + 16.h,
      left: 16.w,
      right: 16.w,
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(30.r),
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // Play / Pause / Loading button
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints:
                        BoxConstraints(minWidth: 36.r, minHeight: 36.r),
                    onPressed: () {
                      if (audioState.isPlaying) {
                        audioNotifier.pause();
                      } else {
                        audioNotifier.resume();
                      }
                    },
                    icon:
                        audioState.isLoading || audioState.isDownloading
                            ? SizedBox(
                              width: 22.r,
                              height: 22.r,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.gold,
                                ),
                                strokeWidth: 2,
                                value:
                                    audioState.isDownloading &&
                                            audioState.downloadProgress > 0
                                        ? audioState.downloadProgress
                                        : null,
                              ),
                            )
                            : Icon(
                              audioState.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_fill,
                              color: AppColors.gold,
                              size: 32.r,
                            ),
                  ),

                  SizedBox(width: 6.w),

                  // Title & navigation click area
                  Expanded(
                    child: GestureDetector(
                      onTap:
                          () => _navigateToTarget(
                            context,
                            audioState.navigationTarget,
                          ),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            audioState.title!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'ElMessiri',
                            ),
                          ),
                          Text(
                            audioState.isDownloading
                                ? 'تحميل ${(audioState.downloadProgress * 100).toInt()}%'
                                : '${_formatDuration(audioState.position)} / ${_formatDuration(audioState.duration)}',
                            style: TextStyle(
                              color: AppColors.gold.withValues(alpha: 0.9),
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Speed toggle button
                  InkWell(
                    onTap: () {
                      final speeds = [1.0, 1.25, 1.5, 2.0, 0.75];
                      final currentIndex = speeds.indexOf(
                        audioState.playbackRate,
                      );
                      final nextSpeed =
                          speeds[currentIndex == -1
                              ? 0
                              : (currentIndex + 1) % speeds.length];
                      audioNotifier.setPlaybackRate(nextSpeed);
                    },
                    borderRadius: BorderRadius.circular(10.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        '${audioState.playbackRate}x',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 2.w),

                  // Stop / Close button
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints:
                        BoxConstraints(minWidth: 32.r, minHeight: 32.r),
                    onPressed: () {
                      audioNotifier.stop();
                    },
                    icon: Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 18.r,
                    ),
                  ),
                ],
              ),

              // Thin progress bar at bottom of pill
              if (audioState.duration.inMilliseconds > 0)
                Padding(
                  padding: EdgeInsets.only(
                    left: 12.w,
                    right: 12.w,
                    bottom: 2.h,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2.r),
                    child: LinearProgressIndicator(
                      value: (audioState.position.inMilliseconds /
                              audioState.duration.inMilliseconds)
                          .clamp(0.0, 1.0),
                      minHeight: 2.5,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
