import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/ingredient/data/repositories/ingredient.repository.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient_add_data.dart';
import 'package:pantry_chef/features/ingredient/domain/repositories/ingredient.repository.dart';

class GetIngredientCategoriesAndUnitsUsecase implements UseCase<IngredientAddData> {
  @override
  Future<IngredientAddData> call() {
    IngredientRepository repo = IngredientRepositoryImpl();
    return repo.getCategoriesAndUnits();
  }
}
