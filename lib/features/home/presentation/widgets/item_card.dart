import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:new_azkar_app/core/constants/layout_constants.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final String label;
  final GestureTapCallback? onTap;
  final bool isExpand;

  const ItemCard({
    super.key,
    required this.label,
    this.onTap,
    this.isExpand = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70.h,
        width: isExpand ? double.infinity : 170.w,
        padding: EdgeInsets.symmetric(
          horizontal: LayoutConstants.rContainerPadding,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.r)),
          color: AppColors.gold.shade50,
          border: Border.all(color: AppColors.neutral.shade600, width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyles.medium,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
