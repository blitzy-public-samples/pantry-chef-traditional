import { User } from 'src/users/domain/user';

/**
 * Response shape returned by AuthService.validateLogin, register, and
 * refreshToken methods.
 *
 * Carries the JWT access token, refresh token, token expiry timestamp,
 * and the authenticated User. Note that login/register/refresh endpoints
 * actually return `Omit<LoginResponseType, 'user'>` — the user object is
 * fetched separately via GET /api/v1/auth/me.
 *
 * Properties:
 * - `token`: JWT access token signed with AUTH_JWT_SECRET (15m default TTL).
 * - `refreshToken`: JWT refresh token signed with AUTH_REFRESH_SECRET (3650d
 *   default TTL — see ../../../PRODUCTION_READINESS.md § Secrets Management).
 * - `tokenExpires`: Unix epoch milliseconds when the access token expires.
 * - `user`: The authenticated User (omitted in login/register/refresh responses).
 */
export type LoginResponseType = Readonly<{
  token: string;
  refreshToken: string;
  tokenExpires: number;
  user: User;
}>;
