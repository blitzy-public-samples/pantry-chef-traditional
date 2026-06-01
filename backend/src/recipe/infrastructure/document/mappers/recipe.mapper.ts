import { Recipe } from '../../../domain/recipe';
import { RecipeSchemaClass } from '../entities/recipe.schema';
import { IngridientMapper } from 'src/ingridient/infrastructure/document/mappers/ingridient.mapper';
import { IngridientSchemaClass } from 'src/ingridient/infrastructure/document/entities/ingridient.schema';

/**
 * Stateless converter between the persisted `RecipeSchemaClass` document and the
 * domain `Recipe` entity. Exposes only static methods and performs no I/O or
 * side effects, centralizing field-by-field mapping for the recipe document layer.
 *
 * Source: backend/src/recipe/infrastructure/document/mappers/recipe.mapper.ts:L6
 */
export class RecipeMapper {
  /**
   * Converts a persisted recipe document into a domain `Recipe` instance.
   *
   * Maps the nested `ingridientList`, resolving each embedded `ingridient` via
   * `IngridientMapper.toDomain(...)` only when the reference is populated, and
   * using `null` otherwise. Maps `instructions` and copies the scalar fields
   * (`title`, `description`, `prepTime`, `cookTime`, `servings`, `difficulty`,
   * `tags`, `imageUrl`, `matchScore`, `createdAt`, `updatedAt`, `deletedAt`).
   *
   * @param raw the `RecipeSchemaClass` document loaded from MongoDB
   * @returns the mapped domain `Recipe`
   *
   * Source: backend/src/recipe/infrastructure/document/mappers/recipe.mapper.ts:L7-L47
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
   * Converts a domain `Recipe` into a partial persistence document for writes.
   *
   * Assigns `_id` only when `recipe.id` is a string. Maps the nested
   * `ingridientList` and `instructions` back to persistence form, delegating
   * embedded ingredients to `IngridientMapper.toPersistence(...)` (cast to
   * `IngridientSchemaClass`).
   *
   * @param recipe the domain `Recipe` to serialize
   * @returns a `Partial<RecipeSchemaClass>` for database writes
   *
   * Source: backend/src/recipe/infrastructure/document/mappers/recipe.mapper.ts:L49-L83
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
