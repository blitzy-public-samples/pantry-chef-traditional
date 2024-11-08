import 'package:flutter/material.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

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
