part of 'ingredient_add_bloc.dart';

sealed class IngredientAddEvent extends Equatable {
  const IngredientAddEvent();

  @override
  List<Object?> get props => [];
}

class CategoriesAndUnitsFetched extends IngredientAddEvent {}

class IngredientSearch extends IngredientAddEvent {
  final String query;
  final int? page;

  const IngredientSearch({required this.query, this.page});

  @override
  List<Object?> get props => [query];
}

class DataChanged extends IngredientAddEvent {
  final Nullable<Ingredient>? selectedIngredient;
  final String? ingredientName;
  final int? categoryId;
  final Nullable<String>? quantity;
  final int? unitId;
  final String? imageUrl;
  final String? expirationDate;
  final String? query;
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

class IngredientCreated extends IngredientAddEvent {}
