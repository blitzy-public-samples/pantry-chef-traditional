import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/features/ingredient/domain/models/unit.dart';
import 'package:pantry_chef/features/ingredient/domain/models/category.dart';
import 'package:pantry_chef/core/utils/mappers.dart';

part 'create_ingredient.dto.g.dart';

/// Outbound request DTO for creating an ingredient via the data layer.
///
/// Immutable value object built with a `const` constructor and annotated
/// `@JsonSerializable()`; JSON output comes from the generated companion
/// part file 'create_ingredient.dto.g.dart'. Serialization only: this
/// payload provides `toJson` and intentionally has no `fromJson`.
@JsonSerializable()
class CreateIngredientDto {
  /// Display name of the ingredient.
  final String name;
  /// Owning category; serialized via [Mappers.categoryToJson].
  @JsonKey(toJson: Mappers.categoryToJson)
  final Category category;
  /// Amount (quantity) of the ingredient.
  final double quantity;
  /// Measurement unit; serialized via [Mappers.unitToJson].
  @JsonKey(toJson: Mappers.unitToJson)
  final Unit unit;
  /// Optional image URL for the ingredient (nullable).
  final String? imageUrl;
  /// Optional expiration date string (nullable).
  final String? expirationDate;
  /// Recognition confidence in range 0-1; defaults to 1.
  final double confidence;

  const CreateIngredientDto({
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    this.imageUrl,
    this.expirationDate,
    this.confidence = 1,
  });

  /// Serializes this DTO to a JSON map for outbound API requests.
  /// Delegates to the generated _$CreateIngredientDtoToJson(this).
  Map<String, dynamic> toJson() => _$CreateIngredientDtoToJson(this);
}
