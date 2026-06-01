import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:pantry_chef/features/pantry/data/dto/create_pantry_item.dto.dart';
import 'package:pantry_chef/features/pantry/domain/models/pantry_item.dart';
import 'package:pantry_chef/features/pantry/domain/usecases/add_to_pantry.usecase.dart';
import 'package:pantry_chef/features/pantry/domain/usecases/pantry_items_fetch.usecase.dart';

part 'pantry_event.dart';
part 'pantry_state.dart';

/// Collection-level state holder for the pantry feature.
///
/// Extends [Bloc] with [HydratedMixin] so the pantry list is auto-persisted
/// to [HydratedBloc.storage] (configured in `mobile/lib/main.dart:L14-L16`
/// using `getTemporaryDirectory()` from `path_provider ^2.1.5`).
///
/// Handles five events:
/// * [PantryItemsFetched] — list refresh via [FetchPantryItemsUsecase].
/// * [PantryItemAdded] — POST then prepend to list.
/// * [PantryItemUpdated] — in-memory list mutation (replace by id).
/// * [PantryItemDeleted] — in-memory list mutation (filter out by id).
/// * [PantryListReseted] — emit fresh empty state (used on logout).
///
/// Consumers in the screen layer (e.g.,
/// `presentation/widgets/screens/patry_main.dart`) dispatch these events;
/// the edit bloc in `../pantry_edit_item/` dispatches [PantryItemUpdated]
/// and [PantryItemDeleted] via the screen's listeners after successful
/// PATCH/DELETE calls.
class PantryBloc extends Bloc<PantryEvent, PantryState> with HydratedMixin {
  /// Initializes the bloc with an empty [PantryState] and immediately
  /// invokes [hydrate] (Source: L13) to restore any previously-persisted
  /// list from [HydratedBloc.storage] before the first event is processed.
  ///
  /// Registers five event handlers on construction:
  /// * [PantryItemsFetched] delegates to [FetchPantryItemsUsecase] and
  ///   replaces `state.items` with the result.
  /// * [PantryItemAdded] delegates to [AddToPantryUsecase] and prepends the
  ///   returned item to `state.items` (defensive `?? []` when items is null).
  /// * [PantryItemUpdated] performs an in-memory replace by `id`.
  /// * [PantryItemDeleted] performs an in-memory filter by `id`.
  /// * [PantryListReseted] emits a fresh empty `PantryState()`.
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

  /// Deserializes the persisted state's `items` list from JSON.
  ///
  /// Maps each JSON entry to a [PantryItem] via [PantryItem.fromJson].
  /// Returns a fresh [PantryState] whose `items` defaults to an empty list
  /// when `json['items']` is `null`. Called automatically by [HydratedMixin]
  /// during construction (Source: L13 `hydrate()`).
  @override
  PantryState? fromJson(Map<String, dynamic> json) {
    return PantryState(
      items: (json['items'] as List<dynamic>?)?.map((e) => PantryItem.fromJson(e)).toList() ?? [],
    );
  }

  /// Serializes the state for [HydratedBloc] persistence.
  ///
  /// Delegates per-element serialization to [PantryItem.toJson] via the
  /// default JSON encoder when [HydratedBloc] writes the map to storage.
  /// Called automatically by [HydratedMixin] after each `emit`.
  @override
  Map<String, dynamic>? toJson(PantryState state) {
    return {
      'items': state.items,
    };
  }
}
