import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';

PlatformAppBar getAppBarWidget(
  BuildContext context, {
  required String title,
  Widget? trailingAction,
}) =>
    PlatformAppBar(
      title: Text(
        title,
        style: context.theme.appTextTheme.semiBold18,
      ),
      backgroundColor: context.theme.appColors.darkBeige,
      trailingActions: trailingAction != null ? [trailingAction] : null,
    );
