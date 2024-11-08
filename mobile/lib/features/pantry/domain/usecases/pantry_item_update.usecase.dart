import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/pantry/data/dto/update_pantry_item.dto.dart';
import 'package:pantry_chef/features/pantry/data/repositories/pantry.repository.dart';
import 'package:pantry_chef/features/pantry/domain/models/pantry_item.dart';
import 'package:pantry_chef/features/pantry/domain/repositories/pantry.repository.dart';

class PantryItemUpdateUsecase implements UseCaseWithParams<PantryItem, UpdatePantryItemDto> {
  @override
  Future<PantryItem> call(UpdatePantryItemDto dto) {
    PantryRepository repo = PantryRepositoryImpl();
    return repo.updatePantryItem(dto);
  }
}
