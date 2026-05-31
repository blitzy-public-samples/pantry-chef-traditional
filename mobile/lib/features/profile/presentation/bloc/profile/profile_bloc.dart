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

/// BLoC for the profile feature. Extends
/// `Bloc<ProfileEvent, ProfileState>` with `HydratedMixin` to persist
/// `userProfile` and `favoriteRecipes` across app launches. Calls
/// `hydrate()` in its constructor to restore cached state.
/// Source: profile_bloc.dart:L14,L16
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> with HydratedMixin {
  ProfileBloc() : super(ProfileState()) {
    // Restore any persisted state from hydrated storage on creation.
    hydrate();

    on<ProfileFetched>((_, emit) async {
      // Load the current profile via the GetProfileUsecase.
      GetProfileUsecase useCase = GetProfileUsecase();
      Profile result = await useCase();
      // Emit state with the freshly fetched profile.
      emit(state.copyWith(userProfile: result));
    });

    on<FavoriteRecipesFetched>((_, emit) async {
      // Short-circuit to an empty list when there are no favorites.
      if (state.userProfile!.favoriteRecipes.isEmpty) {
        emit(state.copyWith(favoriteRecipes: const []));
        return;
      }
      // Otherwise load full Recipe objects for the favorite ids.
      GetFavoriteRecipeListUsecase useCase = GetFavoriteRecipeListUsecase();
      List<Recipe> result = await useCase(state.userProfile!.favoriteRecipes);
      emit(state.copyWith(favoriteRecipes: result));
    });

    on<FavoriteRecipesListUpdated>((event, emit) async {
      // Build the current list of favorite recipe ids from state.
      List<String> favoriteRecipesIds =
          state.favoriteRecipes != null ? state.favoriteRecipes!.map((el) => el.id).toList() : [];

      // Add at the front when favoriting; otherwise remove the id.
      if (event.isFavorite) {
        favoriteRecipesIds.insert(0, event.recipeId);
      } else {
        favoriteRecipesIds = favoriteRecipesIds.where((el) => el != event.recipeId).toList();
      }
      // Persist the updated favorites via the update use case.
      FavoriteRecipesUpdateUsecase useCase = FavoriteRecipesUpdateUsecase();
      Recipe? addedRecipe = await useCase(
        FavoriteRecipesUpdateDto(
          favoriteList: favoriteRecipesIds,
          addedId: event.isFavorite ? event.recipeId : null,
        ),
      );
      // Emit the updated profile ids and the favorite Recipe list.
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
      // Run the logout use case with the event's build context.
      LogoutUsecase useCase = LogoutUsecase();
      await useCase(event.context);
    });

    on<ProfileDataReseted>((_, emit) {
      // Reset to a fresh, empty ProfileState.
      emit(ProfileState());
    });
  }

  /// Reconstructs a [ProfileState] from persisted [json], using null
  /// fields when keys are absent. Invoked by HydratedMixin on startup.
  @override
  ProfileState? fromJson(Map<String, dynamic> json) {
    return ProfileState(
      userProfile: json['userProfile'] != null ? Profile.fromJson(json['userProfile']) : null,
      favoriteRecipes: json['favoriteRecipes'] != null
          ? (json['favoriteRecipes'] as List<dynamic>).map((el) => Recipe.fromJson(el)).toList()
          : null,
    );
  }

  /// Serializes [state] to a JSON map for hydrated persistence.
  @override
  Map<String, dynamic>? toJson(ProfileState state) {
    return {
      'userProfile': state.userProfile?.toJson(),
      'favoriteRecipes': state.favoriteRecipes,
    };
  }
}
