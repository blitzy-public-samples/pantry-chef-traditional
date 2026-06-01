import 'package:pantry_chef/features/pantry/data/dto/index.dart';
import 'package:pantry_chef/features/pantry/domain/models/pantry_item.dart';

/// Persistence contract for pantry items in the mobile domain layer.
///
/// Keeps domain code (use cases, BLoCs) independent of `Dio`/HTTP details by
/// exposing only abstract `Future`-returning operations. Concrete persistence
/// lives in the data layer: `PantryRepositoryImpl` at
/// `mobile/lib/features/pantry/data/repositories/pantry.repository.dart`,
/// which adapts `PantryApi` JSON responses into [PantryItem] domain entities
/// via `PantryItem.fromJson`.
///
/// Mirrors the backend `PantryIngridient` resource (spelling preserved
/// verbatim from the backend codebase); the mobile-side [PantryItem] class
/// uses the correct English spelling, while the field name `ingridient` on
/// [PantryItem] and the DTOs preserves the backend's typo for wire
/// compatibility.
///
/// All methods are user-scoped: the backend resolves `userId` from the JWT
/// bearer token attached by `DioClient`'s request interceptor (see
/// `mobile/lib/core/utils/dio_client.dart:L36-L42`).
///
/// Source: `mobile/lib/features/pantry/domain/repositories/pantry.repository.dart:L4-L12`.
/// See `../../../../../../ARCHITECTURE.md` § Soft-Delete Contract for the
/// broader contract this repository participates in.
abstract class PantryRepository {
  /// Fetches all pantry items for the authenticated user.
  ///
  /// The backend resolves `userId` from the JWT bearer attached by
  /// `DioClient` and caps results at 50 records per page (pagination cap
  /// enforced server-side; the mobile client does not yet handle paging).
  /// Maps to backend route `GET /api/pantry`.
  ///
  /// Throws `DioException` on network/HTTP errors (e.g., 401 Unauthorized
  /// when the access token is missing or expired).
  Future<List<PantryItem>> fetchPantryItems();

  /// Creates a new pantry item from [dto] and returns the persisted entity.
  ///
  /// The DTO carries `ingridient` (spelling preserved verbatim — mirrors the
  /// backend `PantryIngridient` schema), `quantity`, `unit`, `location`, and
  /// `expirationDate`. The backend assigns `id`, `createdAt`, and
  /// `updatedAt` server-side and returns the populated entity.
  ///
  /// Maps to backend route `POST /api/pantry`. Throws `DioException` on
  /// network/HTTP errors (400 validation, 401 unauthorized, etc.).
  Future<PantryItem> createPantryItem(CreatePantryItemDto dto);

  /// Updates an existing pantry item; [dto] carries the `id` (used to build
  /// the URL path) plus the mutable fields `location`, `quantity`, and
  /// `expirationDate`.
  ///
  /// Maps to backend route `PATCH /api/pantry/:id`; `PantryApi` reads the
  /// id from `dto.id` and inserts it into the URL. Returns the updated
  /// [PantryItem] from the backend response.
  ///
  /// Throws `DioException` on network/HTTP errors (404 if the id is unknown,
  /// 400 validation, 401 unauthorized).
  Future<PantryItem> updatePantryItem(UpdatePantryItemDto dto);

  /// Deletes a pantry item by [id].
  ///
  /// Maps to backend route `DELETE /api/pantry/:id`.
  ///
  /// Note: the backend implementation method is named `softDelete` but it
  /// currently calls `deleteOne()` rather than setting a `deletedAt`
  /// timestamp (Source:
  /// `backend/src/pantry/infrastructure/document/repositories/`
  /// `pantryIngridient.repository.ts:L119-L123`).
  /// The record is therefore physically removed despite the route name
  /// implying soft-delete semantics. Mobile callers should treat this as a
  /// fire-and-forget physical deletion; data cannot be recovered from the
  /// mobile client. See `../../../../../../DATA_MODEL.md` § Soft-Delete
  /// Contract for the broader contract this method participates in.
  ///
  /// Throws `DioException` on network/HTTP errors (404 if the id is unknown,
  /// 401 unauthorized).
  Future<void> deletePantryItem(String id);
}
