part of 'pantry_item_edit_bloc.dart';

/// Immutable state for the pantry item edit form.
class PantryItemEditState extends Equatable {
  /// Identifier of the pantry item being edited.
  final String id;
  /// Current quantity input, string-typed for the form field.
  final String quantity;
  /// Current location input.
  final String location;
  /// Current expiration-date input.
  final String expirationDate;
  /// True when quantity validation fails.
  final bool quantityError;
  /// True while a save or delete operation is in flight.
  final bool isFetching;
  /// Holds the saved [PantryItem] on success; null otherwise.
  final PantryItem? updatedItem;
  /// True once the item has been deleted.
  final bool deleted;

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

  /// Returns a copy with [location], [quantity], [expirationDate],
  /// [quantityError], [isFetching], [updatedItem] or [deleted]
  /// overridden; unspecified fields retain their current values.
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
