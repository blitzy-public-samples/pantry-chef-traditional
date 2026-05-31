import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/profile/data/dto/favorite_recipes_update.dto.dart';
import 'package:pantry_chef/features/profile/data/repositories/profile.repositiry.dart';
import 'package:pantry_chef/features/profile/domain/repositories/profile.repository.dart';
import 'package:pantry_chef/features/recipe/data/repositories/recipe.repository.dart';
import 'package:pantry_chef/features/recipe/domain/models/recipe.dart';
import 'package:pantry_chef/features/recipe/domain/repositories/recipe.repository.dart';

/// Use case that updates the persisted favorite recipes list and
/// optionally returns the newly added [Recipe].
///
/// Implements [UseCaseWithParams], taking a `FavoriteRecipesUpdateDto`
/// and returning the added `Recipe?` (or `null` when none was added).
class FavoriteRecipesUpdateUsecase implements UseCaseWithParams<Recipe?, FavoriteRecipesUpdateDto> {
  /// Updates favorites from [dto], then conditionally fetches the recipe.
  ///
  /// Persists [dto].favoriteList through the profile repository, then
  /// only when [dto].addedId is non-null loads that recipe and returns
  /// it; otherwise returns `null`.
  @override
  Future<Recipe?> call(FavoriteRecipesUpdateDto dto) async {
    // Bind the misspelled impl to the correct interface type.
    ProfileRepository profileRepo = ProfileRepositiryImpl();
    // Persist the updated favorites id list.
    await profileRepo.updateFavoriteRecipesList(dto.favoriteList);
    // Recipe repository used to resolve the newly added recipe.
    RecipeRepository recipeRepo = RecipeRepositoryImpl();
    Recipe? addedRecipe;
    // Only fetch when an added id is present; null means none added.
    if (dto.addedId != null) {
      // Non-null assertion is guarded by the null check above.
      addedRecipe = await recipeRepo.getRecipeById(dto.addedId!);
    }
    // Returns the fetched recipe, or null when nothing was added.
    return addedRecipe;
  }
}
