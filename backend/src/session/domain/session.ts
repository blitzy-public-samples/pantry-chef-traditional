import { User } from 'src/users/domain/user';

/**
 * In-memory domain model for an authenticated session.
 *
 * `Session` is the behavior-free canonical shape shared across the session service and the
 * infrastructure layer; it backs JWT refresh-token rotation. The class carries no methods,
 * decorators, or validation — it is a plain data contract.
 *
 * The persistence representation lives in `SessionSchemaClass`; conversion between this domain
 * model and that schema is handled by `SessionMapper`.
 *
 * Source: backend/src/session/infrastructure/document/entities/session.schema.ts
 * Source: backend/src/session/infrastructure/document/mappers/session.mapper.ts
 */
export class Session {
  // Unique session identifier (string | number); populated from the Mongoose document _id.
  id: number | string;

  // The owning User this session belongs to.
  user: User;

  // Timestamp marking when the session was created (schema default now).
  createdAt: Date;

  // Soft-deletion timestamp field.
  // KNOWN ISSUE: declared but NOT honored at runtime — the document repository
  // hard-deletes via deleteMany rather than setting this field.
  // Source: backend/src/session/infrastructure/document/repositories/session.repository.ts:L54
  deletedAt: Date;
}
