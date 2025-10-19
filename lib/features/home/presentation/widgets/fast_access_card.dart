import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:new_azkar_app/core/constants/fixed_assets.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:new_azkar_app/core/widgets/svg_icon.dart';
import 'package:flutter/material.dart';

class FastAccessCard extends StatelessWidget {
  final String text;
  final GestureTapCallback? onTap;

  const FastAccessCard({super.key, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      width: 200,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.gold.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                text,
                style: TextStyles.regular,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.error.shade50,
                borderRadius: BorderRadius.circular(5),
              ),
              child: CSvgIcon(
                icon: SvgAssets.delete,
                size: 20,
                color: AppColors.error.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
