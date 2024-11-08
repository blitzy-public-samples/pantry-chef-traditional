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

@Injectable()
export class PantryService {
  constructor(private readonly pantryRepository: PantryRepository) {}

  async create(
    createIngridientDto: CreatePantryIngridientDto,
    userId: string,
  ): Promise<PantryIngridient> {
    const clonedPayload = {
      ...createIngridientDto,
      userId,
    };

    return this.pantryRepository.create(clonedPayload);
  }

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

  findAllByUserId(userId: string): Promise<PantryIngridient[]> {
    return this.pantryRepository.findAllByUserId(userId);
  }

  findOne(
    fields: EntityCondition<PantryIngridient>,
  ): Promise<NullableType<PantryIngridient>> {
    return this.pantryRepository.findOne(fields);
  }

  async update(
    id: PantryIngridient['id'],
    payload: DeepPartial<UpdatePantryIngridientDto>,
  ): Promise<PantryIngridient | null> {
    const clonedPayload = {
      ...payload,
    };

    const ingredientObject = await this.pantryRepository.findOne({ id });
    if (!ingredientObject?.id) {
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

  async softDelete(id: PantryIngridient['id']): Promise<void> {
    await this.pantryRepository.softDelete(id);
  }
}
