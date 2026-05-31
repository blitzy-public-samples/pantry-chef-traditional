import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/recipe/data/repositories/recipe.repository.dart';
import 'package:pantry_chef/features/recipe/domain/models/recipe.dart';
import 'package:pantry_chef/features/recipe/domain/repositories/recipe.repository.dart';

/// Use case resolving favorite recipe IDs into full [Recipe]s.
class GetFavoriteRecipeListUsecase implements UseCaseWithParams<List<Recipe>, List<String>> {
  /// Forwards [ids] to [RecipeRepositoryImpl] and returns a [Future]
  /// resolving to the matching [Recipe] list.
  @override
  Future<List<Recipe>> call(List<String> ids) async {
    RecipeRepository repo = RecipeRepositoryImpl();
    return repo.getFavoriteList(ids);
  }
}
