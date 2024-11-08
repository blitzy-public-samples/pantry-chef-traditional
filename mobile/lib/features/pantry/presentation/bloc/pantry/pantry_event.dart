part of 'pantry_bloc.dart';

sealed class PantryEvent extends Equatable {
  const PantryEvent();

  @override
  List<Object> get props => [];
}

class PantryItemsFetched extends PantryEvent {}

class PantryItemAdded extends PantryEvent {
  final CreatePantryItemDto dto;

  const PantryItemAdded({required this.dto});

  @override
  List<Object> get props => [dto];
}

class PantryItemUpdated extends PantryEvent {
  final PantryItem item;

  const PantryItemUpdated({required this.item});

  @override
  List<Object> get props => [item];
}

class PantryItemDeleted extends PantryEvent {
  final String id;

  const PantryItemDeleted({required this.id});

  @override
  List<Object> get props => [id];
}

class PantryListReseted extends PantryEvent {}
