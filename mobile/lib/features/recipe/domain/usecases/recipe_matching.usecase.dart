import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/recipe/data/dto/recipe_filters.dto.dart';
import 'package:pantry_chef/features/recipe/data/repositories/recipe.repository.dart';
import 'package:pantry_chef/features/recipe/domain/models/recipe.dart';
import 'package:pantry_chef/features/recipe/domain/repositories/recipe.repository.dart';

/// Use case that requests filter-based recipe matching.
class RecipeMatchingUsecase implements UseCaseWithParams<List<Recipe>, RecipeFiltersDto> {
  /// Forwards [filters] to [RecipeRepositoryImpl] and returns a
  /// [Future] resolving to the matching [Recipe] list.
  @override
  Future<List<Recipe>> call(RecipeFiltersDto filters) {
    RecipeRepository repo = RecipeRepositoryImpl();
    return repo.recipeMatching(filters);
  }
}
