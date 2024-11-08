import 'package:pantry_chef/core/data/dto/index.dart';
import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/ingredient/data/repositories/ingredient.repository.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';
import 'package:pantry_chef/features/ingredient/domain/repositories/ingredient.repository.dart';

class SearchIngredientUsecase implements UseCaseWithParams<List<Ingredient>, SearchDto> {
  @override
  Future<List<Ingredient>> call(SearchDto dto) {
    IngredientRepository repo = IngredientRepositoryImpl();
    return repo.searchIngredient(dto);
  }
}
