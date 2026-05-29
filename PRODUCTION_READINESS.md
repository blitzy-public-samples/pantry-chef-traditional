# Production Readiness Checklist

## Overview

PantryChef is currently a **dev-grade** monorepo: it boots cleanly for local
development but is not yet safe to deploy to production. The backend container
runs in watch mode and compiles TypeScript on the fly, MongoDB credentials are
hardcoded into `docker-compose.yml`, CORS is wide open, JWT secrets ship with
placeholder values, the refresh-token lifetime is set to roughly ten years, and
there is no CI/CD pipeline, observability stack, or release signing for the
Flutter client. None of these are accidental omissions in the application
logic — they are the expected state of a project that has reached
feature-complete development but has not yet been hardened for production.

This document enumerates every gap that blocks a production deployment, grouped
into the eleven categories below, and gives a concrete, actionable remediation
path for each. For system-level context — the request path from the Flutter
client through the NestJS backend to MongoDB and Google Cloud Vision, the
technology choices, and the cross-cutting concerns — see
[ARCHITECTURE.md](ARCHITECTURE.md). For the persistence model, including the
soft-delete (`deletedAt`) contract referenced repeatedly below, see
[DATA_MODEL.md](DATA_MODEL.md).

> **Important — minimal-change clause.** This checklist *documents* gaps; it
> does **not** fix them. No production code, configuration value, environment
> default, or seed data is modified by this engagement. Source files carry the
> corresponding inline markers (`// TODO(prod):` for production gaps, `// NOTE:`
> for intentional decisions, `// FIXME:` for genuine bugs) added separately
> under `backend/` and `mobile/`; the remediation steps here describe the
> recommended path without applying it.

**Legend.** Each category carries a status indicator:

| Indicator | Meaning |
|-----------|---------|
| ❌ | Not started — hard blocker for production |
| ⚠️ | Partial — placeholders or scaffolding exist; improvement needed |
| ✅ | Production-ready |

## Status Categories

| Category | Key Items | Status |
|----------|-----------|--------|
| Build & Runtime | Container runs `npm run dev`; TypeScript not compiled to /dist; Flutter release builds not configured | ❌ |
| Secrets Management | MongoDB credentials and JWT secrets hardcoded; no secrets manager; refresh TTL 3650d | ❌ |
| Networking & TLS | Open CORS (`cors: true`); no reverse proxy / TLS termination | ❌ |
| Infrastructure & Orchestration | Docker Compose for dev only; no Kubernetes / managed service; no DB backup | ❌ |
| File Storage | `FILE_DRIVER=local` placeholder; AWS_* env vars empty; S3 driver not implemented | ⚠️ |
| Security Hardening | No rate limiting; no Helmet; no JWT guard on `/v1/ai/vision`; MIME filter commented out; password reset endpoints unwired | ❌ |
| Observability | No structured logging; no `/metrics`; no tracing; no alerting | ❌ |
| CI/CD | No pipeline configured (no GitHub Actions, GitLab CI, etc.) | ❌ |
| Database | Seed runner runs unconditionally; no migration versioning; only one collection index on each schema | ⚠️ |
| Testing | Limited E2E coverage (auth specs only); no unit tests for `matches()` | ⚠️ |
| Mobile Release | No App Store / Play Store signing configs; no release pipeline; baseUrl is local IP `192.168.2.20` | ❌ |

## Build & Runtime

The backend container is configured for development, not production. Its single
`CMD` installs dependencies at container start and then launches Nest in watch
mode, recompiling TypeScript on the fly — slow to boot, memory-hungry, and
dependent on having dev tooling and source present at runtime.

> 🚧 The Dockerfile runs `CMD npm i && npm run dev`, i.e. watch-mode startup
> with on-the-fly TypeScript compilation. This is unsafe and slow for
> production. *Source: backend/Dockerfile:L13.*

The fix does not require new tooling — the scripts already exist. The backend
`package.json` defines `"build": "nest build"` and `"start:prod": "node dist/main"`,
but the container uses neither; it uses `"dev": "nest start --watch"` instead.
*Source: backend/package.json:L9, L12, L14.*

> 🚧 Adopt a multi-stage Dockerfile: a build stage that runs `nest build` to
> emit `dist/`, and a slim runtime stage that runs `node dist/main` with
> `NODE_ENV=production`, no source maps, no watch, and production-only
> dependencies (`npm ci --omit=dev`).

On the client side, no release build is configured. `mobile/pubspec.yaml`
still carries the scaffold description "A new Flutter project." and no
release/flavor configuration. *Source: mobile/pubspec.yaml:L2.*

> 🚧 Produce signed release artifacts with the production API base URL injected
> at compile time, e.g.
> `flutter build apk --release --dart-define=API_BASE_URL=https://api.pantry-chef.com/api`
> (and the equivalent `ipa` / `web` builds). The compile-time define is read by
> `EnvConfig.apiBaseUrl`. *Source: mobile/lib/env_config.dart:L2.*

## Secrets Management

Every secret in the repository is a development placeholder, and several are
committed in plaintext. None of them are safe to carry into production.

> 🚧 The Mongo root credentials are hardcoded in Compose as
> `MONGO_INITDB_ROOT_USERNAME: admin` and `MONGO_INITDB_ROOT_PASSWORD: 123456`.
> Move these to a secrets manager (AWS Secrets Manager, HashiCorp Vault,
> Kubernetes Secrets) and inject them at runtime rather than baking them into
> the image or the Compose file. *Source: backend/docker-compose.yml:L9-L10.*

> 🚧 The environment template ships default signing secrets:
> `AUTH_JWT_SECRET=secret` and `AUTH_REFRESH_SECRET=secret_for_refresh`. These
> must be replaced with high-entropy values, stored externally, and rotated on
> a schedule. *Source: backend/env_example:L20, L22.*

> 🚧 The refresh-token lifetime is `AUTH_REFRESH_TOKEN_EXPIRES_IN=3650d`
> (~10 years). A stolen refresh token would remain valid for a decade. Reduce
> to a sensible window (e.g. `30d`) and pair it with refresh-token rotation and
> revocation on logout. *Source: backend/env_example:L23.*

> 🚧 Google Cloud Vision credentials must be loaded from a secrets manager, not
> committed to `src/config/ai.json`. The AI service today resolves the key file
> relative to its own directory and degrades gracefully when it is absent
> (setting `isGoogleVisionEnabled = false`), which is fine for local dev but
> must be replaced by an explicit, managed credential source for production.
> *Source: backend/src/ai/ai.service.ts:L52-L56.*

## Networking & TLS

The HTTP edge is unhardened. CORS is fully open and there is no transport
encryption in front of the Node process.

> 🚧 The application is created with `{ cors: true }`, which reflects **any**
> origin. Replace this with an explicit allowlist, e.g.
> `{ cors: { origin: ['https://app.pantry-chef.com'] } }`, scoped to the real
> client origins. *Source: backend/src/main.ts:L11.*

> 🚧 No TLS termination is configured. Place a reverse proxy (NGINX, AWS ALB, or
> Cloudflare) in front of the NestJS service, terminate TLS there with a valid
> certificate, and redirect HTTP→HTTPS.

Beyond TLS, the proxy layer should add standard security headers — HSTS,
`X-Frame-Options`, and `X-Content-Type-Options` — none of which are emitted by
the application today (see also **Security Hardening** for Helmet).

## Infrastructure & Orchestration

The deployment topology is a single-host Docker Compose stack intended for a
developer laptop, with no high-availability or durability guarantees.

> 🚧 `backend/docker-compose.yml` is suitable for local development only.
> Replace it with a managed container orchestration platform — Kubernetes,
> AWS ECS, or Google Cloud Run — that provides health checks, rolling
> deployments, autoscaling, and restart policies beyond a single host.
> *Source: backend/docker-compose.yml.*

> 🚧 MongoDB runs as one container with a bind-mounted data directory
> (`./data/db:/data/db`) — a single point of failure with no replication, no
> automated backups, and no point-in-time recovery. Move to MongoDB Atlas or a
> self-managed replica set with automated snapshots.
> *Source: backend/docker-compose.yml:L14.*

Recommended high-availability target: a minimum three-node replica set, daily
automated snapshots, and at least 7-day point-in-time recovery, fronted by the
managed orchestrator above.

## File Storage

File storage is the one category that is *partially* prepared: the
configuration surface anticipates S3, but no driver implements it.

> 🚧 The environment template declares `FILE_DRIVER=local` with a comment noting
> support for `s3` and `s3-presigned`, but the S3 driver is **not implemented**
> in the codebase — only the env-var placeholders exist
> (`ACCESS_KEY_ID`, `SECRET_ACCESS_KEY`, `AWS_S3_REGION`,
> `AWS_DEFAULT_S3_BUCKET`, all empty).
> *Source: backend/env_example:L13-L18.*

For production, implement the S3 driver behind the existing `FILE_DRIVER`
switch using those four env vars, then set `FILE_DRIVER=s3` (or `s3-presigned`).
Local disk storage in production is fragile: it is single-node, has no CDN, and
offers no lifecycle/expiry policies. S3 (object storage) fronted by CloudFront
(CDN) is the recommended path. This category is ⚠️ rather than ❌ because the
configuration contract already exists; only the driver implementation is
missing.


## Security Hardening

This is the highest-density gap category. The API has no abuse controls, the AI
endpoint is unauthenticated, an upload validation filter is disabled, and a
password-reset flow is half-built.

> 🚧 **No rate limiting.** There is no throttling on any endpoint. Install
> `@nestjs/throttler` and apply `@Throttle()` to the auth surface (login,
> register, refresh) to blunt brute-force and credential-stuffing attacks.

> 🚧 **No Helmet middleware.** The bootstrap sets no security headers. Add
> `helmet` to the NestJS startup to emit CSP, HSTS, `X-Content-Type-Options`,
> and related headers. *Source: backend/src/main.ts:L10-L11.*

> 🚧 **AI endpoint is unguarded.** `AiController` is declared with
> `@Controller('ai')` and `@Post('vision')` but carries **no**
> `@UseGuards(AuthGuard('jwt'))`. The endpoint accepts a 10 MB image upload
> (`limits: { fileSize: 10 * 1024 * 1024 }`) from anonymous clients — a clear
> abuse and cost vector against Google Cloud Vision. Add `@ApiBearerAuth()` and
> `@UseGuards(AuthGuard('jwt'))` to the controller.
> *Source: backend/src/ai/ai.controller.ts:L12-L43.*

> 🚧 **MIME-type filter is commented out.** The `FileInterceptor` contains a
> disabled `fileFilter` that would reject anything other than JPG/JPEG/PNG.
> Uncomment it and verify it handles edge cases such as a mismatched extension
> versus actual content type. *Source: backend/src/ai/ai.controller.ts:L20-L28.*

> 🚧 **Password-reset endpoints are unwired.** The DTOs
> `AuthForgotPasswordDto` and `AuthResetPasswordDto` exist, but `AuthController`
> exposes only seven routes (login, register, `GET me`, refresh, logout,
> `PATCH me`, `DELETE me`) and **no** `forgot-password` or `reset-password`
> route. Add the two endpoints plus the matching service methods (token
> issuance, email delivery, hash verification).
> *Source: backend/src/auth/dto/auth-forgot-password.dto.ts:L6; backend/src/auth/dto/auth-reset-password.dto.ts:L4; backend/src/auth/auth.controller.ts:L31-L92.*

Each of these is flagged at its source location with a `// TODO(prod):` marker
per the project's tag taxonomy; the AI gaps additionally appear in
[backend/src/ai/README.md](backend/src/ai/README.md) and the auth gap in
[backend/src/auth/README.md](backend/src/auth/README.md).

## Observability

The service is effectively a black box at runtime. There is no structured
logging, metrics, tracing, or alerting — confirmed by the absence of any
corresponding dependency in `backend/package.json` (no `pino`, `winston`,
`@willsoto/nestjs-prometheus`, or OpenTelemetry packages).

> 🚧 **No structured logging.** Adopt Pino or Winston and ship JSON logs to a
> central aggregator (CloudWatch, Datadog, or Loki) with request correlation
> IDs.

> 🚧 **No metrics endpoint.** There is no Prometheus `/metrics`. Install
> `@willsoto/nestjs-prometheus` and instrument the hot paths — request count,
> latency histograms, error rate, recipe-match query count, and AI-vision call
> count.

> 🚧 **No distributed tracing.** Add the OpenTelemetry SDK and export spans to a
> trace backend (Tempo, Jaeger, or Honeycomb) so a single request can be
> followed from controller through repository to MongoDB and Google Cloud
> Vision.

> 🚧 **No alerting.** Define SLOs for p95 latency, error rate, and MongoDB
> connection-pool saturation, and wire alerts to PagerDuty or OpsGenie.

## CI/CD

There is no automation in the repository at all.

> 🚧 No `.github/workflows/`, no `.gitlab-ci.yml`, and no `Jenkinsfile` exist
> anywhere in the tree — the CI/CD pipeline is entirely absent.

Recommended pipeline: lint (`npm run lint` + `flutter analyze`) → type-check
(`tsc --noEmit`) → unit tests (Jest for the backend, `flutter test` for the
client) → build the backend Docker image → push to a registry → deploy to
staging → manual approval gate → deploy to production. Add Dependabot or
Renovate for automated dependency updates and security patching.

## Database

The persistence layer works for development but lacks the safety rails needed at
production scale. See [DATA_MODEL.md](DATA_MODEL.md) for the full schema and the
soft-delete (`deletedAt`) contract that the items below relate to.

> 🚧 **The seed runner is unconditional and destructive.** `run-seed.ts` invokes
> `UserSeedService.run()`, then `IngridientSeedService.run()`, then
> `RecipeSeedService.run()`, then `PantrySeedService.run()` on every invocation
> of `npm run seed:run:document`; the seed services drop their collections
> before reseeding. Gate this behind an explicit flag (e.g. `--force-reseed`)
> so it can never run by accident in production.
> *Source: backend/src/database/seeds/run-seed.ts:L13-L16.*

> 🚧 **No migration versioning.** There is no `migrate-mongo` or
> `mongoose-migrate`; schema changes are applied implicitly through Mongoose's
> loose schema mode. Add a migration framework and version every change so
> deployments are reproducible and reversible.

> 🚧 **Minimal indexing.** Each schema declares a single index —
> `SessionSchema.index({ user: 1 })`,
> `PantryIngridientSchema.index({ userId: 1 })`, and
> `RecipeSchema.index({ title: 1 })`. The recipe matching pipeline filters on
> `ingridientList.ingridient` (spelling preserved verbatim) with `$nin` and on
> `tags` with `$all`, neither of which is indexed, so matching will degrade as
> the recipe corpus grows. Add a compound index covering `(deletedAt, tags)` and
> consider a text index on `title` for fuzzy search.
> *Source: backend/src/session/infrastructure/document/entities/session.schema.ts:L28; backend/src/pantry/infrastructure/document/entities/pantryIngridient.schema.ts:L49; backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L106; backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L108, L113.*

A related correctness issue lives in the pantry repository: `softDelete` calls
`deleteOne`, physically removing the document instead of setting `deletedAt`,
which violates the soft-delete contract documented in
[DATA_MODEL.md](DATA_MODEL.md). It is preserved as-is and flagged with
`// FIXME:` and `// TODO(prod):` at its source.
*Source: backend/src/pantry/infrastructure/document/repositories/pantryIngridient.repository.ts:L119-L123.*

This category is ⚠️ rather than ❌ because the database is functional and
indexed for its current single-index queries; the blockers are operational
(seed gating, migrations, scale indexing) rather than a non-functioning store.

## Testing

Automated test coverage is thin and concentrated on a single feature.

> 🚧 **Backend coverage is auth-only.** `backend/test/` contains the Jest E2E
> harness (`jest-e2e.json`), a single auth spec (`user/auth.e2e-spec.ts`), and
> shared constants. There are **no** unit tests for the recipe matching
> algorithm `RecipeDocumentRepository.matches()`. Add unit tests against an
> in-memory Mongo server that assert the documented `matchScore`, `isQuickMake`,
> and `isAlmostThere` derivations.
> *Source: backend/test/user/auth.e2e-spec.ts; backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L92-L171.*

> 🚧 **No integration tests for the AI vision endpoint**, and no tests covering
> pantry CRUD against the destructive `softDelete` behavior described above.

> 🚧 **Mobile tests are the default smoke test.** `mobile/test/widget_test.dart`
> still contains only the generated "Counter increments smoke test". Add BLoC
> unit tests, golden tests for key screens, and an integration test for the
> camera → vision → ingredient-resolution flow.
> *Source: mobile/test/widget_test.dart:L13.*

This category is ⚠️: a real (if narrow) E2E harness exists, so the foundation is
present; the gap is breadth of coverage, especially around the matching pipeline.

## Mobile Release

The Flutter client has no production release configuration on any platform.

> 🚧 **Local API base URL baked in.** `EnvConfig.apiBaseUrl` defaults to
> `http://192.168.2.20:3000/api`, a private LAN address. Production builds must
> override it via `--dart-define API_BASE_URL=https://api.pantry-chef.com/api`.
> *Source: mobile/lib/env_config.dart:L2.*

> 🚧 **No iOS signing config.** There is no `mobile/ios/Runner/Runner.entitlements`
> and no associated provisioning profile/App Store signing set up in the Xcode
> project (`mobile/ios/Runner.xcodeproj`).

> 🚧 **No Play Store signing config.** `mobile/android/app/build.gradle` signs
> release builds with the **debug** keystore
> (`signingConfig = signingConfigs.debug`, annotated "Signing with the debug
> keys for now"). A production keystore and a `release` signing config are
> required. *Source: mobile/android/app/build.gradle:L36-L37.*

> 🚧 **Placeholder PWA manifest.** `mobile/web/manifest.json` carries scaffold
> values — `name: "pantry_chef"` and `description: "A new Flutter project."` —
> that should be reviewed for production (name, description, theme color,
> icons). *Source: mobile/web/manifest.json:L2, L8.*

> 🚧 **No mobile CD pipeline.** There is no Fastlane, Codemagic, or Bitrise
> integration to build, sign, and publish the app to the App Store and Play
> Store.


## Summary Table — Gap to Module Mapping

The table below provides traceability from each code-level gap surfaced in this
central checklist down to the module README that also documents it and the
inline annotation that flags it at the source. A developer reading a single
module can find its local context; an operator scanning for blockers reads this
document.

| Gap | Module README | Inline Annotation |
|-----|---------------|-------------------|
| Recipe `_id` matching only / no unit normalization / no quantity check | [backend/src/recipe/README.md](backend/src/recipe/README.md) | `// TODO(prod):` block comment above `matches()` in `recipe.repository.ts` |
| AI MIME filter commented out | [backend/src/ai/README.md](backend/src/ai/README.md) | `// TODO(prod):` at `ai.controller.ts:L20-L28` |
| AI endpoint no JWT guard | [backend/src/ai/README.md](backend/src/ai/README.md) | `// TODO(prod):` above `AiController` class |
| AI small ingredient dictionary | [backend/src/ai/README.md](backend/src/ai/README.md) | `// TODO(prod):` at `ai.service.ts:L11-L49` |
| Pantry destructive `softDelete` | [backend/src/pantry/README.md](backend/src/pantry/README.md) | `// FIXME:` + `// TODO(prod):` at `pantryIngridient.repository.ts:L119-L123` |
| Auth password reset unwired | [backend/src/auth/README.md](backend/src/auth/README.md) | (No inline — a missing endpoint cannot be flagged in code) |
| Seed runner destructive | [backend/src/database/README.md](backend/src/database/README.md) | `// TODO(prod):` at each seed service `run()` method |
| Preserved spelling variants | [backend/src/ingridient/README.md](backend/src/ingridient/README.md), [backend/src/pantry/README.md](backend/src/pantry/README.md), [mobile/lib/features/recipe/README.md](mobile/lib/features/recipe/README.md) | `// NOTE:` at first occurrence in each affected file |
| `Recipe.copyWith` no-op on `inFavorite` | [mobile/lib/features/recipe/README.md](mobile/lib/features/recipe/README.md) | `// NOTE:` + `// FIXME:` at `recipe.dart:L37-L53` |

> **Note on preserved spellings.** The identifiers `Ingridient`,
> `InstractionItem`, and the `singup` route are intentional, stable contracts
> across the codebase (spelling preserved verbatim). They are documented, never
> "corrected," in keeping with the minimal-change clause.

