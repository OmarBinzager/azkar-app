import 'package:flutter/material.dart';

class CShadow {
  // ignore: non_constant_identifier_names
  static List<BoxShadow> SM = [
    BoxShadow(
      offset: const Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -1,
      color: const Color(0x2D364314).withValues(alpha: 0.05),
    ),
  ];
  // ignore: non_constant_identifier_names
  static List<BoxShadow> MD = [
    BoxShadow(
      offset: const Offset(0, 4),
      blurRadius: 8,
      spreadRadius: -2,
      color: const Color(0x2D364314).withValues(alpha: 0.08),
    ),
    BoxShadow(
      offset: const Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -2,
      color: const Color(0x2D364314).withValues(alpha: 0.06),
    ),
  ];
  // ignore: non_constant_identifier_names
  static List<BoxShadow> LG = [
    BoxShadow(
      offset: const Offset(0, 8),
      blurRadius: 11,
      spreadRadius: -4,
      color: const Color(0x2D364314).withValues(alpha: 0.04),
    ),
    BoxShadow(
      offset: const Offset(0, 20),
      blurRadius: 24,
      spreadRadius: -4,
      color: const Color(0x2D364314).withValues(alpha: 0.04),
    ),
  ];
}
