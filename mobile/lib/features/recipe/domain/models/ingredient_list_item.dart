import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';

part 'ingredient_list_item.g.dart';

@JsonSerializable()
class IngredientListItem {
  final Ingredient ingridient;
  final double amount;
  final String unit;
  final bool required;
  final List<String>? substitutes;

  const IngredientListItem({
    required this.ingridient,
    required this.amount,
    required this.unit,
    required this.required,
    this.substitutes,
  });

  factory IngredientListItem.fromJson(Map<String, dynamic> json) => _$IngredientListItemFromJson(json);

  Map<String, dynamic> toJson() => _$IngredientListItemToJson(this);
}
