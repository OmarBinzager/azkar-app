import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:flutter/material.dart';

class SecondItemCard extends StatelessWidget {
  final String label;
  final GestureTapCallback? onTap;

  const SecondItemCard({
    super.key,
    required this.label,this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width:  120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: AppColors.primaryColor,
          border: Border.all(color: AppColors.neutral.shade600, width: 1.5),
        ),
        child: Center(child: Text(label, style: TextStyles.medium.copyWith(
          color: AppColors.fourthColor
        ))),
      ),
    );
  }
}