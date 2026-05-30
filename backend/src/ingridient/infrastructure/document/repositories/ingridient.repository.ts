import { Injectable } from '@nestjs/common';
import { EntityCondition } from 'src/utils/types/entity-condition.type';
import { NullableType } from 'src/utils/types/nullable.type';
import { Ingridient } from 'src/ingridient/domain/ingrident';
import { IngridientRepository } from '../../ingridient.repository';
import { IngridientSchemaClass } from '../entities/ingridient.schema';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { IngridientMapper } from '../mappers/ingridient.mapper';
import { SortIngridientDto } from '../../../dto/query-ingridient.dto';
import { IPaginationOptions } from 'src/utils/types/pagination-options';

// NOTE: 'Ingridient', 'IngridientDocumentRepository', 'IngridientSchemaClass' spellings preserved verbatim. Do not rename.

/**
 * Mongoose-backed concrete implementation of IngridientRepository
 * (spelling preserved verbatim).
 *
 * Implements softDelete properly via updateOne({ deletedAt: new Date() }) —
 * in contrast to PantryIngridientDocumentRepository.softDelete which uses
 * destructive deleteOne (see backend/src/pantry/README.md § Known Limitations).
 */
@Injectable()
export class IngridientDocumentRepository implements IngridientRepository {
  constructor(
    @InjectModel(IngridientSchemaClass.name)
    private readonly ingridientModel: Model<IngridientSchemaClass>,
  ) {}

  /**
   * Persist a new Ingridient (spelling preserved verbatim).
   *
   * Uses `IngridientMapper.toPersistence` to flatten the domain entity,
   * saves via the Mongoose model, then maps back to domain.
   *
   * @param data Ingridient domain entity.
   * @returns The persisted Ingridient with assigned `id`.
   */
  async create(data: Ingridient): Promise<Ingridient> {
    const persistenceModel = IngridientMapper.toPersistence(data);
    const createdIngridient = new this.ingridientModel(persistenceModel);
    const ingridentObject = await createdIngridient.save();
    return IngridientMapper.toDomain(ingridentObject);
  }

  /**
   * Find a single Ingridient by id or arbitrary conditions
   * (spelling preserved verbatim).
   *
   * When `fields.id` is present, uses `findById`; otherwise `findOne(fields)`.
   *
   * @param fields `EntityCondition<Ingridient>`.
   * @returns The matching Ingridient or null.
   */
  async findOne(
    fields: EntityCondition<Ingridient>,
  ): Promise<NullableType<Ingridient>> {
    if (fields.id) {
      const ingridentObject = await this.ingridientModel.findById(fields.id);
      return ingridentObject
        ? IngridientMapper.toDomain(ingridentObject)
        : null;
    }

    const ingridentObject = await this.ingridientModel.findOne(fields);
    return ingridentObject ? IngridientMapper.toDomain(ingridentObject) : null;
  }

  /**
   * Paginated list of non-soft-deleted Ingridients (spelling preserved verbatim).
   *
   * Always filters `deletedAt: null`. When `filterOptions` is provided, applies
   * `{ name: { $regex: filterOptions, $options: 'i' } }` for case-insensitive
   * partial name matching. Sort directives are translated from {orderBy, order}
   * pairs to Mongoose sort objects with `id` mapped to `_id`.
   *
   * @param params.filterOptions Optional name regex fragment.
   * @param params.sortOptions Optional `SortIngridientDto[]`.
   * @param params.paginationOptions `{ page, limit }` 1-based pagination.
   * @returns Array of Ingridient domain entities for the requested page.
   */
  async findManyWithPagination({
    filterOptions,
    sortOptions,
    paginationOptions,
  }: {
    filterOptions?: string | null;
    sortOptions?: SortIngridientDto[] | null;
    paginationOptions: IPaginationOptions;
  }): Promise<Ingridient[]> {
    const where: EntityCondition<Ingridient> = {};

    if (filterOptions) {
      where['name'] = { $regex: filterOptions, $options: 'i' } as any;
    }

    const ingridentObjects = await this.ingridientModel
      .find({
        ...where,
        deletedAt: null,
      })
      .sort(
        sortOptions?.reduce(
          (accumulator, sort) => ({
            ...accumulator,
            [sort.orderBy === 'id' ? '_id' : sort.orderBy]:
              sort.order.toUpperCase() === 'ASC' ? 1 : -1,
          }),
          {},
        ),
      )
      .skip((paginationOptions.page - 1) * paginationOptions.limit)
      .limit(paginationOptions.limit);

    return ingridentObjects.map((ingridientObject) =>
      IngridientMapper.toDomain(ingridientObject),
    );
  }

  /**
   * Apply a partial update to an Ingridient (spelling preserved verbatim).
   *
   * Uses `findByIdAndUpdate(..., { new: true })` to return the updated
   * document, then maps to domain.
   *
   * @param id MongoDB ObjectId string.
   * @param payload Sparse field overrides.
   * @returns The updated Ingridient, or null when the id is not found.
   */
  async update(
    id: Ingridient['id'],
    payload: Partial<Ingridient>,
  ): Promise<Ingridient | null> {
    const updatedIngridient = await this.ingridientModel.findByIdAndUpdate(
      id,
      payload,
      { new: true },
    );

    return updatedIngridient
      ? IngridientMapper.toDomain(updatedIngridient)
      : null;
  }

  /**
   * Proper soft-delete: sets `deletedAt: new Date()` via `updateOne(...)`
   * (spelling preserved verbatim).
   *
   * Records remain in the collection; `findManyWithPagination` excludes
   * them by filtering `deletedAt: null`. This contrasts with
   * PantryIngridientDocumentRepository.softDelete which uses destructive
   * deleteOne (see backend/src/pantry/README.md § Known Limitations).
   *
   * @param id MongoDB ObjectId string.
   */
  async softDelete(id: Ingridient['id']): Promise<void> {
    await this.ingridientModel.updateOne(
      { _id: id },
      { deletedAt: new Date() },
    );
  }
}
