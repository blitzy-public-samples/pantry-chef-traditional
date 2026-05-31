import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/recipe/data/repositories/recipe.repository.dart';
import 'package:pantry_chef/features/recipe/domain/models/recipe.dart';
import 'package:pantry_chef/features/recipe/domain/repositories/recipe.repository.dart';

/// Domain use case that retrieves the full recipe list.
///
/// A thin, stateless wrapper over the recipe [RecipeRepository].
class GetRecipeListUsecase implements UseCase<List<Recipe>> {
  /// Returns a [Future] resolving to the complete [Recipe] list.
  ///
  /// Instantiates [RecipeRepositoryImpl] locally (typed as the
  /// domain [RecipeRepository]) and delegates to `getRecipeList()`.
  @override
  Future<List<Recipe>> call() {
    RecipeRepository repo = RecipeRepositoryImpl();
    return repo.getRecipeList();
  }
}
