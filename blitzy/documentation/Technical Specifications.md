# Technical Specification

# 0. Agent Action Plan

## 0.1 Intent Clarification

### 0.1.1 Core Documentation Objective

Based on the provided requirements, the Blitzy platform understands that the documentation objective is to produce comprehensive code documentation for the PantryChef monorepo such that (a) any developer joining the project gains a foundational understanding of what is currently implemented across the Flutter mobile client and the NestJS backend, and (b) the documentation surfaces a clear picture of the gaps and concrete steps required to move the system from its current dev-grade state to a production-ready deployment.

Request categorization:

- **Primary mode — CREATE new documentation**: sixteen module `README.md` files plus three top-level cross-cutting documents (`ARCHITECTURE.md`, `PRODUCTION_READINESS.md`, `DATA_MODEL.md`) must be authored from scratch.
- **Secondary mode — UPDATE existing documentation**: two existing root README files (`mobile/README.md` [mobile/README.md:L1-L17] containing default Flutter boilerplate and `backend/README.md` [backend/README.md:L1-L16] containing minimal setup instructions) must be fully replaced with content matching the ten-section module README structure required by the prompt.
- **Tertiary mode — UPDATE existing source files with inline annotations**: TypeScript JSDoc and Dart DartDoc comments must be added to source files within seven backend directories and seven mobile directories, without altering any executable code, signatures, or behavior.

Documentation type breakdown:

- **Module READMEs** — per-module developer-onboarding documents with a strictly ordered ten-section structure (Module Purpose, Key Components, Architecture Fit, Dependencies, Primary Use Cases, API/Endpoint Reference, Data Flows, Configuration, Known Limitations and Implementation Gaps, Production Readiness Status).
- **Architecture documentation** — system-wide narrative in `ARCHITECTURE.md` covering monorepo structure, technology choices, cross-cutting concerns, the full request path from Flutter to MongoDB/Google Cloud Vision, and a dedicated deep-dive on the recipe matching pipeline.
- **Production-readiness checklist** — categorized status table in `PRODUCTION_READINESS.md` enumerating every gap blocking production deployment across eleven categories (Build & Runtime, Secrets Management, Networking & TLS, Infrastructure & Orchestration, File Storage, Security Hardening, Observability, CI/CD, Database, Testing, Mobile Release).
- **Data model reference** — Mermaid `erDiagram` in `DATA_MODEL.md` for all five MongoDB collections (`User`, `Session`, `Ingridient`, `PantryIngridient`, `Recipe`) including the embedded `Preferences` subdocument, `location` enum, `deletedAt` soft-delete field, and `@Schema({ timestamps: true })` `createdAt`/`updatedAt` fields.
- **Inline code documentation** — JSDoc (`/** */`) for TypeScript and DartDoc (`///`) for Dart on all public exported items in scope, following a fixed tag taxonomy (`// TODO(prod):`, `// NOTE:`, `// FIXME:`).

### 0.1.2 Special Instructions and Constraints

**CRITICAL** — the prompt encodes a strict minimal-change clause: documentation work must add comments and documentation files **without modifying any production code logic or behavior**. Specifically:

- No refactoring, renaming, or reorganization of any existing files, classes, functions, or variables.
- No changes to interfaces, DTOs, schemas, or API contracts.
- No bug fixes during this documentation pass — bugs discovered during documentation are flagged with `// FIXME:` comments only.
- No correction of intentional spelling variants in identifiers (`Ingridient`, `singup`, `InstractionItem`) — these are stable API and file-system contracts.
- No alteration of configuration values, environment defaults, or seed data.

**Spelling preservation directive (verbatim from prompt)**: "When referencing code identifiers, preserve exact spelling as found in source — including `Ingridient`, `InstractionItem`, `singup` — and note in a parenthetical that the spelling is preserved verbatim."

**Format directive (verbatim from prompt)**: "Use the topic order defined above as H2 headings (`##`). Do not reorder them."

**Length directive (verbatim from prompt)**: "Aim for 400–800 words of prose per README, excluding tables and code blocks."

**Diagram directive (verbatim from prompt)**: "Include one Mermaid diagram per README where it adds clarity. Use `flowchart TD` or `sequenceDiagram` as appropriate. Keep diagrams to ≤10 nodes."

**Callout directive (verbatim from prompt)**: "Use blockquotes (`>`) prefixed with `> ⚠️` for known limitations and `> 🚧` for production-readiness gaps."

**Code excerpt directive (verbatim from prompt)**: "Include short real excerpts from the actual source files to anchor explanations — do not invent illustrative examples."

**Tag taxonomy directive (verbatim from prompt)**: `// TODO(prod):` for production gaps, `// NOTE:` for clarifications on intentional decisions, `// FIXME:` for genuine bugs identified during documentation (do not fix — document only).

**Priority gap directive (verbatim from prompt)** — the following gaps must be explicitly called out in their respective module READMEs and again in `PRODUCTION_READINESS.md`:

- `recipe/`: no unit normalization, no quantity sufficiency check, exact `_id` matching only.
- `ai/`: MIME-type filter is commented out; no JWT guard on `POST /v1/ai/vision`; small internal ingredient dictionary.
- `pantry/`: `softDelete` calls `deleteOne` (physically destructive despite method name).
- `auth/`: password reset DTOs exist (`forgot-password`, `reset-password`) but no endpoints are wired.
- `database/`: seed runner runs on every startup; no migration versioning.
- Preserved spelling variants (`Ingridient`, `instraction_item.dart`, `singup` route) — note these are intentional and must not be corrected.

No user-provided templates or worked examples are attached; the prompt itself defines the canonical content structure.

### 0.1.3 Technical Interpretation

These documentation requirements translate to the following technical documentation strategy:

- **To document each backend module**, create a README at the module's source root (`backend/src/<module>/README.md`) populated by extracting controller endpoints from `*.controller.ts`, service operations from `*.service.ts`, schema fields from `*.schema.ts`, and dependency declarations from `*.module.ts`. Each README includes a Mermaid `sequenceDiagram` or `flowchart TD` derived from the actual request/response flow through controller → service → repository → MongoDB.
- **To document each mobile feature**, create a README at the feature's source root (`mobile/lib/features/<feature>/README.md`) populated by extracting BLoC events/states from `presentation/bloc/`, use cases from `domain/usecases/`, API client methods from `data/api/`, and screen/widget surface from `presentation/screens/` and `presentation/widgets/`. Each README maps the feature to its clean-architecture layering.
- **To document the system overall**, create `ARCHITECTURE.md` at the repository root with a Mermaid `flowchart LR` derived from the actual request path (Flutter `DioClient` → NestJS `main.ts` bootstrap → feature module → repository → MongoDB or Google Cloud Vision) and a dedicated subsection on the recipe matching pipeline using the verbatim algorithm from `backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts` [backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L92-L171].
- **To document production gaps**, create `PRODUCTION_READINESS.md` at the repository root with one table row per gap identified during this analysis, mapped to one of the eleven prompt-defined categories and tagged with a status indicator (❌/⚠️/✅).
- **To document the data model**, create `DATA_MODEL.md` at the repository root using a Mermaid `erDiagram` constructed from the five schema files (`backend/src/users/infrastructure/document/entities/user.schema.ts`, `backend/src/session/infrastructure/document/entities/session.schema.ts`, `backend/src/ingridient/infrastructure/document/entities/ingridient.schema.ts`, `backend/src/pantry/infrastructure/document/entities/pantryIngridient.schema.ts`, `backend/src/recipe/infrastructure/document/entities/recipe.schema.ts`).
- **To add inline JSDoc** to TypeScript source, edit each `*.ts` file in scope to prepend `/** */` blocks above every exported function/class/method declaration, with `// TODO(prod):`, `// NOTE:`, and `// FIXME:` single-line comments embedded inline at the specific lines they describe.
- **To add inline DartDoc** to Dart source, edit each `*.dart` file in scope (excluding `*.g.dart` and `*.freezed.dart`) to prepend `///` comments above every public class, method, and field, with the same single-line tag taxonomy as the backend.

### 0.1.4 Inferred Documentation Needs

Several documentation needs are implicit in the prompt's structure and the codebase's current state:

- **Cross-document referencing**: each module README must reference `ARCHITECTURE.md` for system-level context, `PRODUCTION_READINESS.md` for the production gap inventory, and `DATA_MODEL.md` for the schema diagram. Without these links the documents become orphaned silos.
- **Gap consolidation**: gaps surfaced in any module README's "Known Limitations" or "Production Readiness Status" section must also appear as line items in `PRODUCTION_READINESS.md`. Each gap therefore has two homes: the module-local README (developer reading the module needs to see it) and the central checklist (production-operator scanning for blockers needs to see it).
- **Schema field documentation**: although `*.schema.ts` files are exempt from per-field inline JSDoc (the prompt excludes "boilerplate field declarations"), the schemas are described comprehensively in `DATA_MODEL.md` so the field-level knowledge is captured exactly once in a canonical location.
- **Algorithm narrative**: the recipe `matches()` method [backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L92-L171] is identified by the prompt as the highest-value documentation target. It receives a full block comment in source (describing the four Mongo pre-filters, the per-recipe scoring loop, the `isQuickMake`/`isAlmostThere` derivation, and the post-filter and sort steps) AND a dedicated subsection in `ARCHITECTURE.md`.
- **Configuration discoverability**: the backend's runtime configuration depends on `backend/env_example` [backend/env_example:L1-L24] (which must not be modified per scope) and the mobile build configuration depends on `mobile/lib/env_config.dart` [mobile/lib/env_config.dart] (compile-time `--dart-define API_BASE_URL`). Each module README's "Configuration" section enumerates only the env vars that affect that module.
- **Verbatim-spelling discipline**: every occurrence of `Ingridient`, `InstractionItem`, or `singup` in documentation prose must be marked with a parenthetical note (e.g., "the `Ingridient` schema (spelling preserved verbatim throughout the backend)…") to alert readers that the deviation is intentional and not a typo in the documentation itself.
- **Workflow-derived diagrams**: each feature module README's Mermaid diagram is derived from the actual end-to-end user journey, not from generic architectural patterns. For example, the `ai/` README's diagram shows multipart upload → `FileInterceptor` → `AiService.detectIngredientsFromBuffer` → Google Cloud Vision label detection → ingredient dictionary lookup → `IngridientService.findManyWithPagination` → response. This grounds the diagrams in observable code paths.

## 0.2 Documentation Discovery and Analysis

### 0.2.1 Existing Documentation Infrastructure Assessment

Repository analysis reveals **no formal documentation infrastructure** of any kind. There is no `docs/` folder, no MkDocs/Docusaurus/Sphinx configuration, no `.readthedocs.yml`, no `typedoc.json`, and no documentation build script in either `backend/package.json` or `mobile/pubspec.yaml`. The PantryChef monorepo is effectively greenfield from a documentation-tooling perspective; all output of this engagement will be plain Markdown files committed alongside source code and rendered by GitHub's native viewer.

Existing Markdown surface (entire repository inventory):

| File | Current State | Action |
|------|---------------|--------|
| `backend/README.md` [backend/README.md:L1-L16] | 16 lines — minimal setup: copy env, run seed, `docker-compose up`, GCV credentials note | UPDATE — full replacement with ten-section module README |
| `mobile/README.md` [mobile/README.md:L1-L17] | 17 lines — default Flutter project boilerplate (`A new Flutter project`, codelab links) | UPDATE — full replacement with ten-section module README |
| `mobile/ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md` | Auto-generated by Xcode — launch image notes | OUT OF SCOPE (platform host directory) |

Documentation framework details:

- **Documentation generator**: NONE configured. Mermaid diagrams will render natively in GitHub's Markdown viewer with no additional tooling required.
- **API documentation tools in use**: `@nestjs/swagger` ^8.0.1 [backend/package.json:L33] generates an OpenAPI surface at `/docs` at runtime (via `SwaggerModule.setup('docs', app, document)` [backend/src/main.ts:L31]); the prompt does not request changes to this, but `ARCHITECTURE.md` will reference it.
- **Diagram tools detected**: NONE in code. Mermaid is the canonical choice per prompt directive.
- **Documentation hosting/deployment**: NONE. Documentation lives in-repo and is consumed via GitHub's web UI or local Markdown viewers.

Existing inline documentation coverage:

- **TypeScript JSDoc (backend/src)**: a `grep -rn "/**" backend/src/` returned no matches. Effective coverage: **0%**.
- **Dart DartDoc (mobile/lib)**: a `grep -rn "/// " mobile/lib/` returned a single occurrence in `mobile/lib/core/styles/app_theme.dart`. Effective coverage: **<1%**.

Because the prompt scopes inline documentation only to specific directories (excluding `*.config.ts`, `pubspec.yaml`, `package.json`, test files, auto-generated `*.g.dart`/`*.freezed.dart`, and platform-host directories), the new annotations land precisely where developer-onboarding value is highest: feature controllers, services, repositories, BLoCs, use cases, and shared utilities.

### 0.2.2 Repository Code Analysis for Documentation

The following code surfaces require documentation. Each has been verified to exist in the repository via direct file inspection.

**Backend public API surface** (NestJS controllers, all under global prefix `/api/v1/*`):

| Source File | Verified Endpoints |
|-------------|--------------------|
| `backend/src/auth/auth.controller.ts` [backend/src/auth/auth.controller.ts:L31-L87] | `POST /auth/email/login`, `POST /auth/email/register`, `GET /auth/me`, `POST /auth/refresh`, `POST /auth/logout`, `PATCH /auth/me`, `DELETE /auth/me` |
| `backend/src/recipe/recipe.controller.ts` [backend/src/recipe/recipe.controller.ts:L37-L99] | `POST /recipe`, `GET /recipe/matches`, `GET /recipe`, `GET /recipe/:id`, `PATCH /recipe/:id`, `DELETE /recipe/:id` |
| `backend/src/pantry/pantry.controller.ts` [backend/src/pantry/pantry.controller.ts:L36-L99] | `POST /pantry`, `GET /pantry`, `GET /pantry/:id`, `PATCH /pantry/:id`, `DELETE /pantry/:id` |
| `backend/src/ingridient/ingridient.controller.ts` [backend/src/ingridient/ingridient.controller.ts:L41-L133] | `GET /ingredient/creation-data`, `POST /ingredient`, `GET /ingredient`, `GET /ingredient/:id`, `PATCH /ingredient/:id`, `DELETE /ingredient/:id` |
| `backend/src/users/users.controller.ts` [backend/src/users/users.controller.ts:L36-L83] | `POST /users`, `GET /users`, `GET /users/me`, `PATCH /users`, `DELETE /users/:id` |
| `backend/src/ai/ai.controller.ts` [backend/src/ai/ai.controller.ts:L16-L43] | `POST /ai/vision` — **no JWT guard** (`@UseGuards` is absent) |
| `backend/src/app.controller.ts` | `GET /` returning the literal `'Hello World!'` from `AppService.getHello()` — boilerplate, documented as such in the root backend README |

**Backend module composition root** [backend/src/app.module.ts:L13-L31] imports the seven feature modules — `AuthModule`, `SessionModule`, `UsersModule`, `IngridientModule` (spelling preserved verbatim), `PantryModule`, `RecipeModule`, `AiModule` — along with `ConfigModule.forRoot(...)` and `MongooseModule.forRootAsync(...)` driven by `MongooseConfigService` [backend/src/database/mongoose-config.service.ts].

**Bootstrap entrypoint** [backend/src/main.ts:L10-L35] enables CORS, registers `useContainer` for class-validator DI, applies the global prefix from `app.apiPrefix` (default `api`) with `/` excluded, installs a global `ValidationPipe` with shared `validationOptions` [backend/src/utils/validation-options.ts], and serves Swagger UI at `/docs` with `addBearerAuth()`.

**Mobile feature surface** (Flutter clean-architecture per feature: `domain/`, `data/`, `presentation/`):

| Feature Folder | Verified Contents |
|----------------|-------------------|
| `mobile/lib/features/authentication/` | login + signup flows, BLoCs, screens including `authentication_start.dart` that navigates via `Navigation.singup` (sic) |
| `mobile/lib/features/pantry/` | pantry list browsing, item edit, hydrated BLoC state |
| `mobile/lib/features/recipe/` | recipe browsing, filtering, detail, favorites; domain model in `mobile/lib/features/recipe/domain/models/recipe.dart` with `ingridientList` field (sic) and `InstractionItem` reference (sic) |
| `mobile/lib/features/ingredient/` | ingredient search, creation, camera capture; depends on backend `/ai/vision` for label detection |
| `mobile/lib/features/profile/` | profile state, preferences, favorites, logout; hydrated BLoC for persistence |

**Mobile shared infrastructure** [mobile/lib/core/]:

- `mobile/lib/core/constants/` — route names (including `singup` preserved verbatim) [mobile/lib/core/constants/navigation.dart:L6], endpoints, status codes, preference keys
- `mobile/lib/core/utils/` — `DioClient` HTTP setup, `SharedPreferencesHelper`, `service_locator.dart` GetIt bootstrap, regex helpers, mappers
- `mobile/lib/core/styles/` — theme tokens (out of inline-comment scope per prompt's narrow listing, but covered narratively in `mobile/lib/core/README.md`)
- `mobile/lib/core/navigation.dart` — route resolution layer
- `mobile/lib/core/presentation/`, `mobile/lib/core/data/`, `mobile/lib/core/domain/` — shared cross-feature primitives (covered narratively in the core README)

**MongoDB schema files** (DATA_MODEL.md erDiagram source) — five files:

- `backend/src/users/infrastructure/document/entities/user.schema.ts` with embedded `Preferences` subdocument [backend/src/users/infrastructure/document/entities/user.schema.ts:L8-L20]
- `backend/src/session/infrastructure/document/entities/session.schema.ts`
- `backend/src/ingridient/infrastructure/document/entities/ingridient.schema.ts`
- `backend/src/pantry/infrastructure/document/entities/pantryIngridient.schema.ts` with `location` enum (`fridge`/`freezer`/`pantry`) [backend/src/pantry/infrastructure/document/entities/pantryIngridient.schema.ts:L32-L33] and userId index [backend/src/pantry/infrastructure/document/entities/pantryIngridient.schema.ts:L49]
- `backend/src/recipe/infrastructure/document/entities/recipe.schema.ts` with `difficulty` enum (`easy`/`medium`/`hard`) [backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L82] and title index [backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L106]

**Recipe matching algorithm** [backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L92-L171] — the headline feature receives dedicated treatment in three places: a full block comment above the `matches()` method, the `recipe/README.md` Data Flows section with a Mermaid diagram, and a dedicated `## Recipe Matching Pipeline` subsection in `ARCHITECTURE.md`.

### 0.2.3 Web Search Research Conducted

No web search was conducted during this analysis. The prompt is fully self-contained: it specifies the ten-section README template, the Mermaid diagram standard, the tag taxonomy (`// TODO(prod):`, `// NOTE:`, `// FIXME:`), the callout convention (`> ⚠️`, `> 🚧`), the spelling preservation rule, and the citation format. All documentation tooling required (JSDoc, DartDoc, Mermaid in GitHub-flavoured Markdown, GitHub's native Markdown table support) is already supported by versions present in `backend/package.json` (TypeScript ^5.1.3, `@typescript-eslint/parser` ^8.0.0) and `mobile/pubspec.yaml` (Dart SDK `^3.5.1`, `flutter_lints` ^4.0.0). No "best practices research" results need to be incorporated because the prompt itself is the binding style guide for this engagement.

## 0.3 Documentation Scope Analysis

### 0.3.1 Code-to-Documentation Mapping

The following tables exhaustively enumerate every code surface that requires documentation, the existing documentation state, and the action required.

**Backend modules requiring per-module READMEs:**

| Module | Public Code Surface | Current Documentation | Documentation Required |
|--------|--------------------|------------------------|------------------------|
| `backend/` (root) | `package.json` scripts, `Dockerfile`, `docker-compose.yml`, `nest-cli.json`, top-level orchestration | `backend/README.md` [backend/README.md:L1-L16] — 16-line minimal setup | Replace with full ten-section README covering NestJS root module composition, build/dev/test scripts, dockerized stack |
| `backend/src/auth/` | `AuthController` (7 endpoints) [backend/src/auth/auth.controller.ts:L31-L87], `AuthService`, three Passport strategies (`jwt`, `jwt-refresh`, `anonymous`), six DTOs including the unwired `forgot-password.dto.ts` and `reset-password.dto.ts` [backend/src/auth/dto/] | NONE | CREATE ten-section README with endpoint table, JWT/refresh flow Mermaid sequence diagram, password-reset gap callout |
| `backend/src/users/` | `UsersController` (5 endpoints), `UsersService`, `User` domain entity, `UserSchemaClass` with embedded `Preferences` | NONE | CREATE ten-section README with endpoint table, user→preferences→session relationship diagram |
| `backend/src/pantry/` | `PantryController` (5 endpoints), `PantryService`, `PantryRepository` (abstract), `PantryIngridientDocumentRepository` with destructive `softDelete` [backend/src/pantry/infrastructure/document/repositories/pantryIngridient.repository.ts:L119-L123] | NONE | CREATE ten-section README with endpoint table, user-scoped CRUD flow diagram, destructive-softDelete callout |
| `backend/src/ingridient/` | `IngridientController` (6 endpoints including `/creation-data`), `IngridientService`, `Ingridient` domain (spelling preserved) | NONE | CREATE ten-section README with endpoint table, category/unit reference data flow, spelling-preservation note |
| `backend/src/recipe/` | `RecipeController` (6 endpoints including `/matches`), `RecipeService`, `RecipeDocumentRepository.matches()` algorithm [backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L92-L171] | NONE | CREATE ten-section README; data flow diagram for matching pipeline; cross-link to `ARCHITECTURE.md` deep-dive; gap callouts for unit normalization, quantity sufficiency, exact `_id` matching |
| `backend/src/ai/` | `AiController` (1 endpoint, **unguarded**), `AiService` with Google Cloud Vision integration and ~30-term ingredient dictionary [backend/src/ai/ai.service.ts:L11-L49] | NONE | CREATE ten-section README; sequenceDiagram for multipart upload → GCV → dictionary lookup; production-gap callouts for MIME-filter, missing JWT guard, small dictionary |
| `backend/src/database/` | `MongooseConfigService`, four seed services (`UserSeedService`, `IngridientSeedService`, `RecipeSeedService`, `PantrySeedService`), `run-seed.ts` orchestrator, destructive `dropCollection()` pattern | NONE | CREATE ten-section README documenting connection assembly, seed order, destructive seed pattern, migration-versioning gap |
| `backend/src/config/` | `app.config.ts` factory with `EnvironmentVariablesValidator`, `AllConfigType`, `AppConfig` | NONE | CREATE ten-section README with env-var table sourced from `backend/env_example` [backend/env_example:L1-L24] |
| `backend/src/common/` | `Reference` type alias only [backend/src/common/types.ts] | NONE | CREATE ten-section README (compact — module is small but its contract is widely consumed) |

**Mobile modules requiring per-module READMEs:**

| Module | Public Code Surface | Current Documentation | Documentation Required |
|--------|--------------------|------------------------|------------------------|
| `mobile/` (root) | `pubspec.yaml`, `analysis_options.yaml`, `main.dart` bootstrap, native host directories | `mobile/README.md` [mobile/README.md:L1-L17] — 17-line Flutter boilerplate | Replace with ten-section README documenting Flutter project identity, BLoC + HydratedBloc startup, GetIt DI, env config |
| `mobile/lib/features/authentication/` | login/signup BLoCs, screens (`authentication_start.dart` navigates to `Navigation.singup` (sic) [mobile/lib/features/authentication/presentation/widgets/screens/authentication_start.dart:L36]), Dio-based API client | NONE | CREATE ten-section README with login + signup sequenceDiagram, JWT token storage notes |
| `mobile/lib/features/pantry/` | hydrated BLoC, pantry list/edit screens, repository over Dio | NONE | CREATE ten-section README with CRUD flow diagram, hydrated-state note |
| `mobile/lib/features/recipe/` | recipe list/detail/favorites BLoC, `Recipe` domain model with `ingridientList` field (sic) and `InstractionItem` reference (sic) [mobile/lib/features/recipe/domain/models/recipe.dart], `copyWith` no-op on `inFavorite` [mobile/lib/features/recipe/domain/models/recipe.dart:L37-L53] | NONE | CREATE ten-section README; gap callouts for spelling preservation and copyWith no-op (flagged with `// FIXME:` inline) |
| `mobile/lib/features/ingredient/` | search/creation/camera flows, BLoCs for camera + ingredient-add, image upload to `/v1/ai/vision` | NONE | CREATE ten-section README with camera → AI vision sequenceDiagram |
| `mobile/lib/features/profile/` | hydrated BLoC for profile/favorites/preferences, logout/reset | NONE | CREATE ten-section README with profile state flow |
| `mobile/lib/core/` | navigation, styles, constants, utils, presentation primitives, data/DTO helpers, domain shared | NONE | CREATE ten-section README documenting the entire cross-cutting shared layer |

**Top-level cross-cutting documents:**

| Document | Source Information | Action |
|----------|-------------------|--------|
| `ARCHITECTURE.md` (repo root) | All seven backend modules, mobile clean-architecture layering, JWT auth flow, soft-delete contract, pagination cap (50), BLoC + HydratedBloc, GetIt DI, recipe matching deep-dive | CREATE |
| `PRODUCTION_READINESS.md` (repo root) | `backend/Dockerfile` [backend/Dockerfile:L13] runs `npm run dev`; `backend/docker-compose.yml` [backend/docker-compose.yml:L8-L10] hardcoded mongo credentials; `backend/env_example` [backend/env_example:L23] `AUTH_REFRESH_TOKEN_EXPIRES_IN=3650d`; all seven gap categories inventoried in §0.3.2 | CREATE |
| `DATA_MODEL.md` (repo root) | Five `*.schema.ts` files + `Preferences` subdocument + soft-delete + timestamps convention | CREATE |

**Inline documentation scope** (file globs):

| Source Directory | Glob Pattern | Inline Format |
|------------------|--------------|---------------|
| `backend/src/auth/` | `**/*.ts` (exclude `*.spec.ts`, `*.schema.ts` field boilerplate) | JSDoc `/** */` + `// TODO(prod):`/`// NOTE:`/`// FIXME:` |
| `backend/src/users/` | `**/*.ts` (same exclusions) | JSDoc + tags |
| `backend/src/pantry/` | `**/*.ts` (same exclusions) | JSDoc + tags |
| `backend/src/ingridient/` | `**/*.ts` (same exclusions) | JSDoc + tags |
| `backend/src/recipe/` | `**/*.ts` (same exclusions); priority on `infrastructure/document/repositories/recipe.repository.ts` | JSDoc + tags + full block comment on `matches()` |
| `backend/src/ai/` | `**/*.ts` (same exclusions) | JSDoc + tags |
| `backend/src/database/seeds/` | `**/*.ts` (exclude `*.spec.ts`) | JSDoc + tags |
| `mobile/lib/features/authentication/` | `**/*.dart` (exclude `*.g.dart`, `*.freezed.dart`, test files) | DartDoc `///` + tags |
| `mobile/lib/features/pantry/` | same | DartDoc + tags |
| `mobile/lib/features/recipe/` | same | DartDoc + tags |
| `mobile/lib/features/ingredient/` | same | DartDoc + tags |
| `mobile/lib/features/profile/` | same | DartDoc + tags |
| `mobile/lib/core/utils/` | `**/*.dart` (exclude `*.g.dart`, `*.freezed.dart`) | DartDoc + tags |
| `mobile/lib/core/constants/` | `**/*.dart` (exclude `*.g.dart`, `*.freezed.dart`) | DartDoc + tags |

**Configuration options requiring documentation** (table format in each module's "Configuration" README section):

| Env Var | Default | Source | Affected Modules |
|---------|---------|--------|------------------|
| `NODE_ENV` | `development` | `backend/env_example:L1` | All |
| `APP_PORT` | `3000` | `backend/env_example:L2`, `backend/src/config/app.config.ts` | Bootstrap |
| `API_PREFIX` | `api` | `backend/env_example:L4`, `backend/src/config/app.config.ts` | All controllers |
| `DATABASE_URL` | `mongodb://localhost:27017` | `backend/env_example:L11` | All persistence |
| `DATABASE_USERNAME` / `DATABASE_PASSWORD` | `admin` / `123456` | `backend/env_example:L8-L9` | Database |
| `DATABASE_NAME` | `blitzy` | `backend/env_example:L10` | Database |
| `AUTH_JWT_SECRET` | `secret` | `backend/env_example:L20` | Auth |
| `AUTH_JWT_TOKEN_EXPIRES_IN` | `15m` | `backend/env_example:L21` | Auth |
| `AUTH_REFRESH_SECRET` | `secret_for_refresh` | `backend/env_example:L22` | Auth |
| `AUTH_REFRESH_TOKEN_EXPIRES_IN` | `3650d` | `backend/env_example:L23` | Auth |
| `FILE_DRIVER` | `local` (supports `local`, `s3`, `s3-presigned`) | `backend/env_example:L14` | (no S3 driver implemented) |
| `ACCESS_KEY_ID`, `SECRET_ACCESS_KEY`, `AWS_S3_REGION`, `AWS_DEFAULT_S3_BUCKET` | empty | `backend/env_example:L15-L18` | (placeholders) |
| `API_BASE_URL` (mobile compile-time) | `http://192.168.2.20:3000/api` | `mobile/lib/env_config.dart` | All mobile features |

**Features requiring user-guide-style narrative** (covered inside each feature's README under "Primary Use Cases" and "Data Flows"):

| Feature | Workflow | Current Coverage | Gaps to Cover |
|---------|----------|------------------|---------------|
| Authentication | Sign up → log in → token refresh → logout | None | Refresh-token rotation, 401-handling, missing password reset endpoints |
| Pantry | Add item via camera, edit item, browse | None | Hydrated state, location enum, destructive softDelete |
| Recipe matching | View pantry-aware matches | None | Mongo pre-filter chain, scoring loop, isQuickMake/isAlmostThere derivation, exact `_id` matching limit |
| AI vision | Capture photo → label detection → ingredient resolution | None | Missing JWT guard, commented MIME filter, dictionary size, GCV credential fallback |
| Profile | Manage preferences, favorites, log out | None | favoriteRecipes synchronization, BLoC reset |

### 0.3.2 Documentation Gap Analysis

Given the requirements and repository analysis, documentation gaps fall into the following classes:

**Undocumented public APIs (100% gap):**

- All NestJS controllers (six feature controllers + `AppController`) lack JSDoc on any exported method, class, or constructor parameter.
- All NestJS services lack JSDoc on business-orchestration methods.
- All abstract repository contracts (`backend/src/recipe/infrastructure/recipe.repository.ts`, `backend/src/pantry/infrastructure/pantry.repository.ts`, etc.) lack JSDoc.
- All concrete document repositories lack JSDoc — most critically `RecipeDocumentRepository.matches()` [backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L92-L171] which the prompt designates as the priority annotation target.
- All Passport strategies (`JwtStrategy`, `JwtRefreshStrategy`, `AnonymousStrategy`) lack JSDoc.
- All BLoC classes, events, and states in the mobile feature folders lack DartDoc.
- All use case classes and repository interfaces in `domain/` lack DartDoc.
- All Dio API clients in `data/` lack DartDoc.

**Missing user guides (100% gap):**

- No user guide exists for any of the five feature workflows (authentication, pantry, recipe matching, AI vision, profile).
- This gap is closed by the "Primary Use Cases" and "Data Flows" sections of each module README.

**Incomplete architecture documentation (100% gap):**

- No system-wide diagram or narrative exists. `ARCHITECTURE.md` is the canonical fill.
- No data-model diagram exists. `DATA_MODEL.md` is the canonical fill.
- No production-readiness inventory exists. `PRODUCTION_READINESS.md` is the canonical fill.

**Outdated documentation (limited but present):**

- `backend/README.md` [backend/README.md:L1-L16] documents only setup — out of date relative to the full architecture; replaced wholesale.
- `mobile/README.md` [mobile/README.md:L1-L17] is Flutter scaffolding boilerplate that names the project "A new Flutter project" — replaced wholesale.

**Code-level gaps explicitly required for documentation callouts** (from prompt and verified in code):

| Gap | Evidence | Module README Callout |
|-----|----------|------------------------|
| Recipe `matches()` uses exact `_id` only, no unit normalization, no quantity sufficiency | [backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L97, L132] | `recipe/README.md` §9 with `> ⚠️` |
| AI MIME-type filter commented out | [backend/src/ai/ai.controller.ts:L20-L28] | `ai/README.md` §9 with `> ⚠️` and §10 with `> 🚧` |
| AI endpoint has no JWT guard | [backend/src/ai/ai.controller.ts:L12-L43] — no `@UseGuards` | `ai/README.md` §10 with `> 🚧` |
| AI ingredient dictionary is small | [backend/src/ai/ai.service.ts:L11-L49] (~30 terms hardcoded) | `ai/README.md` §9 with `> ⚠️` |
| Pantry `softDelete` calls `deleteOne` | [backend/src/pantry/infrastructure/document/repositories/pantryIngridient.repository.ts:L119-L123] | `pantry/README.md` §9 with `> ⚠️`; inline `// FIXME:` + `// TODO(prod):` at the method body |
| Auth password reset DTOs unwired | DTOs exist at `backend/src/auth/dto/auth-forgot-password.dto.ts` and `backend/src/auth/dto/auth-reset-password.dto.ts`; no matching endpoint in `auth.controller.ts` | `auth/README.md` §9 with `> ⚠️` |
| Seed runner destructive | [backend/src/database/seeds/user/user-seed.service.ts:L15-L19] (`dropCollection` then reseed) | `database/README.md` §9 with `> ⚠️`; §10 with `> 🚧` for migration versioning |
| `Recipe.copyWith` no-op on `inFavorite` | [mobile/lib/features/recipe/domain/models/recipe.dart:L37-L53] (parameter accepted but not assigned) | `recipe/README.md` (mobile) §9 with `> ⚠️`; inline `// NOTE:` + `// FIXME:` at the method |
| Preserved spelling variants `Ingridient`, `singup`, `InstractionItem` | Many files across both halves of the monorepo | Every affected README's §9; inline `// NOTE:` at first occurrence in each file |

## 0.4 Documentation Implementation Design

### 0.4.1 Documentation Structure Planning

Documentation files are colocated with the code they describe; there is no separate `docs/` directory. The final documentation tree is:

```
PantryChef/
├── ARCHITECTURE.md                                   (CREATE — root)
├── PRODUCTION_READINESS.md                           (CREATE — root)
├── DATA_MODEL.md                                     (CREATE — root)
├── backend/
│   ├── README.md                                     (UPDATE — replace boilerplate)
│   └── src/
│       ├── auth/README.md                            (CREATE)
│       ├── users/README.md                           (CREATE)
│       ├── pantry/README.md                          (CREATE)
│       ├── ingridient/README.md                      (CREATE — spelling preserved verbatim)
│       ├── recipe/README.md                          (CREATE)
│       ├── ai/README.md                              (CREATE)
│       ├── database/README.md                        (CREATE)
│       ├── config/README.md                          (CREATE)
│       └── common/README.md                          (CREATE)
└── mobile/
    ├── README.md                                     (UPDATE — replace boilerplate)
    └── lib/
        ├── features/
        │   ├── authentication/README.md              (CREATE)
        │   ├── pantry/README.md                      (CREATE)
        │   ├── recipe/README.md                      (CREATE)
        │   ├── ingredient/README.md                  (CREATE — mobile spelling)
        │   └── profile/README.md                     (CREATE)
        └── core/README.md                            (CREATE)
```

Every module README follows the prompt-mandated ten H2 sections in this exact order:

```
# <Module Name>

#### Module Purpose

#### Key Components

#### Architecture Fit

#### Dependencies

#### Primary Use Cases

#### API / Endpoint Reference   <-- backend modules only

#### Data Flows

#### Configuration

#### Known Limitations and Implementation Gaps

#### Production Readiness Status

```

`ARCHITECTURE.md` follows this structure (also ordered intentionally):

```
# PantryChef Architecture

#### Monorepo Structure

#### Technology Choices and Rationale

#### Cross-Cutting Concerns

#### JWT Authentication Flow

#### Soft-Delete Contract
#### Pagination Cap (50 records)

#### BLoC State Management
#### GetIt Dependency Injection

#### Full Request Path                                  (Mermaid flowchart LR)

#### Recipe Matching Pipeline                           (algorithm deep-dive)

```

`PRODUCTION_READINESS.md` follows this structure:

```
# Production Readiness Checklist

#### Overview

#### Status Categories

| Category | Key Items | Status |
| Build & Runtime | ... | ❌/⚠️/✅ |
| Secrets Management | ... | ❌ |
| Networking & TLS | ... | ❌ |
| Infrastructure & Orchestration | ... | ❌ |
| File Storage | ... | ⚠️ |
| Security Hardening | ... | ❌/⚠️ |
| Observability | ... | ❌ |
| CI/CD | ... | ❌ |
| Database | ... | ⚠️ |
| Testing | ... | ⚠️ |
| Mobile Release | ... | ❌ |
#### Narrative Per Category                             (one subsection per row)

```

`DATA_MODEL.md` follows this structure:

```
# PantryChef Data Model

#### Overview

#### Entity-Relationship Diagram                        (Mermaid erDiagram, all 5 collections)

#### Collections

#### User

#### Preferences (embedded subdocument)
#### Session

#### Ingridient (spelling preserved verbatim)
#### PantryIngridient (spelling preserved verbatim)

#### Recipe
#### Cross-Cutting Schema Conventions

#### Timestamps

#### Soft-Delete (deletedAt)
#### Reference Type (id + name pair)

```

### 0.4.2 Content Generation Strategy

**Information extraction approach** — each section of each README is populated by reading the corresponding source artifact:

- **Module Purpose** — derived from the module's `*.module.ts` imports and the module's controller responsibilities. Single paragraph, ≤4 sentences.
- **Key Components** — table populated by listing files in the module folder. For backend, columns are: file path, type (Controller/Service/Repository/Strategy/DTO/Domain/Schema), one-line responsibility. For mobile, columns are: file path, type (BLoC/UseCase/Repository/API Client/Screen/Widget), one-line responsibility.
- **Architecture Fit** — derived from observed layering. Backend READMEs document the controller → service → repository → domain pattern explicitly: "`Module.controller.ts` routes HTTP requests, delegates to `Module.service.ts` for business orchestration, which calls the abstract `Module.repository.ts` contract bound at composition time to `infrastructure/document/repositories/*.repository.ts` for Mongoose persistence." Mobile READMEs document the `presentation` → `domain` → `data` clean-architecture pattern.
- **Dependencies** — *Internal* sub-section names other backend modules or mobile features this module imports (e.g., `RecipeModule` imports `DocumentPantryPersistenceModule`, `UsersModule`, and `PantryModule` [backend/src/recipe/recipe.module.ts]). *External* sub-section names npm packages from `backend/package.json` [backend/package.json:L24-L75] or pub packages from `mobile/pubspec.yaml` [mobile/pubspec.yaml:L30-L63], with versions pinned exactly as the manifest declares them.
- **Primary Use Cases** — bullet list of 3–7 concrete user-facing or system-facing workflows extracted from controller endpoints and BLoC events.
- **API / Endpoint Reference** (backend only) — table with columns: HTTP method, path, guard, one-line description. Routes derived from controller decorators (e.g., `@Post('email/login')` under `@Controller({ path: 'auth', version: '1' })` → `POST /api/v1/auth/email/login`).
- **Data Flows** — Mermaid `sequenceDiagram` (for request/response cycles) or `flowchart TD` (for branching control flow), constrained to ≤10 nodes. Diagrams are derived from the actual code path, not from generic patterns.
- **Configuration** — table of env vars or compile-time constants that the module reads, citing `backend/env_example` [backend/env_example:L1-L24] for backend modules and `mobile/lib/env_config.dart` for mobile.
- **Known Limitations and Implementation Gaps** — blockquoted `> ⚠️` callouts for each gap, with source citation.
- **Production Readiness Status** — blockquoted `> 🚧` callouts for each blocker, mapped to one of the eleven `PRODUCTION_READINESS.md` categories.

**Template application** — the prompt is the binding template; no user-supplied template file exists. Every README uses the exact ten-section ordering from the prompt.

**Documentation standards** applied uniformly:

- Markdown headers: `#` for document title, `##` for ten mandatory sections, `###` for sub-sections within (e.g., Dependencies > Internal, Dependencies > External), `####` if needed for deeper drill-downs.
- Mermaid diagrams use the syntax `flowchart TD`, `flowchart LR`, `sequenceDiagram`, or `erDiagram`, in fenced code blocks labeled `mermaid`.
- Code examples use fenced code blocks with language identifiers (`typescript`, `dart`, `bash`, `json`, `yaml`).
- Source citations appear inline or as footnotes in the format `Source: backend/src/<module>/<file>.ts:<LineNumber>` or `Source: mobile/lib/<feature>/<layer>/<file>.dart:<LineNumber>`.
- Tables use standard GitHub-flavoured Markdown.
- Consistent terminology — "Recipe matching pipeline" (not "match engine"); "soft-delete via `deletedAt`" (not "logical deletion"); "JWT access and refresh tokens"; "`Ingridient` (spelling preserved verbatim)" on first occurrence in each document.

### 0.4.3 Diagram and Visual Strategy

**Mermaid diagrams to create** (one per module README plus dedicated diagrams in top-level documents):

| Document | Diagram Type | Subject | Source Code Basis |
|----------|--------------|---------|-------------------|
| `backend/src/auth/README.md` | `sequenceDiagram` | Email login → JWT issuance → bearer-token request → 401 → refresh flow | `auth.controller.ts`, `auth.service.ts`, `JwtStrategy`, `JwtRefreshStrategy` |
| `backend/src/users/README.md` | `flowchart TD` | User creation → preferences embedding → session linkage | `users.controller.ts`, `user.schema.ts` |
| `backend/src/pantry/README.md` | `sequenceDiagram` | Add pantry item → JWT extraction → repository save → response | `pantry.controller.ts`, `pantryIngridient.repository.ts` |
| `backend/src/ingridient/README.md` | `flowchart TD` | Ingredient creation with category/unit reference lookup | `ingridient.controller.ts` |
| `backend/src/recipe/README.md` | `flowchart TD` | Recipe matching pipeline (≤10 nodes summary — full version lives in `ARCHITECTURE.md`) | `recipe.repository.ts:L92-L171` |
| `backend/src/ai/README.md` | `sequenceDiagram` | Multipart image upload → memoryStorage → GCV label detection → dictionary lookup → ingredient resolution | `ai.controller.ts`, `ai.service.ts` |
| `backend/src/database/README.md` | `flowchart TD` | Seed orchestration order: User → Ingridient → Recipe → Pantry | `run-seed.ts` |
| `backend/src/config/README.md` | `flowchart TD` | Env var → validator → registerAs namespace → injected AllConfigType | `app.config.ts`, `config.type.ts` |
| `backend/src/common/README.md` | `flowchart TD` | Reference type usage across feature schemas | `common/types.ts` and consumers |
| `backend/README.md` | `flowchart LR` | NestJS root composition: ConfigModule + MongooseModule + 7 feature modules | `app.module.ts` |
| `mobile/lib/features/authentication/README.md` | `sequenceDiagram` | Login screen → AuthBloc → AuthRepository → DioClient → backend → token persistence | `presentation/bloc`, `data/api`, `core/utils/dio_client.dart` |
| `mobile/lib/features/pantry/README.md` | `flowchart TD` | Pantry list hydration on app start, edit flow, delete flow | `pantry_bloc.dart`, `pantry_repository.dart` |
| `mobile/lib/features/recipe/README.md` | `sequenceDiagram` | Recipe matches query → backend `/recipe/matches` → render with `matchScore` | `recipe_bloc.dart`, `recipe_api.dart` |
| `mobile/lib/features/ingredient/README.md` | `sequenceDiagram` | Camera capture → image upload → AI vision → ingredient suggestion → user confirmation | `camera_bloc.dart`, `ingredient_add_bloc.dart` |
| `mobile/lib/features/profile/README.md` | `flowchart TD` | Profile load → preferences update → favorites sync → logout | `profile_bloc.dart` |
| `mobile/lib/core/README.md` | `flowchart LR` | Service locator wiring: SharedPreferences → SharedPreferencesHelper → DioClient → JWT interceptor | `service_locator.dart`, `dio_client.dart` |
| `mobile/README.md` | `flowchart LR` | Mobile bootstrap: `WidgetsFlutterBinding` → HydratedBloc.storage → setupLocator → runApp | `main.dart` |
| `ARCHITECTURE.md` | `flowchart LR` (main) | Full request path: Flutter `DioClient` → bearer JWT → NestJS bootstrap → feature module → MongoDB / GCV | `mobile/lib/core/utils/dio_client.dart`, `backend/src/main.ts`, `backend/src/app.module.ts` |
| `ARCHITECTURE.md` | `flowchart TD` (sub) | Recipe matching pipeline with all four Mongo pre-filters, scoring loop, post-filter, sort | `backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L92-L171` |
| `DATA_MODEL.md` | `erDiagram` | User ←→ Session, User ⊃ Preferences (embedded), PantryIngridient → Ingridient, Recipe → Ingridient (via IngridientList) | All five `*.schema.ts` files |

**Screenshot/image requirements**: NONE. The prompt does not request UI screenshots, and image generation is outside the documentation scope.

**Architecture diagram specifications**:

- `ARCHITECTURE.md` main diagram: `flowchart LR` — left-to-right system topology, ≤10 nodes per Mermaid rule, with subgraphs grouping client tier, backend tier, and persistence/external tier.
- `ARCHITECTURE.md` recipe pipeline diagram: `flowchart TD` — vertical top-down decision flow showing the four Mongo pre-filter steps (allergies/disliked `$nin`, dietary `$all`, cookingTime `$lte`, deletedAt null), the scoring loop, the isQuickMake / isAlmostThere flag derivation, the optional `FilterType` post-filter, and the final sort by `matchScore` descending.
- `DATA_MODEL.md` ER diagram: Mermaid `erDiagram` syntax with proper crow's-foot notation for relationships (1-to-many between User and Session, 1-to-many between User and PantryIngridient via userId scalar, many-to-many between Recipe and Ingridient via the embedded IngridientList array, etc.).

## 0.5 Documentation File Transformation Mapping

### 0.5.1 File-by-File Documentation Plan

The following table is the exhaustive file-by-file transformation map. Every documentation file in scope is listed; nothing is left "pending" or "to be discovered."

Transformation modes:

- **CREATE** — author a new documentation file from scratch
- **UPDATE** — modify an existing file (full replacement when the existing content is boilerplate, or edit-in-place for inline-comment additions to source files)
- **DELETE** — remove an obsolete documentation file (none required for this engagement)
- **REFERENCE** — used as a style/structure exemplar, not modified

| Target Documentation File | Transformation | Source Code / Docs | Content / Changes |
|---------------------------|----------------|--------------------|--------------------|
| `ARCHITECTURE.md` | CREATE | `backend/src/app.module.ts`, `backend/src/main.ts`, `mobile/lib/main.dart`, `mobile/lib/core/utils/service_locator.dart`, `mobile/lib/core/utils/dio_client.dart`, all module composition files | System-wide architecture document with monorepo structure, technology rationale (NestJS 10, Flutter ^3.5.1, MongoDB 8.8, Google Cloud Vision 4.3.2), cross-cutting concerns (JWT auth, soft-delete, pagination cap 50, BLoC + HydratedBloc, GetIt DI), Mermaid `flowchart LR` showing Flutter client → NestJS → MongoDB/GCV, dedicated `## Recipe Matching Pipeline` subsection deep-diving the `matches()` algorithm |
| `PRODUCTION_READINESS.md` | CREATE | `backend/Dockerfile`, `backend/docker-compose.yml`, `backend/env_example`, all gap-source files | Structured checklist with 11-category status table (❌/⚠️/✅) plus narrative per category covering: multi-stage Dockerfile, removing `npm run dev`, compiling TypeScript to `/dist`, Flutter release builds with `--dart-define API_BASE_URL`, MongoDB credentials out of `docker-compose.yml`, GCV credentials out of `src/config/ai.json`, secrets manager integration, JWT secret rotation, reducing refresh token TTL from `3650d` [backend/env_example:L23], reverse proxy + TLS, CORS whitelist, replacing Docker Compose with Kubernetes/managed container, MongoDB Atlas, backup/PITR, S3 driver via existing `AWS_*` env vars [backend/env_example:L15-L18], rate limiting (`@nestjs/throttler`), Helmet, JWT guard on `POST /v1/ai/vision` [backend/src/ai/ai.controller.ts:L16-L43], MIME-type validation [backend/src/ai/ai.controller.ts:L20-L28], password reset endpoints (DTOs exist at `backend/src/auth/dto/auth-forgot-password.dto.ts` and `auth-reset-password.dto.ts`), structured logging, `/metrics`, OpenTelemetry, alerting, CI/CD pipeline, gating seed runner [backend/src/database/seeds/run-seed.ts] behind explicit flag, indexes for matching at scale, migration versioning, expanded e2e coverage, unit tests for `RecipeRepository.matches()`, App Store/Play Store signing |
| `DATA_MODEL.md` | CREATE | `backend/src/users/infrastructure/document/entities/user.schema.ts`, `backend/src/session/infrastructure/document/entities/session.schema.ts`, `backend/src/ingridient/infrastructure/document/entities/ingridient.schema.ts`, `backend/src/pantry/infrastructure/document/entities/pantryIngridient.schema.ts`, `backend/src/recipe/infrastructure/document/entities/recipe.schema.ts` | Mermaid `erDiagram` of all five collections plus `Preferences` embedded subdocument [backend/src/users/infrastructure/document/entities/user.schema.ts:L8-L20], `location` enum (`fridge`/`freezer`/`pantry`) [backend/src/pantry/infrastructure/document/entities/pantryIngridient.schema.ts:L32-L33], `difficulty` enum (`easy`/`medium`/`hard`) [backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L82], soft-delete `deletedAt`, and `@Schema({ timestamps: true })` `createdAt`/`updatedAt` fields |
| `backend/README.md` | UPDATE | `backend/package.json`, `backend/Dockerfile`, `backend/docker-compose.yml`, `backend/src/app.module.ts`, `backend/src/main.ts` | Full replacement with ten-section module README for the NestJS root: covers project identity (`blitzy-backend` v0.0.1, UNLICENSED), seven feature modules, build/dev/test scripts, dockerized stack, Swagger at `/docs`, env requirements |
| `backend/src/auth/README.md` | CREATE | `backend/src/auth/auth.controller.ts`, `auth.service.ts`, `auth.module.ts`, `strategies/`, `dto/`, `config/`, `types/` | Ten-section README with endpoint table (7 routes including login, register, me, refresh, logout, update, delete), Mermaid sequenceDiagram for login→JWT→bearer→401→refresh, dependency table (UsersModule, SessionModule, PassportModule, JwtModule), gap callout for unwired password reset DTOs |
| `backend/src/users/README.md` | CREATE | `backend/src/users/users.controller.ts`, `users.service.ts`, `users.module.ts`, `infrastructure/`, `domain/user.ts`, `dto/` | Ten-section README with endpoint table (5 routes including `/me`), embedded `Preferences` subdocument description, Mermaid flowchart of user creation + preferences embedding |
| `backend/src/pantry/README.md` | CREATE | `backend/src/pantry/pantry.controller.ts`, `pantry.service.ts`, `pantry.module.ts`, `infrastructure/document/repositories/pantryIngridient.repository.ts`, `domain/pantryIngridient.ts`, `dto/` | Ten-section README with endpoint table, user-scoped CRUD diagram, gap callout for destructive `softDelete` (calls `deleteOne` per [backend/src/pantry/infrastructure/document/repositories/pantryIngridient.repository.ts:L119-L123]), `location` enum (`fridge`/`freezer`/`pantry`) note |
| `backend/src/ingridient/README.md` | CREATE | `backend/src/ingridient/ingridient.controller.ts`, `ingridient.service.ts`, `ingridient.module.ts`, `infrastructure/`, `domain/ingrident.ts`, `dto/` | Ten-section README with endpoint table (6 routes including `/creation-data`), category/unit reference data flow, spelling-preservation parenthetical note on first occurrence of `Ingridient` |
| `backend/src/recipe/README.md` | CREATE | `backend/src/recipe/recipe.controller.ts`, `recipe.service.ts`, `recipe.module.ts`, `infrastructure/recipe.repository.ts`, `infrastructure/document/repositories/recipe.repository.ts`, `domain/recipe.ts`, `dto/`, `types/filter.types.ts` | Ten-section README with endpoint table (6 routes including `/matches`), matching pipeline summary flowchart (≤10 nodes — full version in `ARCHITECTURE.md`), gap callouts for exact `_id` matching, missing unit normalization, missing quantity sufficiency |
| `backend/src/ai/README.md` | CREATE | `backend/src/ai/ai.controller.ts`, `ai.service.ts`, `ai.module.ts` | Ten-section README with single-endpoint table (`POST /v1/ai/vision` — **unguarded**), Mermaid sequenceDiagram for multipart → memoryStorage → GCV `LABEL_DETECTION` (`maxResults: 10`) → dictionary lookup → ingredient resolution, gap callouts for commented MIME filter [backend/src/ai/ai.controller.ts:L20-L28], missing JWT guard, ~30-term hardcoded dictionary [backend/src/ai/ai.service.ts:L11-L49] |
| `backend/src/database/README.md` | CREATE | `backend/src/database/mongoose-config.service.ts`, `database/config/database.config.ts`, `database/config/database-config.type.ts`, `database/seeds/run-seed.ts`, `database/seeds/seed.module.ts`, all four seed services | Ten-section README documenting connection assembly from `AllConfigType`, seed orchestration order (User → Ingridient → Recipe → Pantry per [backend/src/database/seeds/run-seed.ts:L13-L16]), destructive `dropCollection()` pattern, no migration versioning gap |
| `backend/src/config/README.md` | CREATE | `backend/src/config/app.config.ts`, `app-config.type.ts`, `config.type.ts` | Ten-section README documenting `EnvironmentVariablesValidator`, `registerAs('app', ...)`, the `AllConfigType` aggregate with `app`, `auth`, `database` sub-namespaces, env var table sourced from `backend/env_example` [backend/env_example:L1-L24] |
| `backend/src/common/README.md` | CREATE | `backend/src/common/types.ts` | Compact ten-section README documenting the `Reference` type (`{ id: string; name: string }`) and its cross-feature usage in `IngridientSchemaClass.category`, `IngridientSchemaClass.unit` |
| `mobile/README.md` | UPDATE | `mobile/pubspec.yaml`, `mobile/lib/main.dart`, `mobile/lib/env_config.dart`, `mobile/analysis_options.yaml` | Full replacement with ten-section module README for the Flutter root: covers project identity (`pantry_chef` v1.0.0+1), SDK `^3.5.1`, BLoC + HydratedBloc startup, `setupLocator()` GetIt DI, `--dart-define API_BASE_URL` config, lint policy |
| `mobile/lib/features/authentication/README.md` | CREATE | `mobile/lib/features/authentication/domain/`, `data/`, `presentation/`, screen at `presentation/widgets/screens/authentication_start.dart` | Ten-section README with login + signup sequenceDiagram, BLoC events/states, navigation to `Navigation.singup` (sic) [mobile/lib/core/constants/navigation.dart:L6], JWT token persistence via `SharedPreferencesHelper`, callout for preserved `singup` typo |
| `mobile/lib/features/pantry/README.md` | CREATE | `mobile/lib/features/pantry/domain/`, `data/`, `presentation/` | Ten-section README with pantry list/edit/delete flow diagram, hydrated BLoC state note, location enum mapping |
| `mobile/lib/features/recipe/README.md` | CREATE | `mobile/lib/features/recipe/domain/models/recipe.dart`, `instraction_item.dart`, `ingredient_list_item.dart`, `domain/`, `data/`, `presentation/` | Ten-section README with recipe list/detail + matches sequenceDiagram, callout for preserved `instraction_item.dart` + `InstractionItem` spelling [mobile/lib/features/recipe/domain/models/instraction_item.dart], callout for `Recipe.copyWith` no-op on `inFavorite` [mobile/lib/features/recipe/domain/models/recipe.dart:L37-L53] |
| `mobile/lib/features/ingredient/README.md` | CREATE | `mobile/lib/features/ingredient/domain/`, `data/`, `presentation/`, including camera screens | Ten-section README with camera capture → AI vision sequenceDiagram, note on mobile's correct `ingredient` spelling vs backend's preserved `ingridient` |
| `mobile/lib/features/profile/README.md` | CREATE | `mobile/lib/features/profile/domain/`, `data/`, `presentation/` | Ten-section README with profile state flow, preferences/favorites sync, logout/reset |
| `mobile/lib/core/README.md` | CREATE | `mobile/lib/core/navigation.dart`, `core/constants/`, `core/utils/`, `core/styles/`, `core/presentation/`, `core/data/`, `core/domain/` | Ten-section README documenting the cross-cutting shared layer: route resolution, theme tokens, shared constants, GetIt service locator, DioClient with JWT interceptor, SharedPreferencesHelper, regex helpers, mappers |
| `backend/src/auth/*.ts` (inline) | UPDATE | Same files | Add JSDoc to all exported items in `auth.controller.ts`, `auth.service.ts`, `auth.module.ts`, `strategies/*.ts`, `dto/*.ts`, `config/auth.config.ts`. Exclude `.spec.ts` and schema field boilerplate. No code logic changes. |
| `backend/src/users/*.ts` (inline) | UPDATE | Same files | Add JSDoc to all exported items in `users.controller.ts`, `users.service.ts`, `users.module.ts`, `infrastructure/`, `domain/user.ts`, `dto/*.ts`. Exclude `.spec.ts` and `user.schema.ts` field boilerplate (covered in `DATA_MODEL.md`). |
| `backend/src/pantry/*.ts` (inline) | UPDATE | Same files | Add JSDoc; insert `// FIXME: softDelete calls deleteOne — physically destructive despite method name` and `// TODO(prod): Implement true soft-delete with deletedAt timestamp` at [backend/src/pantry/infrastructure/document/repositories/pantryIngridient.repository.ts:L119-L123] |
| `backend/src/ingridient/*.ts` (inline) | UPDATE | Same files | Add JSDoc; insert `// NOTE: spelling 'Ingridient' is preserved verbatim throughout the backend codebase` at the first occurrence in each file |
| `backend/src/recipe/*.ts` (inline) | UPDATE | Same files | Add JSDoc; insert FULL BLOCK COMMENT at [backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L92] above `matches()` describing four Mongo pre-filters (`$nin` allergies/disliked, `$all` dietary, `$lte` cookingTime, `deletedAt: null`), the per-recipe scoring loop (`matchScore = available / total`), `isQuickMake` and `isAlmostThere` derivation, optional `FilterType` post-filter, sort by `matchScore` descending. Add `// TODO(prod): No unit normalization. No quantity sufficiency check. See ARCHITECTURE.md for context.` |
| `backend/src/ai/*.ts` (inline) | UPDATE | Same files | Add JSDoc; insert `// TODO(prod): MIME-type filter is commented out. Enforce image/jpeg and image/png before enabling in production.` at [backend/src/ai/ai.controller.ts:L20-L28] and `// TODO(prod): No JWT guard. Add AuthGuard('jwt') before production deployment.` above the controller class declaration |
| `backend/src/database/seeds/*.ts` (inline) | UPDATE | Same files | Add JSDoc; insert `// TODO(prod): Gate seed runner behind explicit flag. Currently dropCollection() runs before reseed.` at each `run()` method in seed services |
| `mobile/lib/features/authentication/**/*.dart` (inline) | UPDATE | Same files | Add DartDoc to all public classes/methods/fields. Insert `// NOTE: 'singup' spelling is preserved verbatim from Navigation.singup; do not rename` at occurrences of `Navigation.singup` |
| `mobile/lib/features/pantry/**/*.dart` (inline) | UPDATE | Same files | Add DartDoc to all public classes/methods/fields. Exclude `*.g.dart`, `*.freezed.dart`. |
| `mobile/lib/features/recipe/**/*.dart` (inline) | UPDATE | Same files | Add DartDoc; insert `// NOTE: InstractionItem and instraction_item.dart spelling is preserved verbatim` at [mobile/lib/features/recipe/domain/models/recipe.dart:L3,L13] and at `instraction_item.dart`; insert `// NOTE: copyWith currently ignores inFavorite (not a Recipe field). FIXME for follow-up task.` at [mobile/lib/features/recipe/domain/models/recipe.dart:L37-L53] |
| `mobile/lib/features/ingredient/**/*.dart` (inline) | UPDATE | Same files | Add DartDoc to all public classes/methods/fields. |
| `mobile/lib/features/profile/**/*.dart` (inline) | UPDATE | Same files | Add DartDoc to all public classes/methods/fields. |
| `mobile/lib/core/utils/*.dart` (inline) | UPDATE | Same files | Add DartDoc to `DioClient`, `SharedPreferencesHelper`, `setupLocator`, `getEmailErrorText`, `RegExp` helpers, `mappers.dart`, `nullable_wrapper.dart`, `usercase.dart`, `available_languages.dart` |
| `mobile/lib/core/constants/*.dart` (inline) | UPDATE | Same files | Add DartDoc to all `Navigation`, `Endpoints`, `StatusCodes`, `Preferences`, `Common`, etc. Insert `// NOTE: 'singup' spelling preserved verbatim` at [mobile/lib/core/constants/navigation.dart:L6] |

Wildcards used carefully where the directory listing is fully known: `auth/*.ts`, `users/*.ts`, etc. cover the verified contents of each directory.

### 0.5.2 New Documentation Files Detail

**File: `backend/src/auth/README.md`**

```
Type: Module README (backend)
Source Code: backend/src/auth/auth.controller.ts, auth.service.ts, auth.module.ts,
             strategies/jwt.strategy.ts, strategies/jwt-refresh.strategy.ts,
             strategies/anonymous.strategy.ts, dto/*.dto.ts, config/auth.config.ts,
             types/login-response.type.ts
Sections (all 10 H2 required by prompt, in fixed order):
    - Module Purpose
    - Key Components (table: AuthController, AuthService, JwtStrategy,
        JwtRefreshStrategy, AnonymousStrategy, six DTOs, AuthConfig)
    - Architecture Fit (controller → service → JwtService + UsersService +
        SessionService → MongoDB)
    - Dependencies — Internal: UsersModule, SessionModule, PassportModule,
        JwtModule; External: @nestjs/jwt ^10.2.0, @nestjs/passport ^10.0.3,
        passport ^0.7.0, passport-jwt ^4.0.1, passport-anonymous ^1.0.1,
        bcryptjs ^2.4.3, class-validator ^0.14.1
    - Primary Use Cases (sign up, log in, get current user, refresh tokens,
        log out, update profile, delete account)
    - API / Endpoint Reference (table for 7 routes)
    - Data Flows (Mermaid sequenceDiagram for login → JWT issuance → bearer
        request → 401 → refresh)
    - Configuration (AUTH_JWT_SECRET, AUTH_JWT_TOKEN_EXPIRES_IN, AUTH_REFRESH_SECRET,
        AUTH_REFRESH_TOKEN_EXPIRES_IN from backend/env_example)
    - Known Limitations and Implementation Gaps (> ⚠️ unwired password reset DTOs,
        > ⚠️ refresh token TTL 3650d in defaults)
    - Production Readiness Status (> 🚧 Security Hardening: rate limiting,
        wire password reset; > 🚧 Secrets: JWT secret rotation, reduce
        refresh TTL)
Diagrams: 1 Mermaid sequenceDiagram (≤10 nodes)
Key Citations: backend/src/auth/auth.controller.ts:L31-L87,
               backend/src/auth/auth.service.ts (bcrypt verification at L64),
               backend/env_example:L20-L23
```

**File: `backend/src/recipe/README.md`**

```
Type: Module README (backend) — HIGHEST-VALUE TARGET
Source Code: backend/src/recipe/recipe.controller.ts, recipe.service.ts,
             recipe.module.ts, infrastructure/recipe.repository.ts,
             infrastructure/document/repositories/recipe.repository.ts (matches),
             infrastructure/document/entities/recipe.schema.ts,
             infrastructure/document/mappers/recipe.mapper.ts,
             domain/recipe.ts, dto/*.dto.ts, types/filter.types.ts
Sections: (all 10 H2 required)
    - Module Purpose
    - Key Components (table including RecipeController, RecipeService,
        RecipeRepository abstract, RecipeDocumentRepository, RecipeMapper,
        RecipeSchemaClass, Recipe domain entity, DTOs)
    - Architecture Fit (controller → service → repository → MongoDB; injects
        UsersService and PantryService for matches)
    - Dependencies — Internal: DocumentPantryPersistenceModule, UsersModule,
        PantryModule; External: @nestjs/mongoose ^10.1.0, mongoose ^8.8.0,
        class-validator ^0.14.1, class-transformer ^0.5.1
    - Primary Use Cases (create, list with pagination, fetch by id, update,
        soft-delete, **pantry-aware matches**)
    - API / Endpoint Reference (table for 6 routes under /v1/recipe)
    - Data Flows (Mermaid flowchart TD of matches() pipeline, ≤10 nodes summary;
        cross-link to ARCHITECTURE.md for full deep-dive)
    - Configuration (none specific to recipe; references global DATABASE_URL)
    - Known Limitations and Implementation Gaps (> ⚠️ exact _id matching only,
        > ⚠️ no unit normalization, > ⚠️ no quantity sufficiency check)
    - Production Readiness Status (> 🚧 Database: add ingredient lookup index
        on pantry collection; > 🚧 Testing: add unit tests for matches();
        > 🚧 Performance: matching cost grows linearly with pantry+recipe size)
Diagrams: 1 Mermaid flowchart TD (matching pipeline summary, ≤10 nodes)
Key Citations: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L92-L171,
               backend/src/recipe/recipe.controller.ts:L37-L99,
               backend/src/recipe/recipe.module.ts
```

**File: `ARCHITECTURE.md`**

```
Type: Top-level architecture document
Source Code: All seven backend feature modules, mobile/lib/main.dart,
             mobile/lib/core/utils/service_locator.dart,
             mobile/lib/core/utils/dio_client.dart,
             backend/src/main.ts, backend/src/app.module.ts,
             backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts
Sections:
    - Monorepo Structure (mobile/ + backend/ + 3 top-level docs at root)
    - Technology Choices and Rationale (NestJS 10 + Mongoose 8.8 backend
        rationale, Flutter ^3.5.1 cross-platform rationale, MongoDB document
        store rationale for embedded preferences, Google Cloud Vision rationale
        for AI ingredient recognition)
    - Cross-Cutting Concerns
        ### JWT Authentication Flow (login → access + refresh tokens →
            bearer in DioClient → 401 → /v1/auth/refresh via separate
            _refreshDio instance → retry)
        ### Soft-Delete Contract (deletedAt: Date | null across User, Session,
            Recipe, PantryIngridient, Ingridient; > ⚠️ NOTE pantry's
            softDelete actually deletes physically)
        ### Pagination Cap (50 records — enforced in 4 controllers)
        ### BLoC State Management (flutter_bloc ^8.1.6 + hydrated_bloc ^9.1.5
            persisted in path_provider temp directory)
        ### GetIt Dependency Injection (mobile/lib/core/utils/service_locator.dart
            setupLocator wires SharedPreferences → SharedPreferencesHelper →
            DioClient)
    - Full Request Path (Mermaid flowchart LR: UI → BLoC → UseCase → Repository
        → DioClient → bearer JWT → NestJS bootstrap → AuthGuard → ValidationPipe
        → controller → service → repository → Mongoose → MongoDB)
    - Recipe Matching Pipeline (dedicated subsection per prompt)
        ### Algorithm Overview
        ### Mongo Pre-Filter Chain
        ### Per-Recipe Scoring Loop
        ### isQuickMake / isAlmostThere Derivation
        ### Post-Filter and Sort
        ### Known Limitations (exact _id only, no unit normalization, no quantity
            sufficiency)
Diagrams: 2 Mermaid (full-request flowchart LR + recipe pipeline flowchart TD)
Key Citations: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L92-L171,
               backend/src/main.ts:L10-L35,
               backend/src/app.module.ts:L13-L31,
               mobile/lib/main.dart, mobile/lib/core/utils/dio_client.dart
```

**File: `PRODUCTION_READINESS.md`**

```
Type: Top-level production readiness checklist
Source Code: backend/Dockerfile, backend/docker-compose.yml, backend/env_example,
             backend/src/ai/ai.controller.ts (MIME + JWT gaps),
             backend/src/pantry/infrastructure/document/repositories/
                 pantryIngridient.repository.ts (softDelete gap),
             backend/src/auth/dto (unwired password reset DTOs),
             backend/src/database/seeds (destructive seed),
             backend/test, mobile/test (coverage gaps)
Sections:
    - Overview (current state: dev-grade docker-compose; target: production
        deployment)
    - Status Categories (master 11-row table with status indicators)
    - Build & Runtime (multi-stage Dockerfile; remove npm run dev from
        backend/Dockerfile:L13; compile TypeScript to /dist via nest build;
        Flutter release builds with --dart-define API_BASE_URL)
    - Secrets Management (MongoDB credentials out of docker-compose.yml:L8-L10;
        GCV credentials out of src/config/ai.json; secrets manager integration;
        JWT secret rotation; reduce AUTH_REFRESH_TOKEN_EXPIRES_IN from 3650d at
        backend/env_example:L23)
    - Networking & TLS (reverse proxy NGINX or cloud LB; TLS termination;
        CORS whitelist replacing the open `cors: true` at backend/src/main.ts:L11)
    - Infrastructure & Orchestration (replace Docker Compose with Kubernetes or
        managed container service; MongoDB Atlas or managed replica set;
        backup and PITR)
    - File Storage (implement S3 driver using existing ACCESS_KEY_ID /
        SECRET_ACCESS_KEY / AWS_S3_REGION / AWS_DEFAULT_S3_BUCKET env vars at
        backend/env_example:L15-L18; change FILE_DRIVER from local)
    - Security Hardening (rate limiting on auth endpoints via @nestjs/throttler;
        Helmet middleware; add AuthGuard('jwt') to POST /v1/ai/vision at
        backend/src/ai/ai.controller.ts:L16; enforce MIME-type validation on
        image uploads by uncommenting at backend/src/ai/ai.controller.ts:L20-L28;
        wire up password reset endpoints (DTOs exist at backend/src/auth/dto/))
    - Observability (structured logging Pino/Winston → log aggregator;
        Prometheus /metrics endpoint; OpenTelemetry tracing; alerting on
        error rate and latency)
    - CI/CD (pipeline: lint → type-check → test → build Docker image →
        push → deploy to staging → production gate)
    - Database (gate seed runner behind explicit flag at
        backend/src/database/seeds/run-seed.ts; add indexes for recipe matching
        at scale; define migration versioning strategy)
    - Testing (expand e2e coverage beyond auth specs in backend/test;
        add unit tests for RecipeRepository.matches(); add integration tests
        for pantry + recipe matching pipeline)
    - Mobile Release (App Store / Play Store signing config; PWA manifest
        production values; release build pipeline)
Diagrams: none required — primarily tabular content
Key Citations: backend/Dockerfile:L13, backend/docker-compose.yml:L8-L10,
               backend/env_example:L23, backend/src/ai/ai.controller.ts:L16-L28,
               backend/src/pantry/infrastructure/document/repositories/pantryIngridient.repository.ts:L119-L123
```

**File: `DATA_MODEL.md`**

```
Type: Top-level data model reference
Source Code: backend/src/users/infrastructure/document/entities/user.schema.ts,
             backend/src/session/infrastructure/document/entities/session.schema.ts,
             backend/src/ingridient/infrastructure/document/entities/ingridient.schema.ts,
             backend/src/pantry/infrastructure/document/entities/pantryIngridient.schema.ts,
             backend/src/recipe/infrastructure/document/entities/recipe.schema.ts,
             backend/src/common/types.ts (Reference type)
Sections:
    - Overview
    - Entity-Relationship Diagram (Mermaid erDiagram of User, Session,
        Ingridient, PantryIngridient, Recipe, plus Preferences embedded)
    - Collections
        ### User (email unique, password bcrypt, preferences embedded,
            favoriteRecipes[], recentSearches[], deletedAt)
        ### Preferences (embedded; dietary[], allergies[], dislikedIngredients[],
            cookingTime)
        ### Session (user ref to UserSchemaClass, deletedAt for logout)
        ### Ingridient (spelling preserved; name, category Reference,
            quantity, unit Reference, expirationDate, imageUrl, confidence,
            deletedAt)
        ### PantryIngridient (spelling preserved; ingridient ref, quantity,
            userId, unit, expirationDate, location enum, deletedAt; userId index)
        ### Recipe (id, title, description, ingridientList[] of IngridientList,
            instructions[] of Instruction, prepTime, cookTime, servings,
            difficulty enum, tags[], imageUrl, matchScore, deletedAt; title index)
    - Cross-Cutting Schema Conventions
        ### Timestamps (@Schema({ timestamps: true }) → createdAt, updatedAt)
        ### Soft-Delete (deletedAt: Date | null; > ⚠️ NOTE pantry repository
            violates this contract)
        ### Reference Type (id + name pair from backend/src/common/types.ts)
Diagrams: 1 Mermaid erDiagram
Key Citations: backend/src/users/infrastructure/document/entities/user.schema.ts:L8-L20 (Preferences),
               backend/src/pantry/infrastructure/document/entities/pantryIngridient.schema.ts:L32-L33,L49,
               backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L82,L106
```

### 0.5.3 Documentation Files to Update Detail

The two existing in-scope READMEs are replaced wholesale rather than incrementally edited because their current content (Flutter scaffolding boilerplate and minimal NestJS setup) does not match the required ten-section structure and contains no salvageable narrative.

- `mobile/README.md` — REPLACE: existing 17 lines [mobile/README.md:L1-L17] consist of `# pantry_chef` heading, "A new Flutter project" description, codelab + cookbook + documentation links, and a `# blitzy-project` trailer. New content is a full ten-section module README for the Flutter root.
- `backend/README.md` — REPLACE: existing 16 lines [backend/README.md:L1-L16] consist of `# Blitzy backend` heading and three code blocks (`cp env_example .env`, `npm run seed:run:document`, `docker-compose up`) plus four `###` lines for GCV setup. New content is a full ten-section module README for the NestJS root that retains the setup instructions inside the `Configuration` section.

Inline-comment updates (per the file-by-file table in §0.5.1) edit source files in place by adding `/** */` blocks above each exported declaration and inserting `// TODO(prod):`, `// NOTE:`, and `// FIXME:` lines at the specific code locations that the prompt names as required callouts. No source code logic is modified.

### 0.5.4 Documentation Configuration Updates

No documentation generator is configured in this repository and the prompt does not request introducing one. There are therefore no changes to:

- `mkdocs.yml` (does not exist)
- `docusaurus.config.js` (does not exist)
- `.readthedocs.yml` (does not exist)
- `backend/package.json` scripts (no doc build script needed)
- `mobile/pubspec.yaml` (no doc build dependency needed)

`mobile/analysis_options.yaml` already excludes `**/*.g.dart` from analysis; this configuration is left untouched. The `flutter_lints` ^4.0.0 package, already a dev dependency, accepts DartDoc comments without changes.

### 0.5.5 Cross-Documentation Dependencies

- **Shared content blocks**: NONE. Each README is self-contained — there are no `include` directives or partial-content imports.
- **Navigation links between documents**: every module README's "Architecture Fit" section links to `ARCHITECTURE.md`; every README's "Production Readiness Status" section links to `PRODUCTION_READINESS.md` for the centralized inventory; every backend README that references schema fields links to `DATA_MODEL.md` for the canonical schema diagram.
- **Table of contents updates**: GitHub renders Markdown headings as anchor-linkable; the prompt does not request a separate TOC document. Each multi-section document includes its own implicit TOC via headings.
- **Index/glossary updates**: none required by the prompt. The spelling-preservation parenthetical convention (e.g., "`Ingridient` (spelling preserved verbatim throughout the backend)") functions as an in-line glossary on first occurrence.

## 0.6 Dependency Inventory

### 0.6.1 Documentation Dependencies

No new dependencies are introduced by this documentation engagement. Every package required to render, lint, or analyze the deliverables is already present in `backend/package.json` [backend/package.json:L24-L75] or `mobile/pubspec.yaml` [mobile/pubspec.yaml:L30-L63]. The following table lists only the tools that are relevant to this documentation work; no version changes, additions, or removals are required.

| Registry | Package Name | Version | Purpose for Documentation |
|----------|--------------|---------|----------------------------|
| npm | typescript | ^5.1.3 | Native JSDoc (`/** */`) syntax support for backend inline comments |
| npm | @typescript-eslint/parser | ^8.0.0 | Parses JSDoc-annotated TypeScript during lint without errors |
| npm | eslint | ^8.0.0 | Already configured in `backend/.eslintrc.js`; accepts JSDoc by default |
| npm | prettier | ^3.0.0 | Already configured in `backend/.prettierrc`; preserves JSDoc formatting |
| pub | dart (SDK) | ^3.5.1 | Native DartDoc (`///`) syntax support for mobile inline comments |
| pub | flutter_lints | ^4.0.0 | Already configured via `mobile/analysis_options.yaml`; accepts DartDoc by default |
| (built-in) | GitHub Markdown viewer | n/a | Native Mermaid rendering for all README and top-level documents |

**Mermaid diagram tooling**: GitHub natively renders Mermaid in `.md` files since 2022; no `@mermaid-js/mermaid-cli` or local CLI is required. Diagrams render in the GitHub web UI, in `VS Code` with the Markdown Preview Mermaid Support extension, and in any GitLab/Bitbucket viewer that supports Mermaid.

**Documentation-only dependencies that are intentionally NOT introduced**:

- `typedoc` — TypeScript-to-HTML doc generator. Not needed because the prompt produces Markdown READMEs, not generated HTML sites.
- `mkdocs` / `mkdocs-material` — static site generator. Not needed for the same reason.
- `docusaurus` — React-based doc site. Not needed.
- `sphinx` — Python-oriented; not applicable to this TS/Dart codebase.
- `@mermaid-js/mermaid-cli` — local PNG/SVG export of Mermaid diagrams. Not needed because GitHub renders Mermaid inline.

### 0.6.2 Documentation Reference Updates

**Documentation files requiring link updates**: NONE. Because no documentation files exist beyond `mobile/README.md` and `backend/README.md` (both replaced wholesale), there are no pre-existing cross-document links to migrate or rewrite.

**Link transformation rules**: NONE. New documents are authored with correct relative-path links from the outset. Internal navigation patterns to use in the new content:

- From module README to top-level docs: `[ARCHITECTURE.md](../../../ARCHITECTURE.md)` from `backend/src/<module>/README.md`; `[ARCHITECTURE.md](../../../../ARCHITECTURE.md)` from `mobile/lib/features/<feature>/README.md`.
- From top-level docs to module READMEs: `[Auth module](backend/src/auth/README.md)` from `ARCHITECTURE.md`.
- From module README to source files: `[recipe.repository.ts](infrastructure/document/repositories/recipe.repository.ts)` for relative source references within the module.

**Apply to**: only the newly created files. No existing documentation files require link rewriting because none of them currently link out beyond their own scope.

## 0.7 Coverage and Quality Targets

### 0.7.1 Documentation Coverage Metrics

**Current coverage analysis** (baseline, established during Documentation Discovery):

- Public APIs documented: **0 / N** (0%) — no JSDoc anywhere in `backend/src/`, only 1 DartDoc occurrence in the entire `mobile/lib/` tree (`mobile/lib/core/styles/app_theme.dart`)
- User-facing features documented: **0 / 5** (0%) — no feature has any user guide or workflow narrative beyond what is implicit in source
- Module READMEs: **0 / 16** (0%) — no module README exists at any of the 16 target locations
- Top-level docs: **0 / 3** (0%) — `ARCHITECTURE.md`, `PRODUCTION_READINESS.md`, and `DATA_MODEL.md` do not exist
- Configuration options documented: **0 / 17** (0%) — env vars in `backend/env_example` [backend/env_example:L1-L24] and the mobile `API_BASE_URL` are not described anywhere

**Target coverage** (final state after this engagement):

| Surface | Target | Acceptance Criterion |
|---------|--------|----------------------|
| Module READMEs | 16 / 16 (100%) | Each README contains the ten required H2 sections in fixed order, 400–800 words of prose, exactly one Mermaid diagram of ≤10 nodes |
| Top-level documents | 3 / 3 (100%) | `ARCHITECTURE.md`, `PRODUCTION_READINESS.md`, `DATA_MODEL.md` exist at repository root; each contains required Mermaid diagrams |
| JSDoc on backend exported items | 100% | Every exported function, class, method, controller route handler, service method, repository method, strategy, and DTO class in the seven in-scope directories has a `/** */` block above its declaration with purpose, params, return, exceptions |
| DartDoc on mobile public items | 100% | Every public class, method, and field in the seven in-scope directories has a `///` block above its declaration |
| `// TODO(prod):` tags | 100% of required gaps | Every named production gap from the prompt has an inline `// TODO(prod):` tag at the exact code location (e.g., line 20–28 of `ai.controller.ts` for MIME filter, line 119–123 of `pantryIngridient.repository.ts` for softDelete) |
| `// NOTE:` tags | 100% of preserved spellings | Every file containing `Ingridient`, `singup`, or `InstractionItem` has a `// NOTE:` annotation at the first occurrence within that file |
| `// FIXME:` tags | 100% of identified bugs | The destructive `softDelete` and the no-op `Recipe.copyWith` on `inFavorite` each carry a `// FIXME:` annotation; no other code is fixed |
| Configuration option coverage | 17 / 17 (100%) | Every env var in `backend/env_example` and the mobile `API_BASE_URL` appears in at least one module README's "Configuration" section, and the secrets-related ones additionally appear in `PRODUCTION_READINESS.md` |

**Coverage gaps explicitly NOT addressed** (per scope boundaries):

- Schema field-level inline comments — prompt excludes `*.schema.ts` field boilerplate; canonical description lives in `DATA_MODEL.md` instead
- Test files (`backend/test/`, `mobile/test/`) — explicitly out of scope
- Config files (`*.config.ts`, `pubspec.yaml`, `package.json`) — explicitly out of scope
- Backend `session/` and `utils/` directories — not in the prompt's README list; documented narratively in adjacent READMEs and `ARCHITECTURE.md`

### 0.7.2 Documentation Quality Criteria

**Completeness requirements**:

- Every module README contains all ten H2 sections in the prompt-mandated order; missing or reordered sections fail validation.
- Every backend module README's "API / Endpoint Reference" table lists every endpoint exposed by the module's controller, with HTTP method, full path including `/v1` prefix, the guard applied (or "none" when unguarded as for AI), and a one-line description.
- Every README's "Dependencies" section has both an Internal subsection (other modules/features) and an External subsection (npm/pub packages with versions pinned exactly per the manifest).
- Every "Known Limitations and Implementation Gaps" section uses `> ⚠️` blockquote format and is non-empty for modules with known gaps (auth, pantry, recipe, ai, database; the mobile recipe feature for the copyWith no-op).
- Every "Production Readiness Status" section uses `> 🚧` blockquote format and maps each gap to one of the eleven `PRODUCTION_READINESS.md` categories.
- Every README includes exactly one Mermaid diagram in the "Data Flows" section, except `ARCHITECTURE.md` which contains two diagrams (full request path `flowchart LR` and recipe pipeline `flowchart TD`) and `DATA_MODEL.md` which contains one `erDiagram`.

**Accuracy validation**:

- Every code excerpt is verbatim from the source file with no paraphrasing — verified by direct file inspection during writing.
- Every API signature in JSDoc matches the actual function signature in the source — no DTOs renamed, no parameter types invented.
- Every endpoint path includes the global prefix `/api/v1` and uses the exact controller path string from the `@Controller` decorator.
- Every schema field name uses the spelling as it appears in the schema (e.g., `ingridientList` not `ingredientList` in backend Recipe documents).
- Every file path citation uses the absolute path from the repository root, exactly as the file exists.

**Clarity standards**:

- Technical terminology is consistent: "Recipe matching pipeline" (not "match engine"), "soft-delete via `deletedAt`" (not "logical deletion"), "JWT access and refresh tokens" (not "auth tokens"), "BLoC" (not "Bloc"), "HydratedBloc" (capitalized as the package exports it).
- Plain-English module purpose paragraph opens every README with no jargon prerequisites.
- Progressive disclosure: each README begins with high-level purpose and intent, then drills into components, then architecture, then specific gaps.
- Spelling preservation is announced on first occurrence: e.g., "the `Ingridient` schema (spelling preserved verbatim throughout the backend codebase)…".

**Maintainability requirements**:

- Every technical claim about existing code is cited with a `Source: path/to/file:LineNumber` reference, either inline or as a footnote.
- The `// TODO(prod):` / `// NOTE:` / `// FIXME:` tag taxonomy is used exactly as specified by the prompt, never substituted with alternative tags.
- New documentation files use no specialized Markdown extensions beyond GitHub-flavoured Markdown plus Mermaid; future readers do not need a special viewer.
- Cross-references between documents use relative paths that survive directory restructuring as long as the relative tree remains the same.

### 0.7.3 Example and Diagram Requirements

- **Minimum examples per documented API**: 0 — the prompt requires SHORT REAL excerpts (typically 2–4 line snippets) only where they "anchor explanations"; full worked examples are not requested.
- **Diagram types required**: Mermaid `flowchart TD` and `sequenceDiagram` per module README; Mermaid `flowchart LR` plus `flowchart TD` in `ARCHITECTURE.md`; Mermaid `erDiagram` in `DATA_MODEL.md`. No `classDiagram`, `gantt`, or `journey` diagrams are required by the prompt.
- **Diagram size limit**: ≤10 nodes per diagram (prompt directive). Pipelines exceeding 10 logical steps are summarized in the per-module README and detailed in the cross-cutting `ARCHITECTURE.md`.
- **Code example testing**: not applicable — code excerpts are verbatim from working source files; their correctness is verified by the source itself remaining unmodified (minimal-change clause).
- **Visual content freshness**: documentation is generated from the current state of the codebase at this session; no update policy is required because the prompt frames this as a one-shot documentation pass. Future updates fall outside the current engagement.

## 0.8 Scope Boundaries

### 0.8.1 Exhaustively In Scope (with trailing patterns)

**New documentation files at repository root** (CREATE):

- `ARCHITECTURE.md`
- `PRODUCTION_READINESS.md`
- `DATA_MODEL.md`

**New module README files** (CREATE — 14 of 16; the remaining 2 are UPDATEs):

- `backend/src/auth/README.md`
- `backend/src/users/README.md`
- `backend/src/pantry/README.md`
- `backend/src/ingridient/README.md` (spelling preserved verbatim)
- `backend/src/recipe/README.md`
- `backend/src/ai/README.md`
- `backend/src/database/README.md`
- `backend/src/config/README.md`
- `backend/src/common/README.md`
- `mobile/lib/features/authentication/README.md`
- `mobile/lib/features/pantry/README.md`
- `mobile/lib/features/recipe/README.md`
- `mobile/lib/features/ingredient/README.md` (mobile-side correct spelling)
- `mobile/lib/features/profile/README.md`
- `mobile/lib/core/README.md`

**Existing README files to update** (UPDATE — full replacement):

- `backend/README.md` [backend/README.md:L1-L16]
- `mobile/README.md` [mobile/README.md:L1-L17]

**Inline TypeScript JSDoc additions** (UPDATE — comments only, no code logic changes; exclude `*.spec.ts` and `*.schema.ts` field boilerplate):

- `backend/src/auth/**/*.ts`
- `backend/src/users/**/*.ts`
- `backend/src/pantry/**/*.ts`
- `backend/src/ingridient/**/*.ts`
- `backend/src/recipe/**/*.ts` — PRIORITY: full block comment on `matches()` at `backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L92-L171`
- `backend/src/ai/**/*.ts`
- `backend/src/database/seeds/**/*.ts`

**Inline Dart DartDoc additions** (UPDATE — comments only; exclude `*.g.dart`, `*.freezed.dart`, and test files):

- `mobile/lib/features/authentication/**/*.dart`
- `mobile/lib/features/pantry/**/*.dart`
- `mobile/lib/features/recipe/**/*.dart`
- `mobile/lib/features/ingredient/**/*.dart`
- `mobile/lib/features/profile/**/*.dart`
- `mobile/lib/core/utils/**/*.dart`
- `mobile/lib/core/constants/**/*.dart`

**Required inline annotations at specific code locations**:

- `// TODO(prod): MIME-type filter is commented out. Enforce image/jpeg and image/png before enabling in production.` at [backend/src/ai/ai.controller.ts:L20-L28]
- `// TODO(prod): No JWT guard. Add AuthGuard('jwt') before production deployment.` above the `AiController` class declaration in [backend/src/ai/ai.controller.ts]
- `// FIXME: softDelete calls deleteOne — physically destructive despite the method name. Document only; do not fix.` and `// TODO(prod): softDelete calls deleteOne — implement true soft-delete via { deletedAt: new Date() } update before production.` at [backend/src/pantry/infrastructure/document/repositories/pantryIngridient.repository.ts:L119-L123]
- `// TODO(prod): Seed runner drops collections (dropCollection) before reseeding. Gate behind explicit flag before production.` at each seed service's `run()` method in [backend/src/database/seeds/user/user-seed.service.ts] and siblings
- `// NOTE: spelling 'Ingridient' is preserved verbatim across the backend codebase. Do not rename.` at the first occurrence in each backend file referencing the identifier
- `// NOTE: 'singup' spelling is preserved verbatim from Navigation.singup. Do not rename.` at [mobile/lib/core/constants/navigation.dart:L6] and at consumer sites
- `// NOTE: 'InstractionItem' and 'instraction_item.dart' filename are preserved verbatim. Do not rename.` at [mobile/lib/features/recipe/domain/models/instraction_item.dart] and [mobile/lib/features/recipe/domain/models/recipe.dart:L3,L13]
- `// NOTE: copyWith currently ignores inFavorite (parameter accepted, not assigned). Recipe has no inFavorite field. // FIXME: Document only; do not fix.` at [mobile/lib/features/recipe/domain/models/recipe.dart:L37-L53]
- Full block comment above `matches()` at [backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L92] describing the four Mongo pre-filters, the per-recipe scoring loop, `isQuickMake` and `isAlmostThere` derivation, post-filter, and sort steps

### 0.8.2 Explicitly Out of Scope

**Source code modifications** — explicitly excluded by the minimal-change clause:

- No refactoring, renaming, or reorganizing of any file, class, function, or variable
- No changes to interfaces, DTOs, schemas, or API contracts
- No bug fixes (bugs flagged with `// FIXME:` only, never patched)
- No correction of intentional spelling variants in identifiers (`Ingridient`, `singup`, `InstractionItem`)
- No alteration of configuration values, environment defaults, or seed data
- No changes to `backend/Dockerfile` [backend/Dockerfile] (development command `npm run dev` documented in `PRODUCTION_READINESS.md` but the file is NOT modified)
- No changes to `backend/docker-compose.yml` [backend/docker-compose.yml] (hardcoded credentials documented in `PRODUCTION_READINESS.md` but the file is NOT modified)
- No changes to `backend/env_example` [backend/env_example] (contents documented in `PRODUCTION_READINESS.md` but the file is NOT modified)

**Test file modifications**:

- `backend/test/**` — JEST e2e specs, OUT OF SCOPE (test docs are not requested)
- `mobile/test/**` — Flutter widget test harness, OUT OF SCOPE

**Auto-generated and platform-host files**:

- `**/*.g.dart` — JsonSerializable-generated; excluded from inline DartDoc
- `**/*.freezed.dart` — Freezed-generated; excluded from inline DartDoc
- `mobile/android/**` — Android host project; no documentation changes
- `mobile/ios/**` — iOS Xcode project including the auto-generated `LaunchImage.imageset/README.md`; no documentation changes
- `mobile/web/**` — PWA bootstrap assets; no documentation changes

**Configuration files** (no inline comments):

- `*.config.ts` (e.g., `nest-cli.json` config files) — excluded from inline JSDoc
- `pubspec.yaml`, `pubspec.lock` — excluded from inline DartDoc
- `package.json`, `package-lock.json` — excluded from inline JSDoc
- `tsconfig.json`, `tsconfig.build.json` — excluded
- `.eslintrc.js`, `.prettierrc`, `.hygen.js` — excluded
- `analysis_options.yaml`, `flutter_native_splash.yaml`, `i10n.yaml` — excluded

**Schema field boilerplate** (no JSDoc on each `@Prop()` declaration):

- All `*.schema.ts` files have schema field declarations excluded; schemas are documented holistically in `DATA_MODEL.md` with the Mermaid `erDiagram` plus per-collection narrative

**Backend modules NOT in README scope** (per prompt's explicit list — these modules exist in code but their READMEs are not requested):

- `backend/src/session/` — covered narratively in `backend/src/auth/README.md` and `ARCHITECTURE.md` because session lifecycle is tightly coupled to auth; no standalone README
- `backend/src/utils/` — covered narratively in `backend/README.md` and `ARCHITECTURE.md` as a shared infrastructure layer; no standalone README

**Third-party and dependency-tree files**:

- `node_modules/**` — package contents, never modified
- `mobile/.dart_tool/**` — Dart tool cache, never modified
- `backend/dist/**` — compiled output, never modified
- `backend/.hygen/**` — code-generation templates, NOT in inline-comment scope

**Capabilities NOT documented as in-scope features** (because the prompt does not request creation; they are listed in `PRODUCTION_READINESS.md` as gaps but no source/feature documentation is authored for them):

- S3 file storage driver (placeholders only in `backend/env_example` [backend/env_example:L13-L18])
- Password reset endpoints (DTOs exist but no controller; documented as gap in `auth/README.md` and `PRODUCTION_READINESS.md`)
- Migration versioning system (not implemented)
- Rate limiting, Helmet, structured logging, OpenTelemetry, CI/CD pipeline — all listed as gaps, no source code to document

**Documentation not requested by prompt**:

- API client SDKs in languages other than Dart
- Contributor onboarding flows beyond what fits in `backend/README.md` and `mobile/README.md` Configuration sections
- Architecture decision records (ADRs) — not requested
- Postmortems or runbooks — not requested

### 0.8.3 Legacy / Intentional Quirks — Document but Do Not Correct

The following code identifiers are intentional, preserved across the codebase, and must be documented verbatim with a `// NOTE:` annotation at the first occurrence in each affected file. They must NEVER be renamed or "corrected" during this engagement:

- `Ingridient` (and all variants: `ingridient`, `IngridientModule`, `IngridientService`, `IngridientController`, `IngridientSchemaClass`, `PantryIngridient`, `pantryIngridient.repository.ts`, `pantryIngridient.schema.ts`, etc.) — preserved verbatim throughout `backend/src/` per [backend/src/app.module.ts:L13] and the entire `backend/src/ingridient/` and `backend/src/pantry/` subtrees
- `singup` (route constant in `mobile/lib/core/constants/navigation.dart:L6`) — stable identifier; navigated to from [mobile/lib/features/authentication/presentation/widgets/screens/authentication_start.dart:L36]
- `instraction_item.dart` (file name) and `InstractionItem` (class name) in `mobile/lib/features/recipe/domain/models/` — file at [mobile/lib/features/recipe/domain/models/instraction_item.dart], consumed by [mobile/lib/features/recipe/domain/models/recipe.dart:L3,L13]
- `Recipe.copyWith` no-op on `inFavorite` parameter at [mobile/lib/features/recipe/domain/models/recipe.dart:L37-L53] — documented with `// NOTE:` and flagged with `// FIXME:` for a separate follow-up task; not corrected here

Spelling preservation parenthetical convention in prose: every README that references one of these identifiers includes a parenthetical note at the first occurrence — for example, "the `Ingridient` schema (spelling preserved verbatim throughout the backend codebase)…" — to signal to readers that the spelling is intentional, not a typo in the documentation itself.

## 0.9 Execution Parameters

### 0.9.1 Documentation-Specific Instructions

**Documentation build command**: NONE. The deliverables are plain `.md` files committed alongside source. There is no documentation generator to invoke. GitHub renders the resulting Markdown (including Mermaid diagrams) natively when files are pushed.

**Documentation preview command**: `cat <file>.md` for raw content; any Markdown previewer (VS Code's "Open Preview" with the Markdown Preview Mermaid Support extension, or pushing a branch and viewing on GitHub) for rendered output.

**Diagram generation command**: NONE. Mermaid diagrams are embedded inline in fenced ```mermaid blocks and rendered by GitHub on demand. No `@mermaid-js/mermaid-cli` invocation is required.

**Documentation deployment command**: NONE. Documentation lives in-repo; "deployment" means committing the files to the repository.

**Default format**: GitHub-flavoured Markdown with Mermaid diagrams.

**Citation requirement**: every technical claim references a source file. Two citation formats are used:

- For module READMEs and top-level documents: `Source: backend/src/auth/auth.controller.ts:L31-L42` either inline (parenthetical) or as a trailing footnote.
- For this AAP and any cross-referencing within technical documentation: `[backend/src/auth/auth.controller.ts:L31-L42]` immediately following the claim.

**Style guide to follow**: the prompt's ten-section README structure is the binding template. Otherwise, repository conventions:

- TypeScript: follow `backend/.eslintrc.js` and `backend/.prettierrc` — single quotes, trailing commas; JSDoc must not break ESLint's `@typescript-eslint/parser`.
- Dart: follow `mobile/analysis_options.yaml` — `flutter_lints` enforces trailing commas, package imports, no `print`, and other rules; DartDoc must not trigger lints.
- Markdown: GitHub-flavoured; no MDX, no Markdown extensions beyond Mermaid.

**Documentation validation**:

- **Mermaid syntax validation**: each ```mermaid block is hand-validated by counting nodes (≤10), checking for syntactic correctness (matching brackets, correct edge syntax), and verifying the diagram type is one of `flowchart TD`, `flowchart LR`, `sequenceDiagram`, or `erDiagram` as required by the prompt.
- **JSDoc syntax validation**: TypeScript compilation continues to succeed with the new comments — verified by running `npm run build` (alias for `nest build` per [backend/package.json:L9]) after the changes. ESLint also continues to pass.
- **DartDoc syntax validation**: Dart analysis continues to succeed — verified by running `flutter analyze` after the changes (the project's `analysis_options.yaml` elevates several diagnostics to errors, so any syntactically invalid DartDoc would surface immediately).
- **Link validation**: relative paths between Markdown documents are verified by file-system existence checks during writing; no broken cross-references.

### 0.9.2 Required Environment Setup for Documentation Execution

No environment setup is required to produce the documentation deliverables themselves. Validation steps that benefit from a working backend/mobile environment use the existing setup commands:

- Backend: from `backend/README.md` [backend/README.md] — `cp env_example .env`, `npm install`, `npm run build` (or `npm run dev` for watch mode). Used only to verify JSDoc does not break compilation.
- Mobile: standard Flutter — `flutter pub get`, `flutter analyze`. Used only to verify DartDoc does not break analysis.

These commands are listed here for reference; they are not invoked during documentation writing because the minimal-change clause ensures no behavior changes. They serve as the validation harness only.

### 0.9.3 Inline Annotation Conventions

**TypeScript JSDoc format** (backend) — applied to every exported function, class, and method in scope:

```typescript
/**
 * <Brief purpose statement.>
 * @param <name> <Type and meaning.>
 * @returns <What the function returns.>
 * @throws <Exception types and conditions.>
 */
```

JSDoc is placed immediately above the declaration with no blank line between the comment and the code (per prompt directive).

**Dart DartDoc format** (mobile) — applied to every public class, method, and field in scope:

```
/// <Brief purpose statement.>
///
/// <Optional longer narrative; cite source files when relevant.>
```

DartDoc is placed immediately above the declaration with no blank line between the comment and the code (per prompt directive).

**Tag taxonomy** (used as inline `//` comments, never as JSDoc/DartDoc block):

- `// TODO(prod): <description>` — production gaps; examples at [backend/src/ai/ai.controller.ts:L20-L28] (MIME filter), [backend/src/pantry/infrastructure/document/repositories/pantryIngridient.repository.ts:L119-L123] (destructive softDelete), [backend/src/database/seeds/user/user-seed.service.ts] (destructive seed)
- `// NOTE: <description>` — clarifications on intentional decisions; examples at every occurrence of `Ingridient`, `singup`, `InstractionItem` and at [mobile/lib/features/recipe/domain/models/recipe.dart:L37-L53] for `copyWith` no-op
- `// FIXME: <description>` — genuine bugs identified during documentation, NEVER patched; examples at [backend/src/pantry/infrastructure/document/repositories/pantryIngridient.repository.ts:L119-L123] (destructive softDelete) and [mobile/lib/features/recipe/domain/models/recipe.dart:L37-L53] (copyWith no-op)

**Line length**: ≤100 characters per comment line (prompt directive). Long descriptions wrap to subsequent comment lines.

## 0.10 Rules for Documentation

### 0.10.1 User-Specified Rules

The user-specified rules array provided for this engagement is **empty** (`[]`). No additional implementation rules, coding guidelines, or constraints have been supplied beyond what the prompt itself contains.

### 0.10.2 Documentation-Specific Directives Encoded in the Prompt

Although the formal rules array is empty, the prompt body itself encodes numerous binding documentation directives. These are extracted, deduplicated, and listed below as the operative rules for this engagement.

**Structure rules (verbatim from prompt)**:

- "Use the topic order defined above as H2 headings (`##`). Do not reorder them." — applies to all sixteen module READMEs.
- "Aim for 400–800 words of prose per README, excluding tables and code blocks." — per-README length budget.
- "Use standard GitHub-flavoured Markdown tables. Tables are preferred over prose for endpoint lists, component lists, and dependency lists."
- "Include one Mermaid diagram per README where it adds clarity. Use `flowchart TD` or `sequenceDiagram` as appropriate. Keep diagrams to ≤10 nodes."

**Content rules (verbatim from prompt)**:

- "Include short real excerpts from the actual source files to anchor explanations — do not invent illustrative examples."
- "Use fenced code blocks with language identifiers (triple-backtick `typescript`, triple-backtick `dart`, triple-backtick `bash`)."
- "Use blockquotes (`>`) prefixed with `> ⚠️` for known limitations and `> 🚧` for production-readiness gaps."
- "Explicitly document any gaps or deviations from expected behavior."
- "Module purpose — One-paragraph plain-English summary of what this module does and why it exists in the system."
- "Architecture Fit — How this module fits into the overall layered architecture: Backend: how it maps to the controller → service → repository → domain layers. Mobile: how it maps to the domain → data → presentation layers. Call out any deviations from the standard pattern."

**Inline comment rules (verbatim from prompt)**:

- "Explain the *why*, not just the *what*. The code itself shows what is happening; comments should explain non-obvious decisions, known constraints, and intent."
- "Flag known gaps explicitly. Where a known implementation gap exists, add a comment calling it out."
- "Document function signatures using JSDoc for TypeScript files and Dart doc comments (`///`) for Dart files. Include: purpose, parameters with types and meaning, return value, and any thrown exceptions or error conditions."
- "Mark production gaps inline with a consistent tag: `// TODO(prod):` followed by a short description."
- "Explain the recipe matching algorithm in full block-comment form at the top of the `matches()` method — describe the four Mongo pre-filters, the per-recipe scoring loop, the `isQuickMake` / `isAlmostThere` derivation, and the post-filter and sort steps."
- "Do not comment obvious code — standard CRUD scaffolding, simple getter/setters, or NestJS decorator boilerplate do not need annotation."

**Formatting rules for inline comments (verbatim from prompt)**:

- "TypeScript (backend): JSDoc (`/** ... */`) for all exported functions, classes, and methods. Single-line `//` for inline notes. No `/* */` block comments outside JSDoc."
- "Dart (mobile): Dart doc `///` triple-slash for all public classes, methods, and fields. Single `//` for inline notes."
- "Tag format: `// TODO(prod):` for production gaps. `// NOTE:` for clarifications on intentional decisions (e.g., preserved spellings). `// FIXME:` only for genuine bugs identified during documentation (do not fix — document only)."
- "Line length: Keep comment lines to ≤ 100 characters."
- "Placement: Function/method doc comments immediately above the declaration with no blank line between comment and declaration. Inline notes on the same line or the line above the statement they describe."

**Spelling preservation rules (verbatim from prompt)**:

- "Preserved spelling variants (`Ingridient`, `instraction_item.dart`, `singup` route) — note these are intentional and must not be corrected."
- "When referencing code identifiers, preserve exact spelling as found in source — including `Ingridient`, `InstractionItem`, `singup` — and note in a parenthetical that the spelling is preserved verbatim."
- "Do not correct intentional spelling variants in identifiers (`Ingridient`, `singup`, `InstractionItem`) — these are stable API and file-system contracts."

**Minimal change rules (verbatim from prompt)**:

- "Make only the changes absolutely necessary to implement comprehensive code documentation."
- "Add comments and documentation files without modifying any production code logic or behavior."
- "Do not refactor, rename, or reorganize any existing files, classes, functions, or variables."
- "Do not change interfaces, DTOs, schemas, or API contracts."
- "Do not fix bugs discovered during documentation — use `// FIXME:` to flag them for a separate task."
- "Do not alter any configuration values, environment defaults, or seed data."
- "Document existing code as-is, reflecting its actual implemented behavior rather than its intended or desired behavior."

**Mandatory README section rules (verbatim from prompt)** — every module README must cover the following topics in the prescribed order:

1. Module Purpose
2. Key Components
3. Architecture Fit
4. Dependencies (Internal + External sub-sections)
5. Primary Use Cases
6. API / Endpoint Reference (backend modules ONLY)
7. Data Flows
8. Configuration
9. Known Limitations and Implementation Gaps
10. Production Readiness Status

**Priority gap directive (verbatim from prompt)** — the following gaps MUST be called out:

- `recipe/`: no unit normalization, no quantity sufficiency check, exact `_id` matching only.
- `ai/`: MIME-type filter is commented out; no JWT guard on `POST /v1/ai/vision`; small internal ingredient dictionary.
- `pantry/`: `softDelete` calls `deleteOne` (physically destructive despite method name).
- `auth/`: password reset DTOs exist (`forgot-password`, `reset-password`) but no endpoints are wired.
- `database/`: seed runner runs on every startup; no migration versioning.
- Preserved spelling variants (`Ingridient`, `instraction_item.dart`, `singup` route) — note these are intentional and must not be corrected.

**Scope rules (verbatim from prompt)**:

- "In scope: All source files under `backend/src/` and `mobile/lib/`. The three top-level documents: `ARCHITECTURE.md`, `PRODUCTION_READINESS.md`, `DATA_MODEL.md`. Module `README.md` files as listed above."
- "Out of scope: `backend/test/` and `mobile/test/` — test files are excluded. Auto-generated Dart files (`*.g.dart`, `*.freezed.dart`). Platform host directories (`mobile/android/`, `mobile/ios/`, `mobile/web/`) — no documentation changes needed. `backend/Dockerfile` and `backend/docker-compose.yml` — these are covered narratively in `PRODUCTION_READINESS.md` but no inline changes are needed to the files themselves. `backend/env_example` — document its contents in `PRODUCTION_READINESS.md` but do not modify the file. Third-party packages and node_modules."

### 0.10.3 Repository Conventions to Follow

In addition to the prompt-specified rules, documentation must follow the repository's existing conventions (verified during Documentation Discovery):

- **TypeScript formatting**: single quotes, trailing commas (from `backend/.prettierrc`). JSDoc text inside `/** */` uses sentence case and ends sentences with periods.
- **Dart formatting**: trailing commas required by `mobile/analysis_options.yaml`'s `require_trailing_commas` rule. DartDoc text inside `///` uses sentence case.
- **Markdown heading levels**: progressive (no jumps); each document uses one `#` H1 for the title, `##` H2 for the ten mandatory sections, `###` H3 for sub-sections within (e.g., Dependencies > Internal vs External).
- **Code excerpts in READMEs**: ≤2-3 lines per excerpt (per general AAP guidance applied to documentation work); use real source extracts only.
- **Source citations**: file paths are repository-relative (e.g., `backend/src/auth/auth.controller.ts`, not `./auth.controller.ts` or absolute system paths).

## 0.11 Attachments

### 0.11.1 File Attachments

**No file attachments were provided** for this project. The `review_attachments` tool returned "No attachments found for this project." All documentation content is derived from:

- The user's prompt body (the codebase documentation requirements specification)
- Direct inspection of the PantryChef repository source files via the repository inspection tools
- Tech-spec context retrieved via `get_tech_spec_section` for cross-document consistency

### 0.11.2 Figma Designs

**No Figma designs were provided** for this project. The `review_attachments` tool reported no Figma metadata. The Documentation engagement does not require visual design references because:

- The deliverables are Markdown documentation files (no UI screens to design)
- The Mermaid diagrams that DO appear in the deliverables are derived from observable code paths (request sequences, data flows, architectural relationships), not from user-supplied designs

### 0.11.3 External URLs and References

**No external URLs were supplied** in the prompt body, attachments, or rules. All references in the deliverables are repository-internal:

- Source file paths within `backend/src/` and `mobile/lib/`
- Tech-spec section cross-references where relevant
- The `backend/env_example` template (referenced but not modified)
- The `backend/Dockerfile` and `backend/docker-compose.yml` files (referenced narratively in `PRODUCTION_READINESS.md`, not modified)

No external technical reference URLs (e.g., NestJS docs, MongoDB docs, Flutter docs) are embedded in the deliverables because the prompt does not request them. Repository-resident sources are sufficient and authoritative for the documentation goals.

