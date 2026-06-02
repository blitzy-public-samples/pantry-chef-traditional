import { User } from 'src/users/domain/user';

/**
 * Immutable (`Readonly`) response contract for login, registration, and refresh.
 * The controller's login/register/refresh routes return
 * `Omit<LoginResponseType, 'user'>` (tokens only; the user object is omitted).
 */
export type LoginResponseType = Readonly<{
  token: string;
  refreshToken: string;
  tokenExpires: number;
  user: User;
}>;
