import 'package:flutter/material.dart';
import 'package:pantry_chef/core/constants/common.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';

/// A tappable, full-width row that renders a single [item]
/// ([Ingredient]) for use in the ingredient search results list.
class IngredientSearchResultItem extends StatelessWidget {
  /// The [Ingredient] rendered by this row; its name is displayed.
  final Ingredient item;

  const IngredientSearchResultItem({super.key, required this.item});

  /// Builds a [Material]/[InkWell]/[Ink] row in the given [context]
  /// that shows `item.name` with a bottom divider and is tappable to
  /// select the ingredient.
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Pop the current route via Navigator.of(context).pop(item)
          // to return the selected Ingredient to the search dialog caller.
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
