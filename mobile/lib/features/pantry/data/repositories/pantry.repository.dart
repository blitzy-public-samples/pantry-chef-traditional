import 'package:pantry_chef/features/pantry/data/api/pantry.api.dart';
import 'package:pantry_chef/features/pantry/data/dto/index.dart';
import 'package:pantry_chef/features/pantry/domain/models/pantry_item.dart';
import 'package:pantry_chef/features/pantry/domain/repositories/pantry.repository.dart';

/// Concrete implementation of the abstract [PantryRepository] contract for
/// the pantry feature's data layer.
///
/// Acts as the architectural seam between higher-level application code
/// (use cases, BLoCs) and the lower-level [PantryApi] HTTP transport.
/// Each method delegates the network call to a freshly constructed
/// [PantryApi] instance, awaits the response, and converts the raw
/// `Map<String, dynamic>` (or `List<dynamic>`) payload into a strongly
/// typed [PantryItem] domain model via `PantryItem.fromJson`.
///
/// Note: each method instantiates a NEW [PantryApi] per call rather than
/// caching a shared instance. The [PantryApi] constructor is cheap — it
/// only resolves `getIt<DioClient>().dio` — so the cost is negligible,
/// but the class deliberately holds no per-instance state.
///
/// See `../../README.md` for the feature-level Pantry README and
/// `../../../../../../ARCHITECTURE.md` for the system architecture.
class PantryRepositoryImpl implements PantryRepository {
  /// POSTs the given [dto] via [PantryApi.createPantryItem] and deserializes
  /// the response body into a [PantryItem] domain model.
  ///
  /// The [dto] carries the new pantry item's `ingridient` (spelling preserved
  /// verbatim — mirrors the backend `PantryIngridient` schema), `quantity`,
  /// `unit`, `location`, and `expirationDate`. The returned [PantryItem]
  /// includes the server-assigned `id`, `createdAt`, and `updatedAt` fields.
  ///
  /// Throws [DioException] on network failure (propagated unchanged from
  /// [PantryApi]).
  @override
  Future<PantryItem> createPantryItem(CreatePantryItemDto dto) async {
    PantryApi api = PantryApi();
    Map<String, dynamic> response = await api.createPantryItem(dto);
    return PantryItem.fromJson(response);
  }

  /// Fetches the authenticated user's pantry items via
  /// [PantryApi.fetchPantryItems] and maps each raw JSON entry into a
  /// [PantryItem] domain model via `PantryItem.fromJson`.
  ///
  /// The backend caps the result at 50 records (pagination cap) — see
  /// `backend/src/pantry/pantry.controller.ts`. Returns a possibly-empty
  /// `List<PantryItem>`. Throws [DioException] on network failure.
  @override
  Future<List<PantryItem>> fetchPantryItems() async {
    PantryApi api = PantryApi();
    List<dynamic> response = await api.fetchPantryItems();
    return response.map((el) => PantryItem.fromJson(el)).toList();
  }

  /// PATCHes the given [dto] via [PantryApi.updatePantryItem] and
  /// deserializes the response body into a [PantryItem] domain model.
  ///
  /// The [dto] carries the target `id` plus the mutable fields `location`,
  /// `quantity`, and `expirationDate`. Returns the updated [PantryItem]
  /// from the backend response. Throws [DioException] on network failure.
  @override
  Future<PantryItem> updatePantryItem(UpdatePantryItemDto dto) async {
    PantryApi api = PantryApi();
    Map<String, dynamic> response = await api.updatePantryItem(dto);
    return PantryItem.fromJson(response);
  }

  /// Awaits [PantryApi.deletePantryItem] to remove a pantry item by [id]
  /// from the backend.
  ///
  /// Note: the backend route is named `softDelete` but the implementation
  /// at `backend/src/pantry/infrastructure/document/repositories/`
  /// `pantryIngridient.repository.ts:L119-L123` calls `deleteOne()` —
  /// physically removing the document despite the soft-delete naming
  /// convention. This mobile `DELETE /api/v1/pantry/:id` request therefore
  /// performs a destructive removal. See
  /// `../../../../../../PRODUCTION_READINESS.md` § Database for the
  /// production-readiness gap and
  /// `../../README.md` § Known Limitations for the feature-level callout.
  ///
  /// Returns `Future<void>`; does not produce a domain object. Throws
  /// [DioException] on network failure.
  @override
  Future<void> deletePantryItem(String id) async {
    PantryApi api = PantryApi();
    await api.deletePantryItem(id);
  }
}
