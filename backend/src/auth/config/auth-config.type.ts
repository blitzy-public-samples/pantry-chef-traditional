/**
 * Typed shape of the `auth` configuration namespace produced by `auth.config.ts`.
 */
export type AuthConfig = {
  // Access-token signing secret (AUTH_JWT_SECRET)
  secret?: string;
  // Access-token TTL string (AUTH_JWT_TOKEN_EXPIRES_IN)
  expires?: string;
  // Refresh-token signing secret (AUTH_REFRESH_SECRET)
  refreshSecret?: string;
  // Refresh-token TTL string (AUTH_REFRESH_TOKEN_EXPIRES_IN)
  refreshExpires?: string;
};
