import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { EntityCondition } from 'src/utils/types/entity-condition.type';
import { IPaginationOptions } from 'src/utils/types/pagination-options';
import { NullableType } from '../utils/types/nullable.type';
import { IngridientRepository } from './infrastructure/ingridient.repository';
import { DeepPartial } from 'src/utils/types/deep-partial.type';
import { Ingridient } from './domain/ingrident';
import { CreateIngridientDto } from './dto/create-ingridient.dto';
import { SortIngridientDto } from './dto/query-ingridient.dto';

@Injectable()
export class IngridientService {
  constructor(private readonly ingridientRepository: IngridientRepository) {}

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

  findOne(
    fields: EntityCondition<Ingridient>,
  ): Promise<NullableType<Ingridient>> {
    return this.ingridientRepository.findOne(fields);
  }

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

  async softDelete(id: Ingridient['id']): Promise<void> {
    await this.ingridientRepository.softDelete(id);
  }
}
