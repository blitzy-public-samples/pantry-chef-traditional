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

/// BLoC for the profile feature, managing user profile and favorite recipes state.
///
/// Extends [Bloc] with [HydratedMixin] (functionally equivalent to a
/// `HydratedBloc<ProfileEvent, ProfileState>`) so the emitted state is
/// automatically persisted to and rehydrated from [HydratedBloc.storage].
/// Storage is configured globally in `mobile/lib/main.dart` (lines 14-16) via
/// `HydratedStorage.build(storageDirectory: await getTemporaryDirectory())`
/// from `path_provider`.
///
/// The constructor calls [hydrate] to restore previously serialized state
/// from storage on instantiation. Reacts to [ProfileFetched],
/// [FavoriteRecipesFetched], [FavoriteRecipesListUpdated], [Logout], and
/// [ProfileDataReseted] events; the [Logout] event carries a [BuildContext]
/// because [LogoutUsecase] needs it for sibling-BLoC resets and
/// `Navigator.pushNamedAndRemoveUntil`.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> with HydratedMixin {
  /// Creates a [ProfileBloc] and registers handlers for all five events.
  ///
  /// Immediately calls [hydrate] to restore any persisted state from
  /// [HydratedBloc.storage] before the first event is dispatched.
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

  /// Deserializes persisted hydrated state into a [ProfileState].
  ///
  /// Restores `userProfile` via [Profile.fromJson] and `favoriteRecipes` by
  /// mapping each JSON list entry through [Recipe.fromJson]. Returns a
  /// [ProfileState] with `null`-tolerant fields when the corresponding JSON
  /// keys are absent. Called by [HydratedMixin] on construction.
  @override
  ProfileState? fromJson(Map<String, dynamic> json) {
    return ProfileState(
      userProfile: json['userProfile'] != null ? Profile.fromJson(json['userProfile']) : null,
      favoriteRecipes: json['favoriteRecipes'] != null
          ? (json['favoriteRecipes'] as List<dynamic>).map((el) => Recipe.fromJson(el)).toList()
          : null,
    );
  }

  /// Serializes the current [ProfileState] for persistence to
  /// [HydratedBloc.storage].
  ///
  /// Calls `state.userProfile?.toJson()` for the embedded profile and writes
  /// `state.favoriteRecipes` as the raw recipes list. Called by [HydratedMixin]
  /// on every state emission.
  @override
  Map<String, dynamic>? toJson(ProfileState state) {
    return {
      'userProfile': state.userProfile?.toJson(),
      'favoriteRecipes': state.favoriteRecipes,
    };
  }
}
