# Recipe feature

> Part of the PantryChef mobile client. See the
> [Mobile app README](../../../README.md) for the project overview and
> cross-feature setup.

The `recipe/` feature provides recipe browsing, matching recipes against the
user's available pantry ingredients, and detail viewing, alongside
favorite-related interactions surfaced on each recipe card.

## Purpose

The feature lets a user browse recipes the backend has matched against their
pantry, open any recipe to read its full detail, and toggle a recipe as a
favorite directly from its card.

- The main list screen, `RecipeMain`, renders matched recipes and supports
  pull-to-refresh
  (Source: mobile/lib/features/recipe/presentation/widgets/screens/recipe_main.dart:L16).
  On first display it dispatches a `RecipeMatching` event so the matched list
  loads automatically
  (Source: mobile/lib/features/recipe/presentation/widgets/screens/recipe_main.dart:L26-L34).
- Tapping a card opens the detail view rendered by `RecipeDetailed`
  (Source: mobile/lib/features/recipe/presentation/widgets/screens/recipe_detailed.dart:L15).
- A favorite button on each card toggles the recipe in the user's favorites.
  The action is dispatched to the profile feature's `ProfileBloc` via
  `FavoriteRecipesListUpdated`, so favorite state is owned cross-feature rather
  than by the recipe BLoC
  (Source: mobile/lib/features/recipe/presentation/widgets/recipe_card.dart:L177-L190).

## Key components

| Layer | Component | Source |
|-------|-----------|--------|
| Presentation / BLoC | `RecipeBloc` (`Bloc<RecipeEvent, RecipeState>`) with handlers for `RecipeListFetched`, `RecipeMatching`, `RecipeDetailedSelected`, `RecipeListReseted` | Source: mobile/lib/features/recipe/presentation/bloc/recipe/recipe_bloc.dart:L16-L71 |
| Presentation / BLoC | `RecipeEvent` hierarchy | Source: mobile/lib/features/recipe/presentation/bloc/recipe/recipe_event.dart:L4-L29 |
| Presentation / BLoC | `RecipeState` (`items`, `isFetching`, `detailedItemId`) | Source: mobile/lib/features/recipe/presentation/bloc/recipe/recipe_state.dart:L4-L10 |
| Domain / model | `Recipe` | Source: mobile/lib/features/recipe/domain/models/recipe.dart:L14 |
| Domain / model | `IngredientListItem` | Source: mobile/lib/features/recipe/domain/models/ingredient_list_item.dart:L12 |
| Domain / model | `InstractionItem` (sic) | Source: mobile/lib/features/recipe/domain/models/instraction_item.dart:L11 |
| Domain / repository | abstract `RecipeRepository` | Source: mobile/lib/features/recipe/domain/repositories/recipe.repository.dart:L14-L27 |
| Domain / use case | `GetRecipeListUsecase` | Source: mobile/lib/features/recipe/domain/usecases/get_recipe_list.usecase.dart:L9 |
| Domain / use case | `GetFavoriteRecipeListUsecase` | Source: mobile/lib/features/recipe/domain/usecases/get_favorite_recipe_list.usecase.dart:L7 |
| Domain / use case | `RecipeMatchingUsecase` | Source: mobile/lib/features/recipe/domain/usecases/recipe_matching.usecase.dart:L8 |
| Domain / use case | use-case barrel | Source: mobile/lib/features/recipe/domain/usecases/index.dart:L1-L3 |
| Data / api | `RecipeApi` | Source: mobile/lib/features/recipe/data/api/recipe.api.dart:L14 |
| Data / repository | `RecipeRepositoryImpl` | Source: mobile/lib/features/recipe/data/repositories/recipe.repository.dart:L12 |
| Data / dto | `RecipeFiltersDto` | Source: mobile/lib/features/recipe/data/dto/recipe_filters.dto.dart:L8 |
| Data / dto | `QueryRecipeDto` | Source: mobile/lib/features/recipe/data/dto/query_recipe.dto.dart:L9 |
| Data / dto | dto barrel | Source: mobile/lib/features/recipe/data/dto/index.dart:L2 |
| Widget / screen | `RecipeCard` | Source: mobile/lib/features/recipe/presentation/widgets/recipe_card.dart:L22 |
| Widget / screen | `RecipeMain` | Source: mobile/lib/features/recipe/presentation/widgets/screens/recipe_main.dart:L16 |
| Widget / screen | `RecipeDetailed` | Source: mobile/lib/features/recipe/presentation/widgets/screens/recipe_detailed.dart:L15 |

## Architecture fit

The feature follows clean architecture with three layers, mirroring the
monorepo-wide per-feature convention:

- `domain/` — models, the `RecipeRepository` interface, and use cases.
- `data/` — `RecipeApi`, DTOs, and the `RecipeRepositoryImpl`.
- `presentation/` — `RecipeBloc`, widgets, and screens.

Dependencies flow inward. The presentation layer dispatches BLoC events that
invoke use cases, which call the domain `RecipeRepository`
(Source: mobile/lib/features/recipe/domain/repositories/recipe.repository.dart:L14-L27);
that interface is fulfilled by `RecipeRepositoryImpl` in `data/`
(Source: mobile/lib/features/recipe/data/repositories/recipe.repository.dart:L12).
Dependency injection uses `get_it`: `RecipeApi` resolves the shared HTTP client
through `getIt<DioClient>().dio`
(Source: mobile/lib/features/recipe/data/api/recipe.api.dart:L20).

For the full system picture, see [Architecture](../../../../docs/ARCHITECTURE.md).

## Data models

All three models are `@JsonSerializable` and rely on a generated `part '*.g.dart'`
file produced by `build_runner`; those generated files are not hand-edited
(Source: mobile/lib/features/recipe/domain/models/recipe.dart:L5,
Source: mobile/lib/features/recipe/domain/models/instraction_item.dart:L3,
Source: mobile/lib/features/recipe/domain/models/ingredient_list_item.dart:L4).

### `Recipe`

Source: mobile/lib/features/recipe/domain/models/recipe.dart:L14-L88

| Field | Type | Source line |
|-------|------|-------------|
| `id` | `String` | Source: mobile/lib/features/recipe/domain/models/recipe.dart:L69 |
| `title` | `String` | Source: mobile/lib/features/recipe/domain/models/recipe.dart:L70 |
| `description` | `String` | Source: mobile/lib/features/recipe/domain/models/recipe.dart:L71 |
| `ingridientList` (sic) | `List<IngredientListItem>` | Source: mobile/lib/features/recipe/domain/models/recipe.dart:L72 |
| `instructions` | `List<InstractionItem>` (sic) | Source: mobile/lib/features/recipe/domain/models/recipe.dart:L73 |
| `prepTime` | `int` | Source: mobile/lib/features/recipe/domain/models/recipe.dart:L74 |
| `cookTime` | `int` | Source: mobile/lib/features/recipe/domain/models/recipe.dart:L75 |
| `servings` | `int` | Source: mobile/lib/features/recipe/domain/models/recipe.dart:L76 |
| `difficulty` | `String` | Source: mobile/lib/features/recipe/domain/models/recipe.dart:L77 |
| `tags` | `List<String>` | Source: mobile/lib/features/recipe/domain/models/recipe.dart:L78 |
| `imageUrl` | `String` | Source: mobile/lib/features/recipe/domain/models/recipe.dart:L79 |
| `matchScore` | `double?` | Source: mobile/lib/features/recipe/domain/models/recipe.dart:L80 |

The `matchScore` field carries the codebase's own inline description,
`// how well it matches available ingredients`, preserved verbatim in source
(Source: mobile/lib/features/recipe/domain/models/recipe.dart:L41). The field
name `ingridientList` is misspelled in source; this spelling is intentional and
stable, and is preserved as-is and never renamed
(Source: mobile/lib/features/recipe/domain/models/recipe.dart:L23).

### `IngredientListItem`

Source: mobile/lib/features/recipe/domain/models/ingredient_list_item.dart:L12-L33

| Field | Type | Source line |
|-------|------|-------------|
| `ingridient` (sic) | `Ingredient` | Source: mobile/lib/features/recipe/domain/models/ingredient_list_item.dart:L15 |
| `amount` | `double` | Source: mobile/lib/features/recipe/domain/models/ingredient_list_item.dart:L17 |
| `unit` | `String` | Source: mobile/lib/features/recipe/domain/models/ingredient_list_item.dart:L19 |
| `required` | `bool` | Source: mobile/lib/features/recipe/domain/models/ingredient_list_item.dart:L21 |
| `substitutes` | `List<String>?` | Source: mobile/lib/features/recipe/domain/models/ingredient_list_item.dart:L23 |

The field name `ingridient` is misspelled in source; it is intentional and
preserved as-is. The `Ingredient` type itself is owned by the `ingredient/`
feature and imported from there
(Source: mobile/lib/features/recipe/domain/models/ingredient_list_item.dart:L2);
its full field table is cross-referenced in
[Data models](../../../../docs/DATA_MODELS.md).

### `InstractionItem` (sic)

Source: mobile/lib/features/recipe/domain/models/instraction_item.dart:L11-L23

The class name spelling `InstractionItem` is intentional and stable; it is
preserved as-is and never renamed.

| Field | Type | Source line |
|-------|------|-------------|
| `step` | `int` | Source: mobile/lib/features/recipe/domain/models/instraction_item.dart:L13 |
| `description` | `String` | Source: mobile/lib/features/recipe/domain/models/instraction_item.dart:L15 |
| `timer` | `double?` | Source: mobile/lib/features/recipe/domain/models/instraction_item.dart:L17 |

For the full persisted-schema field tables (backend Mongoose entities plus the
Dart models), see [Data models](../../../../docs/DATA_MODELS.md).

## API endpoints / public interface

Recipe endpoints resolve to `/api/recipe`, built from
`Endpoints.recipe = "$apiBaseUrl/recipe"`
(Source: mobile/lib/core/constants/endpoints.dart:L44), where `apiBaseUrl`
defaults to `http://192.168.2.20:3000/api`
(Source: mobile/lib/env_config.dart:L19). Because the base URL already includes
the `/api` prefix, every route is `/api/<resource>` with no `/v1/` segment.

The mobile client consumes the backend through `RecipeApi`, whose methods all
issue HTTP `GET` requests:

| Method | Request | Source |
|--------|---------|--------|
| `getRecipeList()` | `GET /api/recipe` — returns `response.data['data']` | Source: mobile/lib/features/recipe/data/api/recipe.api.dart:L25-L30 |
| `recipeMatching(filters)` | `GET /api/recipe/matches` — sends `RecipeFiltersDto` as query params via `filters.toJson()` | Source: mobile/lib/features/recipe/data/api/recipe.api.dart:L34-L37 |
| `getRecipeById(id)` | `GET /api/recipe/:id` — single recipe by id | Source: mobile/lib/features/recipe/data/api/recipe.api.dart:L41-L44 |
| `getFavoriteList(ids)` | `GET /api/recipe` — reuses the list route with a `QueryRecipeDto(ids: ...)` query | Source: mobile/lib/features/recipe/data/api/recipe.api.dart:L49-L55 |

`recipeMatching` is invoked through `RecipeMatchingUsecase`
(Source: mobile/lib/features/recipe/domain/usecases/recipe_matching.usecase.dart:L8-L15),
and favorites are surfaced through `GetFavoriteRecipeListUsecase`
(Source: mobile/lib/features/recipe/domain/usecases/get_favorite_recipe_list.usecase.dart:L7-L14).

The domain contract `RecipeRepository` declares `getRecipeList()`,
`getFavoriteList(List<String> ids)`, `recipeMatching(RecipeFiltersDto filters)`,
and `getRecipeById(String id)`
(Source: mobile/lib/features/recipe/domain/repositories/recipe.repository.dart:L14-L27).

The list endpoint is paginated and the server enforces a result cap of 50
(Source: backend/src/recipe/recipe.controller.ts:L63); that server-side
detail, together with recipe match-scoring, is also documented in
[API reference](../../../../docs/API_REFERENCE.md).

Accuracy note: the mobile `RecipeApi` issues read (`GET`) requests only. The
backend recipe resource additionally supports `POST` / `PATCH` / `DELETE`, but
those are not called from this feature and are documented in
[API reference](../../../../docs/API_REFERENCE.md); the mobile client does not
perform recipe create, update, or delete.

## Configuration

- The API base URL comes from `EnvConfig.apiBaseUrl`, a compile-time constant
  defined as
  `String.fromEnvironment('API_BASE_URL', defaultValue: 'http://192.168.2.20:3000/api')`
  (Source: mobile/lib/env_config.dart:L19), and is consumed through
  `Endpoints.recipe` (Source: mobile/lib/core/constants/endpoints.dart:L44).
- `RecipeFiltersDto` carries the matching flags `isQuickMake` (default `false`)
  and `isAlmostThere` (default `false`)
  (Source: mobile/lib/features/recipe/data/dto/recipe_filters.dto.dart:L8-L17),
  serialized to the `/matches` query via `toJson()`
  (Source: mobile/lib/features/recipe/data/dto/recipe_filters.dto.dart:L20).
- `QueryRecipeDto` drives list/pagination query params: `page` (default `1`),
  `limit` (default `500`), `query` (default `''`), optional `ids`, and `sort`
  (mapped via `Mappers.orderToJson`)
  (Source: mobile/lib/features/recipe/data/dto/query_recipe.dto.dart:L9-L28).
  Although the client default `limit` is `500`, the backend caps results at 50
  (Source: backend/src/recipe/recipe.controller.ts:L63; see also
  [API reference](../../../../docs/API_REFERENCE.md)).

## Data flow

A list or match request travels from the UI through the BLoC and a use case
into the repository, which delegates to `RecipeApi` and the shared `DioClient`,
returning parsed `Recipe` instances back to the UI as emitted state.

```mermaid
sequenceDiagram
    participant UI as RecipeMain / RecipeCard
    participant Bloc as RecipeBloc
    participant UC as RecipeMatchingUsecase / GetRecipeListUsecase
    participant Repo as RecipeRepositoryImpl
    participant Api as RecipeApi
    participant Dio as DioClient
    participant API as Backend /api/recipe
    UI->>Bloc: add(RecipeMatching) / add(RecipeListFetched)
    Bloc->>UC: call(RecipeFiltersDto())
    UC->>Repo: recipeMatching(filters) / getRecipeList()
    Repo->>Api: recipeMatching(filters) / getRecipeList()
    Api->>Dio: GET /api/recipe/matches (or /api/recipe)
    Dio->>API: HTTP GET
    API-->>Dio: JSON
    Dio-->>Api: Response
    Api-->>Repo: List<dynamic>
    Repo-->>Bloc: List<Recipe> via Recipe.fromJson
    Bloc-->>UI: emit RecipeState(items)
```

Flow citations: list/match dispatch
(Source: mobile/lib/features/recipe/presentation/widgets/screens/recipe_main.dart:L26-L34);
BLoC handlers
(Source: mobile/lib/features/recipe/presentation/bloc/recipe/recipe_bloc.dart:L18-L69);
use case
(Source: mobile/lib/features/recipe/domain/usecases/recipe_matching.usecase.dart:L8-L15);
repository
(Source: mobile/lib/features/recipe/data/repositories/recipe.repository.dart:L12-L46);
api (Source: mobile/lib/features/recipe/data/api/recipe.api.dart:L25-L37);
endpoint (Source: mobile/lib/core/constants/endpoints.dart:L44).

A detail-selection sub-flow runs alongside the list flow: tapping a card
dispatches `RecipeDetailedSelected(id: item.id)` and navigates to the detail
route
(Source: mobile/lib/features/recipe/presentation/widgets/recipe_card.dart:L67-L68),
and `RecipeDetailed` then renders the recipe whose `id` equals
`state.detailedItemId`
(Source: mobile/lib/features/recipe/presentation/widgets/screens/recipe_detailed.dart:L27).

## Design patterns used

- **BLoC (event/state)** — `RecipeBloc` maps events to emitted `RecipeState`s
  (Source: mobile/lib/features/recipe/presentation/bloc/recipe/recipe_bloc.dart:L16-L71).
- **Repository** — an abstract `RecipeRepository`
  (Source: mobile/lib/features/recipe/domain/repositories/recipe.repository.dart:L14-L27)
  decouples the domain from data access, implemented by `RecipeRepositoryImpl`
  (Source: mobile/lib/features/recipe/data/repositories/recipe.repository.dart:L12).
- **Use Case** — single-purpose `UseCase` / `UseCaseWithParams` implementations
  encapsulate each operation
  (Source: mobile/lib/features/recipe/domain/usecases/get_recipe_list.usecase.dart:L9,
  Source: mobile/lib/features/recipe/domain/usecases/recipe_matching.usecase.dart:L8).
- **Dependency injection (`get_it`)** — the shared `DioClient` is resolved via
  `getIt` rather than constructed directly
  (Source: mobile/lib/features/recipe/data/api/recipe.api.dart:L20).
- **DTO-based filtering** — `RecipeFiltersDto` and `QueryRecipeDto` serialize
  query parameters for the matching and list routes
  (Source: mobile/lib/features/recipe/data/dto/recipe_filters.dto.dart:L8-L20,
  Source: mobile/lib/features/recipe/data/dto/query_recipe.dto.dart:L9-L28).

## Known limitations / gaps

KNOWN ISSUE: `Recipe.copyWith({final bool? inFavorite})` accepts an `inFavorite`
argument but never applies it. The `Recipe` class has no `inFavorite` field, so
the method copies every existing field unchanged and returns an identical copy —
a no-op (Source: mobile/lib/features/recipe/domain/models/recipe.dart:L65-L66;
full method Source: mobile/lib/features/recipe/domain/models/recipe.dart:L65-L81).
This behavior is documented here as-is and is not corrected.

KNOWN ISSUE: a default `RecipeFiltersDto()` is not "no filters" on the wire. Both
flags default to `false`
(Source: mobile/lib/features/recipe/data/dto/recipe_filters.dto.dart:L14-L17),
but `toJson()` always serializes `isQuickMake` and `isAlmostThere`
(Source: mobile/lib/features/recipe/data/dto/recipe_filters.dto.dart:L20), and
`RecipeApi.recipeMatching` sends them as query params
(Source: mobile/lib/features/recipe/data/api/recipe.api.dart:L34-L37). The backend
binds `@Query()` to a `FilterType` alias with no boolean transform
(Source: backend/src/recipe/recipe.controller.ts:L45;
Source: backend/src/recipe/types/filter.types.ts:L9) and filters by truthiness
(Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L251,L255,L259),
where the query string `"false"` is truthy. Default `false` flags are therefore
not guaranteed to behave as an unfiltered match. Documented here as-is and not
corrected.

- **Preserved misspelled identifiers** — the class `InstractionItem`, and the
  `Recipe` field/usages `ingridientList` and `ingridient`, are misspelled in
  source. These spellings are intentional and stable; they are documented as-is
  and never renamed
  (Source: mobile/lib/features/recipe/domain/models/recipe.dart:L23,L48,
  Source: mobile/lib/features/recipe/domain/models/ingredient_list_item.dart:L15).
- **Matching is server-side and exact-ingredient based** — the client only
  sends the `isQuickMake` / `isAlmostThere` flags; the match scoring is computed
  by the backend, which derives `matchScore` as
  `availableIngredients.length / totalIngredients`
  (Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L231),
  then derives `isQuickMake` (`totalIngredients <= 5`)
  (Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L234)
  and `isAlmostThere` (1–2 missing ingredients)
  (Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L237-L238).
  Matching uses exact `_id` comparison with no unit normalization. Further detail
  is documented in [API reference](../../../../docs/API_REFERENCE.md).

## Local development

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run --dart-define API_BASE_URL=http://<host>:3000/api
```

- `flutter pub get` installs dependencies.
- `dart run build_runner build --delete-conflicting-outputs` regenerates the
  `*.g.dart` files, required because the models use codegen (`@JsonSerializable`
  with `part '*.g.dart'`).
- `flutter run --dart-define API_BASE_URL=http://<host>:3000/api` overrides the
  compile-time API base (Source: mobile/lib/env_config.dart:L19). `<host>` must
  be reachable from the device or emulator (a LAN IP, or `10.0.2.2` for the
  Android emulator).
- Keep static analysis clean with `flutter analyze` (equivalently
  `dart analyze`). The recipe feature's production behavior is unchanged by
  documentation; this checkpoint adds this README plus additive Dartdoc/comments
  to the recipe source files.

For the project overview and cross-feature setup, see the
[Mobile app README](../../../README.md). For system-wide context, see
[Architecture](../../../../docs/ARCHITECTURE.md),
[API reference](../../../../docs/API_REFERENCE.md), and
[Data models](../../../../docs/DATA_MODELS.md).
