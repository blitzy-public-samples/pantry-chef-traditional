import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { now, HydratedDocument } from 'mongoose';
import { EntityDocumentHelper } from 'src/utils/document-entity-helper';
import { IngridientSchemaClass } from 'src/ingridient/infrastructure/document/entities/ingridient.schema';

@Schema()
export class IngridientList {
  @Prop({
    type: mongoose.Schema.Types.ObjectId,
    ref: 'IngridientSchemaClass',
    required: true,
  })
  ingridient: IngridientSchemaClass;

  @Prop({ type: Number, required: true })
  amount: number;

  @Prop({ type: String, required: true })
  unit: string;

  @Prop({ type: Boolean, required: true })
  required: boolean;

  @Prop({ type: [String], default: [] })
  substitutes?: string[];
}

export const IngridientListSchema =
  SchemaFactory.createForClass(IngridientList);

export class Instruction {
  @Prop({ type: Number, required: true })
  step: number;

  @Prop({ type: String, required: true })
  description: string;

  @Prop({ type: Number })
  timer?: number;
}

export type Difficulty = 'easy' | 'medium' | 'hard';

export type RecipeDocument = HydratedDocument<RecipeSchemaClass>;

@Schema({
  timestamps: true,
  toJSON: {
    virtuals: true,
    getters: true,
  },
  toObject: {
    virtuals: true,
    getters: true,
  },
})
export class RecipeSchemaClass extends EntityDocumentHelper {
  @Prop({ type: mongoose.Schema.Types.ObjectId })
  id: string;

  @Prop({ required: true })
  title: string;

  @Prop()
  description: string;

  @Prop({ type: [IngridientListSchema], required: true })
  ingridientList: IngridientList[];

  @Prop({ type: [Instruction], required: true })
  instructions: Instruction[];

  @Prop()
  prepTime: number;

  @Prop()
  cookTime: number;

  @Prop()
  servings: number;

  @Prop({ type: String, enum: ['easy', 'medium', 'hard'], required: true })
  difficulty: Difficulty;

  @Prop([String])
  tags: string[];

  @Prop()
  imageUrl: string;

  @Prop()
  matchScore?: number;

  @Prop({ default: now })
  createdAt: Date;

  @Prop({ default: now })
  updatedAt: Date;

  @Prop()
  deletedAt?: Date;
}

export const RecipeSchema = SchemaFactory.createForClass(RecipeSchemaClass);

RecipeSchema.index({ title: 1 });
