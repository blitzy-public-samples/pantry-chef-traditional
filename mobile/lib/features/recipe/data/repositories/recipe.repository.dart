import 'package:pantry_chef/features/recipe/data/api/recipe.api.dart';
import 'package:pantry_chef/features/recipe/data/dto/index.dart';
import 'package:pantry_chef/features/recipe/domain/models/recipe.dart';
import 'package:pantry_chef/features/recipe/domain/repositories/recipe.repository.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  @override
  Future<List<Recipe>> getRecipeList() async {
    RecipeApi api = RecipeApi();
    List<dynamic> response = await api.getRecipeList();
    return response.map((el) => Recipe.fromJson(el)).toList();
  }

  @override
  Future<List<Recipe>> getFavoriteList(List<String> ids) async {
    RecipeApi api = RecipeApi();
    List<dynamic> response = await api.getFavoriteList(ids);
    return response.map((el) => Recipe.fromJson(el)).toList();
  }

  @override
  Future<List<Recipe>> recipeMatching(RecipeFiltersDto filters) async {
    RecipeApi api = RecipeApi();
    List<dynamic> response = await api.recipeMatching(filters);
    return response.map((el) => Recipe.fromJson(el)).toList();
  }

  @override
  Future<Recipe> getRecipeById(String id) async {
    RecipeApi api = RecipeApi();
    Map<String, dynamic> response = await api.getRecipeById(id);
    return Recipe.fromJson(response);
  }

  @override
  // Added for "What Can I Make Tonight?" suggestions feature
  Future<RecipeSuggestionsResponseDto> getSuggestions(
    RecipeFiltersDto filters, {
    int page = 1,
    int limit = 10,
  }) async {
    RecipeApi api = RecipeApi();
    final response = await api.getSuggestions(filters, page: page, limit: limit);
    return RecipeSuggestionsResponseDto.fromJson(response);
  }
}
