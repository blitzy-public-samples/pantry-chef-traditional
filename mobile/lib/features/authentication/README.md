# Authentication Feature

The `authentication/` feature provides the user-facing sign-in surface of the
PantryChef mobile client. For the broader client overview, see the
[mobile client README](../../../README.md).

## Purpose

This feature drives the **login and signup flow** for the PantryChef mobile
client. It collects email/password credentials, validates them on the client,
exchanges them with the backend for a token pair, and stores those tokens on the
device so the rest of the app can issue authenticated requests. The flow is
orchestrated with the **BLoC** pattern: UI events feed a single `AuthBloc`, which
delegates the network exchange to dedicated use cases.

On a successful login or signup, the access token and refresh token returned by
the backend are persisted client-side through `SharedPreferences` using
`saveAccessToken` and `saveRefreshToken`.
Source: mobile/lib/features/authentication/domain/usecases/login.usecase.dart:L14-L16
Source: mobile/lib/core/utils/shared_preferences_helper.dart:L12-L19

## Key components

| Component | Layer | Responsibility | Source |
|-----------|-------|----------------|--------|
| `AuthBloc` | presentation | Orchestrates form changes, login, and signup; emits `AuthState`. | Source: mobile/lib/features/authentication/presentation/bloc/auth/auth_bloc.dart:L14 |
| `AuthEvent` | presentation | Sealed event hierarchy: `AuthFormValueChanged`, `LoginActionSent`, `SignupActionSend`. | Source: mobile/lib/features/authentication/presentation/bloc/auth/auth_event.dart:L3-L22 |
| `AuthState` | presentation | Immutable form/flow state (`email`, `password`, `errorMessage`, `success`, `emailWrongFormat`, `passwordToShort`, `isFetching`). | Source: mobile/lib/features/authentication/presentation/bloc/auth/auth_state.dart:L3-L10 |
| `LoginUsecase` | domain | Calls `repo.login(dto)`, then persists the returned tokens. | Source: mobile/lib/features/authentication/domain/usecases/login.usecase.dart:L9-L17 |
| `SignupUsecase` | domain | Calls `repo.signup(dto)`, then persists the returned tokens. | Source: mobile/lib/features/authentication/domain/usecases/signup.usecase.dart:L9-L17 |
| `AuthRepository` (interface) | domain | Abstract `login`/`signup` contract returning `AuthResponse`. | Source: mobile/lib/features/authentication/domain/repositories/auth.repository.dart:L4-L8 |
| `AuthResponse` (entity) | domain | Token-response model holding `token` + `refreshToken`. | Source: mobile/lib/features/authentication/domain/entities/auth_response.entity.dart:L6-L13 |
| `AuthRepositoryImpl` | data | Concrete repository; calls `AuthenticationApi`, maps to `AuthResponse`. | Source: mobile/lib/features/authentication/data/repositories/auth.repository.dart:L6-L19 |
| `AuthenticationApi` | data | Dio-backed HTTP calls that POST to the login/register endpoints. | Source: mobile/lib/features/authentication/data/api/authentication.api.dart:L7-L29 |
| `AuthDto` | data | Request DTO carrying `email` + `password`. | Source: mobile/lib/features/authentication/data/dto/auth.dto.dart:L6-L13 |
| `AuthenticationStart` | presentation | Landing screen; routes to the signup and login screens. | Source: mobile/lib/features/authentication/presentation/widgets/screens/authentication_start.dart:L10-L56 |
| `Login` | presentation | Login form screen; dispatches `LoginActionSent`. | Source: mobile/lib/features/authentication/presentation/widgets/screens/login.dart:L15-L122 |
| `Signup` | presentation | Signup form screen; dispatches `SignupActionSend`. | Source: mobile/lib/features/authentication/presentation/widgets/screens/signup.dart:L14-L121 |

## Architecture fit

The feature follows the client's **clean-architecture** convention, splitting
responsibilities across three layers under
`mobile/lib/features/authentication/`:

- **`domain/`** holds the framework-agnostic core: the `AuthResponse` entity, the
  abstract `AuthRepository` contract, and the `LoginUsecase`/`SignupUsecase` use
  cases.
  Source: mobile/lib/features/authentication/domain/repositories/auth.repository.dart:L4-L8
- **`data/`** holds the outward-facing implementation: `AuthenticationApi`
  (Dio), the `AuthDto` request DTO, and `AuthRepositoryImpl`, which satisfies the
  domain contract.
  Source: mobile/lib/features/authentication/data/repositories/auth.repository.dart:L6-L19
- **`presentation/`** holds `AuthBloc` plus the `AuthenticationStart`, `Login`,
  and `Signup` screens.
  Source: mobile/lib/features/authentication/presentation/bloc/auth/auth_bloc.dart:L14

Cross-cutting dependencies are resolved through the `get_it` service locator: the
`AuthenticationApi` obtains its `Dio` from `getIt<DioClient>()`, and the use cases
read tokens out of `getIt<SharedPreferencesHelper>()`.
Source: mobile/lib/features/authentication/data/api/authentication.api.dart:L11
Source: mobile/lib/features/authentication/domain/usecases/login.usecase.dart:L14

Both use cases implement the shared `UseCaseWithParams<void, AuthDto>` contract,
keeping the feature consistent with the rest of the codebase.
Source: mobile/lib/core/utils/usercase.dart:L5-L7

For the full system picture (backend ↔ mobile ↔ MongoDB, cross-cutting concerns,
and the bootstrap sequence), see [docs/ARCHITECTURE.md](../../../../docs/ARCHITECTURE.md).

## Data models

The feature exchanges two `@JsonSerializable` models; both rely on `build_runner`
codegen (the generated `*.g.dart` parts are build output, not committed source).

- **`AuthResponse`** — the token-response entity returned by the backend, holding
  a `token` (access token) and a `refreshToken`, both `final String`. It exposes
  a `factory AuthResponse.fromJson(...)` for decoding.
  Source: mobile/lib/features/authentication/domain/entities/auth_response.entity.dart:L6-L13
- **`AuthDto`** — the login/register request DTO carrying a `final String email`
  and a `final String password`, with a `toJson()` used by `AuthenticationApi`.
  Source: mobile/lib/features/authentication/data/dto/auth.dto.dart:L6-L13

For the consolidated field tables across all backend and mobile models, see
[docs/DATA_MODELS.md](../../../../docs/DATA_MODELS.md).

## API endpoints / public interface

The feature consumes the backend authentication surface. Routes resolve under
`/api/<resource>` (the mobile `endpoints.dart` constants confirm there is no
`/v1/` segment).

| Method | Path | Purpose | Source |
|--------|------|---------|--------|
| `POST` | `/api/auth/email/login` | Authenticate with email + password; returns a token pair. | Source: mobile/lib/core/constants/endpoints.dart:L12 |
| `POST` | `/api/auth/email/register` | Register a new account with email + password. | Source: mobile/lib/core/constants/endpoints.dart:L13 |
| `POST` | `/api/auth/refresh` | Exchange a refresh token for a new access token. | Source: mobile/lib/core/constants/endpoints.dart:L11 |
| `POST` | `/api/auth/logout` | Invalidate the current session. | Source: mobile/lib/core/constants/endpoints.dart:L14 |
| `GET` | `/api/auth/me` | Fetch the authenticated user profile. | Source: mobile/lib/core/constants/endpoints.dart:L15 |

The feature's own `AuthenticationApi` calls only `login` and `signup` — the login
and register routes.
Source: mobile/lib/features/authentication/data/api/authentication.api.dart:L14-L28
The `refresh`, `logout`, and `me` constants belong to the wider auth surface used
app-wide (for example, by the Dio refresh interceptor).
Source: mobile/lib/core/constants/endpoints.dart:L11-L15

Access tokens last 15 minutes and refresh tokens last 3650 days on the backend;
the full REST contract (request/response DTOs, status codes, and guards) is the
authority and is documented in
[docs/API_REFERENCE.md](../../../../docs/API_REFERENCE.md).

## Configuration

- **API base URL.** Endpoint paths are built on `EnvConfig.apiBaseUrl`, a
  compile-time value resolved via
  `String.fromEnvironment('API_BASE_URL', defaultValue: 'http://192.168.2.20:3000/api')`.
  Source: mobile/lib/env_config.dart:L2
  The `Endpoints` class composes every route on top of this base.
  Source: mobile/lib/core/constants/endpoints.dart:L6
- **Token persistence.** Access and refresh tokens are written through
  `SharedPreferencesHelper` (`saveAccessToken`/`saveRefreshToken`).
  Source: mobile/lib/core/utils/shared_preferences_helper.dart:L12-L19
- **Routing.** The signup destination is the misspelled route constant `singup`
  (sic) — `static const String singup = '/singup';` — which is a stable
  identifier and is intentionally preserved as-is.
  Source: mobile/lib/core/constants/navigation.dart:L6
  The landing screen pushes this route when the user chooses to register.
  Source: mobile/lib/features/authentication/presentation/widgets/screens/authentication_start.dart:L36

## Data flow

Both the login and signup paths share the same pipeline — a screen dispatches an
event to `AuthBloc`, which validates input and invokes the matching use case down
through the repository, API, and Dio client, finally persisting the returned
tokens.

```mermaid
sequenceDiagram
    participant U as User
    participant Screen as Login / Signup Screen
    participant Bloc as AuthBloc
    participant UC as LoginUsecase / SignupUsecase
    participant Repo as AuthRepositoryImpl
    participant Api as AuthenticationApi
    participant Dio as DioClient
    participant API as Backend API
    participant SP as SharedPreferences

    U->>Screen: Enter email and password
    Screen->>Bloc: AuthFormValueChanged(email, password)
    U->>Screen: Tap Login or Signup
    Screen->>Bloc: LoginActionSent / SignupActionSend
    Note over Bloc: Validate email via RegExps.email; signup also requires password length 6 or more
    Bloc->>UC: call(AuthDto(email, password))
    UC->>Repo: login(dto) / signup(dto)
    Repo->>Api: login(dto) / signup(dto)
    Api->>Dio: POST /api/auth/email/login or /api/auth/email/register
    Dio->>API: HTTP request
    API-->>Dio: 200 OK with token and refreshToken
    Dio-->>Api: response.data
    Api-->>Repo: Decoded JSON map
    Repo-->>UC: AuthResponse.fromJson(response)
    UC->>SP: saveAccessToken / saveRefreshToken
    UC-->>Bloc: Use case completes
    Bloc-->>Screen: AuthState(success: true)
    Screen->>Screen: Navigate to Navigation.home
```

Source: mobile/lib/features/authentication/presentation/bloc/auth/auth_bloc.dart:L28-L69, mobile/lib/features/authentication/data/api/authentication.api.dart:L14-L28, mobile/lib/features/authentication/domain/usecases/login.usecase.dart:L11-L16

## Design patterns used

- **BLoC (event/state).** `AuthBloc` consumes `AuthEvent`s and emits `AuthState`,
  centralizing form validation and the async login/signup logic.
  Source: mobile/lib/features/authentication/presentation/bloc/auth/auth_bloc.dart:L14
- **Repository pattern.** The domain `AuthRepository` interface decouples use
  cases from transport details, while the data-layer `AuthRepositoryImpl` provides
  the concrete implementation.
  Source: mobile/lib/features/authentication/domain/repositories/auth.repository.dart:L4
  Source: mobile/lib/features/authentication/data/repositories/auth.repository.dart:L6
- **Use Case pattern.** `LoginUsecase` and `SignupUsecase` each implement
  `UseCaseWithParams<void, AuthDto>`, encapsulating one unit of application logic.
  Source: mobile/lib/core/utils/usercase.dart:L5-L7
- **Dependency injection via `get_it`.** Collaborators such as `DioClient` and
  `SharedPreferencesHelper` are resolved from the `getIt` locator rather than
  constructed inline.
  Source: mobile/lib/features/authentication/data/api/authentication.api.dart:L11
  Source: mobile/lib/features/authentication/domain/usecases/login.usecase.dart:L14

## Known limitations / gaps

- The signup route constant is misspelled as `singup` (sic). It is a **stable
  identifier preserved as-is** — documented here, never renamed.
  Source: mobile/lib/core/constants/navigation.dart:L6
- KNOWN ISSUE: Tokens are persisted **client-side** in `SharedPreferences` as
  plain key/value entries with no additional at-rest protection.
  Source: mobile/lib/core/utils/shared_preferences_helper.dart:L12-L19
- SECURITY NOTE: The shared Dio client attaches a verbose `LogInterceptor` that
  logs `Authorization` bearer tokens in all builds. This concern is documented in
  [docs/ARCHITECTURE.md](../../../../docs/ARCHITECTURE.md); it is cross-referenced
  here rather than restated, and the code is intentionally left unchanged.

## Local development

1. Install dependencies:

   ```bash
   flutter pub get
   ```

2. Run code generation for the `@JsonSerializable` models (`AuthDto`,
   `AuthResponse`), which produces `auth.dto.g.dart` and
   `auth_response.entity.g.dart`:

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. Launch the app, overriding the API base URL for your environment:

   ```bash
   flutter run --dart-define API_BASE_URL=http://<host>:3000/api
   ```

   Source: mobile/lib/env_config.dart:L2

   `<host>` must be reachable from the device or emulator — use a LAN IP for a
   physical device, or `10.0.2.2` to reach the host machine from the Android
   emulator.
