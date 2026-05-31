part of 'ingredient_add_bloc.dart';

/// Immutable state of `IngredientAddBloc`.
///
/// Aggregates the in-progress add-form data (`selectedIngredient`,
/// `ingredientName`, `categoryId`, `quantity`, `unitId`, `location`, `imageUrl`,
/// `expirationDate`), the reference data (`categoriesAndUnits`), the
/// search-as-you-type state (`searchResult`, `query`, `page`, `limit`,
/// `isNextPageAvailable`, `isFetching`), and the result of a successful create
/// (`createdIngredient`). Designed to be transformed via `copyWith` which uses
/// the `Nullable<T>` wrapper for two fields (`selectedIngredient` and
/// `quantity`) to support explicit clearing.
class IngredientAddState extends Equatable {
  /// Reference data fetched by `CategoriesAndUnitsFetched`.
  ///
  /// Null until the fetch completes; non-null thereafter. The UI gates rendering
  /// on `categoriesAndUnits != null`.
  final IngredientAddData? categoriesAndUnits;
  /// The ingredient currently selected from search results (or seeded from AI
  /// vision via constructor).
  ///
  /// Null for brand-new ingredients created from a raw typed name.
  final Ingredient? selectedIngredient;
  /// The ingredient's display name.
  ///
  /// Set either by `selectedIngredient.name` when a match is chosen, or by the
  /// raw typed query when the user opts "Use this name".
  final String? ingredientName;
  /// Currently selected category id.
  ///
  /// Initially seeded from `selectedIngredient?.category.id` (constructor), then
  /// from `categoriesAndUnits.categories[0].id` (`CategoriesAndUnitsFetched`),
  /// then by user choice (`DataChanged`).
  final int? categoryId;
  /// Quantity as a free-text string (numeric input).
  ///
  /// Parsed via `double.parse(state.quantity!)` only at submit time. May contain
  /// decimals.
  final String? quantity;
  /// Currently selected unit id.
  ///
  /// Seeded from `categoriesAndUnits.units[0].id` and updated via `DataChanged`.
  final int? unitId;
  /// Storage location, one of `'fridge'`, `'freezer'`, `'pantry'` from
  /// `ingredientLocation`.
  ///
  /// Defaults to `'fridge'` (the first element of `ingredientLocation`).
  final String? location;
  /// Optional image URL.
  final String? imageUrl;
  /// Expiration date as an ISO-8601 string.
  ///
  /// Parsed via `DateTime.parse` when displayed in the date picker.
  final String? expirationDate;
  /// Paginated search results.
  ///
  /// Null before the first `IngredientSearch`; replaced when fetching `page == 1`;
  /// appended otherwise.
  final List<Ingredient>? searchResult;
  /// Mirror of the most recent search query. Defaults to empty string.
  ///
  /// Used by scroll-prefetch in `_SearchDialogState` to keep paginating with the
  /// same query.
  final String query;
  /// Current page number. Defaults to 1.
  ///
  /// "Next page to request when scrolling is `state.page + 1`".
  final int page;
  /// Page size sent to the backend. Defaults to 20.
  ///
  /// Used by the bloc to set `isNextPageAvailable: result.length == state.limit`.
  final int limit;
  /// Whether the backend likely has more results.
  ///
  /// Set to `result.length == state.limit` after each fetch. Used to gate the
  /// scroll-prefetch trigger in `_SearchDialogState`.
  final bool isNextPageAvailable;
  /// The newly created ingredient returned by `CreateIngredientUsecase`.
  ///
  /// Null until `IngredientCreated` succeeds; non-null thereafter.
  /// `IngredientAddingForm` listens for this transition and forwards a
  /// `PantryItemAdded` event to the upstream `PantryBloc`.
  final Ingredient? createdIngredient;
  /// Whether an `IngredientSearch` request is in flight.
  ///
  /// Set to `true` at the start of each search and `false` after results arrive.
  /// Defaults to `true` so the initial render shows the loader.
  final bool isFetching;

  /// Creates an `IngredientAddState`.
  ///
  /// All fields are optional. Defaults: `query = ''`, `page = 1`, `limit = 20`,
  /// `isNextPageAvailable = true`, `isFetching = true`.
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

  /// Returns a new `IngredientAddState` with the supplied fields replaced.
  ///
  /// The [selectedIngredient] and [quantity] parameters are `Nullable<T>?`
  /// wrappers: pass `Nullable.value(value)` to set,
  /// `const Nullable.value(null)` to explicitly clear, or omit (null) to leave
  /// unchanged. All other parameters use plain nullable types where null means
  /// "leave unchanged".
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
