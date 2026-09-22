import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_azkar_app/core/constants/text_styles.dart';
import 'package:flutter/material.dart';

class CustomAppBarForNew extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const CustomAppBarForNew({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          const BackButton(),
          Expanded(
            child: Text(
              title,
              style: TextStyles.bold,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 40.w),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(65.h);
}
