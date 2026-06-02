import { registerAs } from '@nestjs/config';
import { AuthConfig } from 'src/auth/config/auth-config.type';
import { IsString } from 'class-validator';
import validateConfig from '../../utils/validate-config';

/**
 * Validates that the required auth JWT environment variables are present as strings.
 */
class EnvironmentVariablesValidator {
  // Access-token signing secret
  @IsString()
  AUTH_JWT_SECRET: string;

  // Access-token TTL (e.g. 15m)
  @IsString()
  AUTH_JWT_TOKEN_EXPIRES_IN: string;

  // Refresh-token signing secret
  @IsString()
  AUTH_REFRESH_SECRET: string;

  // Refresh-token TTL (e.g. 3650d)
  @IsString()
  AUTH_REFRESH_TOKEN_EXPIRES_IN: string;
}

/**
 * Validates the auth env vars and registers the namespaced `auth` config
 * (`auth.secret`, `auth.expires`, `auth.refreshSecret`, `auth.refreshExpires`).
 */
export default registerAs<AuthConfig>('auth', () => {
  validateConfig(process.env, EnvironmentVariablesValidator);

  // Map validated env vars into the typed AuthConfig shape
  return {
    secret: process.env.AUTH_JWT_SECRET,
    expires: process.env.AUTH_JWT_TOKEN_EXPIRES_IN,
    refreshSecret: process.env.AUTH_REFRESH_SECRET,
    refreshExpires: process.env.AUTH_REFRESH_TOKEN_EXPIRES_IN,
  };
});
