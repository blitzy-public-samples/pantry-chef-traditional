part of 'profile_bloc.dart';

/// Base sealed event for [ProfileBloc]; all profile events extend it.
sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

/// Requests loading or refreshing the current user's profile.
class ProfileFetched extends ProfileEvent {}

/// Requests loading the user's list of favorite recipes.
class FavoriteRecipesFetched extends ProfileEvent {}

/// Toggles a recipe's favorite status, then refreshes the favorites.
class FavoriteRecipesListUpdated extends ProfileEvent {
  /// Identifier of the recipe whose favorite status changes.
  final String recipeId;
  /// True to add the recipe to favorites; false to remove it.
  final bool isFavorite;

  const FavoriteRecipesListUpdated({required this.recipeId, required this.isFavorite});

  @override
  List<Object> get props => [recipeId, isFavorite];
}

/// Triggers the sign-out flow using the provided [context].
class Logout extends ProfileEvent {
  /// Build context used by the logout use case for navigation.
  final BuildContext context;

  const Logout({required this.context});

  @override
  List<Object> get props => [context];
}

/// Clears all persisted profile data back to an empty state.
class ProfileDataReseted extends ProfileEvent {}
