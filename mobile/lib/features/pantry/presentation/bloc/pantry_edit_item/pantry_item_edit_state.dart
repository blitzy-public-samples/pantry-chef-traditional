part of 'pantry_item_edit_bloc.dart';

class PantryItemEditState extends Equatable {
  final String id;
  final String quantity;
  final String location;
  final String expirationDate;
  final bool quantityError;
  final bool isFetching;
  final PantryItem? updatedItem;
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
