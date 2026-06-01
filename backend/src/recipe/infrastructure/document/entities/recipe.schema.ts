import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { now, HydratedDocument } from 'mongoose';
import { EntityDocumentHelper } from 'src/utils/document-entity-helper';
import { IngridientSchemaClass } from 'src/ingridient/infrastructure/document/entities/ingridient.schema';

/**
 * Embedded subdocument representing one ingredient line of a recipe. Links a
 * persisted ingredient document to its amount, unit, requirement flag, and
 * optional substitutes. Spelling of `IngridientList` is intentional.
 */
@Schema()
export class IngridientList {
  // References the persisted ingredient document by ObjectId; required.
  @Prop({
    type: mongoose.Schema.Types.ObjectId,
    ref: 'IngridientSchemaClass',
    required: true,
  })
  ingridient: IngridientSchemaClass;

  // Quantity for this ingredient line; required number.
  @Prop({ type: Number, required: true })
  amount: number;

  // Unit of measure for the amount; required string.
  @Prop({ type: String, required: true })
  unit: string;

  // Whether this ingredient is mandatory for the recipe; required boolean.
  @Prop({ type: Boolean, required: true })
  required: boolean;

  // Optional substitute ingredient names; defaults to an empty array.
  @Prop({ type: [String], default: [] })
  substitutes?: string[];
}

// Compiled Mongoose schema for the IngridientList embedded subdocument.
export const IngridientListSchema =
  SchemaFactory.createForClass(IngridientList);

/**
 * Describes a single recipe preparation step.
 */
export class Instruction {
  // Ordinal position of this step in the instruction list; required.
  @Prop({ type: Number, required: true })
  step: number;

  // Text describing the step; required string.
  @Prop({ type: String, required: true })
  description: string;

  // Optional timer duration for the step.
  @Prop({ type: Number })
  timer?: number;
}

// Literal union of recipe difficulty levels: 'easy' | 'medium' | 'hard'.
export type Difficulty = 'easy' | 'medium' | 'hard';

// Hydrated Mongoose document type for RecipeSchemaClass.
export type RecipeDocument = HydratedDocument<RecipeSchemaClass>;

/**
 * Primary Mongoose schema for recipe documents. Extends `EntityDocumentHelper`
 * for shared `_id` serialization, enables `timestamps`, and includes virtuals
 * and getters when serializing via `toJSON` and `toObject`.
 */
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
  // Explicit ObjectId property declared alongside the inherited _id.
  @Prop({ type: mongoose.Schema.Types.ObjectId })
  id: string;

  // Recipe title; required.
  @Prop({ required: true })
  title: string;

  // Free-text recipe description.
  @Prop()
  description: string;

  // Embedded ingredient lines (IngridientList[]); required. Spelling preserved.
  @Prop({ type: [IngridientListSchema], required: true })
  ingridientList: IngridientList[];

  // Ordered preparation steps (Instruction[]); required.
  @Prop({ type: [Instruction], required: true })
  instructions: Instruction[];

  // Preparation time in minutes.
  @Prop()
  prepTime: number;

  // Cooking time in minutes.
  @Prop()
  cookTime: number;

  // Number of servings the recipe yields.
  @Prop()
  servings: number;

  // Difficulty constrained to the enum: easy | medium | hard; required.
  @Prop({ type: String, enum: ['easy', 'medium', 'hard'], required: true })
  difficulty: Difficulty;

  // Free-form tags used for categorization and search.
  @Prop([String])
  tags: string[];

  // URL of the recipe image.
  @Prop()
  imageUrl: string;

  // Optional match score (0 to 1) populated by the recipe matching logic.
  @Prop()
  matchScore?: number;

  // Creation timestamp; defaults to now.
  @Prop({ default: now })
  createdAt: Date;

  // Last-update timestamp; defaults to now.
  @Prop({ default: now })
  updatedAt: Date;

  // Soft-delete marker; set when the recipe is soft-deleted, else undefined.
  @Prop()
  deletedAt?: Date;
}

// Compiled Mongoose schema used to register the recipe model.
export const RecipeSchema = SchemaFactory.createForClass(RecipeSchemaClass);

// Secondary ascending index on title to optimize title lookups.
RecipeSchema.index({ title: 1 });
