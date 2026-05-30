import 'package:flutter/material.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';

/// Themed placeholder avatar widget.
///
/// Renders a 100×100 circular [Container] filled with
/// `context.theme.appColors.darkBeige` and a centered `Icons.person` icon
/// (size 48) in `context.theme.appColors.grey`. Used on the profile main
/// screen above the user's email as the default avatar when no
/// user-provided image is available.
class ProfileAvatar extends StatelessWidget {
  /// Creates a [ProfileAvatar] placeholder.
  const ProfileAvatar({super.key});

  /// Builds the 100×100 themed avatar widget.
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: context.theme.appColors.darkBeige,
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: 48,
          color: context.theme.appColors.grey,
        ),
      ),
    );
  }
}
