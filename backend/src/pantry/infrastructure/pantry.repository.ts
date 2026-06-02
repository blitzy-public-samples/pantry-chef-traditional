import { PantryIngridient } from '../domain/pantryIngridient';
import { NullableType } from 'src/utils/types/nullable.type';
import { EntityCondition } from 'src/utils/types/entity-condition.type';
import { DeepPartial } from 'src/utils/types/deep-partial.type';
import {
  FilterPantryIngridientDto,
  SortPantryIngridientDto,
} from '../dto/query-pantry-ingridient.dto';
import { IPaginationOptions } from 'src/utils/types/pagination-options';

/**
 * Persistence contract for pantry ingredients; implemented by the document
 * repository. It defines the CRUD-style surface (create, paginated list,
 * owner-scoped list, single lookup, partial update, delete) over the
 * `PantryIngridient` domain model, decoupled from any database technology and
 * bound to a concrete implementation via a NestJS DI token.
 */
export abstract class PantryRepository {
  /**
   * Persists a new pantry ingredient and returns the stored record.
   * @param data The new pantry ingredient without system-managed fields; type
   * is `Omit<PantryIngridient, 'id' | 'createdAt' | 'deletedAt' | 'updatedAt'>`
   * (these four are assigned by persistence).
   * @returns A `Promise<PantryIngridient>` resolving to the persisted entity
   * with generated `id` and timestamps.
   */
  abstract create(
    data: Omit<
      PantryIngridient,
      'id' | 'createdAt' | 'deletedAt' | 'updatedAt'
    >,
  ): Promise<PantryIngridient>;

  /**
   * Returns a filtered, sorted, paginated list of pantry ingredients.
   * @param filterOptions Optional `FilterPantryIngridientDto | null`. NOTE: the
   * DTO declares `id`, but the document implementation applies only `userId`
   * scoping and does not use `id`. Source:
   * backend/src/pantry/infrastructure/document/repositories/pantryIngridient.repository.ts:L98-L99
   * @param sortOptions Optional `SortPantryIngridientDto[] | null` of
   * orderBy/order pairs.
   * @param paginationOptions The `IPaginationOptions` (page and limit).
   * @returns A `Promise<PantryIngridient[]>` for the matching page.
   */
  abstract findManyWithPagination({
    filterOptions,
    sortOptions,
    paginationOptions,
  }: {
    filterOptions?: FilterPantryIngridientDto | null;
    sortOptions?: SortPantryIngridientDto[] | null;
    paginationOptions: IPaginationOptions;
  }): Promise<PantryIngridient[]>;

  /**
   * Returns all pantry ingredients owned by the given user.
   * @param userId The owner's id used to scope results.
   * @returns A `Promise<PantryIngridient[]>`.
   */
  abstract findAllByUserId(userId: string): Promise<PantryIngridient[]>;

  /**
   * Finds a single pantry ingredient matching the given condition.
   * @param fields An `EntityCondition<PantryIngridient>` (e.g., `{ id }`).
   * @returns A `Promise<NullableType<PantryIngridient>>`; resolves `null` when
   * no record matches.
   */
  abstract findOne(
    fields: EntityCondition<PantryIngridient>,
  ): Promise<NullableType<PantryIngridient>>;

  /**
   * Applies a partial update to the pantry ingredient identified by `id`.
   * @param id The target record id (`PantryIngridient['id']`).
   * @param payload A `DeepPartial<PantryIngridient>` of fields to change.
   * @returns A `Promise<PantryIngridient | null>`; the updated entity, or
   * `null` when not found.
   */
  abstract update(
    id: PantryIngridient['id'],
    payload: DeepPartial<PantryIngridient>,
  ): Promise<PantryIngridient | null>;

  /**
   * Removes (deletes) the pantry ingredient identified by `id`.
   * @param id The target record id (`PantryIngridient['id']`).
   * @returns A `Promise<void>`.
   */
  // Implementations remove/disable the record; the document impl HARD-deletes. See
  // backend/src/pantry/infrastructure/document/repositories/pantryIngridient.repository.ts:L120
  abstract softDelete(id: PantryIngridient['id']): Promise<void>;
}
