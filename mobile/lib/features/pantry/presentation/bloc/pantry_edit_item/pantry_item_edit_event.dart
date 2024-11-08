part of 'pantry_item_edit_bloc.dart';

sealed class PantryItemEditEvent extends Equatable {
  const PantryItemEditEvent();

  @override
  List<Object?> get props => [];
}

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

class ChangedDataSaved extends PantryItemEditEvent {}

class DeleteConfirmed extends PantryItemEditEvent {}
