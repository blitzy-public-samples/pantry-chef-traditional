import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:pantry_chef/features/recipe/data/dto/recipe_filters.dto.dart';
import 'package:pantry_chef/features/recipe/domain/models/recipe.dart';
import 'package:pantry_chef/features/recipe/domain/usecases/index.dart';

part 'recipe_event.dart';
part 'recipe_state.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  RecipeBloc() : super(RecipeState()) {
    on<RecipeListFetched>((_, emit) async {
      emit(state.copyWith(isFetching: true));
      GetRecipeListUsecase useCase = GetRecipeListUsecase();
      try {
        List<Recipe> result = await useCase();
        emit(state.copyWith(items: result));
      } finally {
        emit(state.copyWith(isFetching: false));
      }
    });

    on<RecipeMatching>((_, emit) async {
      emit(state.copyWith(isFetching: true));
      RecipeMatchingUsecase useCase = RecipeMatchingUsecase();
      try {
        List<Recipe> result = await useCase(RecipeFiltersDto());
        emit(state.copyWith(items: result));
      } finally {
        emit(state.copyWith(isFetching: false));
      }
    });

    on<RecipeDetailedSelected>((event, emit) {
      emit(state.copyWith(detailedItemId: event.id));
    });

    on<RecipeListReseted>((_, emit) {
      emit(RecipeState());
    });
  }
}
