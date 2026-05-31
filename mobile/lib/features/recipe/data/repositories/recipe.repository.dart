import 'package:pantry_chef/features/recipe/data/api/recipe.api.dart';
import 'package:pantry_chef/features/recipe/data/dto/index.dart';
import 'package:pantry_chef/features/recipe/domain/models/recipe.dart';
import 'package:pantry_chef/features/recipe/domain/repositories/recipe.repository.dart';

/// Concrete data-layer implementation of the domain [RecipeRepository]
/// contract for the recipe feature.
///
/// Adapts raw API payloads returned by [RecipeApi] into domain [Recipe]
/// objects via `Recipe.fromJson`. Stateless: each method constructs a
/// fresh [RecipeApi] instance per call and holds no cached state.
class RecipeRepositoryImpl implements RecipeRepository {
  /// Fetches the full recipe list via [RecipeApi.getRecipeList] and maps
  /// each element to a [Recipe] with `Recipe.fromJson`.
  @override
  Future<List<Recipe>> getRecipeList() async {
    // Construct a fresh API client and map the payload to domain models.
    RecipeApi api = RecipeApi();
    List<dynamic> response = await api.getRecipeList();
    return response.map((el) => Recipe.fromJson(el)).toList();
  }

  /// Fetches favorite recipes for the given [ids] and maps the list to
  /// [Recipe] instances via `Recipe.fromJson`.
  @override
  Future<List<Recipe>> getFavoriteList(List<String> ids) async {
    RecipeApi api = RecipeApi();
    List<dynamic> response = await api.getFavoriteList(ids);
    return response.map((el) => Recipe.fromJson(el)).toList();
  }

  /// Runs the matching query with the given [filters] and maps the
  /// results to [Recipe] instances via `Recipe.fromJson`.
  @override
  Future<List<Recipe>> recipeMatching(RecipeFiltersDto filters) async {
    RecipeApi api = RecipeApi();
    List<dynamic> response = await api.recipeMatching(filters);
    return response.map((el) => Recipe.fromJson(el)).toList();
  }

  /// Fetches a single recipe by [id] and returns it via `Recipe.fromJson`.
  @override
  Future<Recipe> getRecipeById(String id) async {
    RecipeApi api = RecipeApi();
    Map<String, dynamic> response = await api.getRecipeById(id);
    return Recipe.fromJson(response);
  }
}
