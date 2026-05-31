part of 'pantry_item_edit_bloc.dart';

/// Immutable state for the edit form.
///
/// Combines editable fields ([location], [quantity], [expirationDate]) with
/// transient UI flags ([isFetching], [quantityError]) and terminal-result
/// tracking ([updatedItem], [deleted]) that the screen's listeners watch to
/// notify the parent [PantryBloc] and pop the route.
class PantryItemEditState extends Equatable {
  /// Immutable id of the pantry item being edited.
  ///
  /// Never changes during the edit session. Used to issue PATCH/DELETE
  /// requests and to dispatch `PantryItemDeleted(id: state.id)` to the
  /// parent [PantryBloc] (Source: `pantry_item_edit.dart:L69`).
  final String id;
  /// Quantity stored as `String` for compatibility with `TextFieldInput`.
  ///
  /// Parsed back to `double` via `double.parse(state.quantity)` in the
  /// [ChangedDataSaved] handler (Source: `pantry_item_edit_bloc.dart:L46`).
  /// An empty string short-circuits the save path with `quantityError:true`.
  final String quantity;
  /// One of the `ingredientLocation` enum values: `'fridge'`, `'freezer'`,
  /// `'pantry'` (Source: `mobile/lib/core/constants/ingredient_location.dart:L1`).
  final String location;
  /// ISO 8601 date string parseable by `DateTime.parse`.
  ///
  /// Drives the `DatePickerField` both as `initialDate` and as `firstDate`
  /// (Source: `pantry_item_edit.dart:L142-L143`).
  final String expirationDate;
  /// `true` when an empty quantity was attempted on save.
  ///
  /// Surfaces an error in `TextFieldInput.errorText` at
  /// `pantry_item_edit.dart:L112`. Cleared on the next [DataChanged] event
  /// that carries a non-null quantity (Source:
  /// `pantry_item_edit_bloc.dart:L30`).
  final bool quantityError;
  /// `true` while a PATCH or DELETE call is in flight.
  ///
  /// Drives the `loader_overlay` show/hide listener at
  /// `pantry_item_edit.dart:L49-L57`. Always cleared in the `finally` block
  /// of both [ChangedDataSaved] and [DeleteConfirmed] handlers.
  final bool isFetching;
  /// Backend response set after a successful PATCH.
  ///
  /// The screen's listener at `pantry_item_edit.dart:L59-L65` watches for
  /// this becoming non-null, dispatches
  /// `PantryItemUpdated(item: state.updatedItem!)` to the parent
  /// [PantryBloc], and pops the route.
  final PantryItem? updatedItem;
  /// `true` after a successful DELETE.
  ///
  /// The screen's listener at `pantry_item_edit.dart:L66-L72` watches for
  /// this becoming `true`, dispatches `PantryItemDeleted(id: state.id)` to
  /// the parent [PantryBloc], and pops the route.
  final bool deleted;

  /// Const constructor.
  ///
  /// Required core fields: [id], [location], [quantity], [expirationDate].
  /// Defaulted UI flags: [quantityError] (`false`), [isFetching] (`false`),
  /// [deleted] (`false`), [updatedItem] (`null`).
  const PantryItemEditState({
    required this.id,
    required this.location,
    required this.quantity,
    required this.expirationDate,
    this.quantityError = false,
    this.isFetching = false,
    this.updatedItem,
    this.deleted = false,
  });

  @override
  List<Object?> get props => [
        quantity,
        quantity,
        expirationDate,
        quantityError,
        isFetching,
        updatedItem,
        deleted,
      ];

  /// Immutable-update helper.
  ///
  /// **Note**: [id] is intentionally NOT copyable — it is fixed for the
  /// lifetime of the bloc and reflects the item being edited. Any other
  /// field omitted from the call preserves its existing value via the
  /// `?? this.<field>` fallback.
  PantryItemEditState copyWith({
    final String? location,
    final String? quantity,
    final String? expirationDate,
    final bool? quantityError,
    final bool? isFetching,
    final PantryItem? updatedItem,
    final bool? deleted,
  }) =>
      PantryItemEditState(
        id: id,
        location: location ?? this.location,
        quantity: quantity ?? this.quantity,
        expirationDate: expirationDate ?? this.expirationDate,
        quantityError: quantityError ?? this.quantityError,
        isFetching: isFetching ?? this.isFetching,
        updatedItem: updatedItem ?? this.updatedItem,
        deleted: deleted ?? this.deleted,
      );
}
