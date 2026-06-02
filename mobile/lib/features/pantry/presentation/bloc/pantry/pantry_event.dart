part of 'pantry_bloc.dart';

/// Base type for all pantry list events handled by [PantryBloc].
sealed class PantryEvent extends Equatable {
  const PantryEvent();

  @override
  List<Object> get props => [];
}

/// Requests loading or refreshing of the pantry items.
class PantryItemsFetched extends PantryEvent {}

/// Adds an item; carries the [dto] describing the item to add.
class PantryItemAdded extends PantryEvent {
  final CreatePantryItemDto dto;

  const PantryItemAdded({required this.dto});

  @override
  List<Object> get props => [dto];
}

/// Updates an item; carries the [item] with its new values.
class PantryItemUpdated extends PantryEvent {
  final PantryItem item;

  const PantryItemUpdated({required this.item});

  @override
  List<Object> get props => [item];
}

/// Deletes an item; carries the [id] of the item to remove.
class PantryItemDeleted extends PantryEvent {
  final String id;

  const PantryItemDeleted({required this.id});

  @override
  List<Object> get props => [id];
}

/// Clears the pantry list, resetting to the empty state.
class PantryListReseted extends PantryEvent {}
