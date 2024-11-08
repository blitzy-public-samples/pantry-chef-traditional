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

@Injectable()
export class PantryIngridientDocumentRepository implements PantryRepository {
  constructor(
    @InjectModel(PantryIngridientSchemaClass.name)
    private readonly pantryIngridientModel: Model<PantryIngridientSchemaClass>,
  ) {}

  async create(data: PantryIngridient): Promise<PantryIngridient> {
    const persistenceModel = PantryIngridientMapper.toPersistence(data);
    const createdIngridient = new this.pantryIngridientModel(persistenceModel);
    const ingridentObject = await createdIngridient.save();
    return PantryIngridientMapper.toDomain(
      await ingridentObject.populate('ingridient'),
    );
  }

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

  async softDelete(id: PantryIngridient['id']): Promise<void> {
    await this.pantryIngridientModel.deleteOne({
      _id: id,
    });
  }
}
