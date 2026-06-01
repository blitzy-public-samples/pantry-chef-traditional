/**
 * Typed shape of the auth configuration namespace consumed via
 * `configService.getOrThrow('auth', { infer: true })`.
 *
 * Properties:
 * - `secret`: JWT access-token signing secret (AUTH_JWT_SECRET).
 * - `expires`: Access-token TTL expressed as a vercel-ms duration string,
 *   e.g. `15m`, `1h` (AUTH_JWT_TOKEN_EXPIRES_IN).
 * - `refreshSecret`: JWT refresh-token signing secret (AUTH_REFRESH_SECRET).
 * - `refreshExpires`: Refresh-token TTL expressed as a vercel-ms duration
 *   string (AUTH_REFRESH_TOKEN_EXPIRES_IN).
 *
 * All properties are optional in the type to allow gradual rollout of new
 * config fields without breaking existing deployments.
 */
export type AuthConfig = {
  secret?: string;
  expires?: string;
  refreshSecret?: string;
  refreshExpires?: string;
};
