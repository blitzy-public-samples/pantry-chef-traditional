import 'package:camera/camera.dart';
import 'package:pantry_chef/core/data/dto/index.dart';
import 'package:pantry_chef/features/ingredient/data/api/ingredient.api.dart';
import 'package:pantry_chef/features/ingredient/data/dto/index.dart';
import 'package:pantry_chef/features/ingredient/domain/models/category.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient_add_data.dart';
import 'package:pantry_chef/features/ingredient/domain/models/unit.dart';
import 'package:pantry_chef/features/ingredient/domain/repositories/ingredient.repository.dart';

class IngredientRepositoryImpl implements IngredientRepository {
  @override
  Future<IngredientAddData> getCategoriesAndUnits() async {
    IngredientApi api = IngredientApi();
    Map<String, dynamic> response = await api.getCategoriesAndUnits();
    List<dynamic> categories = response['categories'];
    List<dynamic> units = response['units'];
    return IngredientAddData(
      categories: categories.map((el) => Category.fromJson(el)).toList(),
      units: units.map((el) => Unit.fromJson(el)).toList(),
    );
  }

  @override
  Future<List<Ingredient>> searchIngredient(SearchDto dto) async {
    IngredientApi api = IngredientApi();
    List<dynamic> response = await api.searchIngredient(dto);
    return response.map((el) => Ingredient.fromJson(el)).toList();
  }

  @override
  Future<Ingredient> createingredient(CreateIngredientDto dto) async {
    IngredientApi api = IngredientApi();
    Map<String, dynamic> response = await api.createIngredient(dto);
    return Ingredient.fromJson(response);
  }

  @override
  Future<Ingredient> processImage(XFile image) async {
    IngredientApi api = IngredientApi();
    Map<String, dynamic> response = await api.processImage(image);
    return Ingredient.fromJson(response);
  }
}
