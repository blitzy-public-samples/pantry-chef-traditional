import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/pantry/data/dto/update_pantry_item.dto.dart';
import 'package:pantry_chef/features/pantry/data/repositories/pantry.repository.dart';
import 'package:pantry_chef/features/pantry/domain/models/pantry_item.dart';
import 'package:pantry_chef/features/pantry/domain/repositories/pantry.repository.dart';

/// Use case that updates an existing pantry item.
///
/// Updates a pantry item from the supplied update DTO by delegating
/// to the pantry repository's update operation.
/// Implements `UseCaseWithParams<PantryItem, UpdatePantryItemDto>`.
/// Source: pantry_item_update.usecase.dart:L7
class PantryItemUpdateUsecase implements UseCaseWithParams<PantryItem, UpdatePantryItemDto> {
  /// Updates a pantry item from [dto] and returns the updated
  /// `PantryItem`.
  /// Source: pantry_item_update.usecase.dart:L9
  @override
  Future<PantryItem> call(UpdatePantryItemDto dto) {
    PantryRepository repo = PantryRepositoryImpl();
    return repo.updatePantryItem(dto);
  }
}
