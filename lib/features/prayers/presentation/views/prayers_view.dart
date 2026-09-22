import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:new_azkar_app/core/constants/layout_constants.dart';
import 'package:new_azkar_app/core/constants/routes.dart';
import 'package:new_azkar_app/core/constants/shadows.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:new_azkar_app/core/services/isar_helper.dart';
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
          style: TextStyles.bold.copyWith(color: AppColors.gold, fontSize: 20.sp),
        ),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(LayoutConstants.rScreenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            SizedBox(height: 20.h),
            _buildSectionTitle('الصلوات الخمس و الوتر'),
            _buildPrayerCard(
              icon: Icons.wb_sunny,
              title: 'صلاة الفجر',
              subtitle: 'أدعية وأذكار صلاة الفجر',
              color: AppColors.secondaryColor,
              onTap:
                  () => context.pushNamed(
                    Routes.headersViewer,
                    extra: IsarHelper.getFajrCategory(),
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
                    extra: IsarHelper.getIshraqCategory(),
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
                    extra: IsarHelper.getZuhrCategory(),
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
                    extra: IsarHelper.getAsrCategory(),
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
                    extra: IsarHelper.getMaghribCategory(),
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
                    extra: IsarHelper.getIshaCategory(),
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
                    extra: IsarHelper.getWitrCategory(),
                  ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondaryColor,
            AppColors.secondaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: CShadow.LG,
      ),
      child: Row(
        children: [
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Icon(Icons.mosque, color: AppColors.gold, size: 26.r),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الصلوات',
                  style: TextStyles.bold.copyWith(
                    color: Colors.white,
                    fontSize: 17.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'أدعية وأذكار الصلوات الخمس والوتر',
                  style: TextStyles.medium.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13.sp,
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
      padding: EdgeInsets.only(bottom: 10.h, top: 6.h),
      child: Text(
        title,
        style: TextStyles.mediumBold.copyWith(
          color: AppColors.secondaryColor,
          fontSize: 15.sp,
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
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: CShadow.MD,
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(14.r),
            child: Row(
              children: [
                Container(
                  width: 46.r,
                  height: 46.r,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: color, size: 22.r),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyles.mediumBold.copyWith(
                          color: AppColors.secondaryColor,
                          fontSize: 15.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: TextStyles.regular.copyWith(
                          color: Colors.grey[600],
                          fontSize: 13.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.secondaryColor.withOpacity(0.6),
                  size: 15.r,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
