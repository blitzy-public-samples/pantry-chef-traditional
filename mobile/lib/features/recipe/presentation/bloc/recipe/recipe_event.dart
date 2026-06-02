part of 'recipe_bloc.dart';

/// Sealed base type for all recipe BLoC events.
sealed class RecipeEvent extends Equatable {
  const RecipeEvent();

  @override
  List<Object> get props => [];
}

/// Requests loading the full recipe list.
class RecipeListFetched extends RecipeEvent {}

/// Requests running recipe matching against filters.
class RecipeMatching extends RecipeEvent {}

/// Selects a recipe to show in the detail view.
class RecipeDetailedSelected extends RecipeEvent {
  /// Identifier of the selected recipe.
  final String id;

  const RecipeDetailedSelected({required this.id});

  @override
  List<Object> get props => [id];
}

/// Resets the recipe list/screen state.
class RecipeListReseted extends RecipeEvent {}
