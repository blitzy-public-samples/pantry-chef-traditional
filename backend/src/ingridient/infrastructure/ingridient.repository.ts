import { Ingridient } from '../domain/ingrident';
import { NullableType } from 'src/utils/types/nullable.type';
import { EntityCondition } from 'src/utils/types/entity-condition.type';
import { DeepPartial } from 'src/utils/types/deep-partial.type';
import { IPaginationOptions } from 'src/utils/types/pagination-options';
import { SortIngridientDto } from '../dto/query-ingridient.dto';

/**
 * Abstract persistence contract for the ingredient catalog feature.
 *
 * Declares the full data-access lifecycle (create, paginated listing, single
 * lookup, partial update, and soft delete) without binding to any storage
 * technology. The Mongoose adapter `IngridientDocumentRepository` implements
 * this contract and is bound to this token via dependency injection in
 * `DocumentIngridientPersistenceModule` (provide/useClass). `IngridientService`
 * depends only on this abstraction.
 *
 * The misspelling `Ingridient` is an intentional, preserved identifier.
 */
export abstract class IngridientRepository {
  /**
   * Persists a new ingredient.
   *
   * @param data the ingredient to create; `id`, `createdAt`, `updatedAt`, and
   *   `deletedAt` are assigned by the store, not the caller.
   * @returns the persisted `Ingridient` domain object.
   */
  abstract create(
    data: Omit<Ingridient, 'id' | 'createdAt' | 'deletedAt' | 'updatedAt'>,
  ): Promise<Ingridient>;

  /**
   * Returns a page of ingredients matching optional filter and sort options.
   *
   * @param options pagination/filter/sort container.
   * @param options.filterOptions optional case-insensitive name filter string.
   * @param options.sortOptions optional list of `SortIngridientDto` directives.
   * @param options.paginationOptions `page`/`limit` pagination controls.
   * @returns the matching `Ingridient` records for the requested page.
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
   * Finds a single ingredient matching the given entity condition.
   *
   * @param fields an `EntityCondition<Ingridient>` predicate (e.g. `{ id }`).
   * @returns the matching `Ingridient`, or `null` when none matches.
   */
  abstract findOne(
    fields: EntityCondition<Ingridient>,
  ): Promise<NullableType<Ingridient>>;

  /**
   * Applies a partial update to the ingredient identified by `id`.
   *
   * @param id the ingredient id (`Ingridient['id']`).
   * @param payload a `DeepPartial<Ingridient>` of fields to update.
   * @returns the updated `Ingridient`, or `null` when the id does not exist.
   */
  abstract update(
    id: Ingridient['id'],
    payload: DeepPartial<Ingridient>,
  ): Promise<Ingridient | null>;

  /**
   * Soft-deletes the ingredient identified by `id`.
   *
   * The concrete adapter performs a true soft delete (it sets `deletedAt`
   * rather than removing the document).
   *
   * @param id the ingredient id (`Ingridient['id']`).
   * @returns nothing once the record is marked deleted.
   */
  abstract softDelete(id: Ingridient['id']): Promise<void>;
}
