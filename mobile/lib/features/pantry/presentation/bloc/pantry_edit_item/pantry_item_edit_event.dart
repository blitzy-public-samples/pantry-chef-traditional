part of 'pantry_item_edit_bloc.dart';

/// Sealed base for all [PantryItemEditBloc] events.
///
/// Extends [Equatable] for value-equality so identical dispatches
/// de-duplicate naturally in the bloc stream.
sealed class PantryItemEditEvent extends Equatable {
  const PantryItemEditEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched on each form field change.
///
/// All three fields ([location], [quantity], [expirationDate]) are nullable
/// so the screen can dispatch partial updates — only the changed field is
/// included in the dispatch. The handler in
/// `pantry_item_edit_bloc.dart:L24-L33` clears `quantityError` whenever a
/// non-null [quantity] arrives.
class DataChanged extends PantryItemEditEvent {
  /// New location (one of `'fridge'`, `'freezer'`, `'pantry'`), or `null`
  /// when this field did not change.
  final String? location;
  /// New quantity as a `String` (form input), or `null` when this field did
  /// not change. Converted back to `double` via `double.parse` when the
  /// [ChangedDataSaved] handler builds the `UpdatePantryItemDto`
  /// (Source: `pantry_item_edit_bloc.dart:L46`).
  final String? quantity;
  /// New ISO-8601 expiration date string, or `null` when this field did not
  /// change. Selected via the screen's [DatePickerField].
  final String? expirationDate;

  /// Const constructor; all three fields are optional named parameters
  /// because each form change typically updates only one.
  const DataChanged({
    this.location,
    this.quantity,
    this.expirationDate,
  });

  @override
  List<Object?> get props => [location, quantity, expirationDate];
}

/// Dispatched when the user taps the Save button.
///
/// Source dispatch site: `pantry_item_edit.dart:L170` (the `ActionButton`
/// `onPress` callback). Triggers quantity validation and the
/// [PantryItemUpdateUsecase] invocation in
/// `pantry_item_edit_bloc.dart:L35-L55`.
class ChangedDataSaved extends PantryItemEditEvent {}

/// Dispatched after the user confirms deletion via the platform dialog.
///
/// Source dispatch site: `pantry_item_edit.dart:L26-L36` `_showDeleteDialog`
/// (the `result == true` branch). Triggers the [PantryItemDeleteUsecase]
/// invocation in `pantry_item_edit_bloc.dart:L57-L66`.
class DeleteConfirmed extends PantryItemEditEvent {}
