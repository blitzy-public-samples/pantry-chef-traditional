import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:pantry_chef/features/pantry/data/dto/create_pantry_item.dto.dart';
import 'package:pantry_chef/features/pantry/domain/models/pantry_item.dart';
import 'package:pantry_chef/features/pantry/domain/usecases/add_to_pantry.usecase.dart';
import 'package:pantry_chef/features/pantry/domain/usecases/pantry_items_fetch.usecase.dart';

part 'pantry_event.dart';
part 'pantry_state.dart';

class PantryBloc extends Bloc<PantryEvent, PantryState> with HydratedMixin {
  PantryBloc() : super(PantryState()) {
    hydrate();

    on<PantryItemsFetched>((_, emit) async {
      FetchPantryItemsUsecase useCase = FetchPantryItemsUsecase();
      List<PantryItem> result = await useCase();
      emit(state.copyWith(items: result));
    });

    on<PantryItemAdded>((event, emit) async {
      AddToPantryUsecase useCase = AddToPantryUsecase();
      PantryItem result = await useCase(event.dto);
      List<PantryItem> items = state.items ?? [];
      emit(state.copyWith(items: [result, ...items]));
    });

    on<PantryItemUpdated>((event, emit) {
      List<PantryItem> updatedList = List.from(state.items!);
      int index = updatedList.indexWhere((el) => el.id == event.item.id);
      updatedList[index] = event.item;
      emit(state.copyWith(items: updatedList));
    });

    on<PantryItemDeleted>((event, emit) {
      emit(state.copyWith(items: state.items!.where((el) => el.id != event.id).toList()));
    });

    on<PantryListReseted>((_, emit) {
      emit(PantryState());
    });
  }

  @override
  PantryState? fromJson(Map<String, dynamic> json) {
    return PantryState(
      items: (json['items'] as List<dynamic>?)?.map((e) => PantryItem.fromJson(e)).toList() ?? [],
    );
  }

  @override
  Map<String, dynamic>? toJson(PantryState state) {
    return {
      'items': state.items,
    };
  }
}
