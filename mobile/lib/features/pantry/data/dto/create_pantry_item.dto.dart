import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';

part 'create_pantry_item.dto.g.dart';

/// JSON-serializable request payload for `POST /api/v1/pantry`.
///
/// Marked `@JsonSerializable()`; the generated `toJson` helper lives in
/// `create_pantry_item.dto.g.dart`. The embedded [Ingredient] field uses a
/// custom [_ingredientToJson] serializer (via `@JsonKey(toJson: ...)`) because
/// `json_serializable` does not automatically know how to serialize nested
/// model types.
///
/// Consumed by [PantryApi.createPantryItem] at
/// `mobile/lib/features/pantry/data/api/pantry.api.dart`.
@JsonSerializable()
class CreatePantryItemDto {
  /// The selected ingredient (field name `ingridient` preserved verbatim from
  /// the backend `PantryIngridient` schema — do not rename).
  ///
  /// Backend source:
  /// `backend/src/pantry/infrastructure/document/entities/pantryIngridient.schema.ts`
  /// (L18). Serialized via [_ingredientToJson] because `json_serializable` does
  /// not auto-serialize nested model types.
  @JsonKey(toJson: _ingredientToJson)
  final Ingredient ingridient;
  /// Quantity of the ingredient, expressed in [unit]s.
  final double quantity;
  /// Measurement unit (e.g., `'g'`, `'kg'`, `'ml'`, `'l'`, `'piece'`); mirrors
  /// the backend `Unit` reference name.
  final String unit;
  /// Storage location — one of `'fridge'`, `'freezer'`, or `'pantry'` (see
  /// `mobile/lib/core/constants/ingredient_location.dart`). Matches the backend
  /// `PantryIngridient.location` enum verbatim.
  final String location;
  /// Expiration date as a backend-formatted ISO 8601 string
  /// (e.g., `'2024-12-31T00:00:00.000Z'`).
  final String expirationDate;

  /// Constructs an immutable [CreatePantryItemDto] with all five fields
  /// required.
  ///
  /// `const` permits const instances, but in practice instances are built at
  /// request-construction time, so the const-ness is rarely exploited.
  const CreatePantryItemDto({
    required this.ingridient,
    required this.quantity,
    required this.location,
    required this.unit,
    required this.expirationDate,
  });

  /// Serializes this DTO to a `Map<String, dynamic>` via the generated
  /// `_$CreatePantryItemDtoToJson` helper.
  ///
  /// The generated helper invokes [_ingredientToJson] for the `ingridient`
  /// field per its `@JsonKey(toJson: ...)` annotation.
  Map<String, dynamic> toJson() => _$CreatePantryItemDtoToJson(this);

  /// Custom serializer for the [ingridient] field that delegates to the
  /// [Ingredient] model's own `toJson()`.
  ///
  /// Static so it can be referenced as a tear-off (`_ingredientToJson`) in the
  /// `@JsonKey(toJson: ...)` annotation. Required because `json_serializable`
  /// cannot auto-serialize nested model types.
  static Map<String, dynamic> _ingredientToJson(Ingredient item) => item.toJson();
}
