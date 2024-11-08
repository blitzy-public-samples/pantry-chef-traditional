import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { now, HydratedDocument } from 'mongoose';
import { EntityDocumentHelper } from 'src/utils/document-entity-helper';
import { IngridientSchemaClass } from 'src/ingridient/infrastructure/document/entities/ingridient.schema';

export type PantryIngridientSchemaDocument =
  HydratedDocument<PantryIngridientSchemaClass>;

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
