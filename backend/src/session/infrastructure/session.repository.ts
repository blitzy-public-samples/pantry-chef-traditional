import { NullableType } from '../../utils/types/nullable.type';
import { Session } from '../domain/session';
import { User } from 'src/users/domain/user';
import { EntityCondition } from 'src/utils/types/entity-condition.type';

// Imported helper types used by the repository contract below:
// `NullableType<T>` resolves to `T | null`; lets `findOne` explicitly signal "no match".
// Source: backend/src/utils/types/nullable.type.ts:L2
// `EntityCondition<T>` is a partial map of an entity's fields to a value (or array of
// values) — i.e. flexible, type-safe query conditions.
// Source: backend/src/utils/types/entity-condition.type.ts:L1-L3

/**
 * Persistence contract for `Session` aggregates.
 *
 * Defines the minimum, type-safe repository API for the Session domain and decouples
 * the application / auth layer from the concrete storage technology (MongoDB / Mongoose).
 * Any storage implementation must satisfy this abstract token.
 *
 * The concrete implementation is `SessionDocumentRepository`, bound to this abstract
 * class via dependency injection in `DocumentSessionPersistenceModule`
 * (`{ provide: SessionRepository, useClass: SessionDocumentRepository }`).
 * Source: backend/src/session/infrastructure/document/document-persistence.module.ts:L37-L38
 *
 * Backs the JWT refresh-token lifecycle: sessions are created at login, looked up on
 * refresh, and removed on logout. Consumed by `SessionService`.
 * Source: backend/src/session/session.service.ts:L18-L19
 */
export abstract class SessionRepository {
  /**
   * Finds a single session matching the supplied conditions.
   *
   * @param options - A partial set of `Session` field conditions (e.g. `{ id }` or
   *   `{ user }`), typed as `EntityCondition<Session>`.
   * @returns A promise resolving to the matching `Session`, or `null` when none
   *   matches (`NullableType<Session>`).
   */
  abstract findOne(
    options: EntityCondition<Session>,
  ): Promise<NullableType<Session>>;

  /**
   * Persists a new session.
   *
   * @param data - The creation payload, typed as
   *   `Omit<Session, 'id' | 'createdAt' | 'deletedAt'>`; these fields are generated or
   *   lifecycle-managed by the persistence layer, so they are excluded from the input.
   * @returns A promise resolving to the stored `Session` (with generated `id` and
   *   `createdAt`).
   */
  abstract create(
    data: Omit<Session, 'id' | 'createdAt' | 'deletedAt'>,
  ): Promise<Session>;

  /**
   * Removes sessions selected by the supplied criteria.
   *
   * @param criteria - The destructured selection criteria object, with fields:
   *   - `id` (`Session['id']`) — targets a specific session by id.
   *   - `user` (`Pick<User, 'id'>`) — targets all sessions belonging to a user.
   *   - `excludeId` (`Session['id']`) — removes all of a user's sessions EXCEPT this
   *     one; used to invalidate sibling sessions on refresh-token rotation.
   * @returns A promise that resolves once the matching sessions are removed.
   *
   * KNOWN ISSUE: despite the name `softDelete`, the document implementation performs a
   * HARD delete via `deleteMany(...)` — sessions are physically removed, NOT soft-
   * deleted, even though `SessionSchemaClass` declares a `deletedAt` field. The behavior
   * is documented here; the contract is intentionally left unchanged.
   * Source: backend/src/session/infrastructure/document/repositories/session.repository.ts:L106
   */
  abstract softDelete({
    excludeId,
    ...criteria
  }: {
    id?: Session['id'];
    user?: Pick<User, 'id'>;
    excludeId?: Session['id'];
  }): Promise<void>;
}
