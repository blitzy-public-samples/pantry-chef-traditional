import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.beige,
    required this.grey,
    required this.green,
    required this.white,
    required this.darkGrey,
    required this.black,
    required this.lightGreen,
    required this.red,
    required this.lightGrey,
    required this.darkBeige,
    required this.lightOrange,
    required this.brightRed,
  });

  final Color beige;
  final Color grey;
  final Color green;
  final Color white;
  final Color darkGrey;
  final Color black;
  final Color lightGreen;
  final Color red;
  final Color lightGrey;
  final Color darkBeige;
  final Color lightOrange;
  final Color brightRed;

  @override
  AppColorsExtension copyWith({
    Color? beige,
    Color? grey,
    Color? green,
    Color? white,
    Color? darkGrey,
    Color? black,
    Color? lightGreen,
    Color? red,
    Color? lightGrey,
    Color? darkBeige,
    Color? lightOrange,
    Color? brightRed,
  }) =>
      AppColorsExtension(
        beige: beige ?? this.beige,
        grey: grey ?? this.grey,
        green: green ?? this.green,
        white: white ?? this.white,
        darkGrey: darkGrey ?? this.darkGrey,
        black: black ?? this.black,
        lightGreen: lightGreen ?? this.lightGreen,
        red: red ?? this.red,
        lightGrey: lightGrey ?? this.lightGrey,
        darkBeige: darkBeige ?? this.darkBeige,
        lightOrange: lightOrange ?? this.lightOrange,
        brightRed: brightRed ?? this.brightRed,
      );

  @override
  AppColorsExtension lerp(AppColorsExtension? other, double t) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      beige: Color.lerp(beige, other.beige, t)!,
      grey: Color.lerp(grey, other.grey, t)!,
      green: Color.lerp(green, other.green, t)!,
      white: Color.lerp(white, other.white, t)!,
      darkGrey: Color.lerp(darkGrey, other.darkGrey, t)!,
      black: Color.lerp(black, other.black, t)!,
      lightGreen: Color.lerp(lightGreen, other.lightGreen, t)!,
      red: Color.lerp(red, other.red, t)!,
      lightGrey: Color.lerp(lightGrey, other.lightGrey, t)!,
      darkBeige: Color.lerp(darkBeige, other.darkBeige, t)!,
      lightOrange: Color.lerp(lightOrange, other.lightOrange, t)!,
      brightRed: Color.lerp(brightRed, other.brightRed, t)!,
    );
  }
}
