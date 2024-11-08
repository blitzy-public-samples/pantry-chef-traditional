import 'package:flutter/material.dart';
import 'package:pantry_chef/core/constants/common.dart';
import 'package:pantry_chef/core/styles/app_theme.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';

class IngredientSearchResultItem extends StatelessWidget {
  final Ingredient item;

  const IngredientSearchResultItem({super.key, required this.item});

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
