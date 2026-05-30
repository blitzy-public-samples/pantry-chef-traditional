import 'package:flutter/material.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';

/// Tappable row widget showing a [title] text on the left and a chevron icon
/// on the right.
///
/// Composed as `Material` → `InkWell` → `Ink` → `Padding` → `Row`. On tap,
/// calls `Navigator.of(context).pushNamed(page)` to navigate to the named
/// route. Typical consumers pass `Navigation.preferences` or
/// `Navigation.favoriteRecipes` as the [page] argument. Styled with the app
/// theme (`context.theme.appTextTheme.regular14`, chevron color
/// `context.theme.appColors.grey`).
class ProfileNavigationItem extends StatelessWidget {
  /// The user-facing label rendered on the left of the row.
  final String title;
  /// The named route to push via `Navigator.pushNamed` when the row is tapped.
  ///
  /// Typically one of the route constants from
  /// `mobile/lib/core/constants/navigation.dart` such as
  /// `Navigation.preferences` or `Navigation.favoriteRecipes`.
  final String page;

  /// Creates a [ProfileNavigationItem] row with the given [title] and target
  /// [page] route.
  const ProfileNavigationItem({
    super.key,
    required this.title,
    required this.page,
  });

  /// Builds the tappable navigation row.
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
