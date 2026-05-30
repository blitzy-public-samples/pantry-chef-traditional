# PantryChef REST API Reference

This document is the **REST API reference** for the PantryChef NestJS backend.
It is **reference material**: neutral, present-tense, and table-driven. Each
endpoint is documented exactly as the code serves it, with an inline
`Source: <path>:<line>` citation on every technical claim so that each
statement is traceable to the implementation.

The backend is built on NestJS 10 running on Express and exposes its routes
under a configurable global prefix — `api` by default
(`Source: backend/src/main.ts:L14-L19`, `Source: backend/env_example:L4`). The
API is documented by an existing live Swagger UI; this reference complements it
with stable, version-controlled prose. For the system-level picture of how
requests flow through the layers, see
[./ARCHITECTURE.md](./ARCHITECTURE.md); for the persisted entity shapes
referenced throughout, see [./DATA_MODELS.md](./DATA_MODELS.md).

> This reference documents the system **as built**. Where behavior diverges
> from a name or from the project plan, the divergence is recorded with a
> `KNOWN ISSUE:` or `SECURITY NOTE:` callout rather than corrected.

## Table of Contents

- [1. Base URL and Versioning](#1-base-url-and-versioning)
- [2. Authentication](#2-authentication)
- [3. Auth Endpoints](#3-auth-endpoints)
- [4. Users Endpoints](#4-users-endpoints)
- [5. Pantry Endpoints](#5-pantry-endpoints)
- [6. Recipe Endpoints](#6-recipe-endpoints)
- [7. Ingredient Endpoints](#7-ingredient-endpoints)
- [8. AI Vision Endpoint](#8-ai-vision-endpoint)
- [9. Error Codes](#9-error-codes)
- [10. Swagger UI Location](#10-swagger-ui-location)
- [11. Diagrams](#11-diagrams)
- [12. Related Documentation](#12-related-documentation)

## 1. Base URL and Versioning

All routes are served under a single global prefix. The prefix is applied at
bootstrap with `app.setGlobalPrefix(...)`, reading the value from configuration
and excluding only the root path `/`
(`Source: backend/src/main.ts:L14-L19`). The configured prefix is `api`
(`Source: backend/env_example:L4`), and the server listens on the configured
port, `3000` by default (`Source: backend/env_example:L2`,
`Source: backend/src/main.ts:L33`).

The effective base URL is therefore:

```
http://<host>:3000/api
```

Every endpoint in this reference is documented relative to that base — for
example `POST /api/auth/email/login`, `GET /api/recipe/matches`,
`GET /api/ingredient/creation-data`, and `POST /api/ai/vision`.

### Versioning note

> **KNOWN ISSUE — no `/v1/` segment is served.** Each resource controller
> declares a version in its decorator, e.g.
> `@Controller({ path: 'auth', version: '1' })`
> (`Source: backend/src/auth/auth.controller.ts:L24-L27`). However, `main.ts`
> never calls `app.enableVersioning()` (`Source: backend/src/main.ts:L10-L34`).
> Without URI versioning enabled, NestJS ignores the `version` property and
> does **not** add a `/v1/` segment to the path. The served paths contain no
> version segment.
>
> The mobile client confirms the real paths: every endpoint is built as
> `"$apiBaseUrl/<resource>"` with no `/v1/` — for example the login route is
> `"$apiBaseUrl/auth/email/login"`
> (`Source: mobile/lib/core/constants/endpoints.dart:L12`), the recipe route is
> `"$apiBaseUrl/recipe"` (`Source: mobile/lib/core/constants/endpoints.dart:L19`),
> and the ingredient creation-data route is `"$ingredient/creation-data"`
> (`Source: mobile/lib/core/constants/endpoints.dart:L23`), where `apiBaseUrl`
> defaults to `http://192.168.2.20:3000/api`
> (`Source: mobile/lib/env_config.dart:L2`).
>
> The canonical documented path is `/api/<resource>`. Some project planning
> material refers to `/api/v1/*`; that form is **not** served by the code.

| Property | Value | Source |
|----------|-------|--------|
| Protocol | HTTP/JSON | `Source: mobile/lib/core/utils/dio_client.dart:L19-L26` |
| Global prefix | `api` | `Source: backend/src/main.ts:L14-L19`, `backend/env_example:L4` |
| Port | `3000` (configurable) | `Source: backend/env_example:L2`, `backend/src/main.ts:L33` |
| URI version segment | none (versioning not enabled) | `Source: backend/src/main.ts:L10-L34` |
| Effective base URL | `http://<host>:3000/api` | `Source: mobile/lib/env_config.dart:L2` |

## 2. Authentication

Protected endpoints use **Bearer JWT** authentication. The OpenAPI document
registers a bearer scheme via `addBearerAuth()`
(`Source: backend/src/main.ts:L27`), and protected controllers enforce it with
the Passport JWT guard `@UseGuards(AuthGuard('jwt'))` — applied either at the
class level (Users, Pantry, Recipe, Ingredient) or per route (Auth).

Clients send the access token in the `Authorization` header:

```http
Authorization: Bearer <access_token>
```

### Tokens and lifetimes

The login and register endpoints return an access token, a refresh token, and
the access-token expiry timestamp. Token issuance signs the access token with
the `auth.secret` and an expiry of `auth.expires`, and the refresh token with
`auth.refreshSecret` and an expiry of `auth.refreshExpires`, computing the
absolute expiry with `ms()`
(`Source: backend/src/auth/auth.service.ts:L253-L289`).

| Token | Lifetime | Env variable | Source |
|-------|----------|--------------|--------|
| Access token | `15m` | `AUTH_JWT_TOKEN_EXPIRES_IN` | `Source: backend/env_example:L21` |
| Refresh token | `3650d` | `AUTH_REFRESH_TOKEN_EXPIRES_IN` | `Source: backend/env_example:L23` |

### Passport strategies

The backend registers three Passport strategies that back the guards above:

| Strategy | Guard name | Purpose | Source |
|----------|-----------|---------|--------|
| JWT | `jwt` | Validates the access token on protected routes | `Source: backend/src/auth/auth.module.ts:L21`, `backend/src/auth/auth.controller.ts:L49` |
| JWT refresh | `jwt-refresh` | Validates the refresh token on `POST /api/auth/refresh` | `Source: backend/src/auth/auth.module.ts:L21`, `backend/src/auth/auth.controller.ts:L57` |
| Anonymous | `anonymous` | Registered Passport strategy for anonymous access | `Source: backend/src/auth/auth.module.ts:L21`, `backend/src/auth/strategies/anonymous.strategy.ts:L6` |

For the end-to-end authentication design and the login/refresh sequence
diagram, see [11. Diagrams](#11-diagrams),
[./ARCHITECTURE.md](./ARCHITECTURE.md), and the auth module README
[../backend/src/auth/README.md](../backend/src/auth/README.md).

## 3. Auth Endpoints

The auth controller is tagged `@ApiTags('Auth')` and mounted at base `auth`
(`Source: backend/src/auth/auth.controller.ts:L23-L27`). The login and register
routes are public; the remaining routes require a Bearer token. All routes
return tokens that **omit** the `user` object from the response payload
(`Source: backend/src/auth/auth.controller.ts:L33-L35`).

| Method | Path | Auth | Success | Source |
|--------|------|------|---------|--------|
| `POST` | `/api/auth/email/login` | public | `200 OK` | `Source: backend/src/auth/auth.controller.ts:L31-L37` |
| `POST` | `/api/auth/email/register` | public | `200 OK` | `Source: backend/src/auth/auth.controller.ts:L39-L45` |
| `GET` | `/api/auth/me` | Bearer `jwt` | `200 OK` | `Source: backend/src/auth/auth.controller.ts:L47-L53` |
| `POST` | `/api/auth/refresh` | Bearer `jwt-refresh` | `200 OK` | `Source: backend/src/auth/auth.controller.ts:L55-L63` |
| `POST` | `/api/auth/logout` | Bearer `jwt` | `204 No Content` | `Source: backend/src/auth/auth.controller.ts:L65-L73` |
| `PATCH` | `/api/auth/me` | Bearer `jwt` | `200 OK` | `Source: backend/src/auth/auth.controller.ts:L75-L84` |
| `DELETE` | `/api/auth/me` | Bearer `jwt` | `204 No Content` | `Source: backend/src/auth/auth.controller.ts:L86-L92` |

### 3.1 `POST /api/auth/email/login`

Authenticates a user by email and password and returns tokens. Public route;
no Bearer token required. Returns `200 OK`
(`Source: backend/src/auth/auth.controller.ts:L31-L37`).

Request body — `AuthEmailLoginDto`:

| Field | Type | Required | Validation | Source |
|-------|------|----------|------------|--------|
| `email` | `string` | yes | `@IsEmail`, lower-cased via transformer | `Source: backend/src/auth/dto/auth-email-login.dto.ts:L7-L11` |
| `password` | `string` | yes | `@IsNotEmpty` | `Source: backend/src/auth/dto/auth-email-login.dto.ts:L13-L15` |

```http
POST /api/auth/email/login HTTP/1.1
Content-Type: application/json

{ "email": "test1@example.com", "password": "secret" }
```

```json
{
  "token": "<access_jwt>",
  "refreshToken": "<refresh_jwt>",
  "tokenExpires": 1700000000000
}
```

A non-existent email or an incorrect password returns
`422 Unprocessable Entity` (see [9. Error Codes](#9-error-codes);
`Source: backend/src/auth/auth.service.ts:L40-L79`).

### 3.2 `POST /api/auth/email/register`

Registers a new user and returns tokens. Public route. Returns `200 OK`
(`Source: backend/src/auth/auth.controller.ts:L39-L45`).

Request body — `AuthRegisterLoginDto`:

| Field | Type | Required | Validation | Source |
|-------|------|----------|------------|--------|
| `email` | `string` | yes | `@IsEmail`, lower-cased via transformer | `Source: backend/src/auth/dto/auth-register-login.dto.ts:L7-L10` |
| `password` | `string` | yes | `@MinLength(6)` | `Source: backend/src/auth/dto/auth-register-login.dto.ts:L12-L14` |

```http
POST /api/auth/email/register HTTP/1.1
Content-Type: application/json

{ "email": "test1@example.com", "password": "secret6" }
```

### 3.3 `GET /api/auth/me`

Returns the authenticated user's profile. Requires a Bearer `jwt` token.
Returns `200 OK` (`Source: backend/src/auth/auth.controller.ts:L47-L53`).

```http
GET /api/auth/me HTTP/1.1
Authorization: Bearer <access_token>
```

### 3.4 `POST /api/auth/refresh`

Rotates the session's tokens. Requires a Bearer **refresh** token validated by
the `jwt-refresh` guard; the session id is read from the refresh payload and
new tokens are issued (`Source: backend/src/auth/auth.controller.ts:L55-L63`).
Returns `200 OK`.

```http
POST /api/auth/refresh HTTP/1.1
Authorization: Bearer <refresh_token>
```

### 3.5 `POST /api/auth/logout`

Invalidates the current session. Requires a Bearer `jwt` token. Returns
`204 No Content` (`Source: backend/src/auth/auth.controller.ts:L65-L73`).

### 3.6 `PATCH /api/auth/me`

Updates the authenticated user's profile from an `AuthUpdateDto` body. Requires
a Bearer `jwt` token. Returns `200 OK`
(`Source: backend/src/auth/auth.controller.ts:L75-L84`).

### 3.7 `DELETE /api/auth/me`

Deletes the authenticated user's account via `service.softDelete`. Requires a
Bearer `jwt` token. Returns `204 No Content`
(`Source: backend/src/auth/auth.controller.ts:L86-L92`).

> **KNOWN ISSUE — `softDelete` is a hard delete.** The underlying user
> repository implements `softDelete` with `deleteOne`, permanently removing the
> document rather than setting a `deletedAt` marker
> (`Source: backend/src/users/infrastructure/document/repositories/user.repository.ts:L80-L82`).
> See the soft-delete vs hard-delete matrix in
> [./DATA_MODELS.md](./DATA_MODELS.md).


## 4. Users Endpoints

The users controller is tagged `@ApiTags('Users')` and mounted at base `users`.
The entire controller is protected: `@ApiBearerAuth()` and
`@UseGuards(AuthGuard('jwt'))` are applied at the class level, so every route
requires a Bearer `jwt` token
(`Source: backend/src/users/users.controller.ts:L26-L32`).

| Method | Path | Auth | Success | Source |
|--------|------|------|---------|--------|
| `POST` | `/api/users` | Bearer `jwt` | `201 Created` | `Source: backend/src/users/users.controller.ts:L36-L40` |
| `GET` | `/api/users` | Bearer `jwt` | `200 OK` | `Source: backend/src/users/users.controller.ts:L42-L64` |
| `GET` | `/api/users/me` | Bearer `jwt` | `200 OK` | `Source: backend/src/users/users.controller.ts:L66-L71` |
| `PATCH` | `/api/users` | Bearer `jwt` | `200 OK` | `Source: backend/src/users/users.controller.ts:L73-L81` |
| `DELETE` | `/api/users/:id` | Bearer `jwt` | `204 No Content` | `Source: backend/src/users/users.controller.ts:L83-L92` |

### 4.1 `POST /api/users`

Creates a user from a `CreateUserDto` body. Returns `201 Created`
(`Source: backend/src/users/users.controller.ts:L36-L40`).

Request body — `CreateUserDto`:

| Field | Type | Required | Validation / Notes | Source |
|-------|------|----------|--------------------|--------|
| `email` | `string \| null` | yes | `@IsEmail`, lower-cased via transformer | `Source: backend/src/users/dto/create-user.dto.ts:L41-L45` |
| `password` | `string` | optional | `@MinLength(6)` | `Source: backend/src/users/dto/create-user.dto.ts:L47-L49` |
| `preferences` | `PreferencesDto` | optional | nested, validated | `Source: backend/src/users/dto/create-user.dto.ts:L51-L55` |
| `pantry` | `string[]` | optional | array of strings | `Source: backend/src/users/dto/create-user.dto.ts:L57-L61` |
| `favoriteRecipes` | `string[]` | optional | array | `Source: backend/src/users/dto/create-user.dto.ts:L63-L66` |
| `recentSearches` | `string[]` | optional | array of strings | `Source: backend/src/users/dto/create-user.dto.ts:L68-L72` |

The embedded `PreferencesDto` supplies the inputs consumed by the recipe
matching engine (see [6. Recipe Endpoints](#6-recipe-endpoints)):

| Field | Type | Required | Source |
|-------|------|----------|--------|
| `dietary` | `string[]` | optional | `Source: backend/src/users/dto/create-user.dto.ts:L16-L20` |
| `allergies` | `string[]` | optional | `Source: backend/src/users/dto/create-user.dto.ts:L22-L26` |
| `dislikedIngredients` | `string[]` | optional | `Source: backend/src/users/dto/create-user.dto.ts:L28-L32` |
| `cookingTime` | `number` | optional | `Source: backend/src/users/dto/create-user.dto.ts:L34-L37` |

```http
POST /api/users HTTP/1.1
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "email": "chef@example.com",
  "password": "secret6",
  "preferences": { "dietary": ["vegetarian"], "allergies": ["peanuts"] }
}
```

### 4.2 `GET /api/users`

Returns a paginated list of users from a `QueryUserDto` query (page, limit,
filters, sort). Returns `200 OK`
(`Source: backend/src/users/users.controller.ts:L42-L64`).

| Parameter | Type | Required | Description | Source |
|-----------|------|----------|-------------|--------|
| `page` | `number` | optional | Page number; defaults to `1` | `Source: backend/src/users/users.controller.ts:L47` |
| `limit` | `number` | optional | Items per page; defaults to `10` | `Source: backend/src/users/users.controller.ts:L48` |
| `filters` | object | optional | Filter options applied to the query | `Source: backend/src/users/users.controller.ts:L55` |
| `sort` | object | optional | Sort options | `Source: backend/src/users/users.controller.ts:L56` |

> **KNOWN ISSUE — pagination is capped at 50.** When the requested `limit`
> exceeds `50` it is silently reduced to `50`
> (`Source: backend/src/users/users.controller.ts:L49-L51`). The same cap
> applies to the pantry, recipe, and ingredient list endpoints.

```http
GET /api/users?page=1&limit=20 HTTP/1.1
Authorization: Bearer <access_token>
```

### 4.3 `GET /api/users/me`

Returns the authenticated user, resolved from `req.user?.id`. Returns
`200 OK` (`Source: backend/src/users/users.controller.ts:L66-L71`).

### 4.4 `PATCH /api/users`

Updates the authenticated user from an `UpdateUserDto` body; the target id is
taken from `req.user?.id` rather than the path. Returns `200 OK`
(`Source: backend/src/users/users.controller.ts:L73-L81`).

### 4.5 `DELETE /api/users/:id`

Deletes the user identified by the `:id` path parameter via
`usersService.softDelete`. Returns `204 No Content`
(`Source: backend/src/users/users.controller.ts:L83-L92`).

| Parameter | Type | Description | Source |
|-----------|------|-------------|--------|
| `id` | `string` | User id to delete (path) | `Source: backend/src/users/users.controller.ts:L83-L90` |

> **KNOWN ISSUE — `softDelete` is a hard delete.** The user repository
> implements `softDelete` with `deleteOne`, permanently removing the document
> (`Source: backend/src/users/infrastructure/document/repositories/user.repository.ts:L80-L82`).
> See the soft-delete vs hard-delete matrix in
> [./DATA_MODELS.md](./DATA_MODELS.md).


## 5. Pantry Endpoints

The pantry controller is tagged `@ApiTags('Pantry')` and mounted at base
`pantry`. The whole controller is protected by class-level `@ApiBearerAuth()`
and `@UseGuards(AuthGuard('jwt'))`
(`Source: backend/src/pantry/pantry.controller.ts:L26-L32`). Pantry items are
scoped to the authenticated user: the `userId` is taken from the request rather
than the body (`Source: backend/src/pantry/pantry.controller.ts:L42`).

| Method | Path | Auth | Success | Source |
|--------|------|------|---------|--------|
| `POST` | `/api/pantry` | Bearer `jwt` | `201 Created` | `Source: backend/src/pantry/pantry.controller.ts:L36-L44` |
| `GET` | `/api/pantry` | Bearer `jwt` | `200 OK` | `Source: backend/src/pantry/pantry.controller.ts:L46-L70` |
| `GET` | `/api/pantry/:id` | Bearer `jwt` | `200 OK` | `Source: backend/src/pantry/pantry.controller.ts:L72-L83` |
| `PATCH` | `/api/pantry/:id` | Bearer `jwt` | `200 OK` | `Source: backend/src/pantry/pantry.controller.ts:L85-L97` |
| `DELETE` | `/api/pantry/:id` | Bearer `jwt` | `204 No Content` | `Source: backend/src/pantry/pantry.controller.ts:L99-L108` |

### 5.1 `POST /api/pantry`

Adds an ingredient to the authenticated user's pantry from a
`CreatePantryIngridientDto` body. Returns `201 Created`; the `userId` is taken
from `req.user?.id` (`Source: backend/src/pantry/pantry.controller.ts:L36-L44`).

Request body — `CreatePantryIngridientDto` (filename misspelled as
`create-pantry-ingridient.dto.ts`, preserved verbatim):

| Field | Type | Required | Validation / Notes | Source |
|-------|------|----------|--------------------|--------|
| `ingridient` | `Ingridient` | yes | ingredient reference (`ingridient`, sic) | `Source: backend/src/pantry/dto/create-pantry-ingridient.dto.ts:L12-L14` |
| `quantity` | `number` | yes | `@IsNumber` | `Source: backend/src/pantry/dto/create-pantry-ingridient.dto.ts:L16-L19` |
| `unit` | `string` | yes | `@IsString` | `Source: backend/src/pantry/dto/create-pantry-ingridient.dto.ts:L21-L24` |
| `expirationDate` | `Date` | optional | `@IsDateString` | `Source: backend/src/pantry/dto/create-pantry-ingridient.dto.ts:L26-L32` |
| `location` | `'fridge' \| 'freezer' \| 'pantry'` | yes | enum | `Source: backend/src/pantry/dto/create-pantry-ingridient.dto.ts:L34-L40` |

```http
POST /api/pantry HTTP/1.1
Authorization: Bearer <access_token>
Content-Type: application/json

{ "ingridient": "<ingredientId>", "quantity": 2, "unit": "kg",
  "location": "fridge" }
```

### 5.2 `GET /api/pantry`

Returns a paginated list of the authenticated user's pantry items from a
`QueryPantryIngridientDto` query. The filter is scoped to `userId`
(`Source: backend/src/pantry/pantry.controller.ts:L61`). Returns `200 OK`.

| Parameter | Type | Required | Description | Source |
|-----------|------|----------|-------------|--------|
| `page` | `number` | optional | Page number; defaults to `1` | `Source: backend/src/pantry/pantry.controller.ts:L53` |
| `limit` | `number` | optional | Items per page; defaults to `10`, capped at `50` | `Source: backend/src/pantry/pantry.controller.ts:L54-L57` |
| `filters` | object | optional | Merged with `{ userId }` scope | `Source: backend/src/pantry/pantry.controller.ts:L61` |
| `sort` | object | optional | Sort options | `Source: backend/src/pantry/pantry.controller.ts:L62` |

> **KNOWN ISSUE — pagination is capped at 50.** A requested `limit` above `50`
> is reduced to `50` (`Source: backend/src/pantry/pantry.controller.ts:L55-L57`).

### 5.3 `GET /api/pantry/:id`

Returns a single pantry item by `:id`. Returns `200 OK`
(`Source: backend/src/pantry/pantry.controller.ts:L72-L83`).

| Parameter | Type | Description | Source |
|-----------|------|-------------|--------|
| `id` | `string` | Pantry item id (path) | `Source: backend/src/pantry/pantry.controller.ts:L72-L82` |

### 5.4 `PATCH /api/pantry/:id`

Updates a pantry item by `:id` from an `UpdatePantryIngridientDto` body. Returns
`200 OK` (`Source: backend/src/pantry/pantry.controller.ts:L85-L97`).

### 5.5 `DELETE /api/pantry/:id`

Deletes a pantry item by `:id` via `pantryService.softDelete`. Returns
`204 No Content` (`Source: backend/src/pantry/pantry.controller.ts:L99-L108`).

> **KNOWN ISSUE — `softDelete` is a hard delete.** The pantry repository
> implements `softDelete` with `deleteOne`, permanently removing the document
> (`Source: backend/src/pantry/infrastructure/document/repositories/pantryIngridient.repository.ts:L119-L121`).
> See the soft-delete vs hard-delete matrix in
> [./DATA_MODELS.md](./DATA_MODELS.md).


## 6. Recipe Endpoints

The recipe controller is tagged `@ApiTags('Recipe')` and mounted at base
`recipe`. The whole controller is protected by class-level `@ApiBearerAuth()`
and `@UseGuards(AuthGuard('jwt'))`
(`Source: backend/src/recipe/recipe.controller.ts:L27-L33`).

| Method | Path | Auth | Success | Source |
|--------|------|------|---------|--------|
| `POST` | `/api/recipe` | Bearer `jwt` | `201 Created` | `Source: backend/src/recipe/recipe.controller.ts:L37-L41` |
| `GET` | `/api/recipe/matches` | Bearer `jwt` | `200 OK` | `Source: backend/src/recipe/recipe.controller.ts:L43-L48` |
| `GET` | `/api/recipe` | Bearer `jwt` | `200 OK` | `Source: backend/src/recipe/recipe.controller.ts:L50-L72` |
| `GET` | `/api/recipe/:id` | Bearer `jwt` | `200 OK` | `Source: backend/src/recipe/recipe.controller.ts:L74-L83` |
| `PATCH` | `/api/recipe/:id` | Bearer `jwt` | `200 OK` | `Source: backend/src/recipe/recipe.controller.ts:L85-L97` |
| `DELETE` | `/api/recipe/:id` | Bearer `jwt` | `204 No Content` | `Source: backend/src/recipe/recipe.controller.ts:L99-L108` |

> **Note on routing order.** `GET /api/recipe/matches` is declared **before**
> `GET /api/recipe/:id`
> (`Source: backend/src/recipe/recipe.controller.ts:L43-L48`,
> `Source: backend/src/recipe/recipe.controller.ts:L74-L83`), so `matches` is
> matched as a literal route and is not shadowed by the `:id` parameter route.

### 6.1 `POST /api/recipe`

Creates a recipe from a `CreateRecipeDto` body. Returns `201 Created`
(`Source: backend/src/recipe/recipe.controller.ts:L37-L41`).

Request body — `CreateRecipeDto`:

| Field | Type | Required | Validation / Notes | Source |
|-------|------|----------|--------------------|--------|
| `title` | `string` | yes | `@IsNotEmpty`, `@IsString` | `Source: backend/src/recipe/dto/create-recipe.dto.ts:L64-L67` |
| `description` | `string` | yes | `@IsNotEmpty`, `@IsString` | `Source: backend/src/recipe/dto/create-recipe.dto.ts:L69-L72` |
| `ingridientList` | `IngridientListDto[]` | yes | nested array (`ingridient`, sic) | `Source: backend/src/recipe/dto/create-recipe.dto.ts:L74-L82` |
| `instructions` | `InstructionDto[]` | yes | nested array | `Source: backend/src/recipe/dto/create-recipe.dto.ts:L84-L92` |
| `prepTime` | `number` | yes | `@IsNumber` (minutes) | `Source: backend/src/recipe/dto/create-recipe.dto.ts:L94-L97` |
| `cookTime` | `number` | yes | `@IsNumber` (minutes) | `Source: backend/src/recipe/dto/create-recipe.dto.ts:L99-L102` |
| `servings` | `number` | yes | `@IsNumber` | `Source: backend/src/recipe/dto/create-recipe.dto.ts:L104-L107` |
| `difficulty` | `'easy' \| 'medium' \| 'hard'` | yes | `@IsIn` enum | `Source: backend/src/recipe/dto/create-recipe.dto.ts:L109-L115` |
| `tags` | `string[]` | optional | array of strings | `Source: backend/src/recipe/dto/create-recipe.dto.ts:L117-L124` |
| `imageUrl` | `string` | optional | `@IsUrl` | `Source: backend/src/recipe/dto/create-recipe.dto.ts:L126-L129` |
| `matchScore` | `number` | optional | `@Min(0)`, range `0`–`1` | `Source: backend/src/recipe/dto/create-recipe.dto.ts:L131-L140` |

Each `ingridientList` entry (`IngridientListDto`) carries `ingridient`
(reference, sic), `amount`, `unit`, `required`, and optional `substitutes`
(`Source: backend/src/recipe/dto/create-recipe.dto.ts:L16-L44`). Each
`instructions` entry (`InstructionDto`) carries `step`, `description`, and an
optional `timer` (`Source: backend/src/recipe/dto/create-recipe.dto.ts:L46-L61`).

```http
POST /api/recipe HTTP/1.1
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "title": "Tomato Pasta",
  "description": "Simple pasta",
  "ingridientList": [{ "ingridient": "<id>", "amount": 2, "unit": "cup",
    "required": true }],
  "instructions": [{ "step": 1, "description": "Boil pasta" }],
  "prepTime": 5, "cookTime": 15, "servings": 2, "difficulty": "easy",
  "tags": ["dinner"]
}
```

> **KNOWN ISSUE — duplicate `title` returns `422`.** Creating a recipe whose
> `title` already exists throws `422 Unprocessable Entity`
> (`Source: backend/src/recipe/recipe.service.ts:L27-L42`). The error payload
> uses the key `recipeAlreadyExists` (nested under an `email` errors key in the
> response shape).

### 6.2 `GET /api/recipe/matches`

Runs the recipe matching engine for the authenticated user against their pantry
and preferences and returns scored recipes. Returns `200 OK`
(`Source: backend/src/recipe/recipe.controller.ts:L43-L48`). The query uses the
`FilterType` shape (`Source: backend/src/recipe/types/filter.types.ts:L1-L4`).

| Parameter | Type | Required | Description | Source |
|-----------|------|----------|-------------|--------|
| `isQuickMake` | `boolean` | optional | Keep only quick-make recipes (≤ 5 ingredients) | `Source: backend/src/recipe/types/filter.types.ts:L2` |
| `isAlmostThere` | `boolean` | optional | Keep only recipes missing 1–2 ingredients | `Source: backend/src/recipe/types/filter.types.ts:L3` |

**Matching algorithm** (`RecipeDocumentRepository.matches`):

1. Collect the user's pantry ingredient ids
   (`Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L97`)
   and seed the query with `deletedAt: null`
   (`Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L99`).
2. Apply preference pre-filters: excluded ingredients (allergies +
   `dislikedIngredients`) via `ingridientList.ingridient: { $nin }`
   (`Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L108`);
   dietary tags via `tags: { $all }`
   (`Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L113`);
   cooking time via `cookTime: { $lte }`
   (`Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L118`).
3. For each recipe, `totalIngredients = ingridientList.length`
   (`Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L130`);
   availability is determined by an exact id check
   `pantryIngredientIds.includes(il.ingridient._id.toString())`
   (`Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L131-L133`).
4. Derive `matchScore = availableIngredients.length / totalIngredients`
   (range `0`–`1`)
   (`Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L137`),
   `isQuickMake = totalIngredients <= 5`
   (`Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L139`),
   and `isAlmostThere` when 1–2 ingredients are missing
   (`Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L141-L142`).
5. Filter by the `isQuickMake` / `isAlmostThere` query flags
   (`Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L152-L166`)
   and sort by `matchScore` descending
   (`Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L167`).

See the [recipe-match sequence diagram](#11-diagrams) in section 11.

```http
GET /api/recipe/matches?isQuickMake=true HTTP/1.1
Authorization: Bearer <access_token>
```

> **KNOWN ISSUE — matching is by exact ingredient `_id` only.** Availability is
> decided purely by whether the pantry contains the exact ingredient `_id`,
> with no unit or quantity normalization — an ingredient counts as present
> regardless of amount
> (`Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L131-L137`).
> An existing developer comment documents the scoring intent at
> `backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L129`.

### 6.3 `GET /api/recipe`

Returns a paginated list of recipes from a `QueryRecipeDto` query. The list
excludes soft-deleted recipes via `deletedAt: null`
(`Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L71`).
Returns `200 OK` (`Source: backend/src/recipe/recipe.controller.ts:L50-L72`).

| Parameter | Type | Required | Description | Source |
|-----------|------|----------|-------------|--------|
| `page` | `number` | optional | Page number; defaults to `1` | `Source: backend/src/recipe/recipe.controller.ts:L55` |
| `limit` | `number` | optional | Items per page; defaults to `10`, capped at `50` | `Source: backend/src/recipe/recipe.controller.ts:L56-L59` |
| `query` | `string` | optional | Name filter, applied as case-insensitive `$regex` | `Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L60-L61` |
| `ids` | `string[]` | optional | Restrict to ids via `$in` | `Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L63-L64` |
| `sort` | `SortRecipeDto[]` | optional | Sort options (JSON) | `Source: backend/src/recipe/dto/query-recipe.dto.ts:L58-L67` |

> **KNOWN ISSUE — pagination is capped at 50.** A requested `limit` above `50`
> is reduced to `50` (`Source: backend/src/recipe/recipe.controller.ts:L57-L59`).

```http
GET /api/recipe?query=pasta&limit=20 HTTP/1.1
Authorization: Bearer <access_token>
```

### 6.4 `GET /api/recipe/:id`

Returns a single recipe by `:id`. Returns `200 OK`
(`Source: backend/src/recipe/recipe.controller.ts:L74-L83`).

### 6.5 `PATCH /api/recipe/:id`

Updates a recipe by `:id` from an `UpdateRecipeDto` body. Returns `200 OK`
(`Source: backend/src/recipe/recipe.controller.ts:L85-L97`).

### 6.6 `DELETE /api/recipe/:id`

Deletes a recipe by `:id`. Returns `204 No Content`
(`Source: backend/src/recipe/recipe.controller.ts:L99-L108`).

Unlike the user and pantry deletes, the recipe `softDelete` is a **true soft
delete**: it sets `deletedAt` with `updateOne` rather than removing the
document
(`Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L184-L186`).
See the soft-delete vs hard-delete matrix in
[./DATA_MODELS.md](./DATA_MODELS.md).


## 7. Ingredient Endpoints

The ingredient controller is tagged `@ApiTags('Ingredient')` and the served
route base is the correctly-spelled `ingredient`
(`Source: backend/src/ingridient/ingridient.controller.ts:L33-L37`).

> **Preserved misspelling.** The module directory is spelled `ingridient/` and
> the DTO files are `create-ingridient.dto.ts` / `update-ingridient.dto.ts`
> (sic), with the controller class `IngridientController`
> (`Source: backend/src/ingridient/ingridient.controller.ts:L29-L38`). These
> code identifiers are reproduced exactly here and are not renamed. Only the
> URI route base is the correctly-spelled `ingredient`.

The whole controller is protected by class-level `@ApiBearerAuth()` and
`@UseGuards(AuthGuard('jwt'))`
(`Source: backend/src/ingridient/ingridient.controller.ts:L31-L32`).

| Method | Path | Auth | Success | Source |
|--------|------|------|---------|--------|
| `GET` | `/api/ingredient/creation-data` | Bearer `jwt` | `200 OK` | `Source: backend/src/ingridient/ingridient.controller.ts:L41-L72` |
| `POST` | `/api/ingredient` | Bearer `jwt` | `201 Created` | `Source: backend/src/ingridient/ingridient.controller.ts:L74-L80` |
| `GET` | `/api/ingredient` | Bearer `jwt` | `200 OK` | `Source: backend/src/ingridient/ingridient.controller.ts:L82-L104` |
| `GET` | `/api/ingredient/:id` | Bearer `jwt` | `200 OK` | `Source: backend/src/ingridient/ingridient.controller.ts:L106-L117` |
| `PATCH` | `/api/ingredient/:id` | Bearer `jwt` | `200 OK` | `Source: backend/src/ingridient/ingridient.controller.ts:L119-L131` |
| `DELETE` | `/api/ingredient/:id` | Bearer `jwt` | `204 No Content` | `Source: backend/src/ingridient/ingridient.controller.ts:L133-L142` |

### 7.1 `GET /api/ingredient/creation-data`

Returns the reference data used by clients when creating an ingredient: a fixed
list of categories and a fixed list of units, each as `{ id, name }`. Returns
`200 OK` (`Source: backend/src/ingridient/ingridient.controller.ts:L41-L72`).
This route is declared before `:id`, so it is not shadowed by the parameter
route.

The **5 categories** are hardcoded
(`Source: backend/src/ingridient/ingridient.controller.ts:L53-L59`):

| id | name | Source |
|----|------|--------|
| 1 | `spice` | `Source: backend/src/ingridient/ingridient.controller.ts:L54` |
| 2 | `vegetable` | `Source: backend/src/ingridient/ingridient.controller.ts:L55` |
| 3 | `fruit` | `Source: backend/src/ingridient/ingridient.controller.ts:L56` |
| 4 | `dairy` | `Source: backend/src/ingridient/ingridient.controller.ts:L57` |
| 5 | `protein` | `Source: backend/src/ingridient/ingridient.controller.ts:L58` |

The **9 units** are hardcoded
(`Source: backend/src/ingridient/ingridient.controller.ts:L60-L70`):

| id | name | Source |
|----|------|--------|
| 1 | `kg` | `Source: backend/src/ingridient/ingridient.controller.ts:L61` |
| 2 | `g` | `Source: backend/src/ingridient/ingridient.controller.ts:L62` |
| 3 | `lb` | `Source: backend/src/ingridient/ingridient.controller.ts:L63` |
| 4 | `oz` | `Source: backend/src/ingridient/ingridient.controller.ts:L64` |
| 5 | `ml` | `Source: backend/src/ingridient/ingridient.controller.ts:L65` |
| 6 | `l` | `Source: backend/src/ingridient/ingridient.controller.ts:L66` |
| 7 | `cup` | `Source: backend/src/ingridient/ingridient.controller.ts:L67` |
| 8 | `tbsp` | `Source: backend/src/ingridient/ingridient.controller.ts:L68` |
| 9 | `tsp` | `Source: backend/src/ingridient/ingridient.controller.ts:L69` |

```json
{
  "categories": [{ "id": 1, "name": "spice" }, { "id": 2, "name": "vegetable" }],
  "units": [{ "id": 1, "name": "kg" }, { "id": 7, "name": "cup" }]
}
```

### 7.2 `POST /api/ingredient`

Creates an ingredient from a `CreateIngridientDto` (sic) body. Returns
`201 Created` (`Source: backend/src/ingridient/ingridient.controller.ts:L74-L80`).

Request body — `CreateIngridientDto` (filename `create-ingridient.dto.ts`, sic):

| Field | Type | Required | Validation / Notes | Source |
|-------|------|----------|--------------------|--------|
| `name` | `string` | yes | `@IsNotEmpty`, `@IsString` | `Source: backend/src/ingridient/dto/create-ingridient.dto.ts:L15-L18` |
| `category` | `Reference` | yes | `{ id, name }` reference | `Source: backend/src/ingridient/dto/create-ingridient.dto.ts:L20-L22` |
| `quantity` | `number` | optional | `@IsNumber` | `Source: backend/src/ingridient/dto/create-ingridient.dto.ts:L24-L27` |
| `unit` | `Reference` | optional | `{ id, name }` reference | `Source: backend/src/ingridient/dto/create-ingridient.dto.ts:L29-L31` |
| `expirationDate` | `Date` | optional | `@IsDateString` | `Source: backend/src/ingridient/dto/create-ingridient.dto.ts:L33-L39` |
| `imageUrl` | `string` | optional | `@IsUrl` | `Source: backend/src/ingridient/dto/create-ingridient.dto.ts:L41-L44` |
| `confidence` | `number` | yes | `@Min(0)`, `@Max(1)` — range `0`–`1` | `Source: backend/src/ingridient/dto/create-ingridient.dto.ts:L46-L55` |

The `confidence` field models AI-recognition certainty and is constrained to
the `0`–`1` range; on the persisted entity it is excluded from JSON output by
default (`Source: backend/src/ingridient/infrastructure/document/entities/ingridient.schema.ts:L38-L40`).

```http
POST /api/ingredient HTTP/1.1
Authorization: Bearer <access_token>
Content-Type: application/json

{ "name": "tomato", "category": { "id": 2, "name": "vegetable" },
  "confidence": 0.92 }
```

> **KNOWN ISSUE — duplicate `name` returns `422`.** Creating an ingredient with
> a `name` that already exists throws `422 Unprocessable Entity`
> (`Source: backend/src/ingridient/ingridient.service.ts:L20-L35`).

### 7.3 `GET /api/ingredient`

Returns a paginated list of ingredients from a `QueryIngridientDto` query.
Returns `200 OK` (`Source: backend/src/ingridient/ingridient.controller.ts:L82-L104`).

| Parameter | Type | Required | Description | Source |
|-----------|------|----------|-------------|--------|
| `page` | `number` | optional | Page number; defaults to `1` | `Source: backend/src/ingridient/ingridient.controller.ts:L87` |
| `limit` | `number` | optional | Items per page; defaults to `10`, capped at `50` | `Source: backend/src/ingridient/ingridient.controller.ts:L88-L91` |
| `query` | object | optional | Filter options | `Source: backend/src/ingridient/ingridient.controller.ts:L95` |
| `sort` | object | optional | Sort options | `Source: backend/src/ingridient/ingridient.controller.ts:L96` |

> **KNOWN ISSUE — pagination is capped at 50.** A requested `limit` above `50`
> is reduced to `50`
> (`Source: backend/src/ingridient/ingridient.controller.ts:L89-L91`).

### 7.4 `GET /api/ingredient/:id`

Returns a single ingredient by `:id`. Returns `200 OK`
(`Source: backend/src/ingridient/ingridient.controller.ts:L106-L117`).

### 7.5 `PATCH /api/ingredient/:id`

Updates an ingredient by `:id` from an `UpdateIngridientDto` (sic) body. Returns
`200 OK` (`Source: backend/src/ingridient/ingridient.controller.ts:L119-L131`).

### 7.6 `DELETE /api/ingredient/:id`

Deletes an ingredient by `:id` via `ingridientService.softDelete`. Returns
`204 No Content` (`Source: backend/src/ingridient/ingridient.controller.ts:L133-L142`).


## 8. AI Vision Endpoint

The AI controller is mounted at base `ai` with `@Controller('ai')` — it declares
**no** version and **no** `@ApiTags`
(`Source: backend/src/ai/ai.controller.ts:L12-L13`).

| Method | Path | Auth | Success | Source |
|--------|------|------|---------|--------|
| `POST` | `/api/ai/vision` | **none** | `200 OK` | `Source: backend/src/ai/ai.controller.ts:L16-L43` |

### 8.1 `POST /api/ai/vision`

Accepts a single multipart image upload and returns the recognized ingredient.
The upload field is named `image` and is handled by a `FileInterceptor` backed
by `memoryStorage()`, with a file-size limit of **10 MB**
(`10 * 1024 * 1024`) (`Source: backend/src/ai/ai.controller.ts:L16-L31`,
limit at `Source: backend/src/ai/ai.controller.ts:L29`). When no file is
supplied, the endpoint throws `BadRequestException('Image empty')`, producing a
`400 Bad Request` (`Source: backend/src/ai/ai.controller.ts:L33-L34`).

| Field | In | Type | Required | Description | Source |
|-------|----|------|----------|-------------|--------|
| `image` | multipart form-data | file | yes | Image to analyze (≤ 10 MB) | `Source: backend/src/ai/ai.controller.ts:L18-L31` |

> **SECURITY NOTE — this endpoint is unauthenticated.** Unlike every other
> resource controller, the AI controller applies **no** JWT guard, so
> `POST /api/ai/vision` is reachable without a Bearer token
> (`Source: backend/src/ai/ai.controller.ts:L12-L16`). This is documented as a
> deviation, not a recommendation.

> **KNOWN ISSUE — the MIME-type filter is commented out.** The interceptor's
> `fileFilter` (which would reject non-JPG/JPEG/PNG uploads) is commented out,
> so non-image uploads are not rejected at the interceptor layer
> (`Source: backend/src/ai/ai.controller.ts:L20-L28`).

**Behavior.** On success the service returns the matched ingredient object
`{ id, name, category, quantity, unit, confidence }`
(`Source: backend/src/ai/ai.service.ts:L114-L126`). It returns an **empty
object `{}`** when Google Cloud Vision is disabled — for example when the
`ai.json` service-account key is absent
(`Source: backend/src/ai/ai.service.ts:L63-L67`) — or when no label matches the
internal dictionary (`Source: backend/src/ai/ai.service.ts:L84-L86`). For the
`ai.json` provisioning workflow, see [./DEPLOYMENT.md](./DEPLOYMENT.md).

```http
POST /api/ai/vision HTTP/1.1
Content-Type: multipart/form-data; boundary=----boundary

------boundary
Content-Disposition: form-data; name="image"; filename="fridge.jpg"
Content-Type: image/jpeg

<binary image bytes>
------boundary--
```

Successful match:

```json
{
  "id": "665f...",
  "name": "tomato",
  "category": { "id": 2, "name": "vegetable" },
  "quantity": 1,
  "unit": { "id": 1, "name": "kg" },
  "confidence": 0.92
}
```

Graceful degradation (Vision disabled or no match):

```json
{}
```


## 9. Error Codes

The API returns standard HTTP status codes. Validation and domain conflicts use
`422 Unprocessable Entity`; missing or invalid Bearer tokens use `401`; the AI
endpoint uses `400` for an empty upload.

| Status | Meaning | Triggered by | Source |
|--------|---------|--------------|--------|
| `200 OK` | Success (read / login / update) | GET, login, register, refresh, PATCH routes | `Source: backend/src/auth/auth.controller.ts:L31-L37` |
| `201 Created` | Resource created | `POST /api/users`, `/api/pantry`, `/api/recipe`, `/api/ingredient` | `Source: backend/src/users/users.controller.ts:L36-L40` |
| `204 No Content` | Success with no body | logout and `DELETE` routes | `Source: backend/src/auth/auth.controller.ts:L65-L73` |
| `400 Bad Request` | AI vision called with no file | `POST /api/ai/vision` | `Source: backend/src/ai/ai.controller.ts:L33-L34` |
| `401 Unauthorized` | Missing/invalid Bearer token | any class- or route-guarded endpoint | `Source: backend/src/users/users.controller.ts:L26-L27` |
| `422 Unprocessable Entity` | Validation failure | global `ValidationPipe` | `Source: backend/src/main.ts:L21` |
| `422 Unprocessable Entity` | Duplicate recipe `title` | `POST /api/recipe` | `Source: backend/src/recipe/recipe.service.ts:L27-L42` |
| `422 Unprocessable Entity` | Duplicate ingredient `name` | `POST /api/ingredient` | `Source: backend/src/ingridient/ingridient.service.ts:L20-L35` |
| `422 Unprocessable Entity` | Login email not found / wrong password | `POST /api/auth/email/login` | `Source: backend/src/auth/auth.service.ts:L40-L79` |

Validation errors are produced by the global `ValidationPipe` registered at
bootstrap (`Source: backend/src/main.ts:L21`). A representative `422` body:

```json
{
  "status": 422,
  "errors": { "email": "recipeAlreadyExists" }
}
```

## 10. Swagger UI Location

The interactive OpenAPI UI is served at **`/docs`**
(`Source: backend/src/main.ts:L31`). The OpenAPI document is built with the
title `API`, the description `API docs`, the version `1.0`, and a bearer-auth
scheme (`Source: backend/src/main.ts:L23-L28`).

```
http://<host>:3000/docs
```

> **Divergence note.** The global `api` prefix is **not** applied to the Swagger
> route — `SwaggerModule.setup('docs', app, document)` registers it at the root
> `/docs` (`Source: backend/src/main.ts:L31`). Some project planning material
> refers to the UI as `/api/docs`; the served location is `/docs`.

## 11. Diagrams

### Recipe match flow

The sequence below traces `GET /api/recipe/matches` from the client through the
controller, service, and document repository
(`Source: backend/src/recipe/recipe.controller.ts:L43-L48`,
`Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L92-L167`).

```mermaid
sequenceDiagram
    participant Client
    participant Controller as RecipeController
    participant Service as RecipeService
    participant Repo as RecipeDocumentRepository
    participant Mongo as MongoDB via Mongoose

    Client->>Controller: GET /api/recipe/matches?isQuickMake
    Controller->>Service: matches (userId, filterQuery)
    Service->>Repo: matches (preferences, pantry, filter)
    Repo->>Repo: build query (deletedAt=null, $nin, $all, $lte)
    Repo->>Mongo: find then populate ingridientList.ingridient
    Mongo-->>Repo: recipe documents
    Repo->>Repo: compute matchScore, isQuickMake, isAlmostThere
    Repo->>Repo: filter by flags, sort by matchScore desc
    Repo-->>Service: scored recipes
    Service-->>Controller: scored recipes
    Controller-->>Client: 200 OK (recipes)
```

### Auth login and refresh flow

The sequence below traces login (`POST /api/auth/email/login`) and token refresh
(`POST /api/auth/refresh`)
(`Source: backend/src/auth/auth.controller.ts:L31-L63`,
`Source: backend/src/auth/auth.service.ts:L253-L289`).

```mermaid
sequenceDiagram
    participant Client
    participant Auth as AuthController
    participant Service as AuthService
    participant Session as SessionService

    Note over Client,Session: Login
    Client->>Auth: POST /api/auth/email/login (email, password)
    Auth->>Service: validateLogin (dto)
    Service->>Service: verify password (bcryptjs)
    Service->>Session: create session
    Service->>Service: issue access (15m) + refresh (3650d) via ms()
    Service-->>Auth: token, refreshToken, tokenExpires
    Auth-->>Client: 200 OK (tokens, user omitted)

    Note over Client,Session: Refresh
    Client->>Auth: POST /api/auth/refresh (Bearer refresh, jwt-refresh guard)
    Auth->>Service: refreshToken (sessionId)
    Service->>Service: rotate access + refresh tokens
    Service-->>Auth: token, refreshToken, tokenExpires
    Auth-->>Client: 200 OK (new tokens)
```

## 12. Related Documentation

This reference is the endpoint-level entry point. For broader context, follow
these sibling references and package READMEs:

- [./ARCHITECTURE.md](./ARCHITECTURE.md) — system design, layered backend and
  clean mobile architecture, and the request lifecycle.
- [./DATA_MODELS.md](./DATA_MODELS.md) — Mongoose entities and Dart models with
  field tables, plus the soft-delete vs hard-delete matrix.
- [./DEPLOYMENT.md](./DEPLOYMENT.md) — Docker Compose bring-up, environment
  variables, database seeding, and the `ai.json` Vision key workflow.
- [../backend/README.md](../backend/README.md) — backend project overview and
  local development.

Per-module READMEs provide the deepest detail, for example
[../backend/src/auth/README.md](../backend/src/auth/README.md),
[../backend/src/recipe/README.md](../backend/src/recipe/README.md),
[../backend/src/ingridient/README.md](../backend/src/ingridient/README.md), and
[../backend/src/ai/README.md](../backend/src/ai/README.md).

