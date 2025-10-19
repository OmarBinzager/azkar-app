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
        height: 70,
        width: isExpand ? MediaQuery.of(context).size.width : 185,
        padding: EdgeInsets.symmetric(
          horizontal: LayoutConstants.containerPadding,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: AppColors.gold.shade50,
          border: Border.all(color: AppColors.neutral.shade600, width: 1.5),
        ),
        child: Center(child: Text(label, style: TextStyles.medium)),
      ),
    );
  }
}
