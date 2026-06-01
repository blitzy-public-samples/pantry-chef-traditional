import { User } from 'src/users/domain/user';

/**
 * Immutable (`Readonly`) response contract for login, registration, and refresh.
 * The controller's login/register/refresh routes return
 * `Omit<LoginResponseType, 'user'>` (tokens only; the user object is omitted).
 */
export type LoginResponseType = Readonly<{
  token: string; // Signed JWT access token
  refreshToken: string; // Signed JWT refresh token
  tokenExpires: number; // Access-token expiry as epoch milliseconds
  user: User; // Authenticated user (omitted from login/register/refresh responses)
}>;
