part of 'pantry_bloc.dart';

/// Immutable state for the pantry list managed by [PantryBloc].
class PantryState extends Equatable {
  /// The loaded pantry items; null when not yet loaded.
  final List<PantryItem>? items;

  const PantryState({
    this.items,
  });

  @override
  List<Object?> get props => [items];

  /// Returns a copy of this state, overriding [items] when provided
  /// and preserving the current value when omitted.
  PantryState copyWith({
    final List<PantryItem>? items,
  }) =>
      PantryState(
        items: items ?? this.items,
      );
}
