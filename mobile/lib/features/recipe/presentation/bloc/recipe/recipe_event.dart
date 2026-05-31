part of 'recipe_bloc.dart';

/// Base sealed event type for `RecipeBloc`.
///
/// All concrete events extend this and use `Equatable` for value equality.
/// Three events carry no payload (`RecipeListFetched`, `RecipeMatching`,
/// `RecipeListReseted`) while `RecipeDetailedSelected` carries a required
/// `id`.
sealed class RecipeEvent extends Equatable {
  /// Base const constructor; concrete events have either no fields or a
  /// single `id` field.
  const RecipeEvent();

  @override
  List<Object> get props => [];
}

/// Event triggering a paginated list fetch via `GetRecipeListUsecase`.
class RecipeListFetched extends RecipeEvent {}

/// Event triggering a pantry-aware matches fetch via `RecipeMatchingUsecase`.
class RecipeMatching extends RecipeEvent {}

/// Event selecting a specific recipe by `id` for the detail screen.
class RecipeDetailedSelected extends RecipeEvent {
  /// The `Recipe.id` of the recipe to display in the detail screen.
  final String id;

  /// Creates a selection event for the recipe with the given `id`.
  const RecipeDetailedSelected({required this.id});

  @override
  List<Object> get props => [id];
}

/// Event resetting the BLoC to its initial empty `RecipeState()`.
class RecipeListReseted extends RecipeEvent {}
