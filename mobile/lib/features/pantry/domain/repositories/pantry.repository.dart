import 'package:pantry_chef/features/pantry/data/dto/index.dart';
import 'package:pantry_chef/features/pantry/domain/models/pantry_item.dart';

abstract class PantryRepository {
  Future<List<PantryItem>> fetchPantryItems();

  Future<PantryItem> createPantryItem(CreatePantryItemDto dto);

  Future<PantryItem> updatePantryItem(UpdatePantryItemDto dto);

  Future<void> deletePantryItem(String id);
}
