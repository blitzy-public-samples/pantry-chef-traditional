import { Session } from 'src/session/domain/session';

/**
 * Shape of the JWT refresh-token payload signed by AuthService and decoded
 * by JwtRefreshStrategy.
 *
 * Unlike JwtPayloadType, this carries ONLY the `sessionId` (plus standard
 * `iat`/`exp` claims) — not the user id — because the refresh endpoint
 * looks up the user via the session document rather than trusting the
 * token to carry user identity directly.
 *
 * Properties:
 * - `sessionId`: Session document id used to validate that the session is
 *   still active before issuing new tokens.
 * - `iat`, `exp`: Standard JWT issued-at and expiry epoch seconds.
 */
export type JwtRefreshPayloadType = {
  sessionId: Session['id'];
  iat: number;
  exp: number;
};
