// NOTE: 'PantryIngridient' spelling preserved verbatim across the backend codebase. Do not rename.
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
 * Abstract repository contract for the PantryIngridient aggregate
 * (spelling preserved verbatim across the backend codebase).
 *
 * Concrete implementation lives in
 * document/repositories/pantryIngridient.repository.ts (Mongoose-backed).
 * The current `softDelete` implementation in that concrete class is
 * destructive — see ../README.md § Known Limitations and
 * ../../../../ARCHITECTURE.md § Soft-Delete Contract.
 */
export abstract class PantryRepository {
  /**
   * Persist a new PantryIngridient and return the populated domain entity.
   *
   * @param data PantryIngridient minus auto-managed timestamps/id fields.
   * @returns The created PantryIngridient.
   */
  abstract create(
    data: Omit<
      PantryIngridient,
      'id' | 'createdAt' | 'deletedAt' | 'updatedAt'
    >,
  ): Promise<PantryIngridient>;

  /**
   * List PantryIngridient records with filter, sort, and pagination.
   *
   * @returns Array of PantryIngridient matching the filter.
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
   * List every non-deleted PantryIngridient owned by a single userId.
   * Consumed by RecipeService.matches() to feed the recipe matching pipeline
   * (see ../../../../ARCHITECTURE.md § Recipe Matching Pipeline).
   *
   * @param userId Owner userId (scalar String, not ObjectId).
   * @returns All non-deleted PantryIngridient records for the user.
   */
  abstract findAllByUserId(userId: string): Promise<PantryIngridient[]>;

  /**
   * Find one PantryIngridient by an arbitrary EntityCondition.
   *
   * @param fields Conditions; typically `{ id }`.
   * @returns The PantryIngridient or null.
   */
  abstract findOne(
    fields: EntityCondition<PantryIngridient>,
  ): Promise<NullableType<PantryIngridient>>;

  /**
   * Apply a partial update to a PantryIngridient by id.
   *
   * @param id PantryIngridient _id.
   * @param payload Deep-partial update payload.
   * @returns The updated PantryIngridient or null if not found.
   */
  abstract update(
    id: PantryIngridient['id'],
    payload: DeepPartial<PantryIngridient>,
  ): Promise<PantryIngridient | null>;

  /**
   * Mark a PantryIngridient as deleted.
   *
   * NOTE: The Mongoose-backed concrete implementation
   * (PantryIngridientDocumentRepository.softDelete) currently calls
   * `deleteOne` and PHYSICALLY REMOVES the document. See ../README.md
   * § Known Limitations.
   *
   * @param id PantryIngridient _id.
   * @returns Promise<void>.
   */
  abstract softDelete(id: PantryIngridient['id']): Promise<void>;
}
