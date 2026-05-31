import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/pantry/data/repositories/pantry.repository.dart';
import 'package:pantry_chef/features/pantry/domain/repositories/pantry.repository.dart';

/// Deletes a pantry item by id via [PantryRepository.deletePantryItem].
///
/// Stateless deletion orchestration use case implementing
/// [UseCaseWithParams]<`void`, [String]>, where the [String] parameter is the
/// pantry item's id. It is the only use case in this folder whose parameter is
/// a primitive rather than a DTO. Mirrors the `AddToPantryUsecase` pattern: it
/// holds no state and instantiates a fresh [PantryRepositoryImpl] per call,
/// typing it against the [PantryRepository] abstraction for dependency
/// inversion.
///
/// Backend behavior: despite the `softDelete` route name, the backend performs
/// a PHYSICAL delete (via `deleteOne`) rather than setting `deletedAt`, per
/// backend/src/pantry/infrastructure/document/repositories/pantryIngridient.repository.ts:L119-L123
/// The mobile contract treats this call as fire-and-forget deletion; the route
/// name does not reflect the actual backend behavior.
///
/// Typically invoked from `PantryItemEditBloc` when a `DeleteConfirmed` event
/// fires.
class PantryItemDeleteUsecase implements UseCaseWithParams<void, String> {
  /// Awaits [PantryRepository.deletePantryItem] for the given [id], returning
  /// `void`.
  ///
  /// This is the only use case in this folder marked `async`: the sibling use
  /// cases (`AddToPantryUsecase`, `PantryItemUpdateUsecase`,
  /// `FetchPantryItemsUsecase`) return the repository `Future` directly. The
  /// `await` here ensures the deletion completes before returning; no response
  /// body is consumed (the backend returns nothing meaningful on delete).
  /// Errors thrown by the repository (e.g., 404 Not Found, `DioException` on
  /// network failure, 401 Unauthorized on an expired JWT) propagate to the
  /// caller unhandled.
  @override
  Future<void> call(String id) async {
    PantryRepository repo = PantryRepositoryImpl();
    await repo.deletePantryItem(id);
  }
}
