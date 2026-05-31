import 'package:camera/camera.dart';
import 'package:pantry_chef/core/data/dto/index.dart';
import 'package:pantry_chef/features/ingredient/data/dto/index.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient.dart';
import 'package:pantry_chef/features/ingredient/domain/models/ingredient_add_data.dart';

/// Domain-layer contract for the ingredient feature's persistence and AI workflows.
///
/// Concrete implementations live under `mobile/lib/features/ingredient/data/repositories/`;
/// the current implementation is `IngredientRepositoryImpl`, which delegates every
/// call to a freshly-constructed `IngredientApi` and decodes JSON responses into
/// typed domain models before returning them.
///
/// Four asynchronous workflows are abstracted by this interface:
///
/// 1. [getCategoriesAndUnits] — fetch reference data (categories + units) for the
///    add-ingredient form.
/// 2. [searchIngredient] — paginated query against the backend ingredient catalog.
/// 3. [createingredient] — persist a new ingredient. The method name uses lowercase
///    `i` in "ingredient" — preserved verbatim across the entire mobile call chain
///    (use case → impl → API mapping).
/// 4. [processImage] — upload a captured photo to the backend AI vision endpoint
///    and receive the resolved ingredient.
///
/// The repository is consumed by use cases in `../usecases/` and is instantiated as
/// `IngredientRepositoryImpl()` per call rather than via the GetIt service locator,
/// matching the per-call instantiation convention used by sibling features.
///
/// See `../../../../../ARCHITECTURE.md` § Full Request Path for the system-level
/// view and `../../../../README.md` for the feature overview.
abstract class IngredientRepository {
  /// Fetches the categories and units reference data used by the add-ingredient form.
  ///
  /// Returns a [Future] resolving to an [IngredientAddData] aggregate holding a
  /// `List<Category>` and a `List<Unit>`. The concrete implementation hits
  /// `GET /api/v1/ingredient/creation-data` on the backend; the response payload
  /// is `{ categories: [...], units: [...] }` with both lists currently hardcoded
  /// server-side (5 categories and 9 units in `backend/src/ingridient/ingridient.controller.ts`,
  /// with the backend `Ingridient` spelling preserved verbatim).
  Future<IngredientAddData> getCategoriesAndUnits();

  /// Paginated, query-based ingredient search against the backend catalog.
  ///
  /// The [dto] carries the substring query, pagination cursors (`page`, `limit`),
  /// and an optional `List<OrderDto>?` for sort order. Returns a [Future] resolving
  /// to a `List<Ingredient>` — an empty list when no matches are found. The concrete
  /// implementation hits `GET /api/v1/ingredient` with [dto] serialized as query
  /// parameters and maps each element of the raw `List<dynamic>` response through
  /// `Ingredient.fromJson`.
  Future<List<Ingredient>> searchIngredient(SearchDto dto);

  /// Persists a new ingredient.
  ///
  /// Method name `createingredient` uses **lowercase `i`** in "ingredient" — preserved
  /// verbatim for compile-time stability across the call chain (`CreateIngredientUsecase`
  /// → `IngredientRepositoryImpl.createingredient` → `IngredientApi.createIngredient`).
  /// Do not rename to `createIngredient`; the asymmetry between the impl-side method
  /// (lowercase `i`) and the API-side method (`api.createIngredient` with uppercase `I`)
  /// is intentional.
  ///
  /// The [dto] carries the new ingredient payload (`name`, `category` via
  /// `Mappers.categoryToJson`, `quantity`, `unit` via `Mappers.unitToJson`, optional
  /// `imageUrl`, optional `expirationDate`, `confidence` default `1`). Returns a
  /// [Future] resolving to the persisted [Ingredient] with the server-assigned `id`
  /// and `createdAt`. The concrete implementation hits `POST /api/v1/ingredient`.
  Future<Ingredient> createingredient(CreateIngredientDto dto);

  /// Uploads a captured photo to the backend AI vision endpoint and returns the
  /// resolved [Ingredient].
  ///
  /// The [image] is an [XFile] from the `camera` package. The concrete
  /// implementation uploads the file as multipart form data (form field name
  /// `image`) to `POST /api/ai/vision`. When Google Cloud Vision cannot resolve
  /// the image to a known ingredient the backend returns an empty JSON object
  /// `{}`, which causes `Ingredient.fromJson({})` to throw; the upstream
  /// `CameraBloc` catches that error and routes the user to manual entry.
  ///
  /// **Production-readiness caveat**: `POST /api/ai/vision` is currently **unguarded**
  /// — `backend/src/ai/ai.controller.ts` declares the route with no
  /// `@UseGuards(AuthGuard('jwt'))` decorator. The mobile client sends the JWT
  /// bearer header via `DioClient`, but the backend does not verify it. See
  /// `../../../../../backend/src/ai/README.md` for the module-level callout and
  /// `../../../../../PRODUCTION_READINESS.md` for the centralized inventory.
  Future<Ingredient> processImage(XFile image);
}
