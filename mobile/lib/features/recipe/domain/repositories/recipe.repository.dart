import 'package:pantry_chef/features/recipe/data/dto/index.dart';
import 'package:pantry_chef/features/recipe/domain/models/recipe.dart';

/// Abstract contract for recipe data access.
///
/// Bound at composition time to `RecipeRepositoryImpl` in the `data/` layer.
/// Use cases depend on this contract, not on the concrete implementation.
abstract class RecipeRepository {
  /// Returns the paginated recipe list. Backend caps page size to 50.
  Future<List<Recipe>> getRecipeList();

  /// Returns recipes matching the provided list of ids; used to hydrate the user's favorites.
  Future<List<Recipe>> getFavoriteList(List<String> ids);

  /// Returns pantry-aware matches sorted by `matchScore` descending.
  ///
  /// Server applies four Mongo pre-filters and a per-recipe scoring loop
  /// (see `ARCHITECTURE.md` § Recipe Matching Pipeline).
  Future<List<Recipe>> recipeMatching(RecipeFiltersDto filters);

  /// Returns a single recipe by id.
  Future<Recipe> getRecipeById(String id);
}
