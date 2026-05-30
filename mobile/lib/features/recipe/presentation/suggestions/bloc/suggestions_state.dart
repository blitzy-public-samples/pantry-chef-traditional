part of 'suggestions_bloc.dart';

class SuggestionsState extends Equatable {
  final List<RecipeSuggestionDto>? items;
  final bool isFetching;
  final String? error;
  final bool hasMore;
  final RecipeFiltersDto filters;

  const SuggestionsState({
    this.items,
    this.isFetching = false,
    this.error,
    this.hasMore = false,
    this.filters = const RecipeFiltersDto(),
  });

  @override
  List<Object?> get props => [
        items,
        isFetching,
        error,
        hasMore,
        filters,
      ];

  SuggestionsState copyWith({
    List<RecipeSuggestionDto>? items,
    bool? isFetching,
    Nullable<String>? error,
    bool? hasMore,
    RecipeFiltersDto? filters,
  }) =>
      SuggestionsState(
        items: items ?? this.items,
        isFetching: isFetching ?? this.isFetching,
        error: error != null ? error.value : this.error,
        hasMore: hasMore ?? this.hasMore,
        filters: filters ?? this.filters,
      );
}
