import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { now, HydratedDocument } from 'mongoose';
import { EntityDocumentHelper } from 'src/utils/document-entity-helper';
import { IngridientSchemaClass } from 'src/ingridient/infrastructure/document/entities/ingridient.schema';

export type PantryIngridientSchemaDocument =
  HydratedDocument<PantryIngridientSchemaClass>;

/**
 * Mongoose entity for a pantry ingredient; timestamps enabled; `toJSON`
 * exposes virtuals + getters. Extends `EntityDocumentHelper`, which supplies
 * the Mongo `_id` mapped to the domain `id`.
 */
@Schema({
  timestamps: true,
  toJSON: {
    virtuals: true,
    getters: true,
  },
})
export class PantryIngridientSchemaClass extends EntityDocumentHelper {
  // ObjectId reference to IngridientSchemaClass (the ingredient catalog entry)
  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: 'IngridientSchemaClass' })
  ingridient: IngridientSchemaClass;

  // amount of this ingredient on hand
  @Prop()
  quantity: number;

  // owner user id (indexed; scopes queries to one user)
  @Prop()
  userId: string;

  // unit of measure for the quantity (free-form string)
  @Prop()
  unit: string;

  // optional expiry date for the pantry item
  @Prop()
  expirationDate?: Date;

  // storage location; one of the enum values below
  // fridge = refrigerated; freezer = frozen; pantry = shelf-stable
  @Prop({ enum: ['fridge', 'freezer', 'pantry'] })
  location: 'fridge' | 'freezer' | 'pantry';

  // creation timestamp; defaults to now
  @Prop({ default: now })
  createdAt: Date;

  // last-update timestamp; defaults to now
  @Prop({ default: now })
  updatedAt: Date;

  // soft-delete marker; see KNOWN ISSUE — repo hard-deletes instead of setting this
  @Prop()
  deletedAt?: Date;
}

export const PantryIngridientSchema = SchemaFactory.createForClass(
  PantryIngridientSchemaClass,
);

// secondary index on { userId: 1 } for user-scoped lookups
PantryIngridientSchema.index({ userId: 1 });
