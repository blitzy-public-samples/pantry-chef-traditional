import 'package:flutter/material.dart';

const Color defaultTextColor = Color(0xFF0D0D0C);

abstract class AppTypography {
  static TextStyle get regular14 => const TextStyle(
        fontSize: 14,
        height: 1.38,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w400,
        color: defaultTextColor,
      );

  static TextStyle get semiBold18 => const TextStyle(
        fontSize: 18,
        height: 1.39,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w600,
        color: defaultTextColor,
      );

  static TextStyle get regular16 => const TextStyle(
        fontSize: 16,
        height: 1.38,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w400,
        color: defaultTextColor,
      );

  static TextStyle get semiBold12 => const TextStyle(
        fontSize: 12,
        height: 1.33,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w600,
        color: defaultTextColor,
      );

  static TextStyle get semiBold14 => const TextStyle(
        fontSize: 14,
        height: 1.38,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w600,
        color: defaultTextColor,
      );
}
