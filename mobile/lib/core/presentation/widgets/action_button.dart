import 'package:flutter/material.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final void Function()? onPress;
  final Color? backgroundColor;
  final Color? textColor;
  final bool outline;
  final BorderSide? border;
  final TextStyle? style;
  final EdgeInsets? padding;

  const ActionButton({
    super.key,
    required this.text,
    this.onPress,
    this.backgroundColor,
    this.textColor,
    this.outline = false,
    this.border,
    this.style,
    this.padding,
  });

  Widget _getButtonText(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Text(
        text,
        style: style != null
            ? style!.copyWith(
                color: onPress != null ? textColor ?? context.theme.appColors.white : context.theme.appColors.darkGrey,
              )
            : context.theme.appTextTheme.semiBold18.copyWith(
                color: onPress != null ? textColor ?? context.theme.appColors.white : context.theme.appColors.darkGrey,
              ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (outline == true) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onPress != null
              ? () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  onPress!();
                }
              : null,
          style: ButtonStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            side: WidgetStateProperty.all(
              BorderSide(
                color: onPress != null ? context.theme.appColors.green : context.theme.appColors.darkGrey,
              ),
            ),
            padding: WidgetStateProperty.all(EdgeInsets.zero),
          ),
          child: _getButtonText(context),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? context.theme.appColors.green,
          disabledBackgroundColor: context.theme.appColors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          side: border,
          padding: EdgeInsets.zero,
        ),
        onPressed: onPress != null
            ? () {
                FocusManager.instance.primaryFocus?.unfocus();
                onPress!();
              }
            : null,
        child: _getButtonText(context),
      ),
    );
  }
}
