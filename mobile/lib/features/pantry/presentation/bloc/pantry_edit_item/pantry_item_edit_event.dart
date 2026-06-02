part of 'pantry_item_edit_bloc.dart';

/// Base type for all pantry item edit-form events.
sealed class PantryItemEditEvent extends Equatable {
  const PantryItemEditEvent();

  @override
  List<Object?> get props => [];
}

/// Carries optional [location], [quantity] and [expirationDate] edits.
class DataChanged extends PantryItemEditEvent {
  final String? location;
  final String? quantity;
  final String? expirationDate;

  const DataChanged({
    this.location,
    this.quantity,
    this.expirationDate,
  });

  @override
  List<Object?> get props => [location, quantity, expirationDate];
}

/// Validates and persists the current edit-form values.
class ChangedDataSaved extends PantryItemEditEvent {}

/// Confirms deletion of the pantry item.
class DeleteConfirmed extends PantryItemEditEvent {}
