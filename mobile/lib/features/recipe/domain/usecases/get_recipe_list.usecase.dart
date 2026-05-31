import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/recipe/data/repositories/recipe.repository.dart';
import 'package:pantry_chef/features/recipe/domain/models/recipe.dart';
import 'package:pantry_chef/features/recipe/domain/repositories/recipe.repository.dart';

/// Use case wrapping `RecipeRepository.getRecipeList`.
///
/// Resolved via the service locator and dispatched from
/// `RecipeBloc.RecipeListFetched`. Returns the full recipe collection
/// without parameters; pagination and filtering are not applied at this
/// layer.
class GetRecipeListUsecase implements UseCase<List<Recipe>> {
  /// Instantiates the repository implementation and invokes `getRecipeList`.
  ///
  /// The local `RecipeRepositoryImpl` instance is created on every call,
  /// reflecting the use case's stateless, side-effect-free design.
  @override
  Future<List<Recipe>> call() {
    RecipeRepository repo = RecipeRepositoryImpl();
    return repo.getRecipeList();
  }
}
