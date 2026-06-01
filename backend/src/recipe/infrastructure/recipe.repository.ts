// NOTE: 'PantryIngridient' and FilterType spellings preserved verbatim. Do not rename.
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
 * Abstract repository contract for the Recipe aggregate.
 *
 * Concrete implementation lives in document/repositories/recipe.repository.ts
 * (Mongoose-backed). Includes the headline matches() pantry-scoring algorithm.
 */
export abstract class RecipeRepository {
  /**
   * Persist a new recipe document.
   *
   * @param data Recipe payload without lifecycle fields (id, createdAt,
   *   updatedAt, deletedAt) — these are assigned by the persistence layer.
   * @returns The newly persisted Recipe domain entity.
   */
  abstract create(
    data: Omit<Recipe, 'id' | 'createdAt' | 'deletedAt' | 'updatedAt'>,
  ): Promise<Recipe>;

  /**
   * List recipes with pagination, filtering, and sorting support.
   *
   * @param params filterOptions (name regex / ids whitelist),
   *   sortOptions (optional list of sort directives),
   *   paginationOptions (page + limit).
   * @returns Recipe[] for the requested page (concrete implementation also
   *   excludes soft-deleted documents).
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
   * Pantry-aware recipe matching.
   *
   * Concrete implementation builds a Mongo pre-filter chain over the user's
   * `Preferences`, scores each remaining recipe by ingredient coverage, applies
   * a FilterType post-filter, and sorts by matchScore descending. See
   * `document/repositories/recipe.repository.ts:L92-L171` for the full algorithm
   * and `../../../../ARCHITECTURE.md` § Recipe Matching Pipeline for the deep-dive.
   *
   * @param preferences User dietary preferences and constraints.
   * @param pantryIngredients Current PantryIngridient[] (user-scoped — spelling
   *   preserved verbatim).
   * @param filterOptions Optional flags isQuickMake / isAlmostThere.
   * @returns Recipe[] sorted by matchScore descending.
   */
  abstract matches(
    preferences: Preferences,
    pantryIngredients: PantryIngridient[],
    filterOptions: FilterType,
  ): Promise<Recipe[]>;

  /**
   * Find a single recipe matching the given entity condition.
   *
   * @param fields Partial Recipe condition (typically `{ id }` or `{ title }`).
   * @returns Recipe domain entity, or null when no document matches.
   */
  abstract findOne(
    fields: EntityCondition<Recipe>,
  ): Promise<NullableType<Recipe>>;

  /**
   * Partial update of an existing recipe.
   *
   * @param id Recipe identifier (MongoDB ObjectId as string).
   * @param payload DeepPartial<Recipe> update payload.
   * @returns The updated Recipe domain entity, or null when the underlying
   *   findByIdAndUpdate returns no document.
   */
  abstract update(
    id: Recipe['id'],
    payload: DeepPartial<Recipe>,
  ): Promise<Recipe | null>;

  /**
   * Proper soft-delete: marks the recipe document with `deletedAt = new Date()`.
   *
   * Concrete implementation issues a Mongoose `updateOne({ _id }, { deletedAt })`
   * at `document/repositories/recipe.repository.ts:L184-L186`. The document is
   * preserved on disk and excluded from subsequent paginated listings via the
   * `deletedAt: null` filter clause.
   *
   * @param id Recipe identifier (MongoDB ObjectId as string).
   * @returns void on success.
   */
  abstract softDelete(id: Recipe['id']): Promise<void>;
}
