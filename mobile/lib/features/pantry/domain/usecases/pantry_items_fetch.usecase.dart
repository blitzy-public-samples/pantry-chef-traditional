import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/pantry/data/repositories/pantry.repository.dart';
import 'package:pantry_chef/features/pantry/domain/models/pantry_item.dart';
import 'package:pantry_chef/features/pantry/domain/repositories/pantry.repository.dart';

/// Use case that fetches all pantry items.
///
/// A parameterless query that returns the current pantry inventory
/// by delegating to the pantry repository's fetch operation.
/// Implements `UseCase<List<PantryItem>>`.
class FetchPantryItemsUsecase implements UseCase<List<PantryItem>> {
  /// Returns the list of all `PantryItem`s from the repository.
  @override
  Future<List<PantryItem>> call() {
    PantryRepository repo = PantryRepositoryImpl();
    return repo.fetchPantryItems();
  }
}
