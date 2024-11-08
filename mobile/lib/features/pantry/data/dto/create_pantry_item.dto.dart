import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';

part 'create_pantry_item.dto.g.dart';

@JsonSerializable()
class CreatePantryItemDto {
  @JsonKey(toJson: _ingredientToJson)
  final Ingredient ingridient;
  final double quantity;
  final String unit;
  final String location;
  final String expirationDate;

  const CreatePantryItemDto({
    required this.ingridient,
    required this.quantity,
    required this.location,
    required this.unit,
    required this.expirationDate,
  });

  Map<String, dynamic> toJson() => _$CreatePantryItemDtoToJson(this);

  static Map<String, dynamic> _ingredientToJson(Ingredient item) => item.toJson();
}
