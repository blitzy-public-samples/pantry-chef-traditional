import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/pantry/data/dto/create_pantry_item.dto.dart';
import 'package:pantry_chef/features/pantry/data/repositories/pantry.repository.dart';
import 'package:pantry_chef/features/pantry/domain/models/pantry_item.dart';
import 'package:pantry_chef/features/pantry/domain/repositories/pantry.repository.dart';

/// Use case that adds a new item to the pantry.
///
/// Creates a pantry item from the supplied creation DTO by
/// delegating to the pantry repository's create operation.
/// Implements `UseCaseWithParams<PantryItem, CreatePantryItemDto>`.
/// Source: add_to_pantry.usecase.dart:L7
class AddToPantryUsecase implements UseCaseWithParams<PantryItem, CreatePantryItemDto> {
  /// Creates a pantry item from [dto] and returns the created
  /// `PantryItem`.
  /// Source: add_to_pantry.usecase.dart:L9
  @override
  Future<PantryItem> call(CreatePantryItemDto dto) {
    // New repository instance per call; typed as the domain interface.
    PantryRepository repo = PantryRepositoryImpl();
    return repo.createPantryItem(dto);
  }
}
