// NOTE: 'ingridientList' field name preserved verbatim across the mapper. Do not rename.
import { Recipe } from '../../../domain/recipe';
import { RecipeSchemaClass } from '../entities/recipe.schema';
import { IngridientMapper } from 'src/ingridient/infrastructure/document/mappers/ingridient.mapper';
import { IngridientSchemaClass } from 'src/ingridient/infrastructure/document/entities/ingridient.schema';

/**
 * Maps RecipeSchemaClass (Mongoose document) to the Recipe domain entity
 * and back. Preserves the IngridientList sub-array (spelling preserved
 * verbatim) and the optional matchScore populated only by matches().
 */
export class RecipeMapper {
  /**
   * Convert a Mongoose RecipeSchemaClass document into the Recipe domain entity.
   *
   * Walks the embedded `ingridientList` (spelling preserved verbatim) array and
   * delegates ingredient mapping to `IngridientMapper.toDomain`. Copies through
   * all primitive fields plus `matchScore`, `createdAt`, `updatedAt`, `deletedAt`.
   *
   * @param raw Mongoose hydrated document.
   * @returns Recipe domain entity ready to be returned by the service layer.
   */
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

  /**
   * Convert a Recipe domain entity into a `Partial<RecipeSchemaClass>` payload
   * suitable for `new this.recipeModel(persistenceModel)` construction.
   *
   * Delegates per-ingredient mapping to `IngridientMapper.toPersistence` and
   * preserves the `ingridientList` field name verbatim across the sub-schema.
   *
   * @param recipe Recipe domain entity (typically the CreateRecipeDto payload
   *   spread into a Recipe-shaped object by the service layer).
   * @returns Partial<RecipeSchemaClass> ready for Mongoose persistence.
   */
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
