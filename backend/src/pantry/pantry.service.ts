// NOTE: 'PantryIngridient' spelling preserved verbatim across the backend. Do not rename.
import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { EntityCondition } from 'src/utils/types/entity-condition.type';
import { IPaginationOptions } from 'src/utils/types/pagination-options';
import { NullableType } from '../utils/types/nullable.type';
import { DeepPartial } from 'src/utils/types/deep-partial.type';
import { PantryIngridient } from './domain/pantryIngridient';
import { CreatePantryIngridientDto } from './dto/create-pantry-ingridient.dto';
import {
  SortPantryIngridientDto,
  FilterPantryIngridientDto,
} from './dto/query-pantry-ingridient.dto';
import { PantryRepository } from './infrastructure/pantry.repository';
import { UpdatePantryIngridientDto } from './dto/update-pantry-ingridient.dto';

/**
 * Service orchestrating PantryIngridient (spelling preserved verbatim) CRUD.
 *
 * Delegates persistence to the abstract PantryRepository contract; the
 * concrete document-based implementation lives in
 * infrastructure/document/repositories/pantryIngridient.repository.ts.
 *
 * Consumers include:
 * - PantryController (HTTP layer, /api/v1/pantry/*).
 * - RecipeService.matches() — reads the authenticated user's full pantry via
 *   findAllByUserId() to compute pantry-aware recipe match scores. See
 *   ../../../ARCHITECTURE.md § Recipe Matching Pipeline.
 *
 * @see PantryRepository for the persistence contract.
 * @see ../../../ARCHITECTURE.md § Soft-Delete Contract for the (violated)
 *   soft-delete convention.
 */
@Injectable()
export class PantryService {
  constructor(private readonly pantryRepository: PantryRepository) {}

  /**
   * Create a new pantry item for a user.
   *
   * Spreads the DTO into a cloned payload and stamps it with userId before
   * delegating to PantryRepository.create.
   *
   * @param createIngridientDto Validated CreatePantryIngridientDto.
   * @param userId Authenticated user id from the JWT.
   * @returns The persisted PantryIngridient (spelling preserved verbatim).
   */
  async create(
    createIngridientDto: CreatePantryIngridientDto,
    userId: string,
  ): Promise<PantryIngridient> {
    const clonedPayload = {
      ...createIngridientDto,
      userId,
    };

    return this.pantryRepository.create(clonedPayload);
  }

  /**
   * List pantry items with filtering, sorting, and pagination.
   *
   * The controller injects the authenticated userId into filterOptions so
   * results are always user-scoped (see PantryController.findAll). Cap of 50
   * results per page is enforced upstream at the controller.
   *
   * @param params.filterOptions Optional FilterPantryIngridientDto + userId.
   * @param params.sortOptions Optional array of SortPantryIngridientDto.
   * @param params.paginationOptions Required {page, limit}.
   * @returns Array of PantryIngridient.
   */
  findManyWithPagination({
    filterOptions,
    sortOptions,
    paginationOptions,
  }: {
    filterOptions?: (FilterPantryIngridientDto & { userId: string }) | null;
    sortOptions?: SortPantryIngridientDto[] | null;
    paginationOptions: IPaginationOptions;
  }): Promise<PantryIngridient[]> {
    return this.pantryRepository.findManyWithPagination({
      filterOptions,
      sortOptions,
      paginationOptions,
    });
  }

  /**
   * Fetch every non-deleted pantry item for a single user.
   *
   * NOTE: this is the entry point consumed by RecipeService.matches() to feed
   * the recipe matching pipeline. The returned PantryIngridient[] is converted
   * to a set of `ingridient._id.toString()` values inside
   * RecipeDocumentRepository.matches() and used for exact-_id pantry-coverage
   * scoring. See ../../../ARCHITECTURE.md § Recipe Matching Pipeline.
   *
   * @param userId Authenticated user id from the JWT.
   * @returns All non-deleted PantryIngridient records owned by the user.
   */
  findAllByUserId(userId: string): Promise<PantryIngridient[]> {
    return this.pantryRepository.findAllByUserId(userId);
  }

  /**
   * Fetch a single pantry item by an arbitrary EntityCondition (typically
   * `{ id }`).
   *
   * @param fields EntityCondition<PantryIngridient> — usually `{ id }`.
   * @returns The PantryIngridient or null.
   */
  findOne(
    fields: EntityCondition<PantryIngridient>,
  ): Promise<NullableType<PantryIngridient>> {
    return this.pantryRepository.findOne(fields);
  }

  /**
   * Update a pantry item by id.
   *
   * Pre-flights the update with findOne to verify the record exists, throwing
   * HttpException(UNPROCESSABLE_ENTITY) with the message
   * `pantryIngridientNotExists` (spelling preserved) when the id is missing.
   * The payload is shallow-cloned before being passed to the repository.
   *
   * @param id PantryIngridient _id to update.
   * @param payload DeepPartial<UpdatePantryIngridientDto>.
   * @returns The updated PantryIngridient or null.
   * @throws HttpException(UNPROCESSABLE_ENTITY) when the id is not found.
   */
  async update(
    id: PantryIngridient['id'],
    payload: DeepPartial<UpdatePantryIngridientDto>,
  ): Promise<PantryIngridient | null> {
    const clonedPayload = {
      ...payload,
    };

    const ingredientObject = await this.pantryRepository.findOne({ id });
    if (!ingredientObject?.id) {
      throw new HttpException(
        {
          status: HttpStatus.UNPROCESSABLE_ENTITY,
          errors: {
            email: 'pantryIngridientNotExists',
          },
        },
        HttpStatus.UNPROCESSABLE_ENTITY,
      );
    }

    return this.pantryRepository.update(id, clonedPayload);
  }

  /**
   * "Soft"-delete a pantry item — delegates to PantryRepository.softDelete.
   *
   * WARNING: the concrete document implementation
   * (PantryIngridientDocumentRepository.softDelete) currently calls
   * `deleteOne` and PHYSICALLY REMOVES the document despite the method name.
   * This violates the soft-delete contract documented in
   * ../../../ARCHITECTURE.md § Soft-Delete Contract. The bug is flagged inline
   * with `// FIXME:` and `// TODO(prod):` at
   * infrastructure/document/repositories/pantryIngridient.repository.ts:L119
   * — DO NOT FIX in this documentation pass.
   *
   * @param id PantryIngridient _id to remove.
   * @returns Promise<void>.
   */
  async softDelete(id: PantryIngridient['id']): Promise<void> {
    await this.pantryRepository.softDelete(id);
  }
}
