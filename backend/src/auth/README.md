# Auth Module (`backend/src/auth`)

The auth module is the authentication boundary of the PantryChef NestJS
backend. It owns the HTTP routes, Passport strategies, token issuance, and
configuration that protect every other resource controller in the service.

## Purpose

The auth module implements **JWT-based authentication** for the backend. It
exposes user **registration**, **login**, **profile read/update**, **token
refresh** (re-issuing a token pair for the same session), and **logout**. In
practice it is the entry point that issues the access and refresh tokens that
every other protected controller relies on, validating credentials and minting
the bearer tokens that downstream guards check.
Source: backend/src/auth/auth.controller.ts:L35-L39

The orchestration of credential checks, session creation, and token signing is
centralized in `AuthService`, which the controller delegates to for all of its
behavior.
Source: backend/src/auth/auth.service.ts:L33-L50

## Key components

The module is organized as a thin HTTP adapter (`AuthController`) over an
application service (`AuthService`), with three Passport strategies, a set of
strongly typed payload/response contracts, request DTOs, and namespaced
configuration.

| Component | File | Responsibility |
|---|---|---|
| `AuthController` | `auth.controller.ts` | HTTP adapter annotated `@ApiTags('Auth')` and `@Controller({ path: 'auth', version: '1' })`; maps routes to `AuthService`. Source: backend/src/auth/auth.controller.ts:L35-L39 |
| `AuthService` | `auth.service.ts` | Credential validation via bcryptjs `compare`, token issuance, refresh, logout, and profile update/delete. Source: backend/src/auth/auth.service.ts:L33-L50 (bcrypt compares at Source: backend/src/auth/auth.service.ts:L84 and Source: backend/src/auth/auth.service.ts:L238) |
| `JwtStrategy` | `strategies/jwt.strategy.ts` | Passport strategy named `'jwt'` guarding access tokens; `validate` rejects payloads without `id`. Source: backend/src/auth/strategies/jwt.strategy.ts:L14-L35 |
| `JwtRefreshStrategy` | `strategies/jwt-refresh.strategy.ts` | Passport strategy named `'jwt-refresh'` guarding refresh tokens; `validate` rejects payloads without `sessionId`. Source: backend/src/auth/strategies/jwt-refresh.strategy.ts:L15-L41 |
| `AnonymousStrategy` | `strategies/anonymous.strategy.ts` | `passport-anonymous` pass-through for optional/unauthenticated access. Source: backend/src/auth/strategies/anonymous.strategy.ts:L10-L24 |
| Strategy payload types | `strategies/types/jwt-payload.type.ts`, `strategies/types/jwt-refresh-payload.type.ts` | Typed shapes for the decoded access and refresh JWT claims. Source: backend/src/auth/strategies/types/jwt-payload.type.ts:L5-L10, Source: backend/src/auth/strategies/types/jwt-refresh-payload.type.ts:L4-L8 |
| Config | `config/auth.config.ts`, `config/auth-config.type.ts` | Namespaced `registerAs('auth')` configuration plus its typed shape. Source: backend/src/auth/config/auth.config.ts:L31 |
| DTOs | `dto/` | Request validation models for login, register, and update. Source: backend/src/auth/auth.controller.ts:L15-L18 |
| `LoginResponseType` | `types/login-response.type.ts` | Token/response contract returned by the auth routes. Source: backend/src/auth/types/login-response.type.ts:L8-L13 |

**Note (factual):** only `AuthEmailLoginDto`, `AuthRegisterLoginDto`, and
`AuthUpdateDto` are wired to routes in this controller. The
`AuthConfirmEmailDto`, `AuthForgotPasswordDto`, and `AuthResetPasswordDto`
classes exist in `dto/` but are not referenced by `AuthController`.
Source: backend/src/auth/auth.controller.ts:L15-L18

## Architecture fit

`AuthModule` is wired into the root application module as the **first feature
import**, so it is composed ahead of the other resource modules.
Source: backend/src/app.module.ts:L49

The module imports `UsersModule` (account data) and `SessionModule`
(refresh-token sessions), enables `PassportModule`, and registers
`JwtModule.register({})` (empty options; signing options are supplied per call).
Source: backend/src/auth/auth.module.ts:L23-L29

Other resource controllers enforce authentication with
`@UseGuards(AuthGuard('jwt'))`, which is backed by this module's `JwtStrategy`.
Auth is therefore the shared dependency that makes the rest of the API
protectable. For the system-wide view of how modules compose, see
[`../../../docs/ARCHITECTURE.md`](../../../docs/ARCHITECTURE.md).

## Data models

This module **owns no Mongoose schema**. Instead, it produces the
response/token contracts that the routes and guards exchange:

- `LoginResponseType = Readonly<{ token; refreshToken; tokenExpires; user }>`.
  Source: backend/src/auth/types/login-response.type.ts:L8-L13
- **Important:** the login, register, and refresh routes return
  `Omit<LoginResponseType, 'user'>` — that is, tokens only, with no `user`
  object in the response body.
  Source: backend/src/auth/auth.controller.ts:L56-L80 and
  Source: backend/src/auth/auth.controller.ts:L115
- `JwtPayloadType = { id, sessionId, iat, exp }` — the decoded access-token
  claims. Source: backend/src/auth/strategies/types/jwt-payload.type.ts:L5-L10
- `JwtRefreshPayloadType = { sessionId, iat, exp }` — the decoded refresh-token
  claims.
  Source: backend/src/auth/strategies/types/jwt-refresh-payload.type.ts:L4-L8

For the persisted `User` and `Session` entities that these tokens reference,
see [`../../../docs/DATA_MODELS.md`](../../../docs/DATA_MODELS.md).

## API endpoints / public interface

All endpoints are served under the global `api` prefix as **`/api/auth/*`**
with **no `/v1/` segment**. Although `AuthController` declares `version: '1'`
in its decorator (Source: backend/src/auth/auth.controller.ts:L36-L39), the
bootstrap only calls `app.setGlobalPrefix(...)` and **never calls
`app.enableVersioning()`**, so NestJS does not insert a `/v1/` URI segment.
The canonical documented base is therefore `/api/auth`.
Source: backend/src/main.ts:L30-L35

Full request/response detail (bodies, validation messages, error payloads) is
catalogued in [`../../../docs/API_REFERENCE.md`](../../../docs/API_REFERENCE.md).

| Method & Path | Auth | Success | Source |
|---|---|---|---|
| `POST /api/auth/email/login` | public | 200 | Source: backend/src/auth/auth.controller.ts:L56-L62 |
| `POST /api/auth/email/register` | public | 200 | Source: backend/src/auth/auth.controller.ts:L74-L80 |
| `GET /api/auth/me` | Bearer `jwt` | 200 | Source: backend/src/auth/auth.controller.ts:L91-L97 |
| `POST /api/auth/refresh` | Bearer `jwt-refresh` | 200 (new token pair, same session) | Source: backend/src/auth/auth.controller.ts:L111-L119 |
| `POST /api/auth/logout` | Bearer `jwt` | 204 | Source: backend/src/auth/auth.controller.ts:L130-L138 |
| `PATCH /api/auth/me` | Bearer `jwt` | 200 | Source: backend/src/auth/auth.controller.ts:L149-L158 |
| `DELETE /api/auth/me` | Bearer `jwt` | 204 (calls `service.softDelete`) | Source: backend/src/auth/auth.controller.ts:L167-L175 |

The guards in the table are backed by the module's Passport strategies. Each
strategy is identified by a name that the `AuthGuard(...)` call references:

| Passport name | Guard usage | Purpose | Source |
|---|---|---|---|
| `jwt` | `@UseGuards(AuthGuard('jwt'))` | Validates the access token on protected routes; rejects payloads without `id`. | Source: backend/src/auth/strategies/jwt.strategy.ts:L14-L35 |
| `jwt-refresh` | `@UseGuards(AuthGuard('jwt-refresh'))` | Validates the refresh token on `POST /api/auth/refresh`; rejects payloads without `sessionId`. | Source: backend/src/auth/strategies/jwt-refresh.strategy.ts:L15-L41 |
| `anonymous` | not applied by any guard in this controller | `passport-anonymous` pass-through for optional/unauthenticated access. | Source: backend/src/auth/strategies/anonymous.strategy.ts:L10-L24 |

## Configuration

Configuration is environment-driven through `registerAs('auth')` and is
validated at load time by an `EnvironmentVariablesValidator` that applies
`@IsString()` to each variable.
Source: backend/src/auth/config/auth.config.ts:L9-L31

| Env var | Config key | Meaning | Default |
|---|---|---|---|
| `AUTH_JWT_SECRET` | `auth.secret` | Access-token signing secret | `secret` |
| `AUTH_JWT_TOKEN_EXPIRES_IN` | `auth.expires` | Access-token TTL | `15m` |
| `AUTH_REFRESH_SECRET` | `auth.refreshSecret` | Refresh-token signing secret | `secret_for_refresh` |
| `AUTH_REFRESH_TOKEN_EXPIRES_IN` | `auth.refreshExpires` | Refresh-token TTL | `3650d` |

The environment-variable-to-config-key mapping is defined in the `registerAs`
factory. Source: backend/src/auth/config/auth.config.ts:L35-L40 The shipped
default values come from the example environment file.
Source: backend/env_example:L20-L23

The typed configuration shape is
`AuthConfig { secret?, expires?, refreshSecret?, refreshExpires? }`.
Source: backend/src/auth/config/auth-config.type.ts:L4-L13

The absolute access-token expiry timestamp is computed at issuance time with
the `ms()` helper applied to `auth.expires` (`Date.now() + ms(tokenExpiresIn)`).
Source: backend/src/auth/auth.service.ts:L342-L347

**SECURITY NOTE:** the shipped defaults `AUTH_JWT_SECRET=secret` and
`AUTH_REFRESH_SECRET=secret_for_refresh` are weak placeholder secrets and must
be replaced with strong values before any non-local deployment.
Source: backend/env_example:L20-L23 Full guidance is in
[`../../../docs/DEPLOYMENT.md`](../../../docs/DEPLOYMENT.md).

## Data flow

On **login**, `AuthController` forwards the credentials to
`AuthService.validateLogin`, which looks the user up by email through
`UsersService`, verifies the password with `bcrypt.compare`, creates a session
through `SessionService`, and then signs an access token and a refresh token in
parallel before returning the token bundle (with the `user` field omitted).
Source: backend/src/auth/auth.service.ts:L52-L116

On **refresh**, the `jwt-refresh` guard first validates the incoming refresh
token; `AuthService.refreshToken` then loads the session by `sessionId` and
issues a fresh access/refresh pair tied to that same session. The previously
issued refresh JWT is **not** revoked; it remains valid until it expires or the
session is deleted.
Source: backend/src/auth/auth.service.ts:L283-L304

```mermaid
sequenceDiagram
    actor Client
    participant C as AuthController
    participant S as AuthService
    participant U as UsersService
    participant Sess as SessionService
    participant UR as UserRepository
    participant SR as SessionRepository
    participant DB as Mongoose Models (MongoDB)
    participant J as JwtService

    Note over Client,J: Login — POST /api/auth/email/login
    Client->>C: email + password
    C->>S: validateLogin(loginDto)
    S->>U: findOne({ email })
    U->>UR: findOne({ email })
    UR->>DB: usersModel.findOne({ email })
    DB-->>UR: user document
    UR-->>U: User
    U-->>S: user
    S->>S: bcrypt.compare(password, user.password)
    S->>Sess: create({ user })
    Sess->>SR: create(session)
    SR->>DB: new sessionModel(...).save()
    DB-->>SR: session document
    SR-->>Sess: Session
    Sess-->>S: session
    S->>J: signAsync(access 15m) + signAsync(refresh 3650d)
    J-->>S: token, refreshToken
    S-->>C: { token, refreshToken, tokenExpires }
    C-->>Client: 200 OK (user omitted)

    Note over Client,J: Refresh — POST /api/auth/refresh (jwt-refresh guard)
    Client->>C: Bearer refresh token
    C->>S: refreshToken({ sessionId })
    S->>Sess: findOne({ id: sessionId })
    Sess->>SR: findOne({ id })
    SR->>DB: sessionModel.findById(id)
    DB-->>SR: session document
    SR-->>Sess: Session
    Sess-->>S: session
    S->>J: signAsync(new access + refresh)
    J-->>S: new token pair (prior refresh JWT not revoked)
    S-->>C: { token, refreshToken, tokenExpires }
    C-->>Client: 200 OK
```

Diagram sources: login flow Source: backend/src/auth/auth.service.ts:L52-L116;
token signing and `ms()` expiry computation
Source: backend/src/auth/auth.service.ts:L337-L378; refresh flow
Source: backend/src/auth/auth.service.ts:L283-L304; the `jwt-refresh` guard on
the refresh route Source: backend/src/auth/auth.controller.ts:L111-L119. The
`JwtRefreshStrategy` guard validates the refresh token (rejecting payloads
without `sessionId`) before `refreshToken` runs.
Source: backend/src/auth/strategies/jwt-refresh.strategy.ts:L33-L41

## Design patterns used

- **Passport strategy pattern** — three strategies (`jwt`, `jwt-refresh`,
  `anonymous`) encapsulate the distinct authentication mechanisms.
  Source: backend/src/auth/strategies/jwt.strategy.ts:L14,
  Source: backend/src/auth/strategies/jwt-refresh.strategy.ts:L15-L18,
  Source: backend/src/auth/strategies/anonymous.strategy.ts:L10
- **JWT issuance via `@nestjs/jwt`** — `JwtModule.register({})` provides the
  `JwtService`, with signing options (secret, `expiresIn`) supplied per call.
  Source: backend/src/auth/auth.module.ts:L28,
  Source: backend/src/auth/auth.service.ts:L349-L374
- **Guard-based authorization** — routes opt into protection with
  `@UseGuards(AuthGuard('jwt' | 'jwt-refresh'))`.
  Source: backend/src/auth/auth.controller.ts:L93,L113,L132,L151,L169
- **Session-backed refresh re-issuance** — refresh issues a new token pair tied
  to the existing session; it does not revoke the prior refresh JWT, which stays
  valid until it expires or the session is deleted.
  Source: backend/src/auth/auth.service.ts:L283-L304
- **DTO validation** — request bodies are validated by `class-validator` /
  `class-transformer` decorated DTOs.
  Source: backend/src/auth/dto/auth-email-login.dto.ts:L9-L20
- **Namespaced config via `registerAs`** — auth settings are grouped under the
  `auth` namespace. Source: backend/src/auth/config/auth.config.ts:L31

## Known limitations / gaps

- **SECURITY NOTE:** the default JWT secrets are insecure placeholders
  (`AUTH_JWT_SECRET=secret`, `AUTH_REFRESH_SECRET=secret_for_refresh`) and are
  unsafe outside local development.
  Source: backend/env_example:L20,L22 See
  [`../../../docs/DEPLOYMENT.md`](../../../docs/DEPLOYMENT.md).
- **KNOWN ISSUE:** the refresh-token TTL is **3650d (~10 years)**, an unusually
  long-lived credential that widens the window of exposure if a refresh token
  leaks. Source: backend/env_example:L23
- **KNOWN ISSUE:** `DELETE /api/auth/me` delegates to `AuthService.softDelete`,
  which calls `UsersService.softDelete`; despite the `softDelete` name, the
  users repository **hard-deletes** the record (`deleteOne`).
  Source: backend/src/auth/auth.service.ts:L312-L316,
  Source: backend/src/auth/auth.controller.ts:L167-L175 The users hard-delete
  behavior is cross-referenced in
  [`../../../docs/DATA_MODELS.md`](../../../docs/DATA_MODELS.md).
- **KNOWN ISSUE:** `AnonymousStrategy` is registered as a provider but is not
  applied by any guard within this module's controller, so it has no effect on
  the auth routes as written.
  Source: backend/src/auth/auth.module.ts:L31,
  Source: backend/src/auth/auth.controller.ts:L91-L175

## Local development

The auth routes are exercised over HTTP against a running backend (default port
`3000`). Source: backend/env_example:L2 A typical flow is to register, then log
in to obtain a bearer token, then attach that token to guarded routes.

Register a new account and then log in to receive the token bundle:

```bash
# 1. Register (public)
curl -X POST http://localhost:3000/api/auth/email/register \
  -H 'Content-Type: application/json' \
  -d '{"email":"test1@example.com","password":"secret6"}'

# 2. Log in (public) — returns { token, refreshToken, tokenExpires }
curl -X POST http://localhost:3000/api/auth/email/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"test1@example.com","password":"secret6"}'
```

Attach the access token as a bearer credential to call a guarded route:

```http
GET /api/auth/me HTTP/1.1
Host: localhost:3000
Authorization: Bearer <access-token>
```

To obtain a fresh token pair, send the **refresh** token (not the access token)
as the bearer credential to the refresh route:

```http
POST /api/auth/refresh HTTP/1.1
Host: localhost:3000
Authorization: Bearer <refresh-token>
```

For full backend setup — environment configuration, Docker Compose, and
database seeding — see the backend root README
[`../../README.md`](../../README.md). For the complete endpoint catalogue
including request/response schemas and error codes, see
[`../../../docs/API_REFERENCE.md`](../../../docs/API_REFERENCE.md).
