import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/pantry/data/dto/create_pantry_item.dto.dart';
import 'package:pantry_chef/features/pantry/data/repositories/pantry.repository.dart';
import 'package:pantry_chef/features/pantry/domain/models/pantry_item.dart';
import 'package:pantry_chef/features/pantry/domain/repositories/pantry.repository.dart';

/// Adds a new pantry item by delegating to [PantryRepository.createPantryItem].
///
/// Thin orchestration use case implementing
/// [UseCaseWithParams]<[PantryItem], [CreatePantryItemDto]>. It is stateless and
/// dependency-free: a fresh [PantryRepositoryImpl] is instantiated on every
/// [call] (no caching, no constructor injection) and is immediately typed
/// against the [PantryRepository] abstraction to preserve dependency inversion
/// at the call site even though there is no constructor-level DI.
///
/// Typically invoked from `PantryBloc` when a `PantryItemAdded` event fires.
class AddToPantryUsecase implements UseCaseWithParams<PantryItem, CreatePantryItemDto> {
  /// Forwards [dto] to [PantryRepository.createPantryItem] and returns the
  /// resulting [PantryItem].
  ///
  /// Returns the repository `Future` directly without `await` (non-async); this
  /// is intentional and must not be "fixed" by adding `async`/`await`.
  /// Errors thrown by the repository (e.g. a `DioException` on network
  /// failure, or a backend 400 validation error) propagate to the caller
  /// unhandled.
  @override
  Future<PantryItem> call(CreatePantryItemDto dto) {
    PantryRepository repo = PantryRepositoryImpl();
    return repo.createPantryItem(dto);
  }
}
