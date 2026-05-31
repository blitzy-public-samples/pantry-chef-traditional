part of 'recipe_bloc.dart';

/// Immutable UI state for the recipe screen.
class RecipeState extends Equatable {
  /// Loaded recipes, or null before the first load.
  final List<Recipe>? items;
  /// Whether a fetch or match is currently in progress.
  final bool isFetching;
  /// Id of the recipe shown in the detail view.
  final String? detailedItemId;

  const RecipeState({
    this.items,
    this.isFetching = false,
    this.detailedItemId,
  });

  @override
  List<Object?> get props => [
        items,
        isFetching,
        detailedItemId,
      ];

  /// Returns a copy of this state with [items], [isFetching], or
  /// [detailedItemId] overridden; unspecified fields keep their
  /// current values.
  RecipeState copyWith({
    final List<Recipe>? items,
    final bool? isFetching,
    final String? detailedItemId,
  }) =>
      RecipeState(
        items: items ?? this.items,
        isFetching: isFetching ?? this.isFetching,
        detailedItemId: detailedItemId ?? this.detailedItemId,
      );
}
