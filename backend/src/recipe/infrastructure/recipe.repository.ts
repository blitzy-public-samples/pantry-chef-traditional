import { Recipe } from '../domain/recipe';
import { NullableType } from 'src/utils/types/nullable.type';
import { EntityCondition } from 'src/utils/types/entity-condition.type';
import { DeepPartial } from 'src/utils/types/deep-partial.type';
import { IPaginationOptions } from 'src/utils/types/pagination-options';
import { FilterRecipeDto, SortRecipeDto } from '../dto/query-recipe.dto';
import { Preferences } from 'src/users/infrastructure/document/entities/user.schema';
import { PantryIngridient } from 'src/pantry/domain/pantryIngridient';
import { FilterType } from '../types/filter.types';

/**
 * Abstract persistence contract for the recipe feature. It defines the full lifecycle of
 * recipe data access (create, paginated listing, preference and pantry matching, single
 * lookup, partial update, and soft delete) without binding to any storage technology.
 *
 * Implemented by the Mongoose document adapter `RecipeDocumentRepository` and bound to this
 * abstract token via dependency injection using
 * `{ provide: RecipeRepository, useClass: RecipeDocumentRepository }`.
 * Source: backend/src/recipe/infrastructure/document/document-persistence.module.ts:L16-L21
 *
 * Consumed by `RecipeService`, the recipe business layer, so callers depend only on this
 * abstraction rather than on a concrete data store.
 */
export abstract class RecipeRepository {
  /**
   * Persists a new recipe and returns the created domain `Recipe`.
   *
   * @param data the recipe to create, typed as
   * `Omit<Recipe, 'id' | 'createdAt' | 'deletedAt' | 'updatedAt'>`; identity and lifecycle
   * timestamps are assigned by the store, not supplied by the caller.
   * @returns the persisted `Recipe`; the concrete adapter populates
   * `ingridientList.ingridient` before mapping the document back to the domain model.
   */
  abstract create(
    data: Omit<Recipe, 'id' | 'createdAt' | 'deletedAt' | 'updatedAt'>,
  ): Promise<Recipe>;

  /**
   * Returns a page of recipes matching the optional filter and sort options.
   *
   * @param options the query options object containing `filterOptions?`
   * (`FilterRecipeDto` with optional `name` and `ids` filters), `sortOptions?`
   * (`SortRecipeDto[] | null`), and `paginationOptions` (`IPaginationOptions` with
   * `page` and `limit`).
   * @returns the matching recipes for the requested page; the concrete implementation
   * excludes soft-deleted records by constraining `deletedAt: null`.
   */
  abstract findManyWithPagination({
    filterOptions,
    sortOptions,
    paginationOptions,
  }: {
    filterOptions?: FilterRecipeDto;
    sortOptions?: SortRecipeDto[] | null;
    paginationOptions: IPaginationOptions;
  }): Promise<Recipe[]>;

  /**
   * Returns recipes scored and ranked against a user's dietary preferences and current
   * pantry contents. This is the matching-engine contract for the recipe feature.
   *
   * @param preferences the user's `Preferences`; `allergies` and `dislikedIngredients`
   * exclude recipes, `dietary` tags must all be present, and `cookingTime` caps `cookTime`.
   * @param pantryIngredients the user's `PantryIngridient[]` whose ingredient ids drive the
   * ingredient-availability scoring.
   * @param filterOptions a `FilterType` of post-scoring flags (`isQuickMake`,
   * `isAlmostThere`).
   * @returns recipes with a computed `matchScore`, ordered by descending match score. The
   * scoring detail lives in the implementation:
   * Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L92-L171
   */
  abstract matches(
    preferences: Preferences,
    pantryIngredients: PantryIngridient[],
    filterOptions: FilterType,
  ): Promise<Recipe[]>;

  /**
   * Returns a single recipe matching the given condition, or `null` when none matches.
   *
   * @param fields an `EntityCondition<Recipe>` (for example `{ id }` or other recipe fields).
   * @returns the matching recipe, or `null` when no recipe satisfies the condition.
   */
  abstract findOne(
    fields: EntityCondition<Recipe>,
  ): Promise<NullableType<Recipe>>;

  /**
   * Applies a partial update to the recipe identified by `id`.
   *
   * @param id the recipe id (`Recipe['id']`).
   * @param payload a `DeepPartial<Recipe>` describing the fields to update.
   * @returns the updated `Recipe`, or `null` when the id does not exist.
   */
  abstract update(
    id: Recipe['id'],
    payload: DeepPartial<Recipe>,
  ): Promise<Recipe | null>;

  /**
   * Soft-deletes the recipe identified by `id`.
   *
   * The concrete adapter performs a TRUE soft delete: it sets `deletedAt` rather than
   * removing the document, in contrast to the hard-delete adapters in users, pantry, and
   * session.
   * Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L184-L186
   *
   * @param id the recipe id (`Recipe['id']`).
   * @returns nothing once the soft delete is applied.
   */
  abstract softDelete(id: Recipe['id']): Promise<void>;
}
