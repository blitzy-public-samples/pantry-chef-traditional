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

/**
 * Mongoose-backed implementation of the abstract `IngridientRepository`.
 *
 * Uses an injected `IngridientSchemaClass` model and `IngridientMapper` to
 * translate between persistence documents and the `Ingridient` domain entity.
 *
 * The misspelling `Ingridient` is an intentional, preserved identifier.
 */
@Injectable()
export class IngridientDocumentRepository implements IngridientRepository {
  constructor(
    // Injected Mongoose model for the ingredient collection.
    @InjectModel(IngridientSchemaClass.name)
    private readonly ingridientModel: Model<IngridientSchemaClass>,
  ) {}

  /**
   * Persists a new ingredient.
   *
   * @param data the ingredient to create.
   * @returns the persisted `Ingridient` domain object.
   */
  async create(data: Ingridient): Promise<Ingridient> {
    // Map to a persistence document, save, then map the result to domain.
    const persistenceModel = IngridientMapper.toPersistence(data);
    const createdIngridient = new this.ingridientModel(persistenceModel);
    const ingridentObject = await createdIngridient.save();
    return IngridientMapper.toDomain(ingridentObject);
  }

  /**
   * Finds a single ingredient by entity condition.
   *
   * @param fields an `EntityCondition<Ingridient>` predicate.
   * @returns the matching `Ingridient`, or `null` when none matches.
   */
  async findOne(
    fields: EntityCondition<Ingridient>,
  ): Promise<NullableType<Ingridient>> {
    // Use findById when an id is supplied, otherwise query by condition.
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
   * Returns a page of ingredients matching optional filter and sort options.
   *
   * @param options pagination/filter/sort container.
   * @param options.filterOptions optional case-insensitive name filter.
   * @param options.sortOptions optional `SortIngridientDto` directives.
   * @param options.paginationOptions `page`/`limit` pagination controls.
   * @returns the matching `Ingridient` records for the requested page.
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

    // Build a case-insensitive name regex filter when one is provided.
    if (filterOptions) {
      where['name'] = { $regex: filterOptions, $options: 'i' } as any;
    }

    const ingridentObjects = await this.ingridientModel
      // Always exclude soft-deleted records (deletedAt: null).
      .find({
        ...where,
        deletedAt: null,
      })
      // Map sort directives to Mongoose order (id -> _id, ASC=1 / DESC=-1).
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
      // Apply offset pagination via skip/limit.
      .skip((paginationOptions.page - 1) * paginationOptions.limit)
      .limit(paginationOptions.limit);

    return ingridentObjects.map((ingridientObject) =>
      IngridientMapper.toDomain(ingridientObject),
    );
  }

  /**
   * Applies a partial update to the ingredient identified by `id`.
   *
   * @param id the ingredient id.
   * @param payload the fields to update.
   * @returns the updated `Ingridient`, or `null` when the id does not exist.
   */
  async update(
    id: Ingridient['id'],
    payload: Partial<Ingridient>,
  ): Promise<Ingridient | null> {
    // findByIdAndUpdate with { new: true } returns the post-update document.
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
   * Soft-deletes the ingredient identified by `id`.
   *
   * @param id the ingredient id.
   * @returns nothing once the record is marked deleted.
   */
  async softDelete(id: Ingridient['id']): Promise<void> {
    // TRUE soft delete: set deletedAt via updateOne; the document is NOT
    // physically removed (L94-L99).
    await this.ingridientModel.updateOne(
      { _id: id },
      { deletedAt: new Date() },
    );
  }
}
