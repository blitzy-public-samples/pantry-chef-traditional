import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/ingredient/data/dto/index.dart';
import 'package:pantry_chef/features/ingredient/data/repositories/ingredient.repository.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';
import 'package:pantry_chef/features/ingredient/domain/repositories/ingredient.repository.dart';

/// Domain use case for persisting a new ingredient.
///
/// Implements [UseCaseWithParams]`<Ingredient, CreateIngredientDto>` from
/// `package:pantry_chef/core/utils/usercase.dart` (the `usercase` file name
/// carries a verbatim-preserved typo and must not be renamed). The class name
/// [CreateIngredientUsecase] itself is spelled correctly — the only typos in
/// scope are the `usercase` dependency file name and the `createingredient`
/// repository method (lowercase `i`, see below).
///
/// Persists a new ingredient by delegating to
/// [IngredientRepository.createingredient] through a per-call
/// `IngredientRepositoryImpl()` instantiation — no GetIt, no caching —
/// matching the convention across all sibling use cases in this folder.
///
/// `createingredient` is preserved verbatim from
/// `mobile/lib/features/ingredient/domain/repositories/ingredient.repository.dart:L12`;
/// do not rename.
class CreateIngredientUsecase implements UseCaseWithParams<Ingredient, CreateIngredientDto> {
  /// Persists a new ingredient via the repository layer.
  ///
  /// The [dto] carries the ingredient payload: `name`, `category`, `quantity`,
  /// `unit`, optional `imageUrl`, optional `expirationDate`, and `confidence`
  /// (default `1`). The parameter is named `dto` (not the parent contract's
  /// `params` in [UseCaseWithParams.call]); the override deliberately keeps
  /// `dto`, and it must not be renamed.
  ///
  /// Returns a [Future] resolving to the persisted [Ingredient] with the
  /// server-assigned `id` and `createdAt` populated.
  ///
  /// Delegates to [IngredientRepository.createingredient] — the lowercase `i`
  /// in `createingredient` is preserved verbatim from the original codebase
  /// (see
  /// `mobile/lib/features/ingredient/domain/repositories/ingredient.repository.dart:L12`);
  /// do not rename. The concrete `IngredientRepositoryImpl` issues
  /// `POST /api/v1/ingredient` via Dio.
  @override
  Future<Ingredient> call(CreateIngredientDto dto) {
    IngredientRepository repo = IngredientRepositoryImpl();
    return repo.createingredient(dto);
  }
}
