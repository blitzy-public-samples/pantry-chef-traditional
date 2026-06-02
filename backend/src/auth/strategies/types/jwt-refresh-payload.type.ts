import { Session } from 'src/session/domain/session';

/** Decoded refresh-token claims. */
export type JwtRefreshPayloadType = {
  sessionId: Session['id'];
  iat: number;
  exp: number;
};
