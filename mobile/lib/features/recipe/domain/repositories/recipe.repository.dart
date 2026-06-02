import 'package:pantry_chef/features/recipe/data/dto/index.dart';
import 'package:pantry_chef/features/recipe/domain/models/recipe.dart';

/// Domain-layer repository contract for the recipe feature.
///
/// Declares the implementation-agnostic interface that data-layer
/// implementations (for example, `RecipeRepositoryImpl` in
/// `recipe/data/repositories/`) must satisfy, enabling dependency
/// inversion between the domain and data layers. Purely declarative:
/// it has no fields, constructors, or method bodies.
///
/// Distinct from the concrete `RecipeRepositoryImpl` of the same file
/// name that lives in the data layer.
abstract class RecipeRepository {
  /// Retrieves the complete recipe collection.
  Future<List<Recipe>> getRecipeList();

  /// Resolves the favorite recipe identifiers in [ids] into full
  /// [Recipe] objects.
  Future<List<Recipe>> getFavoriteList(List<String> ids);

  /// Returns recipes matching the criteria in [filters], a
  /// [RecipeFiltersDto].
  Future<List<Recipe>> recipeMatching(RecipeFiltersDto filters);

  /// Loads the single recipe identified by [id].
  Future<Recipe> getRecipeById(String id);
}
