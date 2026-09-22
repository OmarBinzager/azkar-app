import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract final class TextStyles {
  static TextStyle get heading1Bold => TextStyle(
    fontSize: 32.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get regular => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get regularBold => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get big => TextStyle(
    fontSize: 30.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get medium => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get mediumBold => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get large => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get bold => TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get bigSplashFont => TextStyle(
    fontSize: 60.sp,
    fontWeight: FontWeight.w500,
    fontFamily: docTypeQuranFont,
  );

  static TextStyle get body => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w400,
    fontFamily: amiriFont,
  );

  static const String uthmanicQuranFont = "KFGQPC HAFS Uthmanic Script";
  static const String nabiQuranFont = "Nabi";
  static const String docTypeQuranFont = "DecoTypeThuluthII";
  static const String amiriFont = "Amiri-Regular";
  static const String lotusFont = "Lotus";
  static const String elmessiriFont = "ElMessiri";

  static TextStyle get quranText => const TextStyle(
    fontWeight: FontWeight.w700,
    fontFamily: uthmanicQuranFont,
  );
}
