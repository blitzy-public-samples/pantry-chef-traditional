import 'package:pantry_chef/core/utils/usercase.dart';
import 'package:pantry_chef/features/pantry/data/repositories/pantry.repository.dart';
import 'package:pantry_chef/features/pantry/domain/models/pantry_item.dart';
import 'package:pantry_chef/features/pantry/domain/repositories/pantry.repository.dart';

/// Fetches all pantry items for the authenticated user via
/// [PantryRepository.fetchPantryItems].
///
/// Parameterless use case: implements [UseCase] of `List<PantryItem>` with a
/// no-argument `call()`, unlike the three sibling use cases in this folder
/// (`AddToPantryUsecase`, `PantryItemUpdateUsecase`, `PantryItemDeleteUsecase`)
/// which implement [UseCaseWithParams]. No client-side parameter is required:
/// the backend resolves the user's `userId` from the JWT bearer token attached
/// by `DioClient`'s request interceptor (`req.user.id`, scoped by the backend
/// `AuthGuard('jwt')`), so a client can never read another user's pantry.
///
/// The backend caps results at 50 records per page, enforced server-side via
/// `pageOptionsDto.take`. This client does not yet handle pagination, so a user
/// with more than 50 pantry items will only see the first page; future
/// contributors who add pagination must revisit this use case.
///
/// Stateless (mirrors `AddToPantryUsecase`): a fresh [PantryRepositoryImpl] is
/// instantiated per call. Invoked from `PantryBloc` on the `PantryItemsFetched`
/// event, typically when `PantryMain` renders with `state.items == null`.
class FetchPantryItemsUsecase implements UseCase<List<PantryItem>> {
  /// Delegates to [PantryRepository.fetchPantryItems] and returns the
  /// resulting `List<PantryItem>` as a `Future`.
  ///
  /// Non-async: returns the repository `Future` directly without `await`,
  /// matching `AddToPantryUsecase` and `PantryItemUpdateUsecase` (only
  /// `PantryItemDeleteUsecase` is `async`). Repository errors, such as a 401
  /// when the JWT is missing or expired or a `DioException` on network
  /// failure, propagate to the caller unhandled.
  @override
  Future<List<PantryItem>> call() {
    PantryRepository repo = PantryRepositoryImpl();
    return repo.fetchPantryItems();
  }
}
