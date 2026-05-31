// NOTE: 'PantryIngridient', 'PantryIngridientSchemaClass' spellings preserved
// verbatim. Do not rename.
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { now, HydratedDocument } from 'mongoose';
import { EntityDocumentHelper } from 'src/utils/document-entity-helper';
import { IngridientSchemaClass } from 'src/ingridient/infrastructure/document/entities/ingridient.schema';

export type PantryIngridientSchemaDocument =
  HydratedDocument<PantryIngridientSchemaClass>;

/**
 * Mongoose schema class for pantry items (spelling preserved verbatim).
 *
 * Decorated with @Schema({ timestamps: true }) so Mongoose auto-maintains
 * createdAt and updatedAt. Declares a `location` enum
 * ('fridge' | 'freezer' | 'pantry') on the `location` field — note
 * that this enum is not currently mirrored by an @IsEnum on the DTO, so
 * invalid values surface as Mongoose write-time errors rather than
 * ValidationPipe 400s. An index on the `userId` field supports user-scoped
 * queries.
 *
 * See ../../../../../../DATA_MODEL.md § PantryIngridient for the full field
 * reference. Per-field @Prop() declarations are intentionally NOT
 * JSDoc-annotated; the schema is documented holistically in DATA_MODEL.md.
 */
@Schema({
  timestamps: true,
  toJSON: {
    virtuals: true,
    getters: true,
  },
})
export class PantryIngridientSchemaClass extends EntityDocumentHelper {
  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: 'IngridientSchemaClass' })
  ingridient: IngridientSchemaClass;

  @Prop()
  quantity: number;

  @Prop()
  userId: string;

  @Prop()
  unit: string;

  @Prop()
  expirationDate?: Date;

  @Prop({ enum: ['fridge', 'freezer', 'pantry'] })
  location: 'fridge' | 'freezer' | 'pantry';

  @Prop({ default: now })
  createdAt: Date;

  @Prop({ default: now })
  updatedAt: Date;

  @Prop()
  deletedAt?: Date;
}

export const PantryIngridientSchema = SchemaFactory.createForClass(
  PantryIngridientSchemaClass,
);

PantryIngridientSchema.index({ userId: 1 });
