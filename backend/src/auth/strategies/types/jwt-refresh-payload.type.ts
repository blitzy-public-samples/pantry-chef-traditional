import { Session } from 'src/session/domain/session';

/** Decoded refresh-token claims. */
export type JwtRefreshPayloadType = {
  sessionId: Session['id']; // Session id used to rotate tokens
  iat: number; // Issued-at epoch seconds
  exp: number; // Expiry epoch seconds
};
