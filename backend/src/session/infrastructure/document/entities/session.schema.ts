import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { now, HydratedDocument } from 'mongoose';
import { UserSchemaClass } from 'src/users/infrastructure/document/entities/user.schema';
import { EntityDocumentHelper } from 'src/utils/document-entity-helper';

export type SessionSchemaDocument = HydratedDocument<SessionSchemaClass>;

/**
 * Mongoose schema / persistence entity for the `sessions` collection.
 *
 * Backs JWT refresh-token rotation: a session is created at login, looked up
 * during refresh, and removed at logout. Configured with `timestamps: true`
 * (Mongoose auto-manages `createdAt`/`updatedAt`) and
 * `toJSON: { virtuals: true, getters: true }` so virtuals/getters survive JSON
 * serialization. Extends `EntityDocumentHelper`, which supplies the `_id`/`id`
 * plumbing (the `_id` is stringified on serialization).
 *
 * Source: backend/src/session/infrastructure/document/entities/session.schema.ts:L8-L15
 */
@Schema({
  timestamps: true,
  toJSON: {
    virtuals: true,
    getters: true,
  },
})
export class SessionSchemaClass extends EntityDocumentHelper {
  // ObjectId reference to the owning user document (ref: 'UserSchemaClass').
  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: 'UserSchemaClass' })
  user: UserSchemaClass;

  // Creation timestamp; defaults to `now` at insert time.
  @Prop({ default: now })
  createdAt: Date;

  // Soft-deletion timestamp (declared, intended for soft delete).
  // KNOWN ISSUE: not honored at runtime — the repository hard-deletes via
  // `deleteMany`, so `deletedAt` is never set on removal.
  // Source: backend/src/session/infrastructure/document/repositories/session.repository.ts:L54
  @Prop()
  deletedAt: Date;
}

export const SessionSchema = SchemaFactory.createForClass(SessionSchemaClass);

// Secondary index on `user` to speed user-scoped session lookups.
SessionSchema.index({ user: 1 });
