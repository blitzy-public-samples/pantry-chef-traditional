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

@Injectable()
export class IngridientDocumentRepository implements IngridientRepository {
  constructor(
    @InjectModel(IngridientSchemaClass.name)
    private readonly ingridientModel: Model<IngridientSchemaClass>,
  ) {}

  async create(data: Ingridient): Promise<Ingridient> {
    const persistenceModel = IngridientMapper.toPersistence(data);
    const createdIngridient = new this.ingridientModel(persistenceModel);
    const ingridentObject = await createdIngridient.save();
    return IngridientMapper.toDomain(ingridentObject);
  }

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

  async softDelete(id: Ingridient['id']): Promise<void> {
    await this.ingridientModel.updateOne(
      { _id: id },
      { deletedAt: new Date() },
    );
  }
}
