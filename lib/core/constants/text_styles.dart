import 'package:flutter/material.dart';

abstract final class TextStyles {
  static const TextStyle heading1Bold = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle regular = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle regularBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle big = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle medium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle mediumBold = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle large = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bold = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bigSplashFont = TextStyle(
    fontSize: 60,
    fontWeight: FontWeight.w500,
    fontFamily: docTypeQuranFont,
  );

  static const TextStyle body = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    fontFamily: amiriFont,
  );

  static const String uthmanicQuranFont = "KFGQPC HAFS Uthmanic Script";
  static const String nabiQuranFont = "Nabi";
  static const String docTypeQuranFont = "DecoTypeThuluthII";
  static const String amiriFont = "Amiri-Regular";
  static const String lotusFont = "Lotus";
  static const String elmessiriFont = "ElMessiri";

  static const TextStyle quranText = TextStyle(
    fontWeight: FontWeight.w700,
    fontFamily: uthmanicQuranFont,
    // fontFamily: ,
  );
}
