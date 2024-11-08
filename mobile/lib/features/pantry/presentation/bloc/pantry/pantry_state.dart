part of 'pantry_bloc.dart';

class PantryState extends Equatable {
  final List<PantryItem>? items;

  const PantryState({
    this.items,
  });

  @override
  List<Object?> get props => [items];

  PantryState copyWith({
    final List<PantryItem>? items,
  }) =>
      PantryState(
        items: items ?? this.items,
      );
}
