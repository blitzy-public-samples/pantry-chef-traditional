// NOTE: The factory in `./app.config.ts` additionally returns `frontendDomain` and
// NOTE: `backendDomain` at runtime, but those two fields are NOT declared on this type.
// NOTE: Reach them via `configService.get('app')` with a narrowing cast, or extend
// NOTE: `AppConfig` in a follow-up task. See backend/src/config/README.md § Known Limitations.
/**
 * Typed shape of the `'app'` configuration namespace produced by the
 * `appConfig` factory in `./app.config.ts`.
 *
 * Fields declared on this type (5):
 * - `nodeEnv`: string — defaults to `'development'`; sourced from `NODE_ENV`
 *   and validated by `@IsEnum(Environment)` (Development | Production | Test).
 * - `name`: string — defaults to `'app'` in the factory code; the
 *   `env_example:L3` file ships `"NestJS API"` as the env-var default.
 * - `workingDirectory`: string — `process.env.PWD || process.cwd()`.
 * - `port`: number — `APP_PORT` or `PORT`, otherwise `3000`. Parsed with
 *   `parseInt(..., 10)` so the exported value is numeric (validated by
 *   `@IsInt() @Min(0) @Max(65535)`).
 * - `apiPrefix`: string — defaults to `'api'`; consumed by
 *   `app.setGlobalPrefix(...)` in `backend/src/main.ts:L14-L19`.
 *
 * Consumed via `ConfigService<AllConfigType>` — e.g.,
 * `configService.getOrThrow('app.apiPrefix', { infer: true })`.
 */
export type AppConfig = {
  nodeEnv: string;
  name: string;
  workingDirectory: string;
  port: number;
  apiPrefix: string;
};
