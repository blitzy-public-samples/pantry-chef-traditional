import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/core/utils/mappers.dart';
import 'package:pantry_chef/features/ingredient/domain/models/unit.dart';
import 'package:pantry_chef/features/ingredient/domain/models/category.dart';

part 'ingredient.g.dart';

/// Mobile-side ingredient model (correct spelling) used across the ingredient feature.
///
/// JSON-serializable via `@JsonSerializable()`; the generated code lives in
/// `ingredient.g.dart`.
///
/// Maps to the backend `Ingridient` schema (spelling preserved verbatim from the backend)
/// via JSON serialization. Custom `@JsonKey(toJson: ...)` annotations route the nested
/// `category` and `unit` fields through `Mappers.categoryToJson` and `Mappers.unitToJson`
/// (see `mobile/lib/core/utils/mappers.dart`).
///
/// Where the backend uses the verbatim-preserved typo `ingridient` (e.g.,
/// `PantryItem.ingridient`), the mobile mapper accepts it via `Ingredient.fromJson` without
/// renaming the class.
///
/// See `DATA_MODEL.md` at the repository root for the backend `Ingridient` schema reference.
@JsonSerializable()
class Ingredient {
  /// Server-assigned MongoDB document id (24-character hex string).
  final String id;

  /// Human-readable ingredient name (e.g., "Tomato", "Bell pepper").
  final String name;

  /// Reference to the ingredient's category, drawn from `IngredientAddData.categories`.
  ///
  /// `@JsonKey(toJson: Mappers.categoryToJson)` overrides the default `json_serializable`
  /// output so the embedded `Category` is serialized as a nested object via its own
  /// `toJson()` (see `mobile/lib/core/utils/mappers.dart`).
  @JsonKey(toJson: Mappers.categoryToJson)
  final Category category;

  /// AI confidence score for ingredient recognition, in the range 0.0–1.0.
  ///
  /// For manually-created ingredients, the value is hardcoded to `1` in
  /// `CreateIngredientDto.confidence` (see
  /// `mobile/lib/features/ingredient/data/dto/create_ingredient.dto.dart`).
  final double confidence;

  /// Server-set ISO-8601 timestamp; nullable for optimistic local instances that have
  /// not yet been persisted by the backend.
  final String? createdAt;

  /// Optional default quantity for this ingredient.
  final double? quantity;

  /// Reference to the ingredient's unit of measurement, drawn from `IngredientAddData.units`.
  ///
  /// `@JsonKey(toJson: Mappers.unitToJson)` overrides the default `json_serializable`
  /// output so the embedded `Unit` is serialized as a nested object via its own
  /// `toJson()` (see `mobile/lib/core/utils/mappers.dart`).
  @JsonKey(toJson: Mappers.unitToJson)
  final Unit unit;

  /// Optional CDN/storage URL for the ingredient's image.
  final String? imageUrl;

  /// Optional ISO-8601 expiration date (e.g., "2024-12-31").
  final String? expirationDate;

  /// Creates an [Ingredient] instance.
  ///
  /// The constructor is `const`, so instances can be used in const contexts.
  ///
  /// Required: [id], [name], [category], [confidence], [createdAt], [unit].
  /// Note: [createdAt] is typed `String?` but listed as required — the field is
  /// server-set and may legitimately be null on optimistic local objects.
  ///
  /// Optional: [quantity], [imageUrl], [expirationDate].
  const Ingredient({
    required this.id,
    required this.name,
    required this.category,
    required this.confidence,
    required this.createdAt,
    required this.unit,
    this.quantity,
    this.imageUrl,
    this.expirationDate,
  });

  /// Deserializes an [Ingredient] from a JSON map via the generated
  /// `_$IngredientFromJson` (in `ingredient.g.dart`).
  ///
  /// Used by the API layer (e.g., `IngredientRepositoryImpl.processImage`,
  /// `searchIngredient`, `createingredient`) to map backend responses.
  factory Ingredient.fromJson(Map<String, dynamic> json) => _$IngredientFromJson(json);

  /// Serializes this [Ingredient] to a JSON map via the generated
  /// `_$IngredientToJson` (in `ingredient.g.dart`).
  ///
  /// The nested [category] and [unit] fields are routed through `Mappers.categoryToJson`
  /// and `Mappers.unitToJson` (NOT the default code-generation output).
  Map<String, dynamic> toJson() => _$IngredientToJson(this);
}
