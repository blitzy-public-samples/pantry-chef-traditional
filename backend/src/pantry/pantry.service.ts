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
 * Application-layer coordinator for the Pantry bounded context.
 *
 * Injectable provider that depends on the abstract {@link PantryRepository}
 * and forwards the pantry use cases: create, paginated list, owner-scoped
 * list, single lookup, update, and delete. Acts as a thin orchestrator that
 * enriches create payloads with the authenticated `userId`, clones payloads
 * before delegating, and enforces an existence check on update.
 */
@Injectable()
export class PantryService {
  constructor(private readonly pantryRepository: PantryRepository) {}

  /**
   * Creates a pantry ingredient owned by the given user.
   *
   * @param createIngridientDto - the create payload (`CreatePantryIngridientDto`).
   * @param userId - id of the authenticated owner, merged into the record.
   * @returns the persisted `PantryIngridient`.
   */
  async create(
    createIngridientDto: CreatePantryIngridientDto,
    userId: string,
  ): Promise<PantryIngridient> {
    // Clone the incoming payload and enrich it with the owner `userId`
    // before delegating persistence to the repository.
    const clonedPayload = {
      ...createIngridientDto,
      userId,
    };

    return this.pantryRepository.create(clonedPayload);
  }

  /**
   * Returns a page of pantry ingredients matching the given options.
   *
   * @param options - the destructured query controls.
   * @param options.filterOptions - optional owner-scoped filter; includes
   *   `userId` for owner scoping, or `null` to apply no filter.
   * @param options.sortOptions - optional list of `SortPantryIngridientDto`.
   * @param options.paginationOptions - `IPaginationOptions` (page and limit).
   * @returns the matching page of `PantryIngridient` records.
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
   * Returns all (non-deleted) pantry ingredients for a user.
   *
   * @param userId - the owner id whose pantry items are returned.
   * @returns every `PantryIngridient` owned by the user.
   */
  findAllByUserId(userId: string): Promise<PantryIngridient[]> {
    return this.pantryRepository.findAllByUserId(userId);
  }

  /**
   * Finds a single pantry ingredient matching the given condition.
   *
   * @param fields - an `EntityCondition<PantryIngridient>` selector (e.g.,
   *   `{ id }`).
   * @returns the matching `PantryIngridient`, or `null` when not found.
   */
  findOne(
    fields: EntityCondition<PantryIngridient>,
  ): Promise<NullableType<PantryIngridient>> {
    return this.pantryRepository.findOne(fields);
  }

  /**
   * Applies a partial update after verifying the record exists.
   *
   * @param id - the pantry ingredient id to update.
   * @param payload - the `DeepPartial<UpdatePantryIngridientDto>` fields to
   *   apply.
   * @returns the updated `PantryIngridient`, or `null`.
   * @throws HttpException with status 422 Unprocessable Entity (error key
   *   `pantryIngridientNotExists`) when no record with `id` exists.
   */
  async update(
    id: PantryIngridient['id'],
    payload: DeepPartial<UpdatePantryIngridientDto>,
  ): Promise<PantryIngridient | null> {
    // Clone the incoming partial payload before applying the update.
    const clonedPayload = {
      ...payload,
    };

    // Verify the record exists before updating.
    const ingredientObject = await this.pantryRepository.findOne({ id });
    if (!ingredientObject?.id) {
      // Throw 422 when no pantry ingredient matches the given id.
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
   * Removes a pantry ingredient by id.
   *
   * @param id - the pantry ingredient id to remove.
   * @returns a promise that resolves once the removal completes.
   */
  async softDelete(id: PantryIngridient['id']): Promise<void> {
    // KNOWN ISSUE: despite the name `softDelete`, the document repository
    // performs a HARD delete (`deleteOne`) that physically removes the record
    // even though the schema declares a `deletedAt` field.
    // Source: pantryIngridient.repository.ts:L184-L186
    await this.pantryRepository.softDelete(id);
  }
}
