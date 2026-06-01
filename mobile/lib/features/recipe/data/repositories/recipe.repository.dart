import 'package:pantry_chef/features/recipe/data/api/recipe.api.dart';
import 'package:pantry_chef/features/recipe/data/dto/index.dart';
import 'package:pantry_chef/features/recipe/domain/models/recipe.dart';
import 'package:pantry_chef/features/recipe/domain/repositories/recipe.repository.dart';

/// Concrete `RecipeRepository` implementation that adapts `RecipeApi` payloads
/// into domain `Recipe` instances via `Recipe.fromJson`.
///
/// Each method instantiates its own `RecipeApi` rather than receiving one
/// through dependency injection. A production refactor should resolve the
/// API client through the `getIt` service locator instead so that tests can
/// substitute a fake — see
/// [PRODUCTION_READINESS.md](../../../../../../PRODUCTION_READINESS.md).
class RecipeRepositoryImpl implements RecipeRepository {
  /// Returns the full recipe list from `GET /api/recipe`, mapping each
  /// element via `Recipe.fromJson`.
  ///
  /// The backend silently caps the page size at 50 regardless of the requested
  /// `limit` (see `mobile/lib/features/recipe/README.md` § API / Endpoint
  /// Reference). Throws whatever `DioException` the underlying client raises.
  @override
  Future<List<Recipe>> getRecipeList() async {
    RecipeApi api = RecipeApi();
    List<dynamic> response = await api.getRecipeList();
    return response.map((el) => Recipe.fromJson(el)).toList();
  }

  /// Resolves the given recipe `ids` into full `Recipe` instances via
  /// `GET /api/recipe` with a `QueryRecipeDto(ids: ids)` query parameter.
  ///
  /// Used by the favorites flow in `ProfileBloc` to hydrate the user's saved
  /// recipe ids stored on the `User.favoriteRecipes` array (see
  /// [DATA_MODEL.md](../../../../../../DATA_MODEL.md) § User).
  @override
  Future<List<Recipe>> getFavoriteList(List<String> ids) async {
    RecipeApi api = RecipeApi();
    List<dynamic> response = await api.getFavoriteList(ids);
    return response.map((el) => Recipe.fromJson(el)).toList();
  }

  /// Returns pantry-aware recipe matches by calling
  /// `RecipeApi.recipeMatching(filters)` and mapping each element via
  /// `Recipe.fromJson`.
  ///
  /// The returned list is already sorted server-side by `matchScore`
  /// descending. The full server-side algorithm — four Mongo pre-filters,
  /// per-recipe scoring loop, `isQuickMake`/`isAlmostThere` derivation — is
  /// documented in
  /// [ARCHITECTURE.md](../../../../../../ARCHITECTURE.md) § Recipe Matching
  /// Pipeline.
  @override
  Future<List<Recipe>> recipeMatching(RecipeFiltersDto filters) async {
    RecipeApi api = RecipeApi();
    List<dynamic> response = await api.recipeMatching(filters);
    return response.map((el) => Recipe.fromJson(el)).toList();
  }

  /// Fetches a single recipe by id via `GET /api/recipe/:id` and
  /// deserializes the response with `Recipe.fromJson`.
  ///
  /// Throws a `DioException` on 404 or other HTTP errors; callers should
  /// handle network failures defensively.
  @override
  Future<Recipe> getRecipeById(String id) async {
    RecipeApi api = RecipeApi();
    Map<String, dynamic> response = await api.getRecipeById(id);
    return Recipe.fromJson(response);
  }
}
