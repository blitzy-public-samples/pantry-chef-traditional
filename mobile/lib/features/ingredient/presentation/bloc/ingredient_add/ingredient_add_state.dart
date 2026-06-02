part of 'ingredient_add_bloc.dart';

/// Immutable state for the add-ingredient flow: form data,
/// reference data, search results, pagination, loading flags,
/// and the created-ingredient result.
class IngredientAddState extends Equatable {
  /// Loaded categories and units reference data.
  final IngredientAddData? categoriesAndUnits;
  /// Ingredient chosen from search or detection, if any.
  final Ingredient? selectedIngredient;
  /// Current name entered for the ingredient.
  final String? ingredientName;
  /// Selected category id.
  final int? categoryId;
  /// Entered quantity as a raw string (parsed on submit).
  final String? quantity;
  /// Selected unit id.
  final int? unitId;
  /// Storage location; defaults to ingredientLocation[0].
  final String? location;
  /// Optional image URL for the ingredient.
  final String? imageUrl;
  /// Optional expiration date string.
  final String? expirationDate;
  /// Accumulated search results (appended when paging).
  final List<Ingredient>? searchResult;
  /// Current search query; defaults to ''.
  final String query;
  /// Current 1-based page index; defaults to 1.
  final int page;
  /// Search page size; defaults to 20.
  final int limit;
  /// Whether another page may exist; defaults to true.
  final bool isNextPageAvailable;
  /// Result of a successful create, if any.
  final Ingredient? createdIngredient;
  /// Whether a search is in flight; defaults to true.
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

  /// Fields used for value equality.
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

  /// Returns a copy of this state with the given overrides.
  ///
  /// [selectedIngredient] and [quantity] accept `Nullable<>`
  /// wrappers so they can be set to null explicitly; every other
  /// field falls back to the current value when its arg is null.
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
        // Nullable unwrap: a passed wrapper sets the field to
        // wrapper.value (maybe null); a null arg keeps the current.
        selectedIngredient: selectedIngredient != null ? selectedIngredient.value : this.selectedIngredient,
        ingredientName: ingredientName ?? this.ingredientName,
        categoryId: categoryId ?? this.categoryId,
        // Same Nullable unwrap pattern as selectedIngredient above.
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
