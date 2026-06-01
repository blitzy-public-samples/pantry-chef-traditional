import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/recipe/data/repositories/recipe.repository.dart';
import 'package:pantry_chef/features/recipe/domain/models/recipe.dart';
import 'package:pantry_chef/features/recipe/domain/repositories/recipe.repository.dart';

/// Use case wrapping `RecipeRepository.getFavoriteList`.
///
/// Takes a list of recipe ids (sourced from `User.favoriteRecipes`,
/// documented in `DATA_MODEL.md` § User) and resolves them into full
/// `Recipe` objects. Typically dispatched from `ProfileBloc` when the
/// favorites tab is opened.
class GetFavoriteRecipeListUsecase implements UseCaseWithParams<List<Recipe>, List<String>> {
  /// Invokes `getFavoriteList(ids)` on the repository implementation.
  ///
  /// Internally instantiates `RecipeRepositoryImpl` and delegates the
  /// favorites lookup. The async signature mirrors the underlying API call.
  @override
  Future<List<Recipe>> call(List<String> ids) async {
    RecipeRepository repo = RecipeRepositoryImpl();
    return repo.getFavoriteList(ids);
  }
}
