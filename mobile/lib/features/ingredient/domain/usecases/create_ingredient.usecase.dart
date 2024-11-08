import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/ingredient/data/dto/index.dart';
import 'package:pantry_chef/features/ingredient/data/repositories/ingredient.repository.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';
import 'package:pantry_chef/features/ingredient/domain/repositories/ingredient.repository.dart';

class CreateIngredientUsecase implements UseCaseWithParams<Ingredient, CreateIngredientDto> {
  @override
  Future<Ingredient> call(CreateIngredientDto dto) {
    IngredientRepository repo = IngredientRepositoryImpl();
    return repo.createingredient(dto);
  }
}
