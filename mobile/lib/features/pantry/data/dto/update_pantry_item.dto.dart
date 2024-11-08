import 'package:json_annotation/json_annotation.dart';

part 'update_pantry_item.dto.g.dart';

@JsonSerializable()
class UpdatePantryItemDto {
  final String id;
  final String location;
  final double quantity;
  final String expirationDate;

  const UpdatePantryItemDto({
    required this.id,
    required this.quantity,
    required this.location,
    required this.expirationDate,
  });

  Map<String, dynamic> toJson() => _$UpdatePantryItemDtoToJson(this);
}
