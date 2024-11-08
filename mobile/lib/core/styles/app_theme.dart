import 'package:flutter/material.dart';
import 'package:pantry_chef/core/styles/app_palette.dart';
import 'package:pantry_chef/core/styles/app_typography.dart';
import 'package:pantry_chef/core/styles/colors_extenstions.dart';
import 'package:pantry_chef/core/styles/typography_extensions.dart';

class AppTheme {
  static final light = ThemeData.light().copyWith(
    scaffoldBackgroundColor: ThemeData.light().appColors.beige,
    progressIndicatorTheme: ProgressIndicatorThemeData(color: ThemeData.light().appColors.green),
  );

  static final _lightAppColors = AppColorsExtension(
    beige: AppPalette.beige,
    grey: AppPalette.grey,
    green: AppPalette.green,
    white: AppPalette.white,
    darkGrey: AppPalette.darkGrey,
    black: AppPalette.black,
    lightGreen: AppPalette.lightGreen,
    red: AppPalette.red,
    lightGrey: AppPalette.lightGrey,
    darkBeige: AppPalette.darkBeige,
    lightOrange: AppPalette.lightOrange,
    brightRed: AppPalette.brightRed,
  );

  static final _lightTextTheme = AppTextThemeExtension(
    regular14: AppTypography.regular14,
    semiBold18: AppTypography.semiBold18,
    regular16: AppTypography.regular16,
    semiBold12: AppTypography.semiBold12,
    semiBold14: AppTypography.semiBold14,
  );
}

extension AppThemeExtension on ThemeData {
  /// Usage example: Theme.of(context).appColors;
  AppColorsExtension get appColors => extension<AppColorsExtension>() ?? AppTheme._lightAppColors;

  AppTextThemeExtension get appTextTheme => extension<AppTextThemeExtension>() ?? AppTheme._lightTextTheme;
}

extension ThemeGetter on BuildContext {
  // Usage example: `context.theme`
  ThemeData get theme => Theme.of(this);
}
