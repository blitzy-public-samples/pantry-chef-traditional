part of 'ingredient_add_bloc.dart';

/// Sealed base class for all events handled by `IngredientAddBloc`.
///
/// Has four concrete subclasses spanning the add-form lifecycle:
/// `CategoriesAndUnitsFetched`, `IngredientSearch`, `DataChanged`, and
/// `IngredientCreated`.
sealed class IngredientAddEvent extends Equatable {
  /// Default const constructor; allows subclasses to be `const`-constructed.
  const IngredientAddEvent();

  @override
  List<Object?> get props => [];
}

/// Event dispatched on screen mount by `IngredientAddingForm` to populate the
/// category and unit dropdowns.
///
/// `IngredientAddBloc` calls `GetIngredientCategoriesAndUnitsUsecase` and seeds
/// `categoryId`/`unitId` from the first available reference values.
class CategoriesAndUnitsFetched extends IngredientAddEvent {}

/// Event dispatched on every search-field text change (initial query, `page: 1`)
/// and on scroll-prefetch (next page, current query).
///
/// Triggers `IngredientAddBloc` to invoke `SearchIngredientUsecase` with a
/// `SearchDto` and update `state.searchResult`, `state.page`,
/// `state.isNextPageAvailable`, and `state.isFetching`.
class IngredientSearch extends IngredientAddEvent {
  /// The current search query. The bloc lower-cases it via
  /// `event.query.toLowerCase()` before passing to the backend.
  final String query;
  /// Optional explicit page number. When null, the bloc falls back to
  /// `state.page` (current page). When 1, the bloc replaces
  /// `state.searchResult`; otherwise it appends to it.
  final int? page;

  /// Creates a search event with the required [query] and optional [page].
  const IngredientSearch({required this.query, this.page});

  @override
  List<Object?> get props => [query];
}

/// Event dispatched on every form-field change.
///
/// Each field is independently optional so individual fields can be updated
/// without overwriting others. Two fields (`selectedIngredient` and `quantity`)
/// use the `Nullable<T>` wrapper from `core/utils/nullable_wrapper.dart` so the
/// bloc can distinguish "field not touched in this event" from "field
/// explicitly cleared to null"; other fields use plain nullable types where the
/// absence of a value semantically means "leave existing value untouched".
class DataChanged extends IngredientAddEvent {
  /// Updates the currently-selected ingredient.
  ///
  /// Pass `Nullable.value(ingredient)` to set, `const Nullable.value(null)` to
  /// clear, or omit (leave null) to leave unchanged. Set via the search dialog
  /// selection callback in `IngredientAddingForm`.
  final Nullable<Ingredient>? selectedIngredient;
  /// Updates the ingredient name. Null means "leave unchanged".
  final String? ingredientName;
  /// Updates the selected category id (references `Category.id` in the reference
  /// data). Null means "leave unchanged".
  final int? categoryId;
  /// Updates the quantity input.
  ///
  /// Pass `Nullable.value('1.5')` to set, `const Nullable.value(null)` to clear
  /// (when the input is emptied), or omit to leave unchanged.
  final Nullable<String>? quantity;
  /// Updates the selected unit id (references `Unit.id` in the reference data).
  /// Null means "leave unchanged".
  final int? unitId;
  /// Updates the image URL associated with the ingredient. Null means
  /// "leave unchanged".
  final String? imageUrl;
  /// Updates the expiration date (ISO-8601 string). Null means "leave unchanged".
  final String? expirationDate;
  /// Updates the current search query mirror in state. Null means
  /// "leave unchanged".
  final String? query;
  /// Updates the storage location (`'fridge'`, `'freezer'`, or `'pantry'` from
  /// `ingredientLocation`). Null means "leave unchanged".
  final String? location;

  /// Creates a `DataChanged` event with any subset of fields populated.
  ///
  /// All parameters are optional; only the fields actually present in the event
  /// update state, all others remain as-is.
  const DataChanged({
    this.selectedIngredient,
    this.ingredientName,
    this.categoryId,
    this.quantity,
    this.unitId,
    this.imageUrl,
    this.expirationDate,
    this.query,
    this.location,
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
        query,
        location,
      ];
}

/// Event dispatched when the user taps "Add" on the form with no pre-selected
/// ingredient.
///
/// `IngredientAddBloc` builds a `CreateIngredientDto` from the current state
/// and invokes `CreateIngredientUsecase` to persist a new ingredient
/// server-side; on success emits `state.copyWith(createdIngredient: result)`
/// which the form then forwards to `PantryBloc` via `PantryItemAdded`.
class IngredientCreated extends IngredientAddEvent {}
