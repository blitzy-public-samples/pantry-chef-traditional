import { UserSchemaClass } from 'src/users/infrastructure/document/entities/user.schema';
import { Session } from '../../../domain/session';
import { SessionSchemaClass } from '../entities/session.schema';
import { UserMapper } from 'src/users/infrastructure/document/mappers/user.mapper';

/**
 * Stateless mapper that translates between the persisted `SessionSchemaClass`
 * (Mongoose document) and the domain `Session` model.
 *
 * Purely functional: it exposes only static methods, holds no state, performs
 * no I/O, and needs no dependency injection. Nested user conversion is
 * delegated to `UserMapper` rather than reimplemented here.
 *
 */
export class SessionMapper {
  /**
   * Converts a Mongoose session document into a domain `Session`.
   *
   * Maps `raw._id.toString()` onto `id`, converts the populated `user` via
   * `UserMapper.toDomain` only when present, and copies `createdAt`/`deletedAt`.
   *
   * @param raw - The `SessionSchemaClass` document read from MongoDB.
   * @returns The hydrated domain `Session`.
   *
   */
  static toDomain(raw: SessionSchemaClass): Session {
    const session = new Session();
    session.id = raw._id.toString();

    // Convert the populated user only when present on the document.
    if (raw.user) {
      session.user = UserMapper.toDomain(raw.user);
    }

    session.createdAt = raw.createdAt;
    session.deletedAt = raw.deletedAt;
    return session;
  }
  /**
   * Converts a domain `Session` into a `SessionSchemaClass` for storage.
   *
   * Builds the `UserSchemaClass` reference from `session.user.id`, sets `_id`
   * only when `session.id` is a string, and copies `user`/`createdAt`/
   * `deletedAt`.
   *
   * @param session - The domain `Session` to serialize for persistence.
   * @returns The `SessionSchemaClass` persistence entity.
   *
   */
  static toPersistence(session: Session): SessionSchemaClass {
    const user = new UserSchemaClass();
    user._id = session.user.id.toString();
    const sessionEntity = new SessionSchemaClass();
    // Preserve an existing string id; otherwise leave `_id` for Mongo to set.
    if (session.id && typeof session.id === 'string') {
      sessionEntity._id = session.id;
    }
    sessionEntity.user = user;
    sessionEntity.createdAt = session.createdAt;
    sessionEntity.deletedAt = session.deletedAt;
    return sessionEntity;
  }
}
