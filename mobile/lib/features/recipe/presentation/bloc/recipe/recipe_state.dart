part of 'recipe_bloc.dart';

/// Immutable state for `RecipeBloc`.
///
/// Holds the current list of recipes (or matches), a fetching flag, and the
/// currently-selected recipe id for the detail screen. All fields are
/// nullable except `isFetching` which defaults to `false`.
class RecipeState extends Equatable {
  /// List of recipes from the most recent fetch or match; `null` until the
  /// first load completes.
  final List<Recipe>? items;

  /// True while a fetch or match request is in flight; defaults to `false`.
  final bool isFetching;

  /// Id of the recipe currently selected for the detail screen; `null` until
  /// a selection occurs.
  final String? detailedItemId;

  /// Creates a state snapshot with all fields optional; `isFetching` defaults
  /// to `false`.
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

  /// Returns a new `RecipeState` with the specified fields overridden;
  /// unspecified fields are inherited from `this`.
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
