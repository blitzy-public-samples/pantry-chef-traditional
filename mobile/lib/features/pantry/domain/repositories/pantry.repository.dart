import 'package:pantry_chef/features/pantry/data/dto/index.dart';
import 'package:pantry_chef/features/pantry/domain/models/pantry_item.dart';

/// Domain persistence contract for the pantry feature.
///
/// Defines the asynchronous CRUD operations that every concrete pantry
/// repository implementation must provide. This abstraction is
/// implementation-agnostic: it returns the domain [PantryItem] model and
/// accepts data-layer DTOs ([CreatePantryItemDto], [UpdatePantryItemDto])
/// for write operations. The concrete implementation lives in the data
/// layer.
abstract class PantryRepository {
  /// Retrieves all pantry items.
  ///
  /// Returns a [List] of [PantryItem]. Takes no parameters.
  Future<List<PantryItem>> fetchPantryItems();

  /// Creates a pantry item from the given [dto].
  ///
  /// Returns the created [PantryItem].
  Future<PantryItem> createPantryItem(CreatePantryItemDto dto);

  /// Updates an existing pantry item from the given [dto].
  ///
  /// Returns the updated [PantryItem].
  Future<PantryItem> updatePantryItem(UpdatePantryItemDto dto);

  /// Deletes the pantry item identified by [id].
  Future<void> deletePantryItem(String id);
}
