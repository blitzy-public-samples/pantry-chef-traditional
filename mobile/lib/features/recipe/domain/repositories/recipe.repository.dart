import 'package:pantry_chef/features/recipe/data/dto/index.dart';
import 'package:pantry_chef/features/recipe/domain/models/recipe.dart';

abstract class RecipeRepository {
  Future<List<Recipe>> getRecipeList();

  Future<List<Recipe>> getFavoriteList(List<String> ids);

  Future<List<Recipe>> recipeMatching(RecipeFiltersDto filters);

  Future<Recipe> getRecipeById(String id);

  // Added for "What Can I Make Tonight?" suggestions feature
  Future<RecipeSuggestionsResponseDto> getSuggestions(
    RecipeFiltersDto filters, {
    int page = 1,
    int limit = 10,
  });
}
