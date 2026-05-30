import { registerAs } from '@nestjs/config';
import { AuthConfig } from 'src/auth/config/auth-config.type';
import { IsString } from 'class-validator';
import validateConfig from '../../utils/validate-config';

/**
 * Runtime-validated shape of the auth-related environment variables.
 *
 * Used by class-validator (via plainToClass + validateOrReject) inside the
 * `registerAs('auth', ...)` factory to fail-fast at startup if any required
 * AUTH_* environment variable is missing or malformed.
 *
 * Validators only assert presence (@IsString); they do NOT validate that
 * `AUTH_JWT_SECRET` is high-entropy or that `AUTH_REFRESH_TOKEN_EXPIRES_IN`
 * is a sensible duration. See ../../../../PRODUCTION_READINESS.md
 * § Secrets Management for the production hardening gap.
 */
class EnvironmentVariablesValidator {
  @IsString()
  AUTH_JWT_SECRET: string;

  @IsString()
  AUTH_JWT_TOKEN_EXPIRES_IN: string;

  @IsString()
  AUTH_REFRESH_SECRET: string;

  @IsString()
  AUTH_REFRESH_TOKEN_EXPIRES_IN: string;
}

/**
 * Auth configuration factory consumed via
 * `configService.getOrThrow('auth', { infer: true })` to retrieve typed
 * access to JWT and refresh-token settings.
 *
 * Reads four environment variables from process.env (defaults shown in
 * backend/env_example:L20-L23):
 * - `AUTH_JWT_SECRET` (default `secret` — UNSAFE for production)
 * - `AUTH_JWT_TOKEN_EXPIRES_IN` (default `15m`)
 * - `AUTH_REFRESH_SECRET` (default `secret_for_refresh` — UNSAFE for production)
 * - `AUTH_REFRESH_TOKEN_EXPIRES_IN` (default `3650d` — ~10 years, UNSAFE)
 *
 * Validation is performed once at module bootstrap via the
 * EnvironmentVariablesValidator class above.
 *
 * @returns AuthConfig namespace registered under the `auth` key in the
 *   global ConfigService.
 */
export default registerAs<AuthConfig>('auth', () => {
  validateConfig(process.env, EnvironmentVariablesValidator);

  return {
    // TODO(prod): Default AUTH_JWT_SECRET is the literal string `secret`.
    // TODO(prod): Rotate to high-entropy value before production.
    secret: process.env.AUTH_JWT_SECRET,
    expires: process.env.AUTH_JWT_TOKEN_EXPIRES_IN,
    refreshSecret: process.env.AUTH_REFRESH_SECRET,
    // TODO(prod): Default AUTH_REFRESH_TOKEN_EXPIRES_IN is 3650d (~10 years).
    // TODO(prod): Reduce substantially before production.
    refreshExpires: process.env.AUTH_REFRESH_TOKEN_EXPIRES_IN,
  };
});
