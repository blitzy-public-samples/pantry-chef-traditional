part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class ProfileFetched extends ProfileEvent {}

class FavoriteRecipesFetched extends ProfileEvent {}

class FavoriteRecipesListUpdated extends ProfileEvent {
  final String recipeId;
  final bool isFavorite;

  const FavoriteRecipesListUpdated({required this.recipeId, required this.isFavorite});

  @override
  List<Object> get props => [recipeId, isFavorite];
}

class Logout extends ProfileEvent {
  final BuildContext context;

  const Logout({required this.context});

  @override
  List<Object> get props => [context];
}

class ProfileDataReseted extends ProfileEvent {}
