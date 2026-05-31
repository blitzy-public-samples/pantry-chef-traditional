import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pantry_chef/features/pantry/data/dto/update_pantry_item.dto.dart';
import 'package:pantry_chef/features/pantry/domain/models/pantry_item.dart';
import 'package:pantry_chef/features/pantry/domain/usecases/index.dart';

part 'pantry_item_edit_event.dart';
part 'pantry_item_edit_state.dart';

/// Single-item edit form's state holder.
///
/// Unlike [PantryBloc], this bloc does **NOT** use [HydratedMixin] — the edit
/// form is ephemeral; state is seeded from the parent screen at
/// `presentation/widgets/screens/pantry_item_edit.dart:L40-L46` via
/// [BlocProvider].
///
/// Handles three events: [DataChanged], [ChangedDataSaved], [DeleteConfirmed].
/// On successful save, sets `state.updatedItem`; on successful delete, sets
/// `state.deleted = true`. The parent screen listens for these terminal
/// states and dispatches `PantryItemUpdated` / `PantryItemDeleted` to the
/// ancestor [PantryBloc] before popping the route
/// (Source: `pantry_item_edit.dart:L59-L72`).
class PantryItemEditBloc extends Bloc<PantryItemEditEvent, PantryItemEditState> {
  /// Initializes state with the current item's persisted values.
  ///
  /// **Note**: [quantity] is received as `double` but stored in state as
  /// `String` via `quantity.toString()` (Source: L20) so it can drive the
  /// editable `TextFieldInput` directly. It is parsed back to `double` via
  /// `double.parse(state.quantity)` in the [ChangedDataSaved] handler
  /// (Source: L46) before being sent to the backend.
  ///
  /// Registers three event handlers on construction:
  /// * [DataChanged] — updates editable fields and clears quantityError.
  /// * [ChangedDataSaved] — validates, calls [PantryItemUpdateUsecase],
  ///   emits `updatedItem`.
  /// * [DeleteConfirmed] — calls [PantryItemDeleteUsecase], emits
  ///   `deleted: true`.
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
    // DataChanged → updates editable fields; clears quantityError when a
    // non-null quantity is provided.
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

    // ChangedDataSaved → validates quantity (empty short-circuits with
    // quantityError:true), then invokes PantryItemUpdateUsecase and emits
    // updatedItem. The `finally` block always clears isFetching.
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

    // DeleteConfirmed → invokes PantryItemDeleteUsecase(id) and emits
    // deleted:true. The `finally` block always clears isFetching.
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
