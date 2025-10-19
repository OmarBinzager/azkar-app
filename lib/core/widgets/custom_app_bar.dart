import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:flutter/material.dart';

class CustomAppBarForNew extends StatelessWidget implements PreferredSizeWidget{
  final String title;
  const CustomAppBarForNew({super.key,required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20)
      ),
      child: Row(
        children: [
          BackButton(),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyles.bold),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(65.0);
}
