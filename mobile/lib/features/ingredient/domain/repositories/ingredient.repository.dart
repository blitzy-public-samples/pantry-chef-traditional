import 'package:camera/camera.dart';
import 'package:pantry_chef/core/data/dto/index.dart';
import 'package:pantry_chef/features/ingredient/data/dto/index.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient_add_data.dart';

abstract class IngredientRepository {
  Future<IngredientAddData> getCategoriesAndUnits();

  Future<List<Ingredient>> searchIngredient(SearchDto dto);

  Future<Ingredient> createingredient(CreateIngredientDto dto);

  Future<Ingredient> processImage(XFile image);
}
