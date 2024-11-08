import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/pantry/data/repositories/pantry.repository.dart';
import 'package:pantry_chef/features/pantry/domain/models/pantry_item.dart';
import 'package:pantry_chef/features/pantry/domain/repositories/pantry.repository.dart';

class FetchPantryItemsUsecase implements UseCase<List<PantryItem>> {
  @override
  Future<List<PantryItem>> call() {
    PantryRepository repo = PantryRepositoryImpl();
    return repo.fetchPantryItems();
  }
}
