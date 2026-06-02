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
Source: mobile/lib/features/authentication/domain/usecases/login.usecase.dart:L35-L36
Source: mobile/lib/features/authentication/domain/usecases/signup.usecase.dart:L35-L36
Source: mobile/lib/core/utils/shared_preferences_helper.dart:L22-L23,L38-L39

## Key components

| Component | Layer | Responsibility | Source |
|-----------|-------|----------------|--------|
| `AuthBloc` | presentation | Orchestrates form changes, login, and signup; emits `AuthState`. | Source: mobile/lib/features/authentication/presentation/bloc/auth/auth_bloc.dart:L27-L109 |
| `AuthEvent` | presentation | Sealed event hierarchy: `AuthFormValueChanged`, `LoginActionSent`, `SignupActionSend`. | Source: mobile/lib/features/authentication/presentation/bloc/auth/auth_event.dart:L4-L28 |
| `AuthState` | presentation | Immutable form/flow state (`email`, `password`, `errorMessage`, `success`, `emailWrongFormat`, `passwordToShort`, `isFetching`). | Source: mobile/lib/features/authentication/presentation/bloc/auth/auth_state.dart:L8-L22 |
| `LoginUsecase` | domain | Calls `repo.login(dto)`, then persists the returned tokens. | Source: mobile/lib/features/authentication/domain/usecases/login.usecase.dart:L16-L37 |
| `SignupUsecase` | domain | Calls `repo.signup(dto)`, then persists the returned tokens. | Source: mobile/lib/features/authentication/domain/usecases/signup.usecase.dart:L16-L37 |
| `AuthRepository` (interface) | domain | Abstract `login`/`signup` contract returning `AuthResponse`. | Source: mobile/lib/features/authentication/domain/repositories/auth.repository.dart:L15-L26 |
| `AuthResponse` (entity) | domain | Token-response model holding `token` + `refreshToken`. | Source: mobile/lib/features/authentication/domain/entities/auth_response.entity.dart:L12-L26 |
| `AuthRepositoryImpl` | data | Concrete repository; calls `AuthenticationApi`, maps to `AuthResponse`. | Source: mobile/lib/features/authentication/data/repositories/auth.repository.dart:L13-L39 |
| `AuthenticationApi` | data | Dio-backed HTTP calls that POST to the login/register endpoints. | Source: mobile/lib/features/authentication/data/api/authentication.api.dart:L13-L51 |
| `AuthDto` | data | Request DTO carrying `email` + `password`. | Source: mobile/lib/features/authentication/data/dto/auth.dto.dart:L14-L28 |
| `AuthenticationStart` | presentation | Landing screen; routes to the signup and login screens. | Source: mobile/lib/features/authentication/presentation/widgets/screens/authentication_start.dart:L19 |
| `Login` | presentation | Login form screen; dispatches `LoginActionSent`. | Source: mobile/lib/features/authentication/presentation/widgets/screens/login.dart:L23 |
| `Signup` | presentation | Signup form screen; dispatches `SignupActionSend`. | Source: mobile/lib/features/authentication/presentation/widgets/screens/signup.dart:L22 |

## Architecture fit

The feature follows the client's **clean-architecture** convention, splitting
responsibilities across three layers under
`mobile/lib/features/authentication/`:

- **`domain/`** holds the framework-agnostic core: the `AuthResponse` entity, the
  abstract `AuthRepository` contract, and the `LoginUsecase`/`SignupUsecase` use
  cases.
  Source: mobile/lib/features/authentication/domain/repositories/auth.repository.dart:L15-L26
- **`data/`** holds the outward-facing implementation: `AuthenticationApi`
  (Dio), the `AuthDto` request DTO, and `AuthRepositoryImpl`, which satisfies the
  domain contract.
  Source: mobile/lib/features/authentication/data/repositories/auth.repository.dart:L13-L39
- **`presentation/`** holds `AuthBloc` plus the `AuthenticationStart`, `Login`,
  and `Signup` screens.
  Source: mobile/lib/features/authentication/presentation/bloc/auth/auth_bloc.dart:L27

Cross-cutting dependencies are resolved through the `get_it` service locator: the
`AuthenticationApi` obtains its `Dio` from `getIt<DioClient>()`, and the use cases
read tokens out of `getIt<SharedPreferencesHelper>()`.
Source: mobile/lib/features/authentication/data/api/authentication.api.dart:L19
Source: mobile/lib/features/authentication/domain/usecases/login.usecase.dart:L33

Both use cases implement the shared `UseCaseWithParams<void, AuthDto>` contract,
keeping the feature consistent with the rest of the codebase.
Source: mobile/lib/core/utils/usercase.dart:L19-L23

For the full system picture (backend ↔ mobile ↔ MongoDB, cross-cutting concerns,
and the bootstrap sequence), see [docs/ARCHITECTURE.md](../../../../docs/ARCHITECTURE.md).

## Data models

The feature exchanges two `@JsonSerializable` models; both rely on `build_runner`
codegen (the generated `*.g.dart` parts are build output, not committed source).

- **`AuthResponse`** — the token-response entity returned by the backend, holding
  a `token` (access token) and a `refreshToken`, both `final String`. It exposes
  a `factory AuthResponse.fromJson(...)` for decoding.
  Source: mobile/lib/features/authentication/domain/entities/auth_response.entity.dart:L12-L26
- **`AuthDto`** — the login/register request DTO carrying a `final String email`
  and a `final String password`, with a `toJson()` used by `AuthenticationApi`.
  Source: mobile/lib/features/authentication/data/dto/auth.dto.dart:L14-L28

For the consolidated field tables across all backend and mobile models, see
[docs/DATA_MODELS.md](../../../../docs/DATA_MODELS.md).

## API endpoints / public interface

The feature consumes the backend authentication surface. Routes resolve under
`/api/<resource>` (the mobile `endpoints.dart` constants confirm there is no
`/v1/` segment).

| Method | Path | Purpose | Source |
|--------|------|---------|--------|
| `POST` | `/api/auth/email/login` | Authenticate with email + password; returns a token pair. | Source: mobile/lib/core/constants/endpoints.dart:L29 |
| `POST` | `/api/auth/email/register` | Register a new account with email + password. | Source: mobile/lib/core/constants/endpoints.dart:L34 |
| `POST` | `/api/auth/refresh` | Exchange a refresh token for a new access token. | Source: mobile/lib/core/constants/endpoints.dart:L27 |
| `POST` | `/api/auth/logout` | Invalidate the current session. | Source: mobile/lib/core/constants/endpoints.dart:L36 |
| `GET` | `/api/auth/me` | Fetch the authenticated user profile. | Source: mobile/lib/core/constants/endpoints.dart:L38 |

The feature's own `AuthenticationApi` calls only `login` and `signup` — the login
and register routes.
Source: mobile/lib/features/authentication/data/api/authentication.api.dart:L27-L51
The `refresh`, `logout`, and `me` constants belong to the wider auth surface used
app-wide (for example, by the Dio refresh interceptor).
Source: mobile/lib/core/constants/endpoints.dart:L27-L38

Access tokens last 15 minutes and refresh tokens last 3650 days on the backend.
Source: backend/env_example:L21
Source: backend/env_example:L23
The full REST contract (request/response DTOs, status codes, and guards) is the
authority and is documented in
[docs/API_REFERENCE.md](../../../../docs/API_REFERENCE.md).

## Configuration

- **API base URL.** Endpoint paths are built on `EnvConfig.apiBaseUrl`, a
  compile-time value resolved via
  `String.fromEnvironment('API_BASE_URL', defaultValue: 'http://192.168.2.20:3000/api')`.
  Source: mobile/lib/env_config.dart:L19
  The `Endpoints` class composes every route on top of this base.
  Source: mobile/lib/core/constants/endpoints.dart:L19
- **Token persistence.** Access and refresh tokens are written through
  `SharedPreferencesHelper` (`saveAccessToken`/`saveRefreshToken`).
  Source: mobile/lib/core/utils/shared_preferences_helper.dart:L22-L23,L38-L39
- **Routing.** The signup destination is the misspelled route constant `singup`
  (sic) — `static const String singup = '/singup';` — which is a stable
  identifier and is intentionally preserved as-is.
  Source: mobile/lib/core/constants/navigation.dart:L17
  The landing screen pushes this route when the user chooses to register.
  Source: mobile/lib/features/authentication/presentation/widgets/screens/authentication_start.dart:L55

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

Source: mobile/lib/features/authentication/presentation/bloc/auth/auth_bloc.dart:L33-L108
Source: mobile/lib/features/authentication/data/api/authentication.api.dart:L27-L51
Source: mobile/lib/features/authentication/domain/usecases/login.usecase.dart:L24-L36

## Design patterns used

- **BLoC (event/state).** `AuthBloc` consumes `AuthEvent`s and emits `AuthState`,
  centralizing form validation and the async login/signup logic.
  Source: mobile/lib/features/authentication/presentation/bloc/auth/auth_bloc.dart:L27
- **Repository pattern.** The domain `AuthRepository` interface decouples use
  cases from transport details, while the data-layer `AuthRepositoryImpl` provides
  the concrete implementation.
  Source: mobile/lib/features/authentication/domain/repositories/auth.repository.dart:L15
  Source: mobile/lib/features/authentication/data/repositories/auth.repository.dart:L13
- **Use Case pattern.** `LoginUsecase` and `SignupUsecase` each implement
  `UseCaseWithParams<void, AuthDto>`, encapsulating one unit of application logic.
  Source: mobile/lib/core/utils/usercase.dart:L19-L23
- **Dependency injection via `get_it`.** Collaborators such as `DioClient` and
  `SharedPreferencesHelper` are resolved from the `getIt` locator rather than
  constructed inline.
  Source: mobile/lib/features/authentication/data/api/authentication.api.dart:L19
  Source: mobile/lib/features/authentication/domain/usecases/login.usecase.dart:L33

## Known limitations / gaps

- The signup route constant is misspelled as `singup` (sic). It is a **stable
  identifier preserved as-is** — documented here, never renamed.
  Source: mobile/lib/core/constants/navigation.dart:L17
- KNOWN ISSUE: Tokens are persisted **client-side** in `SharedPreferences` as
  plain key/value entries with no additional at-rest protection.
  Source: mobile/lib/core/utils/shared_preferences_helper.dart:L22-L23,L38-L39
- SECURITY NOTE: The shared Dio client attaches a verbose `LogInterceptor`
  unconditionally with `requestHeader: true`, so the `Authorization: Bearer
  <token>` header is written to logs in all builds, including release. The code
  is intentionally left unchanged (additive-only task); the system-wide context
  is also captured in
  [docs/ARCHITECTURE.md](../../../../docs/ARCHITECTURE.md).
  Source: mobile/lib/core/utils/dio_client.dart:L42-L53

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

   Source: mobile/lib/env_config.dart:L19

   `<host>` must be reachable from the device or emulator — use a LAN IP for a
   physical device, or `10.0.2.2` to reach the host machine from the Android
   emulator.
