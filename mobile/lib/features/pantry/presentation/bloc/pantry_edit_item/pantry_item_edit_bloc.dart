import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pantry_chef/features/pantry/data/dto/update_pantry_item.dto.dart';
import 'package:pantry_chef/features/pantry/domain/models/pantry_item.dart';
import 'package:pantry_chef/features/pantry/domain/usecases/index.dart';

part 'pantry_item_edit_event.dart';
part 'pantry_item_edit_state.dart';

/// BLoC backing the single pantry item edit form.
///
/// Seeded from the current item's [id], [location], [quantity] and
/// [expirationDate]. The [quantity] argument is a double and is
/// stored in state as a string via quantity.toString().
/// Handles draft edits plus save (update) and delete actions.
class PantryItemEditBloc extends Bloc<PantryItemEditEvent, PantryItemEditState> {
  PantryItemEditBloc({
    required String id,
    required String location,
    required double quantity,
    required String expirationDate,
  }) : super(
          PantryItemEditState(
            id: id,
            location: location,
            quantity: quantity.toString(),
            expirationDate: expirationDate,
          ),
        ) {
    on<DataChanged>((event, emit) {
      // Update draft form fields; clear quantityError when a
      // non-null quantity is provided.
      emit(
        state.copyWith(
          location: event.location,
          quantity: event.quantity,
          expirationDate: event.expirationDate,
          quantityError: event.quantity != null ? false : state.quantityError,
        ),
      );
    });

    on<ChangedDataSaved>((_, emit) async {
      // Validate quantity is non-empty: set quantityError and
      // return early when empty. Otherwise emit isFetching, build
      // an UpdatePantryItemDto, run PantryItemUpdateUsecase, store
      // the returned item, and clear isFetching in finally.
      if (state.quantity == '') {
        emit(state.copyWith(quantityError: true));
        return;
      }
      emit(state.copyWith(isFetching: true));
      try {
        PantryItemUpdateUsecase useCase = PantryItemUpdateUsecase();
        PantryItem updatedItem = await useCase(
          UpdatePantryItemDto(
            id: id,
            quantity: double.parse(state.quantity),
            location: state.location,
            expirationDate: state.expirationDate,
          ),
        );
        emit(state.copyWith(updatedItem: updatedItem));
      } finally {
        emit(state.copyWith(isFetching: false));
      }
    });

    on<DeleteConfirmed>((_, emit) async {
      // Emit isFetching, run PantryItemDeleteUsecase(id), set
      // deleted on success, and clear isFetching in finally.
      emit(state.copyWith(isFetching: true));
      try {
        PantryItemDeleteUsecase useCase = PantryItemDeleteUsecase();
        await useCase(id);
        emit(state.copyWith(deleted: true));
      } finally {
        emit(state.copyWith(isFetching: false));
      }
    });
  }
}
