import 'package:flutter_test/flutter_test.dart';
import 'package:pantry_chef/features/recipe/data/dto/index.dart';
import 'package:pantry_chef/features/recipe/domain/models/recipe.dart';
import 'package:pantry_chef/features/recipe/domain/usecases/get_suggestions.usecase.dart';
import 'package:pantry_chef/features/recipe/presentation/suggestions/bloc/suggestions_bloc.dart';

class _FakeGetSuggestionsUsecase implements GetSuggestionsUsecase {
  RecipeSuggestionsResponseDto? result;
  bool shouldThrow = false;

  @override
  Future<RecipeSuggestionsResponseDto> call(RecipeFiltersDto params) async {
    if (shouldThrow) {
      throw Exception('boom');
    }
    return result!;
  }
}

void main() {
  test('emits fetching then loaded state with items', () async {
    const recipe = Recipe(
      id: '1',
      title: 't',
      description: 'd',
      ingridientList: [],
      instructions: [],
      prepTime: 0,
      cookTime: 0,
      servings: 1,
      difficulty: 'easy',
      tags: [],
      imageUrl: 'https://example.com/x.png',
      matchScore: 1.0,
    );
    final suggestions = <RecipeSuggestionDto>[
      const RecipeSuggestionDto(
        recipe: recipe,
        matchScore: 1.0,
        status: 'READY',
        isQuickMake: true,
        missingIngredients: [],
      ),
    ];
    final fake = _FakeGetSuggestionsUsecase()
      ..result = RecipeSuggestionsResponseDto(data: suggestions, hasMore: true);
    final bloc = SuggestionsBloc(fake);
    addTearDown(bloc.close);

    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        predicate<SuggestionsState>(
          (s) => s.isFetching && s.items == null && s.error == null,
        ),
        predicate<SuggestionsState>(
          (s) => s.isFetching && s.items == suggestions && s.error == null,
        ),
        predicate<SuggestionsState>(
          (s) =>
              !s.isFetching &&
              s.items == suggestions &&
              s.hasMore &&
              s.error == null,
        ),
      ]),
    );

    bloc.add(const SuggestionsFetched());
    await expectation;
  });

  test('emits empty items list when result has no suggestions', () async {
    final fake = _FakeGetSuggestionsUsecase()
      ..result = const RecipeSuggestionsResponseDto(data: [], hasMore: false);
    final bloc = SuggestionsBloc(fake);
    addTearDown(bloc.close);

    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        predicate<SuggestionsState>(
          (s) => s.isFetching && s.error == null,
        ),
        predicate<SuggestionsState>(
          (s) => s.items != null && s.items!.isEmpty && s.error == null,
        ),
        predicate<SuggestionsState>(
          (s) =>
              !s.isFetching &&
              s.items != null &&
              s.items!.isEmpty &&
              s.error == null,
        ),
      ]),
    );

    bloc.add(const SuggestionsFetched());
    await expectation;
  });

  test('emits error state when use case throws', () async {
    final fake = _FakeGetSuggestionsUsecase()..shouldThrow = true;
    final bloc = SuggestionsBloc(fake);
    addTearDown(bloc.close);

    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        predicate<SuggestionsState>(
          (s) => s.isFetching && s.error == null,
        ),
        predicate<SuggestionsState>(
          (s) => s.error == 'Exception: boom',
        ),
        predicate<SuggestionsState>(
          (s) => !s.isFetching && s.error == 'Exception: boom',
        ),
      ]),
    );

    bloc.add(const SuggestionsFetched());
    await expectation;
  });
}
