# PantryChef Backend

The PantryChef backend is a [NestJS](https://nestjs.com/) 10 REST API running on
Express that powers the PantryChef mobile application. It persists data to MongoDB
through Mongoose 8, secures access with JWT-based authentication, publishes an
interactive Swagger/OpenAPI UI, and ships an optional Google Cloud Vision integration
that recognizes ingredients from photos. `Source: backend/package.json:L25`

The published npm package name is `blitzy-backend`. `Source: backend/package.json:L2`

This document is the entry point for the backend. It orients you to the technology
stack, the module layout, how to run the service locally and in Docker, and the
operational caveats you must address before any non-local deployment. For deeper
reference material, see the **Documentation** section at the end of this file and the
`../docs/` knowledge base.

## Tech stack

All versions below are pinned in the dependency manifest and reproduced exactly.

| Area | Package | Version | Source |
|------|---------|---------|--------|
| Framework (NestJS 10) | `@nestjs/common` | `^10.0.0` | `Source: backend/package.json:L26` |
| Framework (NestJS 10) | `@nestjs/core` | `^10.0.0` | `Source: backend/package.json:L28` |
| HTTP platform (Express) | `@nestjs/platform-express` | `^10.0.0` | `Source: backend/package.json:L32` |
| Configuration | `@nestjs/config` | `^3.3.0` | `Source: backend/package.json:L27` |
| Persistence (Mongoose 8) | `mongoose` | `^8.8.0` | `Source: backend/package.json:L37` |
| Persistence (Mongoose 8) | `@nestjs/mongoose` | `^10.1.0` | `Source: backend/package.json:L30` |
| API documentation | `@nestjs/swagger` | `^8.0.1` | `Source: backend/package.json:L33` |
| Auth | `@nestjs/jwt` | `^10.2.0` | `Source: backend/package.json:L29` |
| Auth | `@nestjs/passport` | `^10.0.3` | `Source: backend/package.json:L31` |
| Auth | `passport` | `^0.7.0` | `Source: backend/package.json:L40` |
| Auth | `passport-jwt` | `^4.0.1` | `Source: backend/package.json:L42` |
| Auth | `passport-anonymous` | `^1.0.1` | `Source: backend/package.json:L41` |
| Password hashing | `bcryptjs` | `^2.4.3` | `Source: backend/package.json:L34` |
| AI / image recognition | `@google-cloud/vision` | `^4.3.2` | `Source: backend/package.json:L25` |
| Validation | `class-validator` | `^0.14.1` | `Source: backend/package.json:L36` |
| Validation | `class-transformer` | `^0.5.1` | `Source: backend/package.json:L35` |
| Language | `typescript` | `^5.1.3` | `Source: backend/package.json:L74` |
| Build CLI | `@nestjs/cli` | `^10.0.0` | `Source: backend/package.json:L47` |
| Runtime | Node.js | `20` (`node:20-alpine`) | `Source: backend/Dockerfile:L1` |

## Module map

The backend follows a per-module layered layout (`*.controller.ts` / `*.service.ts` /
`*.module.ts` plus `dto/` and `infrastructure/document/`). Each module owns a dedicated
README that documents its controllers, services, DTOs, entities, and repositories.

| Module | README | Responsibility |
|--------|--------|----------------|
| Auth | [`src/auth/README.md`](src/auth/README.md) | JWT authentication, three Passport strategies, login and refresh |
| Users | [`src/users/README.md`](src/users/README.md) | User CRUD, embedded preferences, favorites and recent searches |
| Pantry | [`src/pantry/README.md`](src/pantry/README.md) | Pantry-ingredient CRUD and the `location` enum |
| Recipe | [`src/recipe/README.md`](src/recipe/README.md) | Recipe CRUD and the ingredient-matching engine |
| Ingridient *(sic)* | [`src/ingridient/README.md`](src/ingridient/README.md) | Ingredient CRUD and the creation-data reference |
| AI | [`src/ai/README.md`](src/ai/README.md) | Image-to-ingredient Google Cloud Vision endpoint |
| Session | [`src/session/README.md`](src/session/README.md) | Session lifecycle backing refresh tokens |
| Database | [`src/database/README.md`](src/database/README.md) | Async Mongoose configuration and seeds |

> **Note on `ingridient/`:** the ingredient module directory is intentionally spelled
> `ingridient/` (with the transposed `i`) in the backend. This misspelling is a stable
> identifier across the codebase — controllers, modules, schemas, and routes all rely on
> it. It is documented and preserved exactly as-is and must never be renamed.
> `Source: backend/src/ingridient/ingridient.module.ts:L35`

Seven feature modules are wired into the root module — `AuthModule`, `SessionModule`,
`UsersModule`, `IngridientModule`, `PantryModule`, `RecipeModule`, and `AiModule`.
`Source: backend/src/app.module.ts:L49-L55` The database module is not a feature module;
it integrates through `MongooseModule.forRootAsync` using `MongooseConfigService`.
`Source: backend/src/app.module.ts:L43-L45`

## API surface

REST routes are served under the global prefix `api`, which is applied at bootstrap
via `app.setGlobalPrefix(...)` — for example, the recipe collection is reachable at
`GET /api/recipe`. `Source: backend/src/main.ts:L30-L35`

The served paths do **not** contain a `/v1/` segment. Although the controllers declare
`version: '1'` (for example `Source: backend/src/recipe/recipe.controller.ts:L47`),
`main.ts` never calls `app.enableVersioning()`, so URI versioning is inactive and no
`/v1/` prefix is emitted. `Source: backend/src/main.ts:L30-L35`

The interactive Swagger/OpenAPI UI is served at **`/docs`** —
`SwaggerModule.setup('docs', ...)`. `Source: backend/src/main.ts:L51` Note the
divergence from prompt wording that references `/api/docs`: because the global `api`
prefix is not applied to the Swagger route, the UI lives at `/docs`, not `/api/docs`.
`Source: backend/src/main.ts:L30-L35`

The complete endpoint catalog (request/response shapes, query parameters, status codes)
lives in the dedicated reference, [`../docs/API_REFERENCE.md`](../docs/API_REFERENCE.md).

## Local development

Run the service directly with Node and npm during development. The commands below map
to the package scripts. `Source: backend/package.json:L8-L23`

```bash
# Install dependencies
npm install
```

```bash
# Create a local environment file from the template (preserved quick-start step)
cp env_example .env
```

```bash
# Start the watch-mode dev server (nest start --watch)
npm run dev
```

```bash
# Build the project (nest build), then run the compiled output (node dist/main)
npm run build
npm run start:prod
```

```bash
# Seed MongoDB with sample documents
# (ts-node -r tsconfig-paths/register ./src/database/seeds/run-seed.ts)
npm run seed:run:document
```

```bash
# Lint the TypeScript sources (eslint "{src,apps,libs,test}/**/*.ts" --fix)
npm run lint
```

```bash
# Run the Jest unit tests
npm run test
```

The application listens on port **3000** by default (`APP_PORT=3000`).
`Source: backend/env_example:L2` The Docker image likewise exposes port 3000.
`Source: backend/Dockerfile:L11`

## Docker Compose bring-up

For a one-command local stack, copy the environment template and start Compose
(preserved quick-start step). `Source: backend/docker-compose.yml:L4-L29`

```bash
cp env_example .env && docker-compose up
```

Compose defines a two-service stack. `Source: backend/docker-compose.yml:L4-L29`

| Service | Image / build | Host port | Notes |
|---------|---------------|-----------|-------|
| `mongodb` | `mongo:latest` | `27017` | Root credentials `admin` / `123456`; data persisted under `./data` |
| `nestjs` | built from this directory | `3000` | `depends_on` `mongodb`; reads `./.env`; `DATABASE_URL=mongodb://mongodb:27017` on the Compose network |

The `nestjs` service builds from this directory, depends on `mongodb`, and connects to
the database over the Compose network using `DATABASE_URL=mongodb://mongodb:27017`
rather than `localhost`. `Source: backend/docker-compose.yml:L17-L29` The full
deployment workflow is documented in
[`../docs/DEPLOYMENT.md`](../docs/DEPLOYMENT.md).

## Google Cloud Vision (`ai.json`) setup

The AI ingredient-recognition feature uses Google Cloud Vision and requires a
service-account key placed at `src/config/ai.json`. To provision it
(preserved from the original setup steps): `Source: backend/src/ai/ai.service.ts:L70-L75`

1. Enable the Cloud Vision API in your Google Cloud project.
2. Create a key file for a service account.
3. Rename the downloaded key to `ai.json`.
4. Copy `ai.json` into `src/config`.

This integration is **optional**. When `ai.json` is absent the backend degrades
gracefully: `existsSync(keyPath)` fails, `isGoogleVisionEnabled` is set to `false`,
and the AI vision endpoint still responds but returns an empty result (`{}`) instead
of recognized ingredients. `Source: backend/src/ai/ai.service.ts:L70-L76,L104-L106`
See [`../docs/DEPLOYMENT.md`](../docs/DEPLOYMENT.md) for the end-to-end provisioning
workflow.

## SECURITY NOTE

> **SECURITY NOTE:** `env_example` ships insecure development defaults that **must** be
> changed before any non-local or production deployment. Do not deploy with these
> values; rotate them to strong, unique secrets managed outside source control.
>
> - **Default database credentials** — `DATABASE_USERNAME=admin` and
>   `DATABASE_PASSWORD=123456`. `Source: backend/env_example:L8-L9`
> - **Weak JWT signing secrets** — `AUTH_JWT_SECRET=secret` and
>   `AUTH_REFRESH_SECRET=secret_for_refresh`. `Source: backend/env_example:L20,L22`
> - **Token lifetimes** — access tokens expire in `15m` and refresh tokens in `3650d`
>   (roughly ten years); review whether the refresh window is appropriate for your
>   deployment. `Source: backend/env_example:L21,L23`
>
> These values are documented as-is and intentionally left unchanged in the repository.

## Documentation

The repository-root knowledge base provides cross-cutting reference and how-to material.
Links are relative to this `backend/` directory.

- [`../docs/ARCHITECTURE.md`](../docs/ARCHITECTURE.md) — system design and diagrams.
- [`../docs/API_REFERENCE.md`](../docs/API_REFERENCE.md) — full REST endpoint reference.
- [`../docs/DATA_MODELS.md`](../docs/DATA_MODELS.md) — Mongoose and Dart model reference.
- [`../docs/DEPLOYMENT.md`](../docs/DEPLOYMENT.md) — Docker, environment, and seed how-to.
