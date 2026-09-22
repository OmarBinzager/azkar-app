import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:new_azkar_app/core/constants/layout_constants.dart';
import 'package:new_azkar_app/core/constants/routes.dart';
import 'package:new_azkar_app/core/constants/shadows.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:new_azkar_app/core/services/isar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FridayNightView extends ConsumerWidget {
  const FridayNightView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: AppColors.gold,
        elevation: 0,
        title: Text(
          'ليلة الجمعة ويومها',
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
            _buildFriDayCard(
              icon: FontAwesomeIcons.moon,
              title: 'ما يطلب ليلة الجمعة',
              subtitle: 'أذكار وأدعية خاصة بليلة الجمعة',
              color: const Color.fromARGB(255, 15, 1, 49),
              onTap:
                  () => context.pushNamed(
                    Routes.headersViewer,
                    extra: IsarHelper.getFridayNightCategory(),
                  ),
            ),
            SizedBox(height: 14.h),
            _buildFriDayCard(
              icon: FontAwesomeIcons.sun,
              title: 'ما يطلب يوم الجمعة',
              subtitle: 'أذكار وأدعية خاصة بيوم الجمعة',
              color: AppColors.gold,
              onTap:
                  () => context.pushNamed(
                    Routes.headersViewer,
                    extra: IsarHelper.getFridayDayCategory(),
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
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
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
            child: Icon(Icons.weekend, color: AppColors.gold, size: 26.r),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ليلة الجمعة ويومها',
                  style: TextStyles.bold.copyWith(
                    color: Colors.white,
                    fontSize: 17.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'أدعية وأذكار خاصة بليلة الجمعة ويومها',
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

  Widget _buildFriDayCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
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
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                Container(
                  width: 68.r,
                  height: 68.r,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Icon(icon, color: color, size: 34.r),
                ),
                SizedBox(height: 12.h),
                Text(
                  title,
                  style: TextStyles.bold.copyWith(
                    color: AppColors.secondaryColor,
                    fontSize: 16.sp,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Text(
                  subtitle,
                  style: TextStyles.medium.copyWith(
                    color: Colors.grey[600],
                    fontSize: 13.sp,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_forward, color: color, size: 14.r),
                      SizedBox(width: 6.w),
                      Text(
                        'عرض المحتوى',
                        style: TextStyles.medium.copyWith(
                          color: color,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
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
