import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:new_azkar_app/core/constants/layout_constants.dart';
import 'package:new_azkar_app/core/constants/routes.dart';
import 'package:new_azkar_app/core/constants/shadows.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:new_azkar_app/features/public/providers/headers_provider.dart';
import 'package:new_azkar_app/features/public/models/header_model.dart';
import 'package:new_azkar_app/features/public/models/header_of_header_model.dart';
import 'package:new_azkar_app/features/home/entities/header.dart';
import 'package:new_azkar_app/core/services/isar_helper.dart';
import 'package:new_azkar_app/core/models/audio_item.dart';
import 'package:new_azkar_app/core/providers/global_audio_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HeadersViewer extends ConsumerWidget {
  final HeaderModel headerModel;

  const HeadersViewer({super.key, required this.headerModel});

  List<AudioItem> _getSectionAudioItems(WidgetRef ref) {
    if (headerModel.headers == null || headerModel.headers!.isEmpty) {
      return const [];
    }
    final allHeaders = ref.read(headersProvider);
    final allAudios = IsarHelper.getAllAudioItems();
    final headerIndices = headerModel.headers!;

    final Map<int, List<AudioItem>> audiosByHeaderId = {};
    for (final a in allAudios) {
      if (a.headerId != null) {
        audiosByHeaderId.putIfAbsent(a.headerId!, () => []).add(a);
      }
    }

    final List<AudioItem> sectionAudios = [];
    for (final idx in headerIndices) {
      if (idx >= 0 && idx < allHeaders.length) {
        final hId = allHeaders[idx].id;
        final items = audiosByHeaderId[hId];
        if (items != null && items.isNotEmpty) {
          sectionAudios.addAll(items);
        }
      }
    }

    return sectionAudios;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headers = ref.read(headersProvider);
    final headerCount = headerModel.headers!.length;
    final audioState = ref.watch(globalAudioProvider);
    final audioNotifier = ref.read(globalAudioProvider.notifier);
    final sectionAudios = _getSectionAudioItems(ref);
    final isSectionPlaying = audioState.isPlaying &&
        sectionAudios.any((a) => a.voiceFile == audioState.voiceFile);

    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: AppColors.gold,
        elevation: 0,
        title: Text(
          headerModel.label,
          style: TextStyles.bold.copyWith(color: AppColors.gold, fontSize: 20),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          if (sectionAudios.isNotEmpty)
            IconButton(
              icon: Icon(
                isSectionPlaying
                    ? Icons.pause_circle_filled_rounded
                    : Icons.volume_up_rounded,
                color: isSectionPlaying ? AppColors.gold : Colors.white,
              ),
              tooltip: isSectionPlaying
                  ? 'إيقاف الصوت مؤقتاً'
                  : 'تشغيل صوتيات القسم بالترتيب',
              onPressed: () {
                if (isSectionPlaying) {
                  audioNotifier.pause();
                } else {
                  audioNotifier.playQueue(sectionAudios, initialIndex: 0);
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.headphones_rounded, color: AppColors.gold),
            tooltip: 'المشغل الصوتي',
            onPressed: () => context.pushNamed(Routes.audioPlayer),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(LayoutConstants.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(
              headerCount,
              sectionAudios,
              isSectionPlaying,
              audioNotifier,
            ),
            const SizedBox(height: 24),
            ...buildContent(ref, context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
    int headerCount,
    List<AudioItem> sectionAudios,
    bool isSectionPlaying,
    GlobalAudioNotifier audioNotifier,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: CShadow.LG,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.gold,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headerModel.label,
                      style: TextStyles.bold.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$headerCount ${headerCount == 1 ? 'قسم' : 'أقسام'}',
                      style: TextStyles.medium.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (sectionAudios.isNotEmpty) ...[
            const SizedBox(height: 14),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (isSectionPlaying) {
                  audioNotifier.pause();
                } else {
                  audioNotifier.playQueue(sectionAudios, initialIndex: 0);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSectionPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: AppColors.secondaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isSectionPlaying
                            ? 'إيقاف مؤقت لصوتيات القسم'
                            : 'استماع لصوتيات القسم بالترتيب (${sectionAudios.length} مقاطع)',
                        style: TextStyles.bold.copyWith(
                          color: AppColors.secondaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> buildContent(WidgetRef ref, BuildContext context) {
    final headers = ref.read(headersProvider);
    List<Widget> widgets = [];
    int itemIndex = 0;
    for (int index in headerModel.headers!) {
      if (index >= 0 && index < headers.length) {
        final header = headers[index];

        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildContentCard(context, header, itemIndex++, index),
          ),
        );
      }
    }

    return widgets;
  }

  Widget _buildContentCard(
    BuildContext context,
    Header header,
    int itemIndex,
    int originalIndex,
  ) {
    final isSpecialCase = IsarHelper.isHeaderWithSubHeaders(originalIndex);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: CShadow.MD,
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (isSpecialCase) {
              context.pushNamed(
                Routes.headersOfHeadersViewer,
                extra: IsarHelper.getDailyAzkarCategory(),
              );
            } else {
              context.pushNamed(Routes.contents, extra: header);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Number Badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${itemIndex + 1}',
                      style: TextStyles.mediumBold.copyWith(
                        color: AppColors.primaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        header.name,
                        style: TextStyles.mediumBold.copyWith(
                          color: AppColors.secondaryColor,
                          fontSize: 16,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isSpecialCase
                            ? 'أذكار وأوراد اليومية'
                            : 'قسم من الأذكار',
                        style: TextStyles.regular.copyWith(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.primaryColor,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
