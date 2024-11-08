import 'package:flutter/material.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';

class ProfileNavigationItem extends StatelessWidget {
  final String title;
  final String page;

  const ProfileNavigationItem({
    super.key,
    required this.title,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(page);
        },
        child: Ink(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: context.theme.appTextTheme.regular14,
                ),
                Icon(
                  Icons.chevron_right,
                  color: context.theme.appColors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
