import 'package:flutter/material.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final void Function() onPress;
  final Color? iconColor;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final double? iconSize;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPress,
    this.iconColor,
    this.backgroundColor,
    this.padding,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: iconColor ?? context.theme.appColors.black,
      ),
      iconSize: iconSize,
      padding: padding ?? EdgeInsets.all(12),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(backgroundColor ?? context.theme.appColors.lightGreen),
      ),
      onPressed: onPress,
    );
  }
}
