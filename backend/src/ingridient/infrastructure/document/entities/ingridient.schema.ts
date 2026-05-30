import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { now, HydratedDocument } from 'mongoose';
import { Exclude } from 'class-transformer';
import { EntityDocumentHelper } from 'src/utils/document-entity-helper';
import { Reference } from 'src/common/types';

// NOTE: 'Ingridient', 'IngridientSchemaClass' spellings preserved verbatim. Do not rename.

/**
 * Hydrated Mongoose document type for IngridientSchemaClass
 * (spelling preserved verbatim across the backend codebase).
 */
export type IngridientSchemaDocument = HydratedDocument<IngridientSchemaClass>;

/**
 * Mongoose schema class for ingridients (spelling preserved verbatim).
 *
 * References the shared common/types.ts `Reference` type for `category`
 * and `unit` fields. Soft-delete via deletedAt (proper).
 *
 * See ../../../../../DATA_MODEL.md § Ingridient for the full field reference.
 */
@Schema({
  timestamps: true,
  toJSON: {
    virtuals: true,
    getters: true,
  },
})
export class IngridientSchemaClass extends EntityDocumentHelper {
  @Prop()
  name: string;

  @Prop({ type: { id: Number, name: String } })
  category: Reference;

  @Prop()
  quantity?: number;

  @Exclude({ toPlainOnly: true })
  @Prop({ type: { id: Number, name: String } })
  unit?: Reference;

  @Exclude({ toPlainOnly: true })
  @Prop()
  expirationDate?: Date;

  @Exclude({ toPlainOnly: true })
  @Prop()
  imageUrl?: string;

  @Exclude({ toPlainOnly: true })
  @Prop()
  confidence: number;

  @Prop({ default: now })
  createdAt: Date;

  @Prop({ default: now })
  updatedAt: Date;

  @Prop()
  deletedAt?: Date;
}

/**
 * Compiled Mongoose schema for IngridientSchemaClass, produced by
 * SchemaFactory and registered with MongooseModule.forFeature
 * (spelling preserved verbatim).
 */
export const IngridientSchema = SchemaFactory.createForClass(
  IngridientSchemaClass,
);
