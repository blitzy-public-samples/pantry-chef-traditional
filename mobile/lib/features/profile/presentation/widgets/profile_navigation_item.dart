import 'package:flutter/material.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';

/// Reusable tappable navigation row for profile/settings menus.
///
/// Renders a [Material] > [InkWell] > [Ink] row that shows [title] on
/// the left and a trailing chevron icon; tapping pushes the named
/// route [page]. Source: profile_navigation_item.dart:L4,L19-L21.
class ProfileNavigationItem extends StatelessWidget {
  /// Visible label text rendered on the left of the row.
  final String title;
  /// Named route pushed via [Navigator.pushNamed] when tapped.
  final String page;

  const ProfileNavigationItem({
    super.key,
    required this.title,
    required this.page,
  });

  /// Builds the row UI for the given [context].
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Navigate to the named route supplied via [page].
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
