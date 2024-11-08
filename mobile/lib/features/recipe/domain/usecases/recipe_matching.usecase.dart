import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/recipe/data/dto/recipe_filters.dto.dart';
import 'package:pantry_chef/features/recipe/data/repositories/recipe.repository.dart';
import 'package:pantry_chef/features/recipe/domain/models/recipe.dart';
import 'package:pantry_chef/features/recipe/domain/repositories/recipe.repository.dart';

class RecipeMatchingUsecase implements UseCaseWithParams<List<Recipe>, RecipeFiltersDto> {
  @override
  Future<List<Recipe>> call(RecipeFiltersDto filters) {
    RecipeRepository repo = RecipeRepositoryImpl();
    return repo.recipeMatching(filters);
  }
}
