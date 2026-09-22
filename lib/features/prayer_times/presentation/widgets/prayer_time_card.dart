import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:new_azkar_app/core/constants/shadows.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:flutter/material.dart';

class PrayerTimeCard extends StatelessWidget {
  final String title;
  final String time;
  final Color? color;
  final bool isActive;
  final VoidCallback? onTap;

  const PrayerTimeCard({
    super.key,
    required this.title,
    required this.time,
    this.color,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppColors.secondaryColor;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: CShadow.MD,
        border: isActive ? Border.all(color: cardColor, width: 2) : null,
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
                    color: cardColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.mosque, color: cardColor, size: 22.r),
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
                      SizedBox(height: 2.h),
                      Text(
                        time,
                        style: TextStyles.bold.copyWith(
                          color: cardColor,
                          fontSize: 18.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    margin: EdgeInsets.only(left: 8.w),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'القادمة',
                      style: TextStyles.regular.copyWith(
                        color: cardColor,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
