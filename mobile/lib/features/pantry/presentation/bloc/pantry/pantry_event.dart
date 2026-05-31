part of 'pantry_bloc.dart';

/// Sealed base for all [PantryBloc] events.
///
/// Extends [Equatable] for value-equality so identical dispatches
/// de-duplicate naturally in the bloc stream.
sealed class PantryEvent extends Equatable {
  const PantryEvent();

  @override
  List<Object> get props => [];
}

/// Dispatched to trigger a backend list refresh.
///
/// The handler in `pantry_bloc.dart:L15-L19` invokes
/// [FetchPantryItemsUsecase] and replaces `state.items` with the result.
/// Dispatched lazily on first build of [PantryMain] when `state.items` is
/// `null` (Source: `patry_main.dart:L21-L24`), and on pull-to-refresh.
/// Carries no payload.
class PantryItemsFetched extends PantryEvent {}

/// Dispatched after the user submits a new pantry item.
///
/// The handler in `pantry_bloc.dart:L21-L26` invokes [AddToPantryUsecase]
/// with [dto], then prepends the returned [PantryItem] to `state.items`
/// (defensive `?? []` when items is null).
class PantryItemAdded extends PantryEvent {
  /// Payload describing the new pantry item (ingridient reference,
  /// quantity, location, unit, expirationDate). Source DTO:
  /// `mobile/lib/features/pantry/data/dto/create_pantry_item.dto.dart`.
  final CreatePantryItemDto dto;

  /// Const constructor; requires the [dto] payload.
  const PantryItemAdded({required this.dto});

  @override
  List<Object> get props => [dto];
}

/// Dispatched after a successful PATCH that updated a pantry item.
///
/// Carries the updated [PantryItem] returned by the backend. The handler
/// in `pantry_bloc.dart:L28-L33` performs an in-memory list replace by
/// matching `item.id`. Dispatch site:
/// `presentation/widgets/screens/pantry_item_edit.dart:L62` (the screen's
/// `BlocListener` after `PantryItemEditBloc.updatedItem` becomes non-null).
class PantryItemUpdated extends PantryEvent {
  /// Updated pantry item returned by the backend.
  ///
  /// Includes the original `id` so the handler can locate the existing
  /// entry in `state.items` and replace it. The `ingridient` field on this
  /// model is preserved verbatim from backend spelling.
  final PantryItem item;

  /// Const constructor; requires the updated [item].
  const PantryItemUpdated({required this.item});

  @override
  List<Object> get props => [item];
}

/// Dispatched after a successful DELETE that removed a pantry item.
///
/// Carries the removed item's [id] so the handler in
/// `pantry_bloc.dart:L35-L37` can filter it out of `state.items` via
/// `where((el) => el.id != event.id)`. Dispatch site:
/// `presentation/widgets/screens/pantry_item_edit.dart:L69` (the screen's
/// `BlocListener` after `PantryItemEditBloc.deleted` becomes `true`).
class PantryItemDeleted extends PantryEvent {
  /// Id of the pantry item removed from the backend.
  final String id;

  /// Const constructor; requires the removed item's [id].
  const PantryItemDeleted({required this.id});

  @override
  List<Object> get props => [id];
}

// NOTE: Class name 'PantryListReseted' is preserved verbatim from source
// (sic — 'Reseted' not 'Reset'). Do not rename. Stable across the app.
/// Dispatched to clear the entire pantry list (e.g., on logout).
///
/// Carries no payload. The handler in `pantry_bloc.dart:L39-L41` emits a
/// fresh empty `PantryState()`, wiping any persisted state in
/// [HydratedBloc.storage] on the next `emit`-driven serialization.
class PantryListReseted extends PantryEvent {}
