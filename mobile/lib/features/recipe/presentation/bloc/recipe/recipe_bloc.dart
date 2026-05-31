import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:pantry_chef/features/recipe/data/dto/recipe_filters.dto.dart';
import 'package:pantry_chef/features/recipe/domain/models/recipe.dart';
import 'package:pantry_chef/features/recipe/domain/usecases/index.dart';

// Events and state are declared in the companion part files below.
part 'recipe_event.dart';
part 'recipe_state.dart';

/// BLoC that orchestrates the recipe screen: fetching, matching,
/// detail selection, and reset.
///
/// Seeds the initial [RecipeState] and registers one handler per
/// [RecipeEvent].
class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  RecipeBloc() : super(RecipeState()) {
    // Seed the initial state and register one handler per event.
    on<RecipeListFetched>((_, emit) async {
      // Toggle the loading flag on before fetching.
      emit(state.copyWith(isFetching: true));
      // Load the full recipe list via the use case.
      GetRecipeListUsecase useCase = GetRecipeListUsecase();
      try {
        List<Recipe> result = await useCase();
        // Store the loaded recipes into state.items.
        emit(state.copyWith(items: result));
      } finally {
        // finally guarantees the loading flag is reset to false.
        emit(state.copyWith(isFetching: false));
      }
    });

    on<RecipeMatching>((_, emit) async {
      // Toggle the loading flag on before matching.
      emit(state.copyWith(isFetching: true));
      // Run matching with a default RecipeFiltersDto() (no filters).
      RecipeMatchingUsecase useCase = RecipeMatchingUsecase();
      try {
        List<Recipe> result = await useCase(RecipeFiltersDto());
        // Store the matched recipes into state.items.
        emit(state.copyWith(items: result));
      } finally {
        // finally guarantees the loading flag is reset to false.
        emit(state.copyWith(isFetching: false));
      }
    });

    on<RecipeDetailedSelected>((event, emit) {
      // Synchronous: store the selected recipe id in state.
      emit(state.copyWith(detailedItemId: event.id));
    });

    on<RecipeListReseted>((_, emit) {
      // Synchronous: re-emit a fresh RecipeState() to clear screen.
      emit(RecipeState());
    });
  }
}
