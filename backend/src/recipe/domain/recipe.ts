// NOTE: 'Ingridient' import + 'ingridientList' field name preserved verbatim. Do not rename.
import { Ingridient } from 'src/ingridient/domain/ingrident';

/**
 * Domain entity returned by RecipeService methods.
 *
 * Includes the embedded `ingridientList` (spelling preserved verbatim) and
 * `instructions` arrays. The optional `matchScore` field is populated only
 * by the matches() flow (see RecipeRepository.matches in infrastructure/).
 */
export class Recipe {
  id: string;
  title: string;
  description: string;
  ingridientList: {
    ingridient: Ingridient;
    amount: number;
    unit: string;
    required: boolean;
    substitutes?: string[];
  }[];
  instructions: {
    step: number;
    description: string;
    timer?: number;
  }[];
  prepTime: number;
  cookTime: number;
  servings: number;
  difficulty: 'easy' | 'medium' | 'hard';
  tags: string[];
  imageUrl?: string;
  matchScore?: number;
  createdAt?: Date;
  updatedAt?: Date;
  deletedAt?: Date;
}
