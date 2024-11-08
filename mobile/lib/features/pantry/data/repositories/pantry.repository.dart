import 'package:pantry_chef/features/pantry/data/api/pantry.api.dart';
import 'package:pantry_chef/features/pantry/data/dto/index.dart';
import 'package:pantry_chef/features/pantry/domain/models/pantry_item.dart';
import 'package:pantry_chef/features/pantry/domain/repositories/pantry.repository.dart';

class PantryRepositoryImpl implements PantryRepository {
  @override
  Future<PantryItem> createPantryItem(CreatePantryItemDto dto) async {
    PantryApi api = PantryApi();
    Map<String, dynamic> response = await api.createPantryItem(dto);
    return PantryItem.fromJson(response);
  }

  @override
  Future<List<PantryItem>> fetchPantryItems() async {
    PantryApi api = PantryApi();
    List<dynamic> response = await api.fetchPantryItems();
    return response.map((el) => PantryItem.fromJson(el)).toList();
  }

  @override
  Future<PantryItem> updatePantryItem(UpdatePantryItemDto dto) async {
    PantryApi api = PantryApi();
    Map<String, dynamic> response = await api.updatePantryItem(dto);
    return PantryItem.fromJson(response);
  }

  @override
  Future<void> deletePantryItem(String id) async {
    PantryApi api = PantryApi();
    await api.deletePantryItem(id);
  }
}
