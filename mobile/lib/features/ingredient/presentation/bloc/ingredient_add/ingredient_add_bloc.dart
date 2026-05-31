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

/// BLoC that drives the add-ingredient flow.
///
/// Handles four events:
/// - `CategoriesAndUnitsFetched`: loads categories + units via
///   [GetIngredientCategoriesAndUnitsUsecase].
/// - `DataChanged`: copies edited form fields into state.
/// - `IngredientSearch`: paginated search via
///   [SearchIngredientUsecase] using [SearchDto]/[OrderDto].
/// - `IngredientCreated`: creates the ingredient via
///   [CreateIngredientUsecase].
class IngredientAddBloc extends Bloc<IngredientAddEvent, IngredientAddState> {
  /// Creates the BLoC; an optional [detectedIngredient] seeds the
  /// initial state (selectedIngredient, ingredientName, categoryId)
  /// and the location always defaults to ingredientLocation[0]
  /// (`'fridge'`).
  IngredientAddBloc({Ingredient? detectedIngredient})
      : super(IngredientAddState(
          selectedIngredient: detectedIngredient,
          ingredientName: detectedIngredient?.name,
          categoryId: detectedIngredient?.category.id,
          location: ingredientLocation[0],
        )) {
    on<CategoriesAndUnitsFetched>((event, emit) async {
      // Loads reference data, then seeds default category/unit
      // selections from the first returned category and unit.
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
      // Copies every editable form field from the event into state
      // via copyWith (selectedIngredient, ingredientName, categoryId,
      // unitId, quantity, imageUrl, expirationDate, query, location).
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
      // Sets isFetching true, then runs the search use case with a
      // SearchDto: query lowercased, page = event.page ?? state.page,
      // limit = state.limit, sort by name ASC.
      // Page 1 replaces searchResult; later pages append (spread of
      // existing + new). isNextPageAvailable = result.length ==
      // state.limit; isFetching reset to false.
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
      // Builds a CreateIngredientDto from current state
      // (name, category by id, quantity parsed to double, unit)
      // and stores the created Ingredient via copyWith.
      CreateIngredientUsecase useCase = CreateIngredientUsecase();
      Ingredient result = await useCase(
        CreateIngredientDto(
          name: state.ingredientName!,
          category: state.categoriesAndUnits!.categories.firstWhere((el) => el.id == state.categoryId),
          quantity: double.parse(state.quantity!),
          // KNOWN ISSUE: unit is resolved by matching el.id ==
          // state.categoryId instead of state.unitId, so the unit can
          // be wrong. Documented per AAP; do NOT fix here.
          unit: state.categoriesAndUnits!.units.firstWhere((el) => el.id == state.categoryId),
        ),
      );
      emit(state.copyWith(createdIngredient: result));
    });
  }
}
