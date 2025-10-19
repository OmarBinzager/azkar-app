import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:new_azkar_app/core/constants/fixed_assets.dart';
import 'package:new_azkar_app/core/constants/layout_constants.dart';
import 'package:new_azkar_app/core/constants/routes.dart';
import 'package:new_azkar_app/core/constants/shadows.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:new_azkar_app/core/widgets/app_tile.dart';
import 'package:new_azkar_app/features/public/models/header_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PrayersView extends ConsumerWidget {
  const PrayersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: AppColors.gold,
        elevation: 0,
        title: Text(
          'الصلوات',
          style: TextStyles.bold.copyWith(color: AppColors.gold, fontSize: 22),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(LayoutConstants.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('الصلوات الخمس و الوتر'),
            _buildPrayerCard(
              icon: Icons.wb_sunny,
              title: 'صلاة الفجر',
              subtitle: 'أدعية وأذكار صلاة الفجر',
              color: AppColors.secondaryColor,
              onTap:
                  () => context.pushNamed(
                    Routes.headersViewer,
                    extra: HeaderModel(
                      label: 'صلاة الفجر',
                      fromHeader: 0,
                      toHeader: 12,
                    ),
                  ),
            ),
            _buildPrayerCard(
              icon: Icons.wb_sunny_outlined,
              title: 'الإشراق والضحى',
              subtitle: 'أدعية وأذكار الإشراق والضحى',
              color: AppColors.primaryColor,
              onTap:
                  () => context.pushNamed(
                    Routes.headersViewer,
                    extra: HeaderModel(
                      label: 'الإشراق والضحى',
                      fromHeader: 13,
                      toHeader: 15,
                    ),
                  ),
            ),
            _buildPrayerCard(
              icon: Icons.wb_sunny,
              title: 'صلاة الظهر',
              subtitle: 'أدعية وأذكار صلاة الظهر',
              color: AppColors.thirdColor,
              onTap:
                  () => context.pushNamed(
                    Routes.headersViewer,
                    extra: HeaderModel(
                      label: 'صلاة الظهر',
                      fromHeader: 16,
                      toHeader: 24,
                    ),
                  ),
            ),
            _buildPrayerCard(
              icon: Icons.wb_sunny_outlined,
              title: 'صلاة العصر',
              subtitle: 'أدعية وأذكار صلاة العصر',
              color: AppColors.warring,
              onTap:
                  () => context.pushNamed(
                    Routes.headersViewer,
                    extra: HeaderModel(
                      label: 'صلاة العصر',
                      fromHeader: 25,
                      toHeader: 37,
                    ),
                  ),
            ),
            _buildPrayerCard(
              icon: Icons.nightlight_round,
              title: 'صلاة المغرب',
              subtitle: 'أدعية وأذكار صلاة المغرب',
              color: AppColors.secondaryColor,
              onTap:
                  () => context.pushNamed(
                    Routes.headersViewer,
                    extra: HeaderModel(
                      label: 'صلاة المغرب',
                      fromHeader: 38,
                      toHeader: 52,
                    ),
                  ),
            ),
            _buildPrayerCard(
              icon: Icons.nightlight_round,
              title: 'صلاة العشاء',
              subtitle: 'أدعية وأذكار صلاة العشاء',
              color: AppColors.primaryColor,
              onTap:
                  () => context.pushNamed(
                    Routes.headersViewer,
                    extra: HeaderModel(
                      label: 'صلاة العشاء',
                      fromHeader: 53,
                      toHeader: 60,
                    ),
                  ),
            ),
            _buildPrayerCard(
              icon: Icons.star,
              title: 'صلاة الوتر',
              subtitle: 'أدعية وأذكار صلاة الوتر',
              color: AppColors.gold,
              onTap:
                  () => context.pushNamed(
                    Routes.headersViewer,
                    extra: HeaderModel(
                      label: 'صلاة الوتر',
                      fromHeader: 61,
                      toHeader: 63,
                    ),
                  ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondaryColor,
            AppColors.secondaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: CShadow.LG,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.mosque, color: AppColors.gold, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الصلوات',
                  style: TextStyles.bold.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'أدعية وأذكار الصلوات الخمس والوتر',
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyles.mediumBold.copyWith(
          color: AppColors.secondaryColor,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildPrayerCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: CShadow.MD,
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyles.mediumBold.copyWith(
                          color: AppColors.secondaryColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyles.regular.copyWith(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.secondaryColor.withOpacity(0.6),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
