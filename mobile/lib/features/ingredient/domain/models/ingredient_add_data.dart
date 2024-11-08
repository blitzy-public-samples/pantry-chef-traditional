import 'package:json_annotation/json_annotation.dart';
import 'package:pantry_chef/features/ingredient/domain/models/category.dart';
import 'package:pantry_chef/features/ingredient/domain/models/unit.dart';

part 'ingredient_add_data.g.dart';

@JsonSerializable()
class IngredientAddData {
  final List<Category> categories;
  final List<Unit> units;

  const IngredientAddData({
    required this.categories,
    required this.units,
  });

  factory IngredientAddData.fromJson(Map<String, dynamic> json) => _$IngredientAddDataFromJson(json);
}
