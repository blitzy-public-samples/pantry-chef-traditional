import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pantry_chef/core/utils/nullable_wrapper.dart';
import 'package:pantry_chef/features/recipe/data/dto/index.dart';
import 'package:pantry_chef/features/recipe/domain/usecases/index.dart';

part 'suggestions_event.dart';
part 'suggestions_state.dart';

class SuggestionsBloc extends Bloc<SuggestionsEvent, SuggestionsState> {
  final GetSuggestionsUsecase _useCase;

  SuggestionsBloc([GetSuggestionsUsecase? useCase])
      : _useCase = useCase ?? GetSuggestionsUsecase(),
        super(const SuggestionsState()) {
    on<SuggestionsFetched>(_onFetched);
  }

  Future<void> _onFetched(
    SuggestionsFetched event,
    Emitter<SuggestionsState> emit,
  ) async {
    emit(state.copyWith(isFetching: true, error: const Nullable.value(null)));
    try {
      final result = await _useCase(event.filters);
      emit(
        state.copyWith(
          items: result.data,
          hasMore: result.hasMore,
          filters: event.filters,
          // QA FINAL Issue #2: propagate the backend's pantry-empty flag so the
          // screen can render the empty-pantry guidance state.
          isPantryEmpty: result.isPantryEmpty,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: Nullable.value(e.toString())));
    } finally {
      emit(state.copyWith(isFetching: false));
    }
  }
}
