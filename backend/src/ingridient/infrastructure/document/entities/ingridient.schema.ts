import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { now, HydratedDocument } from 'mongoose';
import { Exclude } from 'class-transformer';
import { EntityDocumentHelper } from 'src/utils/document-entity-helper';
import { Reference } from 'src/common/types';

/** Hydrated Mongoose document type for the ingredient schema. */
export type IngridientSchemaDocument = HydratedDocument<IngridientSchemaClass>;

/**
 * Mongoose document schema for persisted ingredient records.
 *
 * `timestamps: true` auto-manages `createdAt`/`updatedAt`; the `toJSON` options
 * enable virtuals and getters during serialization. Extends
 * `EntityDocumentHelper`, which exposes a stringified `_id`.
 *
 * The misspelling `Ingridient` is an intentional, preserved identifier.
 */
@Schema({
  timestamps: true,
  toJSON: {
    virtuals: true,
    getters: true,
  },
})
export class IngridientSchemaClass extends EntityDocumentHelper {
  // Display name of the ingredient.
  @Prop()
  name: string;

  // Category reference ({ id, name }) classifying the ingredient.
  @Prop({ type: { id: Number, name: String } })
  category: Reference;

  // Optional stored quantity.
  @Prop()
  quantity?: number;

  // Optional unit reference ({ id, name }); excluded from serialized output.
  @Exclude({ toPlainOnly: true })
  @Prop({ type: { id: Number, name: String } })
  unit?: Reference;

  // Optional expiration date; excluded from serialized output.
  @Exclude({ toPlainOnly: true })
  @Prop()
  expirationDate?: Date;

  // Optional image URL; excluded from serialized output.
  @Exclude({ toPlainOnly: true })
  @Prop()
  imageUrl?: string;

  // Recognition confidence score in the 0-1 range; excluded from output.
  @Exclude({ toPlainOnly: true })
  @Prop()
  confidence: number;

  // Creation timestamp; defaults to the current time.
  @Prop({ default: now })
  createdAt: Date;

  // Last-update timestamp; defaults to the current time.
  @Prop({ default: now })
  updatedAt: Date;

  // Soft-delete marker; set when the record is soft-deleted.
  @Prop()
  deletedAt?: Date;
}

// Compiled Mongoose schema used for model registration.
export const IngridientSchema = SchemaFactory.createForClass(
  IngridientSchemaClass,
);
