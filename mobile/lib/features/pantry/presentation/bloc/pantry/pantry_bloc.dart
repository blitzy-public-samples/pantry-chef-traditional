import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:pantry_chef/features/pantry/data/dto/create_pantry_item.dto.dart';
import 'package:pantry_chef/features/pantry/domain/models/pantry_item.dart';
import 'package:pantry_chef/features/pantry/domain/usecases/add_to_pantry.usecase.dart';
import 'package:pantry_chef/features/pantry/domain/usecases/pantry_items_fetch.usecase.dart';

part 'pantry_event.dart';
part 'pantry_state.dart';

/// Manages the pantry item collection for the pantry feature.
///
/// Mixes in [HydratedMixin] and calls `hydrate()` in its
/// constructor, so the pantry list is persisted to and restored
/// from storage across app launches.
class PantryBloc extends Bloc<PantryEvent, PantryState> with HydratedMixin {
  PantryBloc() : super(PantryState()) {
    hydrate();

    // Loads items via FetchPantryItemsUsecase and emits the result.
    on<PantryItemsFetched>((_, emit) async {
      FetchPantryItemsUsecase useCase = FetchPantryItemsUsecase();
      List<PantryItem> result = await useCase();
      emit(state.copyWith(items: result));
    });

    // Adds via AddToPantryUsecase, then prepends it to the list.
    on<PantryItemAdded>((event, emit) async {
      AddToPantryUsecase useCase = AddToPantryUsecase();
      PantryItem result = await useCase(event.dto);
      List<PantryItem> items = state.items ?? [];
      emit(state.copyWith(items: [result, ...items]));
    });

    // Replaces the matching item by index in a copied list.
    on<PantryItemUpdated>((event, emit) {
      List<PantryItem> updatedList = List.from(state.items!);
      int index = updatedList.indexWhere((el) => el.id == event.item.id);
      updatedList[index] = event.item;
      emit(state.copyWith(items: updatedList));
    });

    on<PantryItemDeleted>((event, emit) {
      // Removes the item whose id matches event.id from the list.
      emit(state.copyWith(items: state.items!.where((el) => el.id != event.id).toList()));
    });

    // Resets the state to an empty PantryState().
    on<PantryListReseted>((_, emit) {
      emit(PantryState());
    });
  }

  /// Rebuilds [PantryState] from persisted [json], mapping each
  /// entry via `PantryItem.fromJson`. Returns an empty list when
  /// no items are present.
  @override
  PantryState? fromJson(Map<String, dynamic> json) {
    return PantryState(
      items: (json['items'] as List<dynamic>?)?.map((e) => PantryItem.fromJson(e)).toList() ?? [],
    );
  }

  /// Serializes [state] (its `items`) to a JSON map for storage.
  @override
  Map<String, dynamic>? toJson(PantryState state) {
    return {
      'items': state.items,
    };
  }
}
