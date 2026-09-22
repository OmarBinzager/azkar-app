import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:new_azkar_app/core/constants/layout_constants.dart';
import 'package:new_azkar_app/core/constants/routes.dart';
import 'package:new_azkar_app/core/constants/shadows.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:new_azkar_app/features/home/entities/header.dart';
import 'package:new_azkar_app/features/public/providers/headers_provider.dart';
import 'package:new_azkar_app/core/services/isar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TipsAndEtiquetteView extends ConsumerWidget {
  const TipsAndEtiquetteView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headers = ref.read(headersProvider);

    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: AppColors.gold,
        elevation: 0,
        title: Text(
          'نصائح وآداب عامة',
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
            _buildTipsCard(
              context,
              headers[IsarHelper.generalTipsHeaderIndex],
              'نصائح عامة',
              'إرشادات عامة للحياة اليومية',
              Icons.tips_and_updates_rounded,
              AppColors.success,
            ),
            SizedBox(height: 14.h),
            _buildTipsCard(
              context,
              headers[IsarHelper.seekerTipsHeaderIndex],
              'نصائح لطالب العلم',
              'إرشادات خاصة لطلاب العلم',
              Icons.school_rounded,
              AppColors.primaryColor,
            ),
            SizedBox(height: 14.h),
            _buildTipsCard(
              context,
              headers[IsarHelper.seekerEtiquetteHeaderIndex],
              'من آداب طالب العلم',
              'الآداب والسلوكيات المطلوبة',
              Icons.auto_stories_rounded,
              AppColors.warring,
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
          colors: [AppColors.thirdColor, AppColors.thirdColor.withOpacity(0.8)],
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
            child: Icon(
              Icons.lightbulb_outline_rounded,
              color: AppColors.gold,
              size: 26.r,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نصائح وآداب عامة',
                  style: TextStyles.bold.copyWith(
                    color: Colors.white,
                    fontSize: 17.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'إرشادات قيمة للسلوك الحسن والحياة الطيبة',
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

  Widget _buildTipsCard(
    BuildContext context,
    Header header,
    String title,
    String subtitle,
    IconData icon,
    MaterialColor color,
  ) {
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
          onTap: () => context.pushNamed(Routes.contents, extra: header),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
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
                        style: TextStyles.bold.copyWith(
                          color: AppColors.secondaryColor,
                          fontSize: 15.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: TextStyles.medium.copyWith(
                          color: Colors.grey[600],
                          fontSize: 12.sp,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(Icons.arrow_forward_ios_outlined, color: Colors.black54, size: 16.r),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
