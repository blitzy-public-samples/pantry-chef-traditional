import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/features/ingredient/domain/models/category.dart';
import 'package:pantry_chef/features/ingredient/domain/models/unit.dart';

part 'ingredient_add_data.g.dart';

/// Aggregate of categories and units returned by `GET /api/v1/ingredient/creation-data`.
///
/// Used to populate the ingredient-add form's dropdown pickers (category picker, unit picker).
///
/// This class intentionally exposes only `fromJson` (no `toJson()`) because `IngredientAddData`
/// is consumed by the mobile client and never sent back to the backend. The `json_serializable`
/// generator emits a `toJson` only when requested via `@JsonSerializable(createToJson: true)`;
/// the current annotation uses defaults.
///
/// Generated code lives in `ingredient_add_data.g.dart` (out of documentation scope).
///
/// Source: `backend/src/ingridient/ingridient.controller.ts:L42-L72` returns this payload.
@JsonSerializable()
class IngredientAddData {
  /// The server-provided list of selectable ingredient categories.
  ///
  /// Currently 5 categories are hardcoded server-side (e.g., "spice", "vegetable",
  /// "fruit", "dairy", "protein") per `backend/src/ingridient/ingridient.controller.ts:L42-L72`.
  final List<Category> categories;

  /// The server-provided list of selectable measurement units.
  ///
  /// Currently 9 units are hardcoded server-side (kg, g, lb, oz, ml, l, cup, tbsp, tsp)
  /// per `backend/src/ingridient/ingridient.controller.ts:L42-L72`.
  final List<Unit> units;

  /// Creates an [IngredientAddData] aggregate.
  ///
  /// The constructor is `const` with two required named parameters: [categories] and [units].
  const IngredientAddData({
    required this.categories,
    required this.units,
  });

  /// Deserializes an [IngredientAddData] from the JSON response of
  /// `GET /api/v1/ingredient/creation-data`.
  ///
  /// Expected response shape: `{ "categories": [{id, name}], "units": [{id, name}] }`.
  /// Delegates to the generated `_$IngredientAddDataFromJson` in `ingredient_add_data.g.dart`.
  factory IngredientAddData.fromJson(Map<String, dynamic> json) => _$IngredientAddDataFromJson(json);
}
