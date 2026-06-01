import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { EntityCondition } from 'src/utils/types/entity-condition.type';
import { IPaginationOptions } from 'src/utils/types/pagination-options';
import { NullableType } from '../utils/types/nullable.type';
import { IngridientRepository } from './infrastructure/ingridient.repository';
import { DeepPartial } from 'src/utils/types/deep-partial.type';
import { Ingridient } from './domain/ingrident';
import { CreateIngridientDto } from './dto/create-ingridient.dto';
import { SortIngridientDto } from './dto/query-ingridient.dto';

/**
 * Application-layer service for the ingredient catalog.
 *
 * Encapsulates ingredient business logic: it performs existence checks
 * (duplicate-name detection on create, presence verification on update)
 * before delegating all persistence to the abstract
 * {@link IngridientRepository}. This keeps the service free of direct
 * data-store concerns and lets the concrete repository own storage details.
 */
@Injectable()
export class IngridientService {
  constructor(private readonly ingridientRepository: IngridientRepository) {}

  /**
   * Creates a new ingredient after enforcing name uniqueness.
   *
   * @param createIngridientDto - The ingredient attributes to persist (name,
   *   category, confidence, and optional quantity/unit/expiration/image).
   * @returns A promise that resolves to the newly created {@link Ingridient}.
   * @throws HttpException 422 (Unprocessable Entity) when an ingredient with
   *   the same `name` already exists.
   */
  async create(createIngridientDto: CreateIngridientDto): Promise<Ingridient> {
    // Clone the incoming DTO so the original argument is never mutated.
    const clonedPayload = {
      ...createIngridientDto,
    };

    // Only enforce uniqueness when a name is present on the payload.
    if (clonedPayload.name) {
      // Look up any existing ingredient already using this name.
      const userObject = await this.ingridientRepository.findOne({
        name: clonedPayload.name,
      });
      // A match means the name is taken: reject with a 422 conflict.
      if (userObject) {
        // KNOWN ISSUE: the 422 payload is keyed under `email` (a copy-paste
        // artifact) instead of `name`; preserved as-is, not corrected.
        // Source: backend/src/ingridient/ingridient.service.ts:L24-L34
        throw new HttpException(
          {
            status: HttpStatus.UNPROCESSABLE_ENTITY,
            errors: {
              email: 'ingridientAlreadyExists',
            },
          },
          HttpStatus.UNPROCESSABLE_ENTITY,
        );
      }
    }

    // No conflict: delegate creation to the repository.
    return this.ingridientRepository.create(clonedPayload);
  }

  /**
   * Retrieves a paginated, optionally filtered and sorted ingredient list.
   *
   * @param options - Query options object (destructured into the fields below).
   * @param options.filterOptions - Optional free-text filter string, or null.
   * @param options.sortOptions - Optional {@link SortIngridientDto} directives.
   * @param options.paginationOptions - Page and limit settings.
   * @returns A promise resolving to the matching {@link Ingridient} array.
   */
  findManyWithPagination({
    filterOptions,
    sortOptions,
    paginationOptions,
  }: {
    filterOptions?: string | null;
    sortOptions?: SortIngridientDto[] | null;
    paginationOptions: IPaginationOptions;
  }): Promise<Ingridient[]> {
    // Direct passthrough to the repository's pagination query.
    return this.ingridientRepository.findManyWithPagination({
      filterOptions,
      sortOptions,
      paginationOptions,
    });
  }

  /**
   * Finds a single ingredient matching the supplied entity condition.
   *
   * @param fields - Partial entity condition used to match an ingredient.
   * @returns A promise resolving to the matching {@link Ingridient}, or null
   *   when no record satisfies the condition.
   */
  findOne(
    fields: EntityCondition<Ingridient>,
  ): Promise<NullableType<Ingridient>> {
    // Direct passthrough to the repository lookup.
    return this.ingridientRepository.findOne(fields);
  }

  /**
   * Updates an existing ingredient after verifying it exists.
   *
   * @param id - Identifier of the ingredient to update.
   * @param payload - Deep-partial set of {@link Ingridient} fields to change.
   * @returns A promise resolving to the updated {@link Ingridient}, or null.
   * @throws HttpException 422 (Unprocessable Entity) when no ingredient
   *   exists for the supplied `id` (error keyed `ingridientNotExists`).
   */
  async update(
    id: Ingridient['id'],
    payload: DeepPartial<Ingridient>,
  ): Promise<Ingridient | null> {
    // Clone the partial payload so the caller's object is left untouched.
    const clonedPayload = { ...payload };

    // Load the target ingredient to confirm it exists before updating.
    const ingredientObject = await this.ingridientRepository.findOne({ id });
    // Guard: a missing record (no id) is rejected with a 422 conflict.
    if (!ingredientObject?.id) {
      // KNOWN ISSUE: the 422 payload is keyed under `email` (a copy-paste
      // artifact) instead of `id`; preserved as-is, not corrected.
      // Source: backend/src/ingridient/ingridient.service.ts:L69-L79
      throw new HttpException(
        {
          status: HttpStatus.UNPROCESSABLE_ENTITY,
          errors: {
            email: 'ingridientNotExists',
          },
        },
        HttpStatus.UNPROCESSABLE_ENTITY,
      );
    }

    // Record exists: delegate the update to the repository.
    return this.ingridientRepository.update(id, clonedPayload);
  }

  /**
   * Soft-deletes an ingredient by delegating to the repository.
   *
   * @param id - Identifier of the ingredient to soft-delete.
   * @returns A promise that resolves once the soft-delete completes.
   */
  async softDelete(id: Ingridient['id']): Promise<void> {
    // Delegates to the repository's soft-delete (which sets `deletedAt`).
    await this.ingridientRepository.softDelete(id);
  }
}
