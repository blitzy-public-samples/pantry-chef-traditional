import { Injectable } from '@nestjs/common';
import { EntityCondition } from 'src/utils/types/entity-condition.type';
import { NullableType } from '../../../../utils/types/nullable.type';
import { PantryRepository } from '../../pantry.repository';
import { PantryIngridientSchemaClass } from '../entities/pantryIngridient.schema';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { PantryIngridientMapper } from '../mappers/pantryIngridient.mapper';
import { PantryIngridient } from 'src/pantry/domain/pantryIngridient';
import {
  FilterPantryIngridientDto,
  SortPantryIngridientDto,
} from 'src/pantry/dto/query-pantry-ingridient.dto';
import { IPaginationOptions } from 'src/utils/types/pagination-options';

/**
 * Mongoose-backed implementation of `PantryRepository`.
 *
 * Persists `PantryIngridient` records to MongoDB and converts documents to and
 * from the domain model via `PantryIngridientMapper`. The constructor injects
 * the `PantryIngridientSchemaClass` model through `@InjectModel`.
 */
@Injectable()
export class PantryIngridientDocumentRepository implements PantryRepository {
  constructor(
    @InjectModel(PantryIngridientSchemaClass.name)
    private readonly pantryIngridientModel: Model<PantryIngridientSchemaClass>,
  ) {}

  /**
   * Persists a new pantry ingredient.
   *
   * Maps `data` to its persistence shape, saves it, populates the referenced
   * `ingridient`, and maps the saved document back to the domain model.
   *
   * @param data The pantry ingredient to persist.
   * @returns The persisted `PantryIngridient` with its populated `ingridient`.
   */
  async create(data: PantryIngridient): Promise<PantryIngridient> {
    const persistenceModel = PantryIngridientMapper.toPersistence(data);
    const createdIngridient = new this.pantryIngridientModel(persistenceModel);
    const ingridentObject = await createdIngridient.save();
    return PantryIngridientMapper.toDomain(
      await ingridentObject.populate('ingridient'),
    );
  }

  /**
   * Finds a single pantry ingredient.
   *
   * When `fields.id` is set the lookup uses `findById`; otherwise it queries by
   * the arbitrary `fields`. Both paths populate the referenced `ingridient`.
   *
   * @param fields Lookup condition; `fields.id` takes precedence when present.
   * @returns The matching `PantryIngridient`, or `null` when none is found.
   */
  async findOne(
    fields: EntityCondition<PantryIngridient>,
  ): Promise<NullableType<PantryIngridient>> {
    if (fields.id) {
      const ingridentObject = await this.pantryIngridientModel
        .findById(fields.id)
        .populate('ingridient');
      return ingridentObject
        ? PantryIngridientMapper.toDomain(ingridentObject)
        : null;
    }

    const ingridentObject = await this.pantryIngridientModel
      .findOne(fields)
      .populate('ingridient');
    return ingridentObject
      ? PantryIngridientMapper.toDomain(ingridentObject)
      : null;
  }

  /**
   * Returns a filtered, sorted, paginated list of pantry ingredients.
   *
   * @param filterOptions Optional filter; scopes by `userId` when provided.
   *   Type `(FilterPantryIngridientDto & { userId: string }) | null`.
   * @param sortOptions Optional sort definitions (`SortPantryIngridientDto[]`).
   * @param paginationOptions Page and limit (`IPaginationOptions`).
   * @returns The matching page of `PantryIngridient` records.
   */
  async findManyWithPagination({
    filterOptions,
    sortOptions,
    paginationOptions,
  }: {
    filterOptions?: (FilterPantryIngridientDto & { userId: string }) | null;
    sortOptions?: SortPantryIngridientDto[] | null;
    paginationOptions: IPaginationOptions;
  }): Promise<PantryIngridient[]> {
    const where: EntityCondition<PantryIngridient> = {};

    // scope filter by userId when provided
    if (filterOptions?.userId) {
      where['userId'] = filterOptions.userId;
    }

    const ingridentObjects = await this.pantryIngridientModel
      .find({
        ...where,
        // deletedAt: null excludes (soft-)deleted records from the list
        deletedAt: null,
      })
      .populate('ingridient')
      // translate sort options to Mongo sort; map orderBy 'id' -> '_id'
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
      // skip/limit pagination
      .skip((paginationOptions.page - 1) * paginationOptions.limit)
      .limit(paginationOptions.limit);

    return ingridentObjects.map((ingridientObject) =>
      PantryIngridientMapper.toDomain(ingridientObject),
    );
  }

  /**
   * Returns all non-deleted pantry ingredients owned by a user.
   *
   * @param userId The owner whose pantry ingredients are returned.
   * @returns The user's `PantryIngridient` records with populated `ingridient`.
   */
  async findAllByUserId(userId: string) {
    const ingridentObjects = await this.pantryIngridientModel
      .find({
        userId,
        deletedAt: null,
      })
      .populate('ingridient');

    return ingridentObjects.map((ingridientObject) =>
      PantryIngridientMapper.toDomain(ingridientObject),
    );
  }

  /**
   * Updates a pantry ingredient and returns the refreshed record.
   *
   * Uses `findByIdAndUpdate(..., { new: true })`, then populates the referenced
   * `ingridient` and maps the result to the domain model.
   *
   * @param id The id of the pantry ingredient to update.
   * @param payload The partial fields to apply (`Partial<PantryIngridient>`).
   * @returns The updated `PantryIngridient`, or `null` when no record matches.
   */
  async update(
    id: PantryIngridient['id'],
    payload: Partial<PantryIngridient>,
  ): Promise<PantryIngridient | null> {
    const updatedPantryIngridient = await this.pantryIngridientModel
      .findByIdAndUpdate(id, payload, {
        new: true,
      })
      .populate('ingridient');

    return updatedPantryIngridient
      ? PantryIngridientMapper.toDomain(updatedPantryIngridient)
      : null;
  }

  /**
   * Removes the pantry ingredient identified by `id`.
   *
   * @param id The id of the pantry ingredient to remove.
   * @returns A promise that resolves once the delete completes.
   */
  async softDelete(id: PantryIngridient['id']): Promise<void> {
    // KNOWN ISSUE: despite the name `softDelete`, this performs a HARD delete
    // via `deleteOne({ _id: id })`. The document is physically removed even
    // though the schema declares a `deletedAt` field, so this is not a true
    // soft delete. Behavior is documented intentionally; the code is unchanged.
    await this.pantryIngridientModel.deleteOne({
      _id: id,
    });
  }
}
