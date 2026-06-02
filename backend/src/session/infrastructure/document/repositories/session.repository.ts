import { Injectable } from '@nestjs/common';
import { NullableType } from '../../../../utils/types/nullable.type';
import { SessionRepository } from '../../session.repository';
import { Session } from '../../../domain/session';
import { SessionSchemaClass } from '../entities/session.schema';
import { Model } from 'mongoose';
import { InjectModel } from '@nestjs/mongoose';
import { User } from 'src/users/domain/user';
import { EntityCondition } from 'src/utils/types/entity-condition.type';
import { SessionMapper } from '../mappers/session.mapper';

/**
 * Mongoose-backed implementation of the abstract `SessionRepository` contract.
 *
 * Bound to the `SessionRepository` token by `DocumentSessionPersistenceModule`
 * via `{ provide: SessionRepository, useClass: SessionDocumentRepository }`, so the
 * application / auth layer depends on the abstraction rather than on Mongoose.
 * Source: backend/src/session/infrastructure/document/document-persistence.module.ts:L37-L38
 *
 * Injects the `SessionSchemaClass` Mongoose model and converts between persistence
 * documents and the domain `Session` via `SessionMapper`. Implements three
 * operations: `findOne`, `create`, and `softDelete`.
 *
 */
@Injectable()
export class SessionDocumentRepository implements SessionRepository {
  // `@InjectModel(SessionSchemaClass.name)` injects the Mongoose `sessionModel`
  // (`Model<SessionSchemaClass>`) used by all three repository methods.
  constructor(
    @InjectModel(SessionSchemaClass.name)
    private sessionModel: Model<SessionSchemaClass>,
  ) {}

  /**
   * Finds a single session matching the supplied query conditions.
   *
   * Uses `findById` when `fields.id` is present; otherwise issues a generic
   * `findOne(fields)` lookup against the Mongoose model.
   *
   * @param fields The `EntityCondition<Session>` query (e.g. `{ id }` or `{ user }`).
   * @returns The matched session mapped to the domain via `SessionMapper.toDomain`,
   *   or `null` (`NullableType<Session>`) when no document matches.
   */
  async findOne(
    fields: EntityCondition<Session>,
  ): Promise<NullableType<Session>> {
    if (fields.id) {
      // Direct primary-key lookup when an `id` is supplied.
      const sessionObject = await this.sessionModel.findById(fields.id);
      return sessionObject ? SessionMapper.toDomain(sessionObject) : null;
    }

    // Fallback: query by the remaining entity conditions.
    const sessionObject = await this.sessionModel.findOne(fields);
    return sessionObject ? SessionMapper.toDomain(sessionObject) : null;
  }

  /**
   * Persists a new session.
   *
   * @param data The domain `Session` to persist.
   * @returns A `Promise<Session>` resolving to the saved session, re-mapped to the
   *   domain via `SessionMapper.toDomain`.
   */
  async create(data: Session): Promise<Session> {
    // Flow: map domain -> persistence (SessionMapper.toPersistence), construct a
    // `sessionModel` document, persist via `.save()`, then map back via toDomain.
    const persistenceModel = SessionMapper.toPersistence(data);
    const createdSession = new this.sessionModel(persistenceModel);
    const sessionObject = await createdSession.save();
    return SessionMapper.toDomain(sessionObject);
  }

  /**
   * Removes the sessions selected by the supplied criteria.
   *
   * Builds `transformedCriteria` from the destructured argument: `user` comes from
   * `criteria.user?.id`; `_id` is `criteria.id`, or `{ $not: { $eq: excludeId } }` when
   * only `excludeId` is supplied, otherwise `undefined`.
   *
   * @param criteria Destructured selection object: `id` removes one specific session;
   *   `user` (`Pick<User, 'id'>`) removes all of a user's sessions; `excludeId` removes
   *   all of a user's sessions EXCEPT this one (used to invalidate sibling sessions on
   *   JWT refresh-token rotation).
   * @returns A `Promise<void>` that resolves once the matching sessions are removed.
   */
  async softDelete({
    excludeId,
    ...criteria
  }: {
    id?: Session['id'];
    user?: Pick<User, 'id'>;
    excludeId?: Session['id'];
  }): Promise<void> {
    const transformedCriteria = {
      user: criteria.user?.id,
      _id: criteria.id
        ? criteria.id
        : excludeId
          ? { $not: { $eq: excludeId } }
          : undefined,
    };
    // KNOWN ISSUE: this performs a HARD delete; sessions are physically removed,
    // not soft-deleted, even though `SessionSchemaClass` declares a `deletedAt` field.
    // Source: backend/src/session/infrastructure/document/entities/session.schema.ts:L39-L40
    await this.sessionModel.deleteMany(transformedCriteria);
  }
}
