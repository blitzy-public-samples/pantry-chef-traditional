import { Ingridient } from 'src/ingridient/domain/ingrident';

/**
 * Framework-agnostic domain model representing a single recipe.
 *
 * `Recipe` is the canonical in-memory shape consumed by the recipe module's
 * service, controller, and DTO layers. It is a plain class with no decorators,
 * validation, or persistence logic of its own. The Mongoose persistence entity
 * `RecipeSchemaClass` is converted to and from this model by `RecipeMapper`
 * (`toDomain` builds a `new Recipe()`; `toPersistence` maps back).
 *
 * Source: backend/src/recipe/infrastructure/document/mappers/recipe.mapper.ts:L28,L83
 * Source: backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L81
 */
export class Recipe {
  // Unique recipe identifier (Mongo document _id rendered as a string).
  id: string;
  // Recipe title; enforced unique at creation time by RecipeService.
  title: string;
  // Long-form description / summary of the recipe.
  description: string;
  // Recipe ingredients (sic spelling): { ingridient, amount, unit, required, substitutes? }[].
  ingridientList: {
    ingridient: Ingridient;
    amount: number;
    unit: string;
    required: boolean;
    substitutes?: string[];
  }[];
  // Ordered preparation steps: { step, description, optional timer }[].
  instructions: {
    step: number;
    description: string;
    timer?: number;
  }[];
  // Preparation time required before cooking.
  prepTime: number;
  // Active cooking time.
  cookTime: number;
  // Number of servings the recipe yields.
  servings: number;
  // Difficulty level; one of the union 'easy' | 'medium' | 'hard'.
  difficulty: 'easy' | 'medium' | 'hard';
  // Free-form categorization labels (e.g., cuisine or dietary tags).
  tags: string[];
  // Optional URL of the recipe image.
  imageUrl?: string;
  // Optional match ratio in 0..1 populated by the matching engine (recipe.repository.ts:L137).
  matchScore?: number;
  // Creation timestamp.
  createdAt?: Date;
  // Last-update timestamp.
  updatedAt?: Date;
  // Soft-delete marker; set when the recipe is soft-deleted, otherwise undefined.
  deletedAt?: Date;
}
