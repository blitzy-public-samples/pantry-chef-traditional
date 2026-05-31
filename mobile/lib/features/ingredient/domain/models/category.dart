import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

/// Lightweight reference data model representing an ingredient category.
///
/// Categories are server-defined constants fetched via `GET /api/v1/ingredient/creation-data`.
/// Currently 5 categories are hardcoded server-side: `spice`, `vegetable`, `fruit`, `dairy`,
/// `protein` (see `backend/src/ingridient/ingridient.controller.ts:L42-L72`, where the backend
/// uses the verbatim-preserved spelling `Ingridient` — spelling preserved verbatim from the
/// backend).
///
/// The [id] field is an `int` (sequential 1–5) because categories are hardcoded constants on
/// the backend, not persisted MongoDB documents — distinct from `Ingredient.id` which is a
/// MongoDB ObjectId hex string.
@JsonSerializable()
class Category {
  /// Server-defined integer identifier (sequential 1–5: 1=spice, 2=vegetable, etc.).
  final int id;

  /// Display name of the category (e.g., "spice", "vegetable", "fruit", "dairy", "protein").
  final String name;

  /// Creates a [Category] reference object.
  ///
  /// The constructor is `const` with two required named parameters: [id] and [name].
  const Category({
    required this.id,
    required this.name,
  });

  /// Deserializes a [Category] from a JSON map via the generated `_$CategoryFromJson`
  /// (in `category.g.dart`).
  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  /// Serializes this [Category] to a JSON map via the generated `_$CategoryToJson`
  /// (in `category.g.dart`).
  ///
  /// Also consumed by `Mappers.categoryToJson` for nested serialization in
  /// `Ingredient.category` and `CreateIngredientDto.category`
  /// (see `mobile/lib/core/utils/mappers.dart`).
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
