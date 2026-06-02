import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';

part 'ingredient_list_item.g.dart';

/// Immutable, JSON-serializable value object for a single
/// ingredient entry within a recipe.
///
/// JSON conversion is delegated to generated code via
/// `part 'ingredient_list_item.g.dart'`.
@JsonSerializable()
class IngredientListItem {
  /// Linked [Ingredient]; the field name spelling
  /// 'ingridient' (sic) is intentional and preserved.
  final Ingredient ingridient;
  /// Quantity amount.
  final double amount;
  /// Measurement unit.
  final String unit;
  /// Whether this ingredient is required for the recipe.
  final bool required;
  /// Optional substitute ingredient names (nullable).
  final List<String>? substitutes;

  const IngredientListItem({
    required this.ingridient,
    required this.amount,
    required this.unit,
    required this.required,
    this.substitutes,
  });

  /// Creates an [IngredientListItem] from a JSON map [json].
  factory IngredientListItem.fromJson(Map<String, dynamic> json) => _$IngredientListItemFromJson(json);

  /// Converts this [IngredientListItem] to a JSON map.
  Map<String, dynamic> toJson() => _$IngredientListItemToJson(this);
}
