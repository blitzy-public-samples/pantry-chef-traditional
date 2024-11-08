import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pantry_chef/features/pantry/data/dto/update_pantry_item.dto.dart';
import 'package:pantry_chef/features/pantry/domain/models/pantry_item.dart';
import 'package:pantry_chef/features/pantry/domain/usecases/index.dart';

part 'pantry_item_edit_event.dart';
part 'pantry_item_edit_state.dart';

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
