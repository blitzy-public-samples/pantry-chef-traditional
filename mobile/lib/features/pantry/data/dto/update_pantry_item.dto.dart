import 'package:json_annotation/json_annotation.dart';

part 'update_pantry_item.dto.g.dart';

/// Immutable `@JsonSerializable` request payload for updating a pantry
/// item (`PATCH /api/pantry/:id`).
@JsonSerializable()
class UpdatePantryItemDto {
  /// Target pantry item id; also used to build the PATCH path.
  final String id;
  /// The storage location.
  final String location;
  /// The quantity amount.
  final double quantity;
  /// The expiration date (string).
  final String expirationDate;

  const UpdatePantryItemDto({
    required this.id,
    required this.quantity,
    required this.location,
    required this.expirationDate,
  });

  /// Returns a `Map<String, dynamic>`, delegating to the generated
  /// `_$UpdatePantryItemDtoToJson`.
  Map<String, dynamic> toJson() => _$UpdatePantryItemDtoToJson(this);
}
