import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';

part 'create_pantry_item.dto.g.dart';

/// Immutable `@JsonSerializable` request payload for creating a pantry
/// item (`POST /api/pantry`); serialized to JSON via generated code.
@JsonSerializable()
class CreatePantryItemDto {
  /// Nested ingredient (field is misspelled `ingridient`, sic — a stable
  /// identifier; never rename). Serialized via the custom
  /// `_ingredientToJson` (see the `@JsonKey(toJson: ...)` below).
  @JsonKey(toJson: _ingredientToJson)
  final Ingredient ingridient;
  /// The quantity amount.
  final double quantity;
  /// The unit of measure.
  final String unit;
  /// The storage location.
  final String location;
  /// The expiration date (string).
  final String expirationDate;

  const CreatePantryItemDto({
    required this.ingridient,
    required this.quantity,
    required this.location,
    required this.unit,
    required this.expirationDate,
  });

  /// Returns a `Map<String, dynamic>`, delegating to the generated
  /// `_$CreatePantryItemDtoToJson`.
  Map<String, dynamic> toJson() => _$CreatePantryItemDtoToJson(this);

  // Private static serializer: serializes the nested `item` by
  // delegating to `Ingredient.toJson()` so the ingredient follows
  // its own JSON contract.
  static Map<String, dynamic> _ingredientToJson(Ingredient item) => item.toJson();
}
