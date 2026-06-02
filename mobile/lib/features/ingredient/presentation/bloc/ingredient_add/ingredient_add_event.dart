part of 'ingredient_add_bloc.dart';

/// Closed (sealed) event hierarchy for the add-ingredient flow.
sealed class IngredientAddEvent extends Equatable {
  const IngredientAddEvent();

  /// Fields used for value equality.
  @override
  List<Object?> get props => [];
}

/// Requests loading of categories + units reference data.
class CategoriesAndUnitsFetched extends IngredientAddEvent {}

/// Runs a paginated search; carries [query] and optional [page].
class IngredientSearch extends IngredientAddEvent {
  /// Search text to match.
  final String query;
  /// Optional 1-based page to fetch.
  final int? page;

  const IngredientSearch({required this.query, this.page});

  /// Equality is based on [query] only.
  @override
  List<Object?> get props => [query];
}

/// Carries form-field updates for the add-ingredient form.
///
/// Nullable fields use [Nullable] wrappers so [selectedIngredient]
/// and [quantity] can be set to null explicitly.
class DataChanged extends IngredientAddEvent {
  /// Selected ingredient, or [Nullable] to set/clear it.
  final Nullable<Ingredient>? selectedIngredient;
  /// Updated ingredient name.
  final String? ingredientName;
  /// Updated category id.
  final int? categoryId;
  /// Quantity as a string, or [Nullable] to set/clear it.
  final Nullable<String>? quantity;
  /// Updated unit id.
  final int? unitId;
  /// Updated image URL.
  final String? imageUrl;
  /// Updated expiration date string.
  final String? expirationDate;
  /// Updated search query.
  final String? query;
  /// Updated storage location.
  final String? location;

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

  /// Equality is based on all carried fields.
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

/// Submits the current form to create the ingredient.
class IngredientCreated extends IngredientAddEvent {}
