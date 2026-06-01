import 'package:pantry_chef/features/pantry/data/api/pantry.api.dart';
import 'package:pantry_chef/features/pantry/data/dto/index.dart';
import 'package:pantry_chef/features/pantry/domain/models/pantry_item.dart';
import 'package:pantry_chef/features/pantry/domain/repositories/pantry.repository.dart';

/// Concrete data-layer implementation of the domain [PantryRepository]
/// contract.
///
/// Adapts [PantryApi] JSON responses into [PantryItem] domain models.
/// This class is stateless and holds no fields; it constructs a fresh
/// [PantryApi] instance on every call.
class PantryRepositoryImpl implements PantryRepository {
  /// Creates a pantry item from the given [dto].
  ///
  /// Delegates to [PantryApi.createPantryItem], then maps the returned
  /// map via [PantryItem.fromJson]. Returns the created [PantryItem].
  @override
  Future<PantryItem> createPantryItem(CreatePantryItemDto dto) async {
    PantryApi api = PantryApi();
    Map<String, dynamic> response = await api.createPantryItem(dto);
    return PantryItem.fromJson(response);
  }

  /// Fetches all pantry items.
  ///
  /// Delegates to [PantryApi.fetchPantryItems], then maps each JSON
  /// element through [PantryItem.fromJson] into a [List] of
  /// [PantryItem].
  @override
  Future<List<PantryItem>> fetchPantryItems() async {
    PantryApi api = PantryApi();
    List<dynamic> response = await api.fetchPantryItems();
    return response.map((el) => PantryItem.fromJson(el)).toList();
  }

  /// Updates the pantry item described by [dto].
  ///
  /// Delegates to [PantryApi.updatePantryItem], then maps the returned
  /// map via [PantryItem.fromJson]. Returns the updated [PantryItem].
  @override
  Future<PantryItem> updatePantryItem(UpdatePantryItemDto dto) async {
    PantryApi api = PantryApi();
    Map<String, dynamic> response = await api.updatePantryItem(dto);
    return PantryItem.fromJson(response);
  }

  /// Deletes the pantry item identified by [id].
  ///
  /// Delegates to [PantryApi.deletePantryItem] and completes without
  /// returning a domain object.
  @override
  Future<void> deletePantryItem(String id) async {
    PantryApi api = PantryApi();
    await api.deletePantryItem(id);
  }
}
