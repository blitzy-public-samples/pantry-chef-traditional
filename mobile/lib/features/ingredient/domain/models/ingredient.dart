import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/core/utils/mappers.dart';
import 'package:pantry_chef/features/ingredient/domain/models/unit.dart';
import 'package:pantry_chef/features/ingredient/domain/models/category.dart';

part 'ingredient.g.dart';

@JsonSerializable()
class Ingredient {
  final String id;
  final String name;
  @JsonKey(toJson: Mappers.categoryToJson)
  final Category category;
  final double confidence;
  final String? createdAt;
  final double? quantity;
  @JsonKey(toJson: Mappers.unitToJson)
  final Unit unit;
  final String? imageUrl;
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

  factory Ingredient.fromJson(Map<String, dynamic> json) => _$IngredientFromJson(json);

  Map<String, dynamic> toJson() => _$IngredientToJson(this);
}
