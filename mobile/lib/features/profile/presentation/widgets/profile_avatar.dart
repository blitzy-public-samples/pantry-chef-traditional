import 'package:flutter/material.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';

/// Default profile image placeholder shown when no user photo
/// is available.
///
/// A [StatelessWidget] that renders a fixed 100x100 circular
/// [Container] (BorderRadius 50, theme `darkBeige` background)
/// with a centered [Icons.person] (size 48, theme `grey`).
/// Source: profile_avatar.dart:L4,L9-L23.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    // Circular themed container holding a centered person icon.
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
