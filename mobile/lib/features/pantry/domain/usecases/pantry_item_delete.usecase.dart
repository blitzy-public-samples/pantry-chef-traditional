import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/pantry/data/repositories/pantry.repository.dart';
import 'package:pantry_chef/features/pantry/domain/repositories/pantry.repository.dart';

class PantryItemDeleteUsecase implements UseCaseWithParams<void, String> {
  @override
  Future<void> call(String id) async {
    PantryRepository repo = PantryRepositoryImpl();
    await repo.deletePantryItem(id);
  }
}
