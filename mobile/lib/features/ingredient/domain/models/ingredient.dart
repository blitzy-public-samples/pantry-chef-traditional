import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/core/utils/mappers.dart';
import 'package:pantry_chef/features/ingredient/domain/models/unit.dart';
import 'package:pantry_chef/features/ingredient/domain/models/category.dart';

part 'ingredient.g.dart';

/// Central, immutable ingredient record for the ingredient feature.
///
/// A `@JsonSerializable()` value object that carries identity, naming,
/// nested [Category] and [Unit] references, recognition confidence, and
/// optional pantry metadata (quantity, image, and expiration).
///
/// The nested `category` and `unit` are serialized through `Mappers`
/// (`Mappers.categoryToJson` / `Mappers.unitToJson`).
///
@JsonSerializable()
class Ingredient {
  /// The unique ingredient identifier (`String`).
  final String id;
  /// The human-readable ingredient name.
  final String name;
  /// The ingredient's [Category]; serialized to JSON via
  /// `Mappers.categoryToJson`, which delegates to `Category.toJson()`.
  /// Source: mobile/lib/core/utils/mappers.dart:L18
  @JsonKey(toJson: Mappers.categoryToJson)
  final Category category;
  /// AI recognition confidence score in the range 0 to 1
  /// (1 = certain); applies to camera/AI-detected ingredients.
  final double confidence;
  /// Optional creation timestamp as an ISO string (nullable).
  final String? createdAt;
  /// Optional numeric quantity for the ingredient (nullable).
  final double? quantity;
  /// The measurement [Unit]; serialized to JSON via
  /// `Mappers.unitToJson`, which delegates to `Unit.toJson()`.
  /// Source: mobile/lib/core/utils/mappers.dart:L22
  @JsonKey(toJson: Mappers.unitToJson)
  final Unit unit;
  /// Optional image URL for the ingredient (nullable).
  final String? imageUrl;
  /// Optional expiration date as a string (nullable).
  final String? expirationDate;

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

  /// Builds an [Ingredient] from the decoded [json] map by delegating
  /// to the generated `_$IngredientFromJson`.
  factory Ingredient.fromJson(Map<String, dynamic> json) => _$IngredientFromJson(json);

  /// Serializes this [Ingredient] to a JSON map via the generated
  /// `_$IngredientToJson`, routing the nested `category` and `unit`
  /// through `Mappers`.
  /// Source: mobile/lib/core/utils/mappers.dart:L18,L22
  Map<String, dynamic> toJson() => _$IngredientToJson(this);
}
