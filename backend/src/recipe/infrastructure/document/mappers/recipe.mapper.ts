import { Recipe } from '../../../domain/recipe';
import { RecipeSchemaClass } from '../entities/recipe.schema';
import { IngridientMapper } from 'src/ingridient/infrastructure/document/mappers/ingridient.mapper';
import { IngridientSchemaClass } from 'src/ingridient/infrastructure/document/entities/ingridient.schema';

export class RecipeMapper {
  static toDomain(raw: RecipeSchemaClass): Recipe {
    const recipe = new Recipe();
    recipe.id = raw._id.toString();
    recipe.title = raw.title;
    recipe.description = raw.description;

    recipe.ingridientList = raw.ingridientList.map((ingredient) => {
      const ingridientDomain = ingredient.ingridient
        ? IngridientMapper.toDomain(
            ingredient.ingridient as IngridientSchemaClass,
          )
        : null;

      return {
        ingridient: ingridientDomain,
        amount: ingredient.amount,
        unit: ingredient.unit,
        required: ingredient.required,
        substitutes: ingredient.substitutes,
      };
    });

    recipe.instructions = raw.instructions.map((instruction) => ({
      step: instruction.step,
      description: instruction.description,
      timer: instruction.timer,
    }));

    recipe.prepTime = raw.prepTime;
    recipe.cookTime = raw.cookTime;
    recipe.servings = raw.servings;
    recipe.difficulty = raw.difficulty;
    recipe.tags = raw.tags;
    recipe.imageUrl = raw.imageUrl;
    recipe.matchScore = raw.matchScore;
    recipe.createdAt = raw.createdAt;
    recipe.updatedAt = raw.updatedAt;
    recipe.deletedAt = raw.deletedAt;

    return recipe;
  }

  static toPersistence(recipe: Recipe): Partial<RecipeSchemaClass> {
    const recipeEntity: Partial<RecipeSchemaClass> = {};

    if (recipe.id && typeof recipe.id === 'string') {
      recipeEntity._id = recipe.id;
    }
    recipeEntity.title = recipe.title;
    recipeEntity.description = recipe.description;
    recipeEntity.ingridientList = recipe.ingridientList.map((ingredient) => ({
      ingridient: IngridientMapper.toPersistence(
        ingredient.ingridient,
      ) as IngridientSchemaClass,
      amount: ingredient.amount,
      unit: ingredient.unit,
      required: ingredient.required,
      substitutes: ingredient.substitutes,
    }));
    recipeEntity.instructions = recipe.instructions.map((instruction) => ({
      step: instruction.step,
      description: instruction.description,
      timer: instruction.timer,
    }));
    recipeEntity.prepTime = recipe.prepTime;
    recipeEntity.cookTime = recipe.cookTime;
    recipeEntity.servings = recipe.servings;
    recipeEntity.difficulty = recipe.difficulty;
    recipeEntity.tags = recipe.tags;
    recipeEntity.imageUrl = recipe.imageUrl;
    recipeEntity.matchScore = recipe.matchScore;
    recipeEntity.createdAt = recipe.createdAt;
    recipeEntity.updatedAt = recipe.updatedAt;
    recipeEntity.deletedAt = recipe.deletedAt;

    return recipeEntity;
  }
}
