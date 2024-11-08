import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:pantry_chef/features/profile/data/dto/favorite_recipes_update.dto.dart';
import 'package:pantry_chef/features/profile/domain/models/profile.dart';
import 'package:pantry_chef/features/profile/domain/usecases/favorite_recipes_update.usecase.dart';
import 'package:pantry_chef/features/profile/domain/usecases/index.dart';
import 'package:pantry_chef/features/recipe/domain/models/recipe.dart';
import 'package:pantry_chef/features/recipe/domain/usecases/index.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> with HydratedMixin {
  ProfileBloc() : super(ProfileState()) {
    hydrate();

    on<ProfileFetched>((_, emit) async {
      GetProfileUsecase useCase = GetProfileUsecase();
      Profile result = await useCase();
      emit(state.copyWith(userProfile: result));
    });

    on<FavoriteRecipesFetched>((_, emit) async {
      if (state.userProfile!.favoriteRecipes.isEmpty) {
        emit(state.copyWith(favoriteRecipes: const []));
        return;
      }
      GetFavoriteRecipeListUsecase useCase = GetFavoriteRecipeListUsecase();
      List<Recipe> result = await useCase(state.userProfile!.favoriteRecipes);
      emit(state.copyWith(favoriteRecipes: result));
    });

    on<FavoriteRecipesListUpdated>((event, emit) async {
      List<String> favoriteRecipesIds =
          state.favoriteRecipes != null ? state.favoriteRecipes!.map((el) => el.id).toList() : [];

      if (event.isFavorite) {
        favoriteRecipesIds.insert(0, event.recipeId);
      } else {
        favoriteRecipesIds = favoriteRecipesIds.where((el) => el != event.recipeId).toList();
      }
      FavoriteRecipesUpdateUsecase useCase = FavoriteRecipesUpdateUsecase();
      Recipe? addedRecipe = await useCase(
        FavoriteRecipesUpdateDto(
          favoriteList: favoriteRecipesIds,
          addedId: event.isFavorite ? event.recipeId : null,
        ),
      );
      emit(
        state.copyWith(
          userProfile: state.userProfile!.copyWith(
            favoriteRecipes: favoriteRecipesIds,
          ),
          favoriteRecipes: addedRecipe != null
              ? [addedRecipe, ...state.favoriteRecipes!]
              : state.favoriteRecipes!.where((el) => el.id != event.recipeId).toList(),
        ),
      );
    });

    on<Logout>((event, emit) async {
      LogoutUsecase useCase = LogoutUsecase();
      await useCase(event.context);
    });

    on<ProfileDataReseted>((_, emit) {
      emit(ProfileState());
    });
  }

  @override
  ProfileState? fromJson(Map<String, dynamic> json) {
    return ProfileState(
      userProfile: json['userProfile'] != null ? Profile.fromJson(json['userProfile']) : null,
      favoriteRecipes: json['favoriteRecipes'] != null
          ? (json['favoriteRecipes'] as List<dynamic>).map((el) => Recipe.fromJson(el)).toList()
          : null,
    );
  }

  @override
  Map<String, dynamic>? toJson(ProfileState state) {
    return {
      'userProfile': state.userProfile?.toJson(),
      'favoriteRecipes': state.favoriteRecipes,
    };
  }
}
