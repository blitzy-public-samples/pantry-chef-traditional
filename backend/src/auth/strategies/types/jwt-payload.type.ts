import { Session } from 'src/session/domain/session';
import { User } from 'src/users/domain/user';

/**
 * Shape of the JWT access-token payload signed by AuthService via
 * `jwtService.signAsync(...)` and decoded by JwtStrategy.
 *
 * Combines `Pick<User, 'id'>` (the authenticated user's MongoDB id) with
 * session metadata:
 * - `sessionId`: Session document id used for server-side invalidation
 *   (set to `null` when the access token outlives its session, e.g. after
 *   logout).
 * - `iat`, `exp`: Standard JWT issued-at and expiry epoch seconds.
 *
 * The payload is what populates `request.user` in JWT-guarded handlers.
 */
export type JwtPayloadType = Pick<User, 'id'> & {
  sessionId: Session['id'];
  iat: number;
  exp: number;
};
