import { Ingridient } from 'src/ingridient/domain/ingrident';

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
