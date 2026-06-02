import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/pantry/data/repositories/pantry.repository.dart';
import 'package:pantry_chef/features/pantry/domain/repositories/pantry.repository.dart';

/// Use case that deletes a pantry item by its identifier.
///
/// Removes the pantry item with the given id by delegating to the
/// pantry repository's delete operation.
/// Implements `UseCaseWithParams<void, String>`.
class PantryItemDeleteUsecase implements UseCaseWithParams<void, String> {
  /// Deletes the pantry item identified by [id].
  ///
  /// Completes with no value (`Future<void>`) once the repository
  /// delete resolves.
  @override
  Future<void> call(String id) async {
    PantryRepository repo = PantryRepositoryImpl();
    await repo.deletePantryItem(id);
  }
}
