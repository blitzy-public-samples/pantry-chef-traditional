part of 'suggestions_bloc.dart';

sealed class SuggestionsEvent extends Equatable {
  const SuggestionsEvent();

  @override
  List<Object> get props => [];
}

class SuggestionsFetched extends SuggestionsEvent {
  final RecipeFiltersDto filters;

  const SuggestionsFetched({this.filters = const RecipeFiltersDto()});

  @override
  List<Object> get props => [filters];
}
