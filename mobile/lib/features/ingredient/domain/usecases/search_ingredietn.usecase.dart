import 'package:pantry_chef/core/data/dto/index.dart';
import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/ingredient/data/repositories/ingredient.repository.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';
import 'package:pantry_chef/features/ingredient/domain/repositories/ingredient.repository.dart';

// KNOWN ISSUE: the file name 'search_ingredietn.usecase.dart' is a
// preserved, intentional misspelling and a stable identifier;
// document it, do NOT rename. The class 'SearchIngredientUsecase'
// below is spelled correctly.
/// Domain use case that searches ingredients by the criteria in a
/// [SearchDto] and returns the matching list of [Ingredient].
///
/// Implements [UseCaseWithParams] (params: [SearchDto], result:
/// List of [Ingredient]).
/// Source: core/utils/usercase.dart:L5
class SearchIngredientUsecase implements UseCaseWithParams<List<Ingredient>, SearchDto> {
  /// Searches ingredients matching [dto] and returns the resulting
  /// list of [Ingredient].
  @override
  Future<List<Ingredient>> call(SearchDto dto) {
    // Resolve the concrete repository behind the IngredientRepository
    // contract (stateless; a fresh impl per call).
    IngredientRepository repo = IngredientRepositoryImpl();
    // Delegate to the repository's searchIngredient query.
    return repo.searchIngredient(dto);
  }
}
