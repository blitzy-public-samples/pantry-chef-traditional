part of 'recipe_bloc.dart';

sealed class RecipeEvent extends Equatable {
  const RecipeEvent();

  @override
  List<Object> get props => [];
}

class RecipeListFetched extends RecipeEvent {}

class RecipeMatching extends RecipeEvent {}

class RecipeDetailedSelected extends RecipeEvent {
  final String id;

  const RecipeDetailedSelected({required this.id});

  @override
  List<Object> get props => [id];
}

class RecipeListReseted extends RecipeEvent {}
