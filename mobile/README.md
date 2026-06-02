# PantryChef Mobile

PantryChef Mobile is the Flutter / Dart client of the PantryChef monorepo; its
Dart package name is `pantry_chef` (`Source: mobile/pubspec.yaml:L1`). The app
lets a user track the ingredients in their pantry, browse and match recipes
against the ingredients on hand, capture ingredients through the device camera
with AI assistance, and manage their profile and preferences.

The mobile client is the front half of a monorepo whose other half is a NestJS
+ MongoDB REST backend; the client talks to that backend over HTTP and targets
an API base URL defined as a compile-time constant
(`Source: mobile/lib/env_config.dart:L19`). State management uses the BLoC
pattern, networking uses Dio, dependency injection uses `get_it`, and local
persistence uses `shared_preferences` together with `hydrated_bloc`
(`Source: mobile/pubspec.yaml:L34-L35,L39,L43,L50`).

## Tech stack

Versions are reproduced exactly from the manifest
(`Source: mobile/pubspec.yaml:L21,L30,L58`).

| Category | Package | Version | Source |
|----------|---------|---------|--------|
| Runtime | Flutter / Dart SDK | `^3.5.1` | `mobile/pubspec.yaml:L22` |
| State management | `bloc` | `^8.1.4` | `mobile/pubspec.yaml:L38` |
| State management | `flutter_bloc` | `^8.1.6` | `mobile/pubspec.yaml:L39` |
| State management | `hydrated_bloc` | `^9.1.5` | `mobile/pubspec.yaml:L43` |
| State management | `equatable` | `^2.0.5` | `mobile/pubspec.yaml:L41` |
| Networking | `dio` | `^5.7.0` | `mobile/pubspec.yaml:L50` |
| Dependency injection | `get_it` | `^8.0.2` | `mobile/pubspec.yaml:L34` |
| Serialization | `json_annotation` | `^4.9.0` | `mobile/pubspec.yaml:L40` |
| Serialization (dev) | `json_serializable` | `^6.7.1` | `mobile/pubspec.yaml:L62` |
| Codegen (dev) | `build_runner` | `^2.4.6` | `mobile/pubspec.yaml:L63` |
| Persistence | `shared_preferences` | `^2.3.2` | `mobile/pubspec.yaml:L35` |
| Camera / media | `camera` | `^0.11.0+2` | `mobile/pubspec.yaml:L46` |
| Camera / media | `cached_network_image` | `^3.4.1` | `mobile/pubspec.yaml:L45` |
| UI | `flutter_platform_widgets` | `^7.0.1` | `mobile/pubspec.yaml:L33` |
| UI | `shimmer` | `^3.0.0` | `mobile/pubspec.yaml:L44` |
| UI | `loader_overlay` | `^4.0.3` | `mobile/pubspec.yaml:L42` |
| UI | `grouped_list` | `^6.0.0` | `mobile/pubspec.yaml:L51` |
| Startup / paths / i18n | `flutter_native_splash` | `^2.4.2` | `mobile/pubspec.yaml:L47` |
| Startup / paths / i18n | `path` | `^1.8.3` | `mobile/pubspec.yaml:L48` |
| Startup / paths / i18n | `path_provider` | `^2.1.5` | `mobile/pubspec.yaml:L49` |
| Startup / paths / i18n | `cupertino_icons` | `^1.0.8` | `mobile/pubspec.yaml:L55` |
| Startup / paths / i18n | `intl` | `any` | `mobile/pubspec.yaml:L56` |
| Startup / paths / i18n | `flutter_localizations` | Flutter SDK | `mobile/pubspec.yaml:L36-L37` |
| Dev tooling | `flutter_launcher_icons` | `^0.14.1` | `mobile/pubspec.yaml:L61` |
| Dev tooling | `flutter_lints` | `^4.0.0` | `mobile/pubspec.yaml:L76` |

## Project structure

The client follows a feature-first clean architecture. The entrypoint is
`lib/main.dart`, and the compile-time API base URL lives in `lib/env_config.dart`
(`Source: mobile/lib/env_config.dart:L19`). Shared infrastructure sits under
`lib/core/` — dependency injection (`get_it`) and the Dio HTTP client live in
`core/utils/`, while route, endpoint, and status-code constants live in
`core/constants/`
(`Source: mobile/lib/core/utils/service_locator.dart:L28, mobile/lib/core/utils/dio_client.dart:L11, mobile/lib/core/constants/endpoints.dart:L8`). Each feature under
`lib/features/<feature>/` is split into `domain/` (models, repository
interfaces, use cases), `data/` (api clients, DTOs, repository
implementations), and `presentation/` (BLoCs, screens, widgets).

```text
lib/
├── main.dart                 # app entrypoint
├── env_config.dart           # compile-time API_BASE_URL
├── l10n/                     # localization resources
├── core/                     # shared infrastructure
│   ├── utils/                # service_locator (get_it), dio_client, helpers
│   ├── constants/            # endpoints, navigation routes, status codes
│   ├── data/                 # shared data layer
│   ├── domain/               # shared domain layer
│   ├── presentation/         # shared widgets (App root)
│   ├── styles/               # shared theming
│   └── navigation.dart       # navigation helpers
└── features/                 # feature modules
    ├── authentication/       # domain / data / presentation
    ├── pantry/
    ├── recipe/
    ├── ingredient/
    └── profile/
```

At startup, `main()` runs inside `runZonedGuarded`, preserves the native splash
screen, builds `HydratedBloc.storage`, locks the device to portrait
orientation, and calls `setupLocator()` to register dependencies before
`runApp` (`Source: mobile/lib/main.dart:L25-L34`). See
[`../docs/ARCHITECTURE.md`](../docs/ARCHITECTURE.md) for the full architecture
picture.

## Feature map

Each feature module ships its own README:

- **Authentication** — login / signup and JWT token persistence.
  [`lib/features/authentication/README.md`](lib/features/authentication/README.md)
- **Pantry** — pantry item list, add, and edit.
  [`lib/features/pantry/README.md`](lib/features/pantry/README.md)
- **Recipe** — recipe browse, match, and detail.
  [`lib/features/recipe/README.md`](lib/features/recipe/README.md)
- **Ingredient** — ingredient search plus camera / AI capture (the mobile
  feature directory is correctly spelled `ingredient/`).
  [`lib/features/ingredient/README.md`](lib/features/ingredient/README.md)
- **Profile** — profile and preferences backed by `HydratedBloc`.
  [`lib/features/profile/README.md`](lib/features/profile/README.md)

## Getting started

The client requires a Dart SDK satisfying `^3.5.1`
(`Source: mobile/pubspec.yaml:L22`).

1. Install dependencies:

   ```sh
   flutter pub get
   ```

2. Generate code. The models use `@JsonSerializable`, so code generation is
   required before the app will build
   (`Source: mobile/pubspec.yaml:L62-L63`):

   ```sh
   dart run build_runner build --delete-conflicting-outputs
   ```

3. Run the app against a backend, supplying the API base URL at build time
   (`Source: mobile/lib/env_config.dart:L19`):

   ```sh
   flutter run --dart-define API_BASE_URL=http://<host>:3000/api
   ```

   `<host>` must be reachable from the device or emulator — use the machine's
   LAN IP for a physical device, or `10.0.2.2` to reach the host machine from
   the Android emulator.

## Configuration — `API_BASE_URL`

The API base URL is a single compile-time constant
(`Source: mobile/lib/env_config.dart:L19`):

```dart
static const String apiBaseUrl =
    String.fromEnvironment('API_BASE_URL',
        defaultValue: 'http://192.168.2.20:3000/api');
```

- The value is fixed at compile time and is **not** runtime-mutable.
- The default points at a LAN IP and already includes the `/api` prefix.
- Override it with `--dart-define API_BASE_URL=...` on `flutter run` or
  `flutter build`.

The backend serves its routes under `/api` (there is no `/v1/` segment). For
the full endpoint catalogue, see
[`../docs/API_REFERENCE.md`](../docs/API_REFERENCE.md).

## Security note

> **SECURITY NOTE:** The Dio client attaches a verbose `LogInterceptor`
> unconditionally to both its main and refresh instances, each configured with
> `requestHeader: true`
> (`Source: mobile/lib/core/utils/dio_client.dart:L42-L53,L99-L111`). As a
> result, `Authorization: Bearer <token>` headers are written to the logs in
> every build, including release builds. This is a documented known risk
> recorded here for awareness; the code is intentionally left unchanged by this
> additive documentation work. The same risk is surfaced in
> [`../docs/ARCHITECTURE.md`](../docs/ARCHITECTURE.md) and
> [`../docs/DEPLOYMENT.md`](../docs/DEPLOYMENT.md).

## Documentation

Cross-cutting documentation lives in the repository-root `docs/` knowledge base:

- [Architecture](../docs/ARCHITECTURE.md)
- [API reference](../docs/API_REFERENCE.md)
- [Data models](../docs/DATA_MODELS.md)
- [Deployment](../docs/DEPLOYMENT.md)
