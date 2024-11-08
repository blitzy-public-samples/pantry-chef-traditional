import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pantry_chef/core/constants/ingredient_location.dart';
import 'package:pantry_chef/core/data/dto/index.dart';
import 'package:pantry_chef/core/utils/nullable_wrapper.dart';
import 'package:pantry_chef/features/ingredient/data/dto/index.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient_add_data.dart';
import 'package:pantry_chef/features/ingredient/domain/usecases/index.dart';

part 'ingredient_add_event.dart';
part 'ingredient_add_state.dart';

class IngredientAddBloc extends Bloc<IngredientAddEvent, IngredientAddState> {
  IngredientAddBloc({Ingredient? detectedIngredient})
      : super(IngredientAddState(
          selectedIngredient: detectedIngredient,
          ingredientName: detectedIngredient?.name,
          categoryId: detectedIngredient?.category.id,
          location: ingredientLocation[0],
        )) {
    on<CategoriesAndUnitsFetched>((event, emit) async {
      GetIngredientCategoriesAndUnitsUsecase useCase = GetIngredientCategoriesAndUnitsUsecase();
      IngredientAddData result = await useCase();
      emit(
        state.copyWith(
          categoriesAndUnits: result,
          categoryId: result.categories[0].id,
          unitId: result.units[0].id,
        ),
      );
    });

    on<DataChanged>((event, emit) {
      emit(
        state.copyWith(
          selectedIngredient: event.selectedIngredient,
          ingredientName: event.ingredientName,
          categoryId: event.categoryId,
          unitId: event.unitId,
          quantity: event.quantity,
          imageUrl: event.imageUrl,
          expirationDate: event.expirationDate,
          query: event.query,
          location: event.location,
        ),
      );
    });

    on<IngredientSearch>((event, emit) async {
      emit(state.copyWith(isFetching: true));
      SearchIngredientUsecase useCase = SearchIngredientUsecase();
      List<Ingredient> result = await useCase(
        SearchDto(
          query: event.query.toLowerCase(),
          page: event.page ?? state.page,
          limit: state.limit,
          sort: [OrderDto(orderBy: 'name', order: 'ASC')],
        ),
      );
      emit(
        state.copyWith(
          searchResult: event.page == 1 ? result : [...state.searchResult!, ...result],
          page: event.page,
          query: event.query,
          isNextPageAvailable: result.length == state.limit,
          isFetching: false,
        ),
      );
    });

    on<IngredientCreated>((_, emit) async {
      CreateIngredientUsecase useCase = CreateIngredientUsecase();
      Ingredient result = await useCase(
        CreateIngredientDto(
          name: state.ingredientName!,
          category: state.categoriesAndUnits!.categories.firstWhere((el) => el.id == state.categoryId),
          quantity: double.parse(state.quantity!),
          unit: state.categoriesAndUnits!.units.firstWhere((el) => el.id == state.categoryId),
        ),
      );
      emit(state.copyWith(createdIngredient: result));
    });
  }
}
