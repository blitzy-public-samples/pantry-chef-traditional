import { registerAs } from '@nestjs/config';
import { AppConfig } from './app-config.type';
import validateConfig from '.././utils/validate-config';
import { IsEnum, IsInt, IsOptional, IsString, Max, Min } from 'class-validator';

enum Environment {
  Development = 'development',
  Production = 'production',
  Test = 'test',
}

/**
 * class-validator schema applied to `process.env` at application boot.
 *
 * Decorators on each field:
 * - `@IsEnum(Environment)` + `@IsOptional()` on `NODE_ENV` (accepts
 *   `'development'`, `'production'`, or `'test'`).
 * - `@IsInt()` + `@Min(0)` + `@Max(65535)` + `@IsOptional()` on `APP_PORT`
 *   (TCP port range — class-transformer's `enableImplicitConversion`
 *   converts the env-var string to a number before validation).
 * - `@IsString()` + `@IsOptional()` on `API_PREFIX`.
 *
 * The validator is consumed by the factory below via `validateConfig()`
 * (see `../utils/validate-config.ts`), which calls `validateSync()` and
 * throws an `Error` at boot if any field fails validation. Because every
 * field is `@IsOptional()`, missing env vars do not throw — only malformed
 * values (e.g. `APP_PORT="not-a-number"`) abort startup.
 */
class EnvironmentVariablesValidator {
  @IsEnum(Environment)
  @IsOptional()
  NODE_ENV: Environment;

  @IsInt()
  @Min(0)
  @Max(65535)
  @IsOptional()
  APP_PORT: number;

  @IsString()
  @IsOptional()
  API_PREFIX: string;
}

/**
 * App configuration factory for the `app` namespace.
 *
 * Reads the following env vars from `process.env` (see `backend/env_example`):
 * - `NODE_ENV`           → `nodeEnv` (default `'development'`).
 * - `APP_NAME`           → `name` (code fallback `'app'`; `env_example:L3`
 *   ships `"NestJS API"`).
 * - `PWD` / `process.cwd()` → `workingDirectory`.
 * - `FRONTEND_DOMAIN`    → `frontendDomain` (undefined if unset).
 * - `BACKEND_DOMAIN`     → `backendDomain` (default `'http://localhost'`).
 * - `APP_PORT` / `PORT`  → `port` (default `3000`, parsed with `parseInt`).
 * - `API_PREFIX`         → `apiPrefix` (default `'api'`).
 *
 * Validation: invokes `validateConfig(process.env, EnvironmentVariablesValidator)`
 * which runs `plainToClass()` + `validateSync()` with
 * `enableImplicitConversion: true` and throws at boot on validation errors.
 *
 * Consumption: registered in `backend/src/app.module.ts:L22` via
 * `ConfigModule.forRoot({ isGlobal: true, load: [..., appConfig], ... })`
 * and read elsewhere with `configService.getOrThrow('app.apiPrefix',
 * { infer: true })` (e.g., `backend/src/main.ts:L14-L19` for the global
 * prefix and `backend/src/main.ts:L33` for the HTTP port).
 *
 * @returns The `AppConfig`-compatible namespace object (with two extra
 *   domain fields present at runtime).
 */
export default registerAs<AppConfig>('app', () => {
  validateConfig(process.env, EnvironmentVariablesValidator);

  // NOTE: The returned object includes two EXTRA properties, `frontendDomain` and
  // NOTE: `backendDomain`, that `AppConfig` (./app-config.type.ts) does not declare.
  // NOTE: TypeScript permits these excess properties because the literal flows through
  // NOTE: the generic `registerAs<AppConfig>` factory (not a directly-typed position),
  // NOTE: where structural assignability allows extras. Reach them via
  // NOTE: `configService.get('app')` with a narrowing cast, or extend `AppConfig` later.
  return {
    nodeEnv: process.env.NODE_ENV || 'development',
    name: process.env.APP_NAME || 'app',
    workingDirectory: process.env.PWD || process.cwd(),
    frontendDomain: process.env.FRONTEND_DOMAIN,
    backendDomain: process.env.BACKEND_DOMAIN ?? 'http://localhost',
    port: process.env.APP_PORT
      ? parseInt(process.env.APP_PORT, 10)
      : process.env.PORT
        ? parseInt(process.env.PORT, 10)
        : 3000,
    apiPrefix: process.env.API_PREFIX || 'api',
  };
});
