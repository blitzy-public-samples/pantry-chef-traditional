import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/features/ingredient/domain/models/unit.dart';
import 'package:pantry_chef/features/ingredient/domain/models/category.dart';
import 'package:pantry_chef/core/utils/mappers.dart';

part 'create_ingredient.dto.g.dart';

@JsonSerializable()
class CreateIngredientDto {
  final String name;
  @JsonKey(toJson: Mappers.categoryToJson)
  final Category category;
  final double quantity;
  @JsonKey(toJson: Mappers.unitToJson)
  final Unit unit;
  final String? imageUrl;
  final String? expirationDate;
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

  Map<String, dynamic> toJson() => _$CreateIngredientDtoToJson(this);
}
