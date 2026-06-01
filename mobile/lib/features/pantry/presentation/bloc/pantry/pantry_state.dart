part of 'pantry_bloc.dart';

/// Immutable state for the pantry list managed by [PantryBloc].
/// Source: pantry_state.dart:L3
class PantryState extends Equatable {
  /// The loaded pantry items; null when not yet loaded.
  /// Source: pantry_state.dart:L4
  final List<PantryItem>? items;

  const PantryState({
    this.items,
  });

  @override
  List<Object?> get props => [items];

  /// Returns a copy of this state, overriding [items] when provided
  /// and preserving the current value when omitted.
  /// Source: pantry_state.dart:L13
  PantryState copyWith({
    final List<PantryItem>? items,
  }) =>
      PantryState(
        items: items ?? this.items,
      );
}
