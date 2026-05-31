import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/recipe/data/dto/recipe_filters.dto.dart';
import 'package:pantry_chef/features/recipe/data/repositories/recipe.repository.dart';
import 'package:pantry_chef/features/recipe/domain/models/recipe.dart';
import 'package:pantry_chef/features/recipe/domain/repositories/recipe.repository.dart';

/// Use case wrapping `RecipeRepository.recipeMatching`.
///
/// Takes a `RecipeFiltersDto` and returns the server-sorted match list.
/// Dispatched from `RecipeBloc.RecipeMatching`, the default screen entry
/// point on `RecipeMain.initState`. The mobile use case is a thin wrapper;
/// the actual matching algorithm runs server-side at `/api/recipe/matches`
/// (see `ARCHITECTURE.md` § Recipe Matching Pipeline and
/// `backend/src/recipe/README.md`).
class RecipeMatchingUsecase implements UseCaseWithParams<List<Recipe>, RecipeFiltersDto> {
  /// Invokes `recipeMatching(filters)` on the repository implementation.
  ///
  /// The result is already sorted by `matchScore` descending on the server,
  /// so the use case performs no client-side reordering. Internally
  /// instantiates `RecipeRepositoryImpl` and delegates the request.
  @override
  Future<List<Recipe>> call(RecipeFiltersDto filters) {
    RecipeRepository repo = RecipeRepositoryImpl();
    return repo.recipeMatching(filters);
  }
}
