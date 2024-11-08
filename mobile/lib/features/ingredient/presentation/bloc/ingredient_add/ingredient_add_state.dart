part of 'ingredient_add_bloc.dart';

class IngredientAddState extends Equatable {
  final IngredientAddData? categoriesAndUnits;
  final Ingredient? selectedIngredient;
  final String? ingredientName;
  final int? categoryId;
  final String? quantity;
  final int? unitId;
  final String? location;
  final String? imageUrl;
  final String? expirationDate;
  final List<Ingredient>? searchResult;
  final String query;
  final int page;
  final int limit;
  final bool isNextPageAvailable;
  final Ingredient? createdIngredient;
  final bool isFetching;

  const IngredientAddState({
    this.selectedIngredient,
    this.ingredientName,
    this.categoryId,
    this.quantity,
    this.unitId,
    this.imageUrl,
    this.location,
    this.expirationDate,
    this.categoriesAndUnits,
    this.searchResult,
    this.query = '',
    this.page = 1,
    this.limit = 20,
    this.isNextPageAvailable = true,
    this.createdIngredient,
    this.isFetching = true,
  });

  @override
  List<Object?> get props => [
        selectedIngredient,
        ingredientName,
        categoryId,
        quantity,
        unitId,
        imageUrl,
        expirationDate,
        categoriesAndUnits,
        searchResult,
        query,
        createdIngredient,
        location,
        isNextPageAvailable,
        isFetching
      ];

  IngredientAddState copyWith({
    final Nullable<Ingredient>? selectedIngredient,
    final String? ingredientName,
    final int? categoryId,
    final Nullable<String>? quantity,
    final int? unitId,
    final String? imageUrl,
    final String? location,
    final IngredientAddData? categoriesAndUnits,
    final String? expirationDate,
    final int? page,
    final List<Ingredient>? searchResult,
    final String? query,
    final Ingredient? createdIngredient,
    final bool? isNextPageAvailable,
    final bool? isFetching,
  }) =>
      IngredientAddState(
        selectedIngredient: selectedIngredient != null ? selectedIngredient.value : this.selectedIngredient,
        ingredientName: ingredientName ?? this.ingredientName,
        categoryId: categoryId ?? this.categoryId,
        quantity: quantity != null ? quantity.value : this.quantity,
        unitId: unitId ?? this.unitId,
        imageUrl: imageUrl ?? this.imageUrl,
        location: location ?? this.location,
        expirationDate: expirationDate ?? this.expirationDate,
        categoriesAndUnits: categoriesAndUnits ?? this.categoriesAndUnits,
        page: page ?? this.page,
        searchResult: searchResult ?? this.searchResult,
        query: query ?? this.query,
        createdIngredient: createdIngredient ?? this.createdIngredient,
        isNextPageAvailable: isNextPageAvailable ?? this.isNextPageAvailable,
        isFetching: isFetching ?? this.isFetching,
      );
}
