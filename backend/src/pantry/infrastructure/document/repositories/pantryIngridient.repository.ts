// NOTE: 'PantryIngridient', 'PantryIngridientSchemaClass',
// 'PantryIngridientDocumentRepository' spellings preserved verbatim. Do not rename.
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
 * Mongoose-backed concrete implementation of the abstract PantryRepository.
 *
 * Persists PantryIngridient records (spelling preserved verbatim) keyed by
 * userId. Provides CRUD plus a `softDelete` method whose current
 * implementation VIOLATES the soft-delete contract (see ../../../README.md
 * § Known Limitations and ../../../../../../ARCHITECTURE.md § Soft-Delete
 * Contract).
 */
@Injectable()
export class PantryIngridientDocumentRepository implements PantryRepository {
  constructor(
    @InjectModel(PantryIngridientSchemaClass.name)
    private readonly pantryIngridientModel: Model<PantryIngridientSchemaClass>,
  ) {}

  /**
   * Persist a new PantryIngridient document.
   *
   * Runs PantryIngridientMapper.toPersistence on the domain entity, saves
   * via the Mongoose model, populates the `ingridient` reference, then maps
   * back to the domain via PantryIngridientMapper.toDomain.
   *
   * @param data PantryIngridient domain entity.
   * @returns The created PantryIngridient with `ingridient` populated.
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
   * Find one PantryIngridient by `id` (preferred) or arbitrary field
   * conditions (fallback).
   *
   * Populates the `ingridient` reference on both code paths.
   *
   * @param fields EntityCondition; if `fields.id` is set, uses findById,
   *   otherwise findOne.
   * @returns The PantryIngridient or null.
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
   * Paginated list of PantryIngridient with user scoping, sort, and skip /
   * limit. Always excludes records where `deletedAt` is non-null.
   *
   * Sort options are converted to Mongoose's `{ field: 1 | -1 }` shape, with
   * the special case `orderBy === 'id'` mapped to `_id`.
   *
   * @param params.filterOptions FilterPantryIngridientDto plus required
   *   userId (injected upstream by the controller).
   * @param params.sortOptions Optional SortPantryIngridientDto[].
   * @param params.paginationOptions {page, limit} (1-based).
   * @returns Array of PantryIngridient.
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

    if (filterOptions?.userId) {
      where['userId'] = filterOptions.userId;
    }

    const ingridentObjects = await this.pantryIngridientModel
      .find({
        ...where,
        deletedAt: null,
      })
      .populate('ingridient')
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
      PantryIngridientMapper.toDomain(ingridientObject),
    );
  }

  /**
   * Return every non-deleted PantryIngridient owned by a user.
   *
   * Consumed by RecipeService.matches() — the returned array is converted
   * to a set of ingredient `_id.toString()` values to score recipes by
   * pantry coverage. See ../../../../../../ARCHITECTURE.md § Recipe Matching
   * Pipeline for the full algorithm.
   *
   * @param userId Owner userId (scalar String).
   * @returns Array of PantryIngridient.
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
   * Apply a partial update to a PantryIngridient by id and return the
   * updated record with `ingridient` populated.
   *
   * Uses Mongoose `findByIdAndUpdate(id, payload, { new: true })`.
   *
   * @param id PantryIngridient _id.
   * @param payload Partial<PantryIngridient>.
   * @returns The updated PantryIngridient or null if not found.
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

  // FIXME: softDelete calls deleteOne — physically destructive despite method
  // name. Document only; do not fix.
  // TODO(prod): Implement true soft-delete via { deletedAt: new Date() } update before production.
  /**
   * "Soft"-delete a pantry item by id.
   *
   * WARNING: this method is misnamed. It calls `deleteOne` and PHYSICALLY
   * REMOVES the document from MongoDB. It does NOT set deletedAt. See
   * ../../../README.md § Known Limitations and ../../../../../../ARCHITECTURE.md
   * § Soft-Delete Contract for the documented gap. Annotation flagged with
   * `// FIXME:` and `// TODO(prod):` above — do not fix in this
   * documentation pass.
   *
   * @param id PantryIngridient _id to remove.
   * @returns Promise<void>.
   */
  async softDelete(id: PantryIngridient['id']): Promise<void> {
    await this.pantryIngridientModel.deleteOne({
      _id: id,
    });
  }
}
