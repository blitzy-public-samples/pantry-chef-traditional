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
/// Source: mobile/lib/features/ingredient/domain/models/ingredient.dart:L8-L20
@JsonSerializable()
class Ingredient {
  /// The unique ingredient identifier (`String`).
  /// Source: mobile/lib/features/ingredient/domain/models/ingredient.dart:L10
  final String id;
  /// The human-readable ingredient name.
  /// Source: mobile/lib/features/ingredient/domain/models/ingredient.dart:L11
  final String name;
  /// The ingredient's [Category]; serialized to JSON via
  /// `Mappers.categoryToJson`, which delegates to `Category.toJson()`.
  /// Source: mobile/lib/features/ingredient/domain/models/ingredient.dart:L12
  /// Source: mobile/lib/features/ingredient/domain/models/ingredient.dart:L13
  /// Source: mobile/lib/core/utils/mappers.dart:L11
  @JsonKey(toJson: Mappers.categoryToJson)
  final Category category;
  /// AI recognition confidence score in the range 0 to 1
  /// (1 = certain); applies to camera/AI-detected ingredients.
  /// Source: mobile/lib/features/ingredient/domain/models/ingredient.dart:L14
  final double confidence;
  /// Optional creation timestamp as an ISO string (nullable).
  /// Source: mobile/lib/features/ingredient/domain/models/ingredient.dart:L15
  final String? createdAt;
  /// Optional numeric quantity for the ingredient (nullable).
  /// Source: mobile/lib/features/ingredient/domain/models/ingredient.dart:L16
  final double? quantity;
  /// The measurement [Unit]; serialized to JSON via
  /// `Mappers.unitToJson`, which delegates to `Unit.toJson()`.
  /// Source: mobile/lib/features/ingredient/domain/models/ingredient.dart:L17
  /// Source: mobile/lib/features/ingredient/domain/models/ingredient.dart:L18
  /// Source: mobile/lib/core/utils/mappers.dart:L13
  @JsonKey(toJson: Mappers.unitToJson)
  final Unit unit;
  /// Optional image URL for the ingredient (nullable).
  /// Source: mobile/lib/features/ingredient/domain/models/ingredient.dart:L19
  final String? imageUrl;
  /// Optional expiration date as a string (nullable).
  /// Source: mobile/lib/features/ingredient/domain/models/ingredient.dart:L20
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
  /// Source: mobile/lib/features/ingredient/domain/models/ingredient.dart:L34
  factory Ingredient.fromJson(Map<String, dynamic> json) => _$IngredientFromJson(json);

  /// Serializes this [Ingredient] to a JSON map via the generated
  /// `_$IngredientToJson`, routing the nested `category` and `unit`
  /// through `Mappers`.
  /// Source: mobile/lib/features/ingredient/domain/models/ingredient.dart:L36
  /// Source: mobile/lib/core/utils/mappers.dart:L11,L13
  Map<String, dynamic> toJson() => _$IngredientToJson(this);
}
