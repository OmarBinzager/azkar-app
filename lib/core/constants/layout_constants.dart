import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const pgHorizontalPadding18 = EdgeInsets.symmetric(horizontal: 18);
const pgHorizontalPadding20 = EdgeInsets.symmetric(horizontal: 20);
const pgAllPadding16 = EdgeInsets.all(16);
const EdgeInsets pgAllPadding24 = EdgeInsets.all(24);
const double defaultBottomPaddingSize = 30;

class LayoutConstants {
  static const double size8 = 8;
  static const double size16 = 16;
  static const double size24 = 24;
  static const double size32 = 32;
  static const double screenPadding = 16;
  static const double containerPadding = 8;

  // Responsive dynamic getters
  static double get rSize8 => 8.r;
  static double get rSize12 => 12.r;
  static double get rSize16 => 16.r;
  static double get rSize20 => 20.r;
  static double get rSize24 => 24.r;
  static double get rSize32 => 32.r;
  static double get rScreenPadding => 16.w;
  static double get rContainerPadding => 8.w;

  static EdgeInsets get responsiveScreenPadding => EdgeInsets.all(16.r);
  static EdgeInsets get responsiveHorizontalScreenPadding => EdgeInsets.symmetric(horizontal: 16.w);
  static EdgeInsets get responsiveContainerPadding => EdgeInsets.all(8.r);
}
