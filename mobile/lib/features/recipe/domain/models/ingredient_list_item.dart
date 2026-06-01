import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';

part 'ingredient_list_item.g.dart';

/// Domain model for a single ingredient entry on a `Recipe.ingridientList` element.
///
/// Maps to the backend `IngridientList` embedded sub-schema (see `DATA_MODEL.md` § Recipe).
/// Class name uses the corrected spelling (`Ingredient*`) but its `ingridient` field
/// (lowercase, sic) is preserved verbatim to keep JSON serialization aligned with the
/// backend.
@JsonSerializable()
class IngredientListItem {
  // NOTE: 'ingridient' (lowercase) preserved verbatim to match backend JSON. Do not rename.
  /// The referenced `Ingredient` entity.
  ///
  /// Field name `ingridient` (lowercase, sic) preserved verbatim to match backend's
  /// `IngridientList.ingridient` property in JSON serialization.
  final Ingredient ingridient;

  /// Quantity required by the recipe (double).
  final double amount;

  /// Unit of measurement as a free-form string.
  ///
  /// No normalization is performed; see `mobile/lib/features/recipe/README.md`
  /// § Known Limitations and `ARCHITECTURE.md` § Recipe Matching Pipeline.
  final String unit;

  /// Whether the ingredient is required (true) or optional (false).
  ///
  /// Used by the server's matching algorithm to compute `availableIngredients`.
  final bool required;

  /// Optional list of substitute ingredient ids.
  ///
  /// Currently NOT consulted by the backend matching algorithm (see Known Limitations).
  final List<String>? substitutes;

  /// Creates an `IngredientListItem` with the required fields and optional `substitutes`.
  const IngredientListItem({
    required this.ingridient,
    required this.amount,
    required this.unit,
    required this.required,
    this.substitutes,
  });

  /// Deserializes from JSON via the generated factory.
  factory IngredientListItem.fromJson(Map<String, dynamic> json) => _$IngredientListItemFromJson(json);

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => _$IngredientListItemToJson(this);
}
