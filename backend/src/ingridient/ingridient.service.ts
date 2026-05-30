// NOTE: 'Ingridient' spelling preserved verbatim across the backend codebase. Do not rename.
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
 * Service orchestrating Ingridient CRUD (spelling preserved verbatim).
 *
 * Delegates persistence to IngridientRepository (abstract); concrete
 * document implementation lives in infrastructure/document/repositories/.
 * Consumed by AiModule (label resolution), PantryModule (Reference embed),
 * and RecipeModule (IngridientList Reference embed — spelling preserved).
 */
@Injectable()
export class IngridientService {
  constructor(private readonly ingridientRepository: IngridientRepository) {}

  /**
   * Create a new Ingridient (spelling preserved verbatim).
   *
   * Clones the incoming DTO, checks for an existing record with the same
   * `name`, and throws `UNPROCESSABLE_ENTITY` (422) with the error marker
   * `ingridientAlreadyExists` if found. Otherwise delegates to
   * `IngridientRepository.create()`.
   *
   * @param createIngridientDto Validated payload from the HTTP request.
   * @returns The persisted `Ingridient` domain entity.
   * @throws HttpException 422 when an Ingridient with the same name exists.
   */
  async create(createIngridientDto: CreateIngridientDto): Promise<Ingridient> {
    const clonedPayload = {
      ...createIngridientDto,
    };

    if (clonedPayload.name) {
      const userObject = await this.ingridientRepository.findOne({
        name: clonedPayload.name,
      });
      if (userObject) {
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

    return this.ingridientRepository.create(clonedPayload);
  }

  /**
   * Pass-through paginated query for Ingridient records (spelling preserved
   * verbatim). Delegates filtering, sorting, and skip/limit pagination to
   * the repository.
   *
   * @param params.filterOptions Optional free-text name filter (regex match,
   *   case-insensitive — see IngridientDocumentRepository.findManyWithPagination).
   * @param params.sortOptions Optional list of `SortIngridientDto` entries.
   * @param params.paginationOptions `{ page, limit }` (caller enforces 50 cap).
   * @returns Array of `Ingridient` domain entities for the requested page.
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
    return this.ingridientRepository.findManyWithPagination({
      filterOptions,
      sortOptions,
      paginationOptions,
    });
  }

  /**
   * Find a single Ingridient by arbitrary entity conditions
   * (spelling preserved verbatim).
   *
   * @param fields `EntityCondition<Ingridient>` (typically `{ id }` or
   *   `{ name }`).
   * @returns The matching `Ingridient` or `null` when not found.
   */
  findOne(
    fields: EntityCondition<Ingridient>,
  ): Promise<NullableType<Ingridient>> {
    return this.ingridientRepository.findOne(fields);
  }

  /**
   * Update an existing Ingridient (spelling preserved verbatim).
   *
   * Verifies the record exists before delegating to the repository; throws
   * `UNPROCESSABLE_ENTITY` (422) with the error marker `ingridientNotExists`
   * when the target id does not resolve.
   *
   * @param id MongoDB ObjectId string of the target Ingridient.
   * @param payload `DeepPartial<Ingridient>` with fields to overwrite.
   * @returns The updated `Ingridient` or `null` if the repository returns null.
   * @throws HttpException 422 when the Ingridient does not exist.
   */
  async update(
    id: Ingridient['id'],
    payload: DeepPartial<Ingridient>,
  ): Promise<Ingridient | null> {
    const clonedPayload = { ...payload };

    const ingredientObject = await this.ingridientRepository.findOne({ id });
    if (!ingredientObject?.id) {
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

    return this.ingridientRepository.update(id, clonedPayload);
  }

  /**
   * Soft-delete an Ingridient by id (spelling preserved verbatim).
   *
   * Delegates to the repository; the document implementation uses the
   * proper `updateOne({ deletedAt: new Date() })` pattern (Source:
   * infrastructure/document/repositories/ingridient.repository.ts).
   *
   * @param id MongoDB ObjectId string of the target Ingridient.
   */
  async softDelete(id: Ingridient['id']): Promise<void> {
    await this.ingridientRepository.softDelete(id);
  }
}
