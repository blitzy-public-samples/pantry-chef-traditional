import { Session } from 'src/session/domain/session';
import { User } from 'src/users/domain/user';

/** Decoded access-token claims. */
export type JwtPayloadType = Pick<User, 'id'> & {
  // User id (from Pick<User,'id'>)
  sessionId: Session['id']; // Owning session id
  iat: number; // Issued-at epoch seconds
  exp: number; // Expiry epoch seconds
};
