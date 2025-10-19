import 'package:new_azkar_app/core/constants/app_colors.dart';
import 'package:new_azkar_app/core/constants/layout_constants.dart';
import 'package:new_azkar_app/core/constants/shadows.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:new_azkar_app/core/widgets/svg_icon.dart';
import 'package:new_azkar_app/features/home/entities/content.dart';
import 'package:flutter/material.dart';
import 'item_content.dart';

class AppTile extends StatefulWidget {
  final String? icon;
  final String label;
  final VoidCallback? onTap;
  final List<Content>? items;

  const AppTile({
    super.key,
    this.icon,
    required this.label,
    this.onTap,
    this.items,
  });

  @override
  State<AppTile> createState() => _AppTileState();
}

class _AppTileState extends State<AppTile> {
  bool isOpenDetails = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(LayoutConstants.containerPadding),
      decoration: BoxDecoration(
        boxShadow: CShadow.MD,
        borderRadius: BorderRadius.circular(8),
        color: AppColors.fourthColor,
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: widget.onTap,
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  CSvgIcon(icon: widget.icon!, size: 40),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyles.medium,
                  ),
                ),
                widget.onTap == null
                    ? IconButton(
                      onPressed: () {
                        setState(() {
                          isOpenDetails = !isOpenDetails;
                        });
                      },
                      icon:
                          isOpenDetails
                              ? Icon(Icons.arrow_upward_rounded)
                              : Icon(Icons.arrow_downward),
                    )
                    : IconButton(
                      onPressed: widget.onTap,
                      icon: Icon(Icons.arrow_forward_ios),
                    ),
              ],
            ),
          ),
          if (isOpenDetails &&
              widget.items != null &&
              widget.items!.isNotEmpty) ...[
            const SizedBox(height: 5),
            Column(
              children:
                  widget.items!.map((e) {
                    return ItemContent(content: e);
                  }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
