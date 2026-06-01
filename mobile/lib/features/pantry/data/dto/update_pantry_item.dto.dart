import 'package:json_annotation/json_annotation.dart';

part 'update_pantry_item.dto.g.dart';

/// JSON-serializable request payload for `PATCH /api/pantry/:id`.
///
/// Carries the target [id] together with the mutable fields ([location],
/// [quantity], and [expirationDate]). Unlike [CreatePantryItemDto], this DTO
/// deliberately omits an `ingridient` field (spelling preserved verbatim from
/// the backend `PantryIngridient` schema) — once a pantry item is created, its
/// embedded ingredient reference is immutable from the client side.
///
/// Marked `@JsonSerializable()`; the generated `toJson` helper lives in
/// `update_pantry_item.dto.g.dart`. Consumed by [PantryApi.updatePantryItem]
/// at `mobile/lib/features/pantry/data/api/pantry.api.dart`.
@JsonSerializable()
class UpdatePantryItemDto {
  /// Server-assigned identifier of the pantry item to update.
  ///
  /// Used by [PantryApi.updatePantryItem] to build the `:id` URL segment
  /// (see `mobile/lib/features/pantry/data/api/pantry.api.dart`).
  final String id;
  /// Updated storage location — one of `'fridge'`, `'freezer'`, or `'pantry'`
  /// (see `mobile/lib/core/constants/ingredient_location.dart`). Matches the
  /// backend `PantryIngridient.location` enum verbatim.
  final String location;
  /// Updated quantity of the ingredient, expressed in the existing unit.
  ///
  /// The unit itself is not mutable through this DTO — `unit` is a create-only
  /// field on [CreatePantryItemDto].
  final double quantity;
  /// Updated expiration date as a backend-formatted ISO 8601 string
  /// (e.g., `'2024-12-31T00:00:00.000Z'`).
  final String expirationDate;

  /// Constructs an immutable [UpdatePantryItemDto] with all four fields
  /// required.
  const UpdatePantryItemDto({
    required this.id,
    required this.quantity,
    required this.location,
    required this.expirationDate,
  });

  /// Serializes this DTO to a `Map<String, dynamic>` via the generated
  /// `_$UpdatePantryItemDtoToJson` helper.
  ///
  /// Produces a simpler JSON shape than [CreatePantryItemDto.toJson] (no nested
  /// ingredient — all four fields are primitives).
  Map<String, dynamic> toJson() => _$UpdatePantryItemDtoToJson(this);
}
