// NOTE: Filename 'search_ingredietn.usecase.dart' preserved verbatim (typo 'ingredietn' retained).
import 'package:pantry_chef/core/data/dto/index.dart';
import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/ingredient/data/repositories/ingredient.repository.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';
import 'package:pantry_chef/features/ingredient/domain/repositories/ingredient.repository.dart';

/// Domain use case that runs a paginated, query-driven ingredient search.
///
/// Implements [UseCaseWithParams]`<List<Ingredient>, SearchDto>` from
/// `package:pantry_chef/core/utils/usercase.dart` (the `usercase` file name
/// carries a verbatim-preserved typo and must not be renamed).
///
/// The class name [SearchIngredientUsecase] is spelled correctly; only the
/// enclosing file `search_ingredietn.usecase.dart` carries the preserved typo
/// `ingredietn`. That file name is a stable contract: renaming it would break
/// the barrel export at `usecases/index.dart`.
///
/// Every call constructs a fresh [IngredientRepositoryImpl] (no dependency
/// injection, no caching) and delegates to
/// [IngredientRepository.searchIngredient], which targets the backend
/// ingredient collection route `GET /api/v1/ingredient` (the
/// `Endpoints.ingredient` constant) with [SearchDto] fields sent as Dio
/// query parameters.
class SearchIngredientUsecase implements UseCaseWithParams<List<Ingredient>, SearchDto> {
  /// Executes a paginated search for [dto] and resolves to the matches.
  ///
  /// [dto] is a [SearchDto] carrying the required `query` ([String]), `page`
  /// ([int] page cursor) and `limit` ([int]) fields, plus an optional
  /// `List<OrderDto>?` `sort`. The optional sort is serialized through the
  /// `Mappers.orderToJson` converter declared on [SearchDto] (see
  /// `core/data/dto/search.dto.dart`) before the DTO is sent as query params.
  ///
  /// Returns a [Future] resolving to a `List<Ingredient>`: an empty list when
  /// nothing matches; the result is never null.
  ///
  /// A fresh [IngredientRepositoryImpl] is instantiated on each call (no DI,
  /// no caching), mirroring the per-call pattern noted on the class.
  @override
  Future<List<Ingredient>> call(SearchDto dto) {
    IngredientRepository repo = IngredientRepositoryImpl();
    return repo.searchIngredient(dto);
  }
}
