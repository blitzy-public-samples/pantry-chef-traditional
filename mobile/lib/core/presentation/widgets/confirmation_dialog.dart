import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';

class ConfirmationDialog extends StatelessWidget {
  final String? title;
  final String content;
  final String? confirmText;
  final String? cancelText;

  const ConfirmationDialog({
    super.key,
    this.title,
    required this.content,
    this.confirmText,
    this.cancelText,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: context.theme,
      child: PlatformAlertDialog(
        title: title != null
            ? Text(
                title!,
                style: context.theme.appTextTheme.semiBold18,
                textAlign: TextAlign.center,
              )
            : null,
        content: Text(
          content,
          style: context.theme.appTextTheme.regular16,
          textAlign: title != null ? TextAlign.start : TextAlign.center,
        ),
        actions: [
          PlatformTextButton(
            child: Text(
              cancelText ?? AppLocalizations.of(context)!.no,
              style: context.theme.appTextTheme.regular16,
            ),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          PlatformTextButton(
            child: Text(
              confirmText ?? AppLocalizations.of(context)!.yes,
              style: context.theme.appTextTheme.regular16,
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );
  }
}
