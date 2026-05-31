part of 'suggestions_bloc.dart';

class SuggestionsState extends Equatable {
  final List<RecipeSuggestionDto>? items;
  final bool isFetching;
  final String? error;
  final bool hasMore;
  final RecipeFiltersDto filters;
  // Added for QA FINAL Issue #2: mirrors the backend's pantry-empty flag so the
  // screen can render the empty-pantry guidance state even though the backend
  // still returns (score-0) recipes for an empty pantry.
  final bool isPantryEmpty;

  const SuggestionsState({
    this.items,
    this.isFetching = false,
    this.error,
    this.hasMore = false,
    this.filters = const RecipeFiltersDto(),
    this.isPantryEmpty = false,
  });

  @override
  List<Object?> get props => [
        items,
        isFetching,
        error,
        hasMore,
        filters,
        isPantryEmpty,
      ];

  SuggestionsState copyWith({
    List<RecipeSuggestionDto>? items,
    bool? isFetching,
    Nullable<String>? error,
    bool? hasMore,
    RecipeFiltersDto? filters,
    bool? isPantryEmpty,
  }) =>
      SuggestionsState(
        items: items ?? this.items,
        isFetching: isFetching ?? this.isFetching,
        error: error != null ? error.value : this.error,
        hasMore: hasMore ?? this.hasMore,
        filters: filters ?? this.filters,
        isPantryEmpty: isPantryEmpty ?? this.isPantryEmpty,
      );
}
