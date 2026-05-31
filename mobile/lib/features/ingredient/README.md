# Ingredient Feature (Mobile)

## Module Purpose

The ingredient feature is the mobile module for ingredient discovery, manual creation, and AI-assisted recognition. It owns the full flow: camera capture, upload to the backend AI vision endpoint, Google Cloud Vision label detection, ingredient resolution against the backend's MongoDB `Ingridient` (spelling preserved verbatim from the backend schema) collection, user confirmation, and persistence as a pantry entry. The module follows mobile clean architecture (domain/data/presentation) and integrates with two backend modules: the `IngridientController` (spelling preserved verbatim) at `/api/v1/ingredient/*` and the `AiController` at `/api/ai/vision`. The mobile-vs-backend spelling divergence is intentional and is detailed in §9.

## Key Components

| Path | Type | Responsibility |
| --- | --- | --- |
| `domain/models/ingredient.dart` | Model | `Ingredient` (mobile-side correct spelling): `id`, `name`, `category`, `confidence`, `createdAt?`, `quantity?`, `unit`, `imageUrl?`, `expirationDate?`. JSON-serializable via `@JsonSerializable()`. |
| `domain/models/category.dart` | Model | `Category` (`id: int`, `name: String`). JSON-serializable. |
| `domain/models/unit.dart` | Model | `Unit` (`id: int`, `name: String`). JSON-serializable. |
| `domain/models/ingredient_add_data.dart` | Model | `IngredientAddData` aggregate `{ categories, units }` for the add-form bootstrap. |
| `domain/repositories/ingredient.repository.dart` | Repository contract | `abstract class IngredientRepository` exposes `getCategoriesAndUnits()`, `searchIngredient(SearchDto)`, `createingredient(CreateIngredientDto)`, `processImage(XFile)`. Source: `domain/repositories/ingredient.repository.dart:L7-L15`. |
| `domain/usecases/create_ingredient.usecase.dart` | UseCase | `CreateIngredientUsecase` implements `UseCaseWithParams<Ingredient, CreateIngredientDto>`. |
| `domain/usecases/get_creation_data.usecase.dart` | UseCase | `GetIngredientCategoriesAndUnitsUsecase` implements `UseCase<IngredientAddData>` — fetches categories + units reference data. |
| `domain/usecases/image_processing.usecase.dart` | UseCase | `ImageProcessingUsecase` implements `UseCaseWithParams<Ingredient, XFile>` — uploads image to AI vision endpoint. |
| `domain/usecases/search_ingredietn.usecase.dart` | UseCase | `SearchIngredientUsecase` — file name `search_ingredietn.usecase.dart` (file name spelling preserved verbatim — 'ingredietn' typo retained for compile-time stability). Class name `SearchIngredientUsecase` is correctly spelled. |
| `domain/usecases/index.dart` | Barrel | Exports the four use cases above. |
| `data/api/ingredient.api.dart` | Dio API client | `IngredientApi` wraps Dio calls: `getCategoriesAndUnits` (GET creation-data), `searchIngredient` (GET with `SearchDto`), `createIngredient` (POST), `processImage` (POST multipart to `${Endpoints.ai}/vision`). |
| `data/dto/create_ingredient.dto.dart` | DTO | `CreateIngredientDto` (`name`, `category` w/ `Mappers.categoryToJson`, `quantity`, `unit` w/ `Mappers.unitToJson`, `imageUrl?`, `expirationDate?`, `confidence=1`). |
| `data/dto/index.dart` | Barrel | Exports `create_ingredient.dto.dart`. |
| `data/repositories/ingredient.repository.dart` | Repository impl | `IngredientRepositoryImpl` implements the domain contract; instantiates `IngredientApi()` per call. |
| `presentation/bloc/camera/camera_bloc.dart` | BLoC | `CameraBloc` manages camera state; handles `PictureTaken` → `ImageProcessingUsecase` → emits `ImagedProcessed(foundIngredient)` or `ImageProcessingError`. Source: `presentation/bloc/camera/camera_bloc.dart:L10-L22`. |
| `presentation/bloc/camera/camera_event.dart` | Event | `sealed class CameraEvent` + `PictureTaken({required this.image})`. |
| `presentation/bloc/camera/camera_state.dart` | State | `sealed class CameraState`: `CameraInitial`, `ImagedProcessed({required foundIngredient})`, `ImageProcessingError`. |
| `presentation/bloc/ingredient_add/ingredient_add_bloc.dart` | BLoC | `IngredientAddBloc` handles `CategoriesAndUnitsFetched`, `DataChanged`, `IngredientSearch` (paginated, page+=1 on scroll), `IngredientCreated`. Source: `presentation/bloc/ingredient_add/ingredient_add_bloc.dart:L14-L85`. |
| `presentation/bloc/ingredient_add/ingredient_add_event.dart` | Event | Four sealed events including `DataChanged` with `Nullable<T>` semantics. |
| `presentation/bloc/ingredient_add/ingredient_add_state.dart` | State | `IngredientAddState` with `searchResult`, `page`, `limit=20`, `isNextPageAvailable`, `isFetching=true` default, `createdIngredient`. `copyWith` uses `Nullable<T>` for nullable fields. |
| `presentation/widgets/screens/ingredient_camera_detecting.dart` | Screen | Camera capture + detection screen. Initializes `CameraController(cameras[0], ResolutionPreset.max)`, dispatches `PictureTaken`, navigates to `Navigation.ingredientAdding` on result. |
| `presentation/widgets/screens/ingredient_adding_form.dart` | Screen | Confirm + edit ingredient form (282 lines). Builds `IngredientAddBloc`, listens for `createdIngredient`, dispatches `PantryItemAdded` on the upstream `PantryBloc` to persist. |
| `presentation/widgets/ingredient_search_dialog.dart` | Widget | `SearchDialog` modal with infinite-scroll pagination via `_scrollController` listener (offset `CommonConstants.fetchScrollOffset=150`). Returns either a selected `Ingredient` or the typed query string. |
| `presentation/widgets/ingredient_search_field.dart` | Widget | `IngredientSearchField` picker-style field that opens `SearchDialog` as a bottom sheet. |
| `presentation/widgets/ingredient_search_result_item.dart` | Widget | `IngredientSearchResultItem` list row showing `item.name`; taps `pop(item)`. |

## Architecture Fit

The feature follows mobile clean architecture: `presentation/` (UI + BLoC) depends on `domain/` (contracts, models, use cases), realized by `data/` (the Dio API client, DTOs, repository impl). The data layer maps backend `Ingridient` JSON responses into the mobile-correct `Ingredient` class. `IngredientApi` resolves its Dio instance via `getIt<DioClient>().dio` (Source: `data/api/ingredient.api.dart:L12-L14`), inheriting the JWT interceptor and refresh logic from `mobile/lib/core/utils/dio_client.dart`. The module is a thin client over two backend modules, with no business logic beyond form orchestration.

See [`../../../../ARCHITECTURE.md`](../../../../ARCHITECTURE.md) §§ Full Request Path and JWT Authentication Flow for the system view; the backend counterparts are [`../../../../backend/src/ingridient/README.md`](../../../../backend/src/ingridient/README.md) and [`../../../../backend/src/ai/README.md`](../../../../backend/src/ai/README.md), and the shared HTTP layer is [`../../../../mobile/lib/core/README.md`](../../../../mobile/lib/core/README.md).

## Dependencies

### Internal

- `mobile/lib/core/utils/dio_client.dart` — Dio HTTP client (JWT interceptor + refresh) resolved via `getIt<DioClient>().dio`.
- `mobile/lib/core/constants/endpoints.dart` — `Endpoints.ingredient`, `Endpoints.ingredientCreationData`, `Endpoints.ai` (Source: `mobile/lib/core/constants/endpoints.dart:L80-L99`).
- `mobile/lib/core/utils/service_locator.dart` — GetIt resolution for `DioClient`.
- `mobile/lib/core/utils/usercase.dart` (file name spelling preserved verbatim) — `UseCase<T>` / `UseCaseWithParams<T, P>` contracts the use cases implement.
- `mobile/lib/core/utils/mappers.dart` — `Mappers.categoryToJson`/`Mappers.unitToJson` for `Ingredient`/`CreateIngredientDto` JSON serialization.
- `mobile/lib/core/utils/nullable_wrapper.dart` — `Nullable<T>` used in `DataChanged` event + `IngredientAddState.copyWith`.
- `mobile/lib/core/constants/ingredient_location.dart` — `ingredientLocation` (`['fridge', 'freezer', 'pantry']`): dropdown source, default `[0] = 'fridge'`.
- `mobile/lib/core/constants/navigation.dart` — `Navigation.ingredientDetecting`, `Navigation.ingredientAdding`.
- `mobile/lib/core/data/dto/index.dart` — `SearchDto`, `OrderDto` for paginated search.
- `mobile/lib/core/presentation/widgets/*` — shared widgets (`ActionButton`, `TextFieldInput`, `SelectField`, `DatePickerField`, `AppIconButton`, `AppBarWidget`).
- `mobile/lib/features/pantry/data/dto/create_pantry_item.dto.dart` — `CreatePantryItemDto` whose verbatim `ingridient` field accepts the mobile `Ingredient` model.
- `mobile/lib/features/pantry/presentation/bloc/pantry/pantry_bloc.dart` — `PantryBloc` + `PantryItemAdded` event dispatched from the adding-form screen on creation.

### External

| Package | Version | Used For |
| --- | --- | --- |
| `camera` | `^0.11.0+2` | `CameraController`, `XFile`, `availableCameras()` for capture flow |
| `dio` | `^5.7.0` | HTTP client, `FormData`, `MultipartFile` for multipart image upload |
| `bloc` | `^8.1.4` | `Bloc<Event, State>` base class for `CameraBloc` and `IngredientAddBloc` |
| `flutter_bloc` | `^8.1.6` | `BlocProvider`, `BlocBuilder`, `BlocListener`, `MultiBlocListener` in screens |
| `equatable` | `^2.0.5` | Value equality on event/state classes |
| `json_annotation` | `^4.9.0` | `@JsonSerializable()`, `@JsonKey(toJson: ...)` on models and DTOs |
| `flutter_platform_widgets` | `^7.0.1` | `PlatformScaffold`, `PlatformCircularProgressIndicator` for cross-platform UI |
| `loader_overlay` | `^4.0.3` | Full-screen loading overlay during AI vision processing |

All versions verified against `mobile/pubspec.yaml`.

## Primary Use Cases

- **Open camera, capture image** of a pantry item (Source: `ingredient_camera_detecting.dart:L43-L44`; `:L145-L146` emits `PictureTaken`).
- **Upload to backend AI vision** (multipart, field `image`) via `IngredientApi.processImage` → `${Endpoints.ai}/vision` (Source: `data/api/ingredient.api.dart:L31-L41`).
- **Receive ingredient suggestion** from Google Cloud Vision plus a server-side dictionary lookup (`IngridientService.findManyWithPagination`, spelling preserved verbatim); the client maps the resolved `Ingridient` JSON (or `{}`) via `Ingredient.fromJson`.
- **Confirm + persist** (POST `/api/v1/ingredient` via `IngredientApi.createIngredient`; Source: `data/api/ingredient.api.dart:L26-L29`).
- **Search existing ingredients** (paginated GET `/api/v1/ingredient` with `SearchDto`); the dialog fetches the next page within `CommonConstants.fetchScrollOffset=150` of the bottom (Source: `ingredient_search_dialog.dart:L29-L43`).
- **Create ingredient manually** when AI detection fails — a fallback button routes to `Navigation.ingredientAdding` (Source: `ingredient_camera_detecting.dart:L83,L154`).

## API / Endpoint Reference

> The feature consumes two backend controllers: `IngridientController` (spelling preserved verbatim) at `/api/v1/ingredient/*`, and `AiController` at `/api/ai/vision` — the latter declares `@Controller('ai')` with no `version` parameter, so it has no `/v1` segment (Source: `backend/src/ai/ai.controller.ts:L22`). See the backend's own [`../../../../backend/src/ingridient/README.md`](../../../../backend/src/ingridient/README.md).

| Method | Path | Guard | Description |
| --- | --- | --- | --- |
| GET | `/api/v1/ingredient/creation-data` | `@UseGuards(AuthGuard('jwt'))` (class-level) | Categories + units reference data. **Note:** lists are hardcoded in `IngridientController.getCreationData` (5 categories, 9 units) — see `backend/src/ingridient/ingridient.controller.ts:L62-L93`. |
| GET | `/api/v1/ingredient` | `@UseGuards(AuthGuard('jwt'))` (class-level) | Paginated ingredient list (`SearchDto` query params). Used by `SearchDialog` infinite scroll. |
| GET | `/api/v1/ingredient/:id` | `@UseGuards(AuthGuard('jwt'))` (class-level) | Fetch single ingredient by id. Not currently called from this feature but available on the contract. |
| POST | `/api/v1/ingredient` | `@UseGuards(AuthGuard('jwt'))` (class-level) | Create a new Ingridient (spelling preserved verbatim). Mobile sends `CreateIngredientDto` body. |
| POST | `/api/ai/vision` | **NONE — UNGUARDED** | Multipart image upload (form field `image`, ≤10MB) returning a resolved Ingridient or `{}`. See [`../../../../backend/src/ai/README.md`](../../../../backend/src/ai/README.md) for the upstream gap. |

## Data Flows

> The diagram below traces an end-to-end camera-driven ingredient detection from the Flutter UI, through the unguarded AI vision endpoint, to Google Cloud Vision, and back to the confirmation screen.

```mermaid
sequenceDiagram
    participant U as User
    participant CS as IngredientCameraDetecting
    participant CB as CameraBloc
    participant IPU as ImageProcessingUsecase
    participant API as IngredientApi
    participant DC as DioClient
    participant AI as Backend /api/ai/vision
    participant GCV as Google Cloud Vision
    participant FORM as IngredientAddingForm
    U->>CS: tap shutter
    CS->>CB: PictureTaken(XFile)
    CB->>IPU: call(XFile)
    IPU->>API: processImage(XFile)
    API->>DC: POST multipart image
    DC->>AI: bearer JWT (none required here)
    AI->>GCV: LABEL_DETECTION (maxResults: 10)
    GCV-->>AI: labels[]
    AI-->>API: Ingridient JSON or {}
    API-->>CB: Ingredient.fromJson
    CB-->>FORM: pushReplacementNamed(ingredientAdding, foundIngredient)
```

> When Vision is disabled or finds no match, the backend returns `{}` (Source: `backend/src/ai/ai.service.ts:L107,L126`); `Ingredient.fromJson({})` then throws, the BLoC catches it and emits `ImageProcessingError`, routing the user to the manual entry form (Source: `presentation/bloc/camera/camera_bloc.dart:L14-L19`).

## Configuration

| Variable / Constant | Value | Source | Notes |
| --- | --- | --- | --- |
| `API_BASE_URL` (compile-time `--dart-define`) | default `http://192.168.2.20:3000/api` | `mobile/lib/env_config.dart:L11` | Developer LAN IP; override for production via `flutter run --dart-define=API_BASE_URL=https://…`. |
| `Endpoints.ingredient` | `$apiBaseUrl/ingredient` | `mobile/lib/core/constants/endpoints.dart:L80` | Routes to backend `/api/v1/ingredient`. |
| `Endpoints.ingredientCreationData` | `$ingredient/creation-data` | `mobile/lib/core/constants/endpoints.dart:L85` | Routes to backend `/api/v1/ingredient/creation-data`. |
| `Endpoints.ai` | `$apiBaseUrl/ai` | `mobile/lib/core/constants/endpoints.dart:L99` | Mobile appends `/vision` for the upload (Source: `data/api/ingredient.api.dart:L35`). |
| iOS camera permission | `NSCameraUsageDescription = "Application using camera for ingredient identification"` | `mobile/ios/Runner/Info.plist` | Required for camera access on iOS. |
| Android camera permission | `<uses-permission android:name="android.permission.CAMERA" />` | `mobile/android/app/src/main/AndroidManifest.xml` | Required for camera access on Android. |
| `ingredientLocation[0]` | `'fridge'` | `mobile/lib/core/constants/ingredient_location.dart:L23` | Default location applied by `IngredientAddBloc` initializer (Source: `presentation/bloc/ingredient_add/ingredient_add_bloc.dart:L20`). |
| Search page size | `limit = 20` | `presentation/bloc/ingredient_add/ingredient_add_state.dart:L34` | Used by `IngredientSearch` event. |
| Scroll prefetch offset | `CommonConstants.fetchScrollOffset = 150` | `mobile/lib/core/constants/common.dart:L21` | When dialog is within 150 px of bottom, fetches next page. |

## Known Limitations and Implementation Gaps

> Most gaps are backend-owned; see [`../../../../backend/src/ai/README.md`](../../../../backend/src/ai/README.md) and [`../../../../PRODUCTION_READINESS.md`](../../../../PRODUCTION_READINESS.md). Summarized here for mobile readers.

> ⚠️ **Backend AI endpoint gaps (upstream-owned).** `POST /api/ai/vision` is unguarded (no `@UseGuards(AuthGuard('jwt'))`, Source: `backend/src/ai/ai.controller.ts:L22-L77`), its MIME `fileFilter` is commented out (`:L51-L61`), and the dictionary is ~36 hardcoded terms (Source: `backend/src/ai/ai.service.ts:L24-L62`). The mobile client cannot mitigate these; unresolved items use the manual add form.

> ⚠️ **Mobile-vs-backend spelling divergence.** This feature uses the correct `ingredient/`/`Ingredient`; the backend uses verbatim `ingridient/`/`Ingridient` (spelling preserved verbatim). The DTO `create_pantry_item.dto.dart:L26` mixes both: `final Ingredient ingridient;`. Intentional — **do not unify.**

> ⚠️ **Verbatim file name `search_ingredietn.usecase.dart`** (spelling preserved verbatim — 'ingredietn' typo retained). The class is correctly named `SearchIngredientUsecase`; renaming the file would break the barrel export at `domain/usecases/index.dart:L3`. Flagged with `// NOTE:`.

> ⚠️ **No offline image queue.** A capture taken offline rethrows the Dio error and emits `ImageProcessingError` (Source: `presentation/bloc/camera/camera_bloc.dart:L18`); the image is discarded with no retry, and hydrated state does not cover in-flight requests.

## Production Readiness Status

> Each gap maps to a category in [`../../../../PRODUCTION_READINESS.md`](../../../../PRODUCTION_READINESS.md); the headline mobile-facing risk — the unguarded AI endpoint — is backend-owned.

> 🚧 **Security Hardening** — guard the backend `AiController` with `@UseGuards(AuthGuard('jwt'))`, uncomment the MIME `fileFilter` (`backend/src/ai/ai.controller.ts:L51-L61`), and add `@nestjs/throttler` rate limits on the 10MB upload (`:L62`) to close the anonymous DoS vector. The mobile JWT is already sent via the `DioClient` interceptor, so no mobile change is needed. See [`../../../../PRODUCTION_READINESS.md`](../../../../PRODUCTION_READINESS.md) § Security Hardening.

> 🚧 **Coverage / Quality** — expand the backend AI dictionary (~36 terms at `backend/src/ai/ai.service.ts:L24-L62`) toward a managed model or labeled dataset. No mobile change required.

> See [`../../../../PRODUCTION_READINESS.md`](../../../../PRODUCTION_READINESS.md) for the full inventory and [`../../../../ARCHITECTURE.md`](../../../../ARCHITECTURE.md) §§ Full Request Path and JWT Authentication Flow. The `Ingridient` schema is documented in [`../../../../DATA_MODEL.md`](../../../../DATA_MODEL.md).
