import 'package:flutter/material.dart';

class AppTextThemeExtension extends ThemeExtension<AppTextThemeExtension> {
  const AppTextThemeExtension({
    required this.regular14,
    required this.semiBold18,
    required this.regular16,
    required this.semiBold12,
    required this.semiBold14,
  });

  final TextStyle regular14;
  final TextStyle semiBold18;
  final TextStyle regular16;
  final TextStyle semiBold12;
  final TextStyle semiBold14;

  @override
  ThemeExtension<AppTextThemeExtension> copyWith({
    TextStyle? regular14,
    TextStyle? semiBold18,
    TextStyle? regular16,
    TextStyle? semiBold12,
    TextStyle? semiBold14,
  }) =>
      AppTextThemeExtension(
        regular14: regular14 ?? this.regular14,
        semiBold18: semiBold18 ?? this.semiBold18,
        regular16: regular16 ?? this.regular16,
        semiBold12: semiBold12 ?? this.semiBold12,
        semiBold14: semiBold14 ?? this.semiBold14,
      );

  @override
  ThemeExtension<AppTextThemeExtension> lerp(
    covariant ThemeExtension<AppTextThemeExtension>? other,
    double t,
  ) {
    if (other is! AppTextThemeExtension) {
      return this;
    }
    return AppTextThemeExtension(
      regular14: TextStyle.lerp(regular14, other.regular14, t)!,
      semiBold18: TextStyle.lerp(semiBold18, other.semiBold18, t)!,
      regular16: TextStyle.lerp(regular16, other.regular16, t)!,
      semiBold12: TextStyle.lerp(semiBold12, other.semiBold12, t)!,
      semiBold14: TextStyle.lerp(semiBold14, other.semiBold14, t)!,
    );
  }
}
