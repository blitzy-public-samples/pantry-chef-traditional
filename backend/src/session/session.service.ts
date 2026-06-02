import { Injectable } from '@nestjs/common';
import { User } from 'src/users/domain/user';
import { EntityCondition } from 'src/utils/types/entity-condition.type';
import { SessionRepository } from './infrastructure/session.repository';
import { Session } from './domain/session';
import { NullableType } from 'src/utils/types/nullable.type';

/**
 * Application service that orchestrates the `Session` lifecycle backing JWT
 * refresh-token rotation: sessions are created at login, looked up during refresh,
 * and removed at logout.
 *
 * Acts as a thin, stateless typed facade that delegates all persistence to the injected
 * abstract `SessionRepository` and embeds no storage logic of its own. Consumed
 * internally by `AuthService`; there is no public REST controller for sessions.
 *
 * Source: backend/src/session/session.service.ts:L8-L10
 */
@Injectable()
export class SessionService {
  // The abstract `SessionRepository` is injected by Nest DI; the concrete binding
  // (`SessionDocumentRepository`) is provided by `DocumentSessionPersistenceModule`.
  constructor(private readonly sessionRepository: SessionRepository) {}

  /**
   * Looks up a single session by flexible entity conditions.
   *
   * Delegates directly to `this.sessionRepository.findOne`.
   *
   * @param options The `EntityCondition<Session>` query conditions (e.g., `{ id }`
   *   or `{ user }`).
   * @returns A `Promise` resolving to the matching `Session`, or `null`
   *   (`NullableType<Session>`) when no session matches.
   */
  findOne(options: EntityCondition<Session>): Promise<NullableType<Session>> {
    return this.sessionRepository.findOne(options);
  }

  /**
   * Persists a new session for an authenticated user.
   *
   * Delegates to `this.sessionRepository.create`.
   *
   * @param data The session payload with `id`, `createdAt`, and `deletedAt`
   *   omitted; these are generated / lifecycle-managed by the persistence layer.
   * @returns A `Promise<Session>` resolving to the persisted session, populated
   *   with the generated `id` and `createdAt`.
   */
  create(
    data: Omit<Session, 'id' | 'createdAt' | 'deletedAt'>,
  ): Promise<Session> {
    return this.sessionRepository.create(data);
  }

  /**
   * Removes sessions matching the supplied criteria.
   *
   * Invoked at logout and during refresh-token rotation to invalidate sessions.
   * Delegates to `this.sessionRepository.softDelete`.
   *
   * @param criteria Selection object with optional fields: `id` targets one specific
   *   session; `user` (`Pick<User, 'id'>`) targets all sessions for that user; and
   *   `excludeId` removes all of a user's sessions except the given one (used to
   *   invalidate sibling sessions on token rotation).
   * @returns A `Promise<void>` that resolves once the matching sessions are removed.
   */
  async softDelete(criteria: {
    id?: Session['id'];
    user?: Pick<User, 'id'>;
    excludeId?: Session['id'];
  }): Promise<void> {
    // KNOWN ISSUE: despite the name `softDelete`, the bound `SessionDocumentRepository`
    // performs a HARD delete via `deleteMany(...)`, so sessions are physically removed
    // even though `SessionSchemaClass` declares a `deletedAt` field. Behavior is
    // documented here and intentionally left unchanged (additive-only task).
    // Source: backend/src/session/infrastructure/document/repositories/session.repository.ts:L54
    await this.sessionRepository.softDelete(criteria);
  }
}
