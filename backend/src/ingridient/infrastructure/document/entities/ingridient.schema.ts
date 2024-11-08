import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { now, HydratedDocument } from 'mongoose';
import { Exclude } from 'class-transformer';
import { EntityDocumentHelper } from 'src/utils/document-entity-helper';
import { Reference } from 'src/common/types';

export type IngridientSchemaDocument = HydratedDocument<IngridientSchemaClass>;

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

export const IngridientSchema = SchemaFactory.createForClass(
  IngridientSchemaClass,
);
