import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/pantry/data/dto/update_pantry_item.dto.dart';
import 'package:pantry_chef/features/pantry/data/repositories/pantry.repository.dart';
import 'package:pantry_chef/features/pantry/domain/models/pantry_item.dart';
import 'package:pantry_chef/features/pantry/domain/repositories/pantry.repository.dart';

/// Updates an existing pantry item by delegating to
/// [PantryRepository.updatePantryItem].
///
/// Thin update orchestration use case implementing
/// [UseCaseWithParams]<[PantryItem], [UpdatePantryItemDto]>. The single
/// [UpdatePantryItemDto] parameter carries the pantry item's `id` in its
/// body, so no separate id argument is required: the backend route is
/// `PATCH /api/pantry/:id` and the data layer reads the id from the DTO
/// to build that URL (Source: `update_pantry_item.dto.dart:L7`).
///
/// Stateless and mirrors the sibling `AddToPantryUsecase`: it instantiates a
/// fresh [PantryRepositoryImpl] per call and returns its `Future` directly.
/// Invoked from `PantryItemEditBloc` on `ChangedDataSaved`, after client-side
/// quantity validation in that bloc.
class PantryItemUpdateUsecase implements UseCaseWithParams<PantryItem, UpdatePantryItemDto> {
  /// Forwards [dto] to [PantryRepository.updatePantryItem] and returns the
  /// updated [PantryItem] directly as a `Future` (non-async), like
  /// `AddToPantryUsecase` and `FetchPantryItemsUsecase`; only
  /// `PantryItemDeleteUsecase` is `async`.
  ///
  /// Repository errors (e.g., 404 Not Found, 400 validation, or a
  /// `DioException` on network failure) propagate to the caller unhandled.
  @override
  Future<PantryItem> call(UpdatePantryItemDto dto) {
    PantryRepository repo = PantryRepositoryImpl();
    return repo.updatePantryItem(dto);
  }
}
