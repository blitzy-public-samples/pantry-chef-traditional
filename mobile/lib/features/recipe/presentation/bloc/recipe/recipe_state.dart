part of 'recipe_bloc.dart';

class RecipeState extends Equatable {
  final List<Recipe>? items;
  final bool isFetching;
  final String? detailedItemId;

  const RecipeState({
    this.items,
    this.isFetching = false,
    this.detailedItemId,
  });

  @override
  List<Object?> get props => [
        items,
        isFetching,
        detailedItemId,
      ];

  RecipeState copyWith({
    final List<Recipe>? items,
    final bool? isFetching,
    final String? detailedItemId,
  }) =>
      RecipeState(
        items: items ?? this.items,
        isFetching: isFetching ?? this.isFetching,
        detailedItemId: detailedItemId ?? this.detailedItemId,
      );
}
