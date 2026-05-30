import { Ingridient } from '../domain/ingrident';
import { NullableType } from 'src/utils/types/nullable.type';
import { EntityCondition } from 'src/utils/types/entity-condition.type';
import { DeepPartial } from 'src/utils/types/deep-partial.type';
import { IPaginationOptions } from 'src/utils/types/pagination-options';
import { SortIngridientDto } from '../dto/query-ingridient.dto';

// NOTE: 'Ingridient', 'IngridientRepository' spellings preserved verbatim. Do not rename.

/**
 * Abstract repository contract for the Ingridient aggregate
 * (spelling preserved verbatim across the backend codebase).
 *
 * Concrete implementation lives in document/repositories/ingridient.repository.ts
 * (Mongoose-backed). softDelete is properly implemented via
 * updateOne({ deletedAt: new Date() }).
 */
export abstract class IngridientRepository {
  /**
   * Persist a new Ingridient record (spelling preserved verbatim).
   *
   * @param data Ingridient fields excluding system-managed id, timestamps,
   *   and deletedAt.
   * @returns The persisted Ingridient domain entity.
   */
  abstract create(
    data: Omit<Ingridient, 'id' | 'createdAt' | 'deletedAt' | 'updatedAt'>,
  ): Promise<Ingridient>;

  /**
   * Paginated, optionally filtered and sorted list of Ingridient records
   * (spelling preserved verbatim).
   *
   * @param params.filterOptions Optional free-text name fragment.
   * @param params.sortOptions Optional `SortIngridientDto[]` directives.
   * @param params.paginationOptions `{ page, limit }` (controller hard-caps limit at 50).
   * @returns Page of Ingridient domain entities.
   */
  abstract findManyWithPagination({
    filterOptions,
    sortOptions,
    paginationOptions,
  }: {
    filterOptions?: string | null;
    sortOptions?: SortIngridientDto[] | null;
    paginationOptions: IPaginationOptions;
  }): Promise<Ingridient[]>;

  /**
   * Find a single Ingridient by arbitrary entity conditions
   * (spelling preserved verbatim).
   *
   * @param fields `EntityCondition<Ingridient>` (typically `{ id }` or
   *   `{ name }`).
   * @returns Matching Ingridient or null.
   */
  abstract findOne(
    fields: EntityCondition<Ingridient>,
  ): Promise<NullableType<Ingridient>>;

  /**
   * Apply a partial update to an Ingridient (spelling preserved verbatim).
   *
   * @param id MongoDB ObjectId string.
   * @param payload Sparse field overrides.
   * @returns The updated Ingridient, or null when the id is not found.
   */
  abstract update(
    id: Ingridient['id'],
    payload: DeepPartial<Ingridient>,
  ): Promise<Ingridient | null>;

  /**
   * Soft-delete by id (spelling preserved verbatim).
   *
   * Concrete implementation sets `deletedAt: new Date()` rather than
   * physically removing the document (Source: document/repositories/ingridient.repository.ts:L94-L99).
   */
  abstract softDelete(id: Ingridient['id']): Promise<void>;
}
