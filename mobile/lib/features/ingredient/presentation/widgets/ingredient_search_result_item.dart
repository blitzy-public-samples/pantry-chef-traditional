import 'package:flutter/material.dart';
import 'package:pantry_chef/core/constants/common.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';

/// List row inside `SearchDialog`'s scrollable result list, displaying
/// `item.name` and, when tapped, popping the modal bottom-sheet route via
/// `Navigator.of(context).pop(item)` so the selected [Ingredient] flows back
/// to the parent caller chain (`SearchDialog` → `showModalBottomSheet` →
/// `IngredientSearchField.onChaged`). Uses `CommonConstants.pagePadding` for
/// horizontal padding and renders a bottom divider in `appColors.grey`.
class IngredientSearchResultItem extends StatelessWidget {
  /// The [Ingredient] represented by this list row. Returned verbatim to the
  /// caller via `Navigator.of(context).pop(item)` on tap.
  final Ingredient item;

  /// Creates a row for the supplied [item]; [item] is required.
  const IngredientSearchResultItem({super.key, required this.item});

  /// Standard Flutter `build` override.
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop(item);
        },
        child: Ink(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: context.theme.appColors.grey,
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: CommonConstants.pagePadding),
            child: Text(item.name),
          ),
        ),
      ),
    );
  }
}
