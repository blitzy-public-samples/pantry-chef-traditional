import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';

part 'pantry_item.g.dart';

@JsonSerializable()
class PantryItem {
  final String id;
  final Ingredient ingridient;
  final double quantity;
  final String location;
  final String createdAt;
  final String updatedAt;
  final String expirationDate;

  const PantryItem({
    required this.id,
    required this.ingridient,
    required this.quantity,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
    required this.expirationDate,
  });

  factory PantryItem.fromJson(Map<String, dynamic> json) => _$PantryItemFromJson(json);

  Map<String, dynamic> toJson() => _$PantryItemToJson(this);
}
