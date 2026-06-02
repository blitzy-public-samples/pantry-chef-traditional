# Users Module

The Users module owns user-account management for the PantryChef backend. It
exposes a JWT-guarded REST surface for creating, listing, reading, updating, and
removing users; hashes passwords on create; stores an embedded
`Preferences` subdocument for dietary settings; and tracks each user's favorite
recipes and recent searches.

## Purpose

This module provides the system's user record and the operations that act on it.
It performs user CRUD through a dedicated controller and service
(`Source: backend/src/users/users.controller.ts:L40-L46`,
`Source: backend/src/users/users.service.ts:L21`), hashes passwords with bcryptjs
on create (`Source: backend/src/users/users.service.ts:L41-L43`), and persists an
embedded dietary `Preferences` object alongside `favoriteRecipes` and
`recentSearches` arrays (`Source: backend/src/users/infrastructure/document/entities/user.schema.ts:L73-L93`).
It is the authoritative source of identity data that the authentication flow
builds on, and every route it serves requires a valid Bearer JWT
(`Source: backend/src/users/users.controller.ts:L40-L45`).

## Key components

- **`UsersModule`** — NestJS module that imports `DocumentUserPersistenceModule`,
  registers `UsersController` and `UsersService`, and re-exports `UsersService`
  plus `DocumentUserPersistenceModule` for consumers such as auth.
  `Source: backend/src/users/users.module.ts:L24-L33`.
- **`UsersController`** — HTTP layer that maps REST routes to service calls and
  applies the class-level JWT guard. `Source: backend/src/users/users.controller.ts:L40-L46`.
- **`UsersService`** — business rules: password hashing on create, duplicate-email
  rejection, and existence checks on update. `Source: backend/src/users/users.service.ts:L21`.
- **Abstract `UserRepository`** — persistence contract
  (`create` / `findManyWithPagination` / `findOne` / `update` / `softDelete`)
  that decouples the service from the storage technology.
  `Source: backend/src/users/infrastructure/user.repository.ts:L21-L89`.
- **`UsersDocumentRepository`** — Mongoose-backed implementation of the contract,
  bound to the abstract token via DI. `Source: backend/src/users/infrastructure/document/repositories/user.repository.ts:L83`.
- **`UserSchemaClass`** (with embedded `Preferences`) — the Mongoose entity that
  defines the persisted shape of a user. `Source: backend/src/users/infrastructure/document/entities/user.schema.ts:L15-L31`,
  `Source: backend/src/users/infrastructure/document/entities/user.schema.ts:L48-L55`.
- **`UserMapper`** — converts between the Mongoose schema document and the domain
  `User` in both directions. `Source: backend/src/users/infrastructure/document/mappers/user.mapper.ts:L11`.
- **Domain `User`** — framework-agnostic user type returned by the service.
  `Source: backend/src/users/domain/user.ts:L10-L40`.
- **DTOs** — `CreateUserDto`, `UpdateUserDto`, and `QueryUserDto` define and
  validate request payloads and query parameters.
  `Source: backend/src/users/dto/create-user.dto.ts:L55`,
  `Source: backend/src/users/dto/update-user.dto.ts:L23`,
  `Source: backend/src/users/dto/query-user.dto.ts:L54`.

## Architecture fit

The module is wired into the application root as `UsersModule`
(`Source: backend/src/app.module.ts:L51`). It is consumed by the authentication
subsystem: `AuthModule` imports `UsersModule`
(`Source: backend/src/auth/auth.module.ts:L24`) and `AuthService` injects
`UsersService` to look up and register users during login and registration
(`Source: backend/src/auth/auth.service.ts:L37`). The session subsystem also
references this module's `User` domain type together with `UserSchemaClass` and
`UserMapper`.

All routes are protected at the class level with a JWT guard
(`@UseGuards(AuthGuard('jwt'))` plus `@ApiBearerAuth()`), so a caller must present
a valid Bearer token to reach any endpoint
(`Source: backend/src/users/users.controller.ts:L40-L45`). For the system-wide
layering (controller → service → repository → Mongoose) and how this module sits
within the monorepo, see [../../../docs/ARCHITECTURE.md](../../../docs/ARCHITECTURE.md).

## Data models

A user is persisted as `UserSchemaClass`, declared with
`@Schema({ timestamps: true, toJSON: { virtuals: true, getters: true } })` and
extending `EntityDocumentHelper`
(`Source: backend/src/users/infrastructure/document/entities/user.schema.ts:L48-L55`).
The fields are:

| Field | Type | Notes | Source |
|-------|------|-------|--------|
| `email` | `string \| null` | Unique index (`unique: true`) | `backend/src/users/infrastructure/document/entities/user.schema.ts:L58-L63` |
| `password` | `string?` | Declares `@Exclude({ toPlainOnly: true })`, but no global serializer is registered, so the bcrypt hash is returned in API responses (KNOWN ISSUE) | `backend/src/users/infrastructure/document/entities/user.schema.ts:L67-L69` |
| `preferences` | embedded `Preferences` | Defaults to an object with empty arrays and `cookingTime: 0` | `backend/src/users/infrastructure/document/entities/user.schema.ts:L73-L82` |
| `favoriteRecipes` | `string[]` | Default `[]` | `backend/src/users/infrastructure/document/entities/user.schema.ts:L85-L89` |
| `recentSearches` | `string[]` | Default `[]` | `backend/src/users/infrastructure/document/entities/user.schema.ts:L92-L93` |
| `createdAt` | `Date` | Default `now` | `backend/src/users/infrastructure/document/entities/user.schema.ts:L96-L97` |
| `updatedAt` | `Date` | Default `now` | `backend/src/users/infrastructure/document/entities/user.schema.ts:L100-L101` |
| `deletedAt` | `Date?` | Declared for soft deletion (see Known limitations) | `backend/src/users/infrastructure/document/entities/user.schema.ts:L106-L107` |

The embedded `Preferences` subdocument captures dietary settings
(`Source: backend/src/users/infrastructure/document/entities/user.schema.ts:L15-L31`):

| Field | Type | Default | Source |
|-------|------|---------|--------|
| `dietary` | `string[]` | `[]` | `backend/src/users/infrastructure/document/entities/user.schema.ts:L17-L18` |
| `allergies` | `string[]` | `[]` | `backend/src/users/infrastructure/document/entities/user.schema.ts:L21-L22` |
| `dislikedIngredients` | `string[]` | `[]` | `backend/src/users/infrastructure/document/entities/user.schema.ts:L25-L26` |
| `cookingTime` | `number` | `0` | `backend/src/users/infrastructure/document/entities/user.schema.ts:L29-L30` |

The framework-agnostic domain `User` type mirrors these fields, with its
identifier typed as `id: number | string`
(`Source: backend/src/users/domain/user.ts:L10-L40`). For the cross-entity model
reference and indexes, see [../../../docs/DATA_MODELS.md](../../../docs/DATA_MODELS.md).

## API endpoints / public interface

The controller declares `@Controller({ path: 'users', version: '1' })`
(`Source: backend/src/users/users.controller.ts:L42-L45`). Effective paths are
served under the global `api` prefix as **`/api/users...`** with **no `/v1/`
segment**: `main.ts` sets the global prefix but never calls
`app.enableVersioning()`, so the declared controller version is inactive
(`Source: backend/src/main.ts:L30-L35`).

| Method | Path | Success | Description |
|--------|------|---------|-------------|
| `POST` | `/api/users` | `201 Created` | Create a user; hashes password and rejects duplicate emails. `Source: backend/src/users/users.controller.ts:L60-L64` |
| `GET` | `/api/users` | `200 OK` | List users with pagination (default `limit=10`, capped at 50). `Source: backend/src/users/users.controller.ts:L77-L101` |
| `GET` | `/api/users/me` | `200 OK` | Return the authenticated user from the request principal. `Source: backend/src/users/users.controller.ts:L112-L118` |
| `PATCH` | `/api/users` | `200 OK` | Update the authenticated user. `Source: backend/src/users/users.controller.ts:L131-L140` |
| `DELETE` | `/api/users/:id` | `204 No Content` | Remove a user by id. `Source: backend/src/users/users.controller.ts:L151-L164` |

The list endpoint defaults to `page=1` and `limit=10`, and clamps the page size
to a maximum of 50 (`if (limit > 50) limit = 50;`)
(`Source: backend/src/users/users.controller.ts:L86-L88`). For full request and
response payloads, validation rules, and error bodies, see
[../../../docs/API_REFERENCE.md](../../../docs/API_REFERENCE.md).

## Configuration

This module has no module-specific configuration. It relies on shared
infrastructure provided elsewhere: the Mongoose connection (registered through the
database module and bound here via `MongooseModule.forFeature`,
`Source: backend/src/users/infrastructure/document/document-persistence.module.ts:L26-L42`)
and the JWT authentication enforced by the controller's class-level guard
(`Source: backend/src/users/users.controller.ts:L40-L45`). Connection strings and
auth secrets are environment-driven; see the backend root README at
[../../README.md](../../README.md) for the shared environment and setup details.

## Data flow

A request enters the JWT-guarded controller, which delegates to the service. The
service applies business rules — bcrypt password hashing **on create only** and
duplicate-email / existence checks — then calls the abstract repository. The
update path forwards its payload without re-hashing (see Known limitations). The
document repository executes the operation against the Mongoose model and, for
reads and writes, returns a domain `User` produced by `UserMapper`.

```mermaid
flowchart TD
    Client[Client with Bearer JWT] --> Controller[UsersController · JWT guard]
    Controller --> Service[UsersService · bcrypt hash on create · duplicate-email & existence checks]
    Service --> AbsRepo[Abstract UserRepository]
    AbsRepo --> DocRepo[UsersDocumentRepository]
    DocRepo --> Model[Mongoose UserSchemaClass model]
    Model --> Mongo[(MongoDB)]
    Model --> Mapper[UserMapper toDomain]
    Mapper --> Domain[Domain User]
    Domain --> Controller
```

Flow sources: controller routing and guard
(`Source: backend/src/users/users.controller.ts:L40-L64`), password hashing on
create (`Source: backend/src/users/users.service.ts:L41-L43`), and persistence
plus mapping (`Source: backend/src/users/infrastructure/document/repositories/user.repository.ts:L102-L120`).

## Design patterns used

- **Repository pattern** — an abstract `UserRepository` defines the contract and a
  document adapter implements it, keeping the service storage-agnostic.
  `Source: backend/src/users/infrastructure/user.repository.ts:L21-L89`.
- **Dependency inversion via DI binding** — the abstract token is bound to the
  concrete implementation with `{ provide: UserRepository, useClass: UsersDocumentRepository }`.
  `Source: backend/src/users/infrastructure/document/document-persistence.module.ts:L34-L39`.
- **Mapper pattern** — `UserMapper` translates between the Mongoose schema and the
  domain `User` in both directions. `Source: backend/src/users/infrastructure/document/mappers/user.mapper.ts:L24`.
- **Embedded subdocument** — dietary settings are modeled as an embedded
  `Preferences` document rather than a separate collection.
  `Source: backend/src/users/infrastructure/document/entities/user.schema.ts:L73-L82`.
- **DTO validation** — request payloads are validated with class-validator and
  transformed with class-transformer decorators.
  `Source: backend/src/users/dto/create-user.dto.ts:L55-L95`.
- **Password hashing** — passwords are salted and hashed with bcryptjs (10 salt
  rounds) on create. `Source: backend/src/users/users.service.ts:L41-L43`.
- **Field exclusion declared but not enforced** — `password` carries
  `@Exclude({ toPlainOnly: true })` on the schema, but no global
  `ClassSerializerInterceptor` is registered, so the decorator is not applied to
  REST responses and the bcrypt hash **is returned** in API responses. This is a
  KNOWN ISSUE; it is documented here and is not changed.
  `Source: backend/src/users/infrastructure/document/entities/user.schema.ts:L67-L69`;
  `Source: backend/src/main.ts:L20-L55`.
- **Pagination clamping** — the list endpoint caps the page size at 50.
  `Source: backend/src/users/users.controller.ts:L86-L88`.

## Known limitations / gaps

**KNOWN ISSUE:** The document repository's `softDelete(id)` performs a **hard
delete**: it calls `deleteOne({ _id: id })`, physically removing the user document
even though the schema declares a `deletedAt` field intended for soft deletion
(`Source: backend/src/users/infrastructure/document/repositories/user.repository.ts:L172`;
the method spans L174-L186). The schema's `deletedAt` column is therefore never set
by this operation (`Source: backend/src/users/infrastructure/document/entities/user.schema.ts:L106-L107`).
This behavior is documented as-is and is not changed here; for how it compares to
other entities, see the soft-delete-vs-hard-delete matrix in
[../../../docs/DATA_MODELS.md](../../../docs/DATA_MODELS.md).

**KNOWN ISSUE:** Password hashing is applied **only on create**. `UsersService.create`
hashes the password with bcryptjs (10 salt rounds) before persistence
(`Source: backend/src/users/users.service.ts:L41-L43`), but `UsersService.update`
forwards its payload to the repository without re-hashing
(`Source: backend/src/users/users.service.ts:L112-L138`). `AuthService.update`
verifies `oldPassword` and then delegates to `UsersService.update`
(`Source: backend/src/auth/auth.service.ts:L192-L269`), so a changed password is
persisted in plaintext rather than as a bcrypt hash. This behavior is documented
as-is and is not changed here.

**KNOWN ISSUE:** The `password` field declares `@Exclude({ toPlainOnly: true })` on
the schema, but the application registers no global `ClassSerializerInterceptor`
(`Source: backend/src/main.ts:L20-L55`), so the decorator is never applied to REST
responses. Endpoints that return a user (for example `GET /api/users/me`) therefore
expose the stored bcrypt password hash in their JSON payloads
(`Source: backend/src/users/infrastructure/document/entities/user.schema.ts:L67-L69`).
This behavior is documented as-is and is not changed here.

## Local development

Seed user data into a running database with the document seeder
(`Source: backend/package.json:L16`):

```bash
npm run seed:run:document
```

Exercising this module's routes requires a running MongoDB instance and a valid
Bearer JWT, because every endpoint is JWT-guarded at the class level
(`Source: backend/src/users/users.controller.ts:L40-L45`); obtain a token through
the authentication module. For the full environment configuration, Docker Compose
bring-up, and shared setup, see the backend root README at
[../../README.md](../../README.md).
