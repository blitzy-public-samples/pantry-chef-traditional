import { PantryIngridient } from '../domain/pantryIngridient';
import { NullableType } from 'src/utils/types/nullable.type';
import { EntityCondition } from 'src/utils/types/entity-condition.type';
import { DeepPartial } from 'src/utils/types/deep-partial.type';
import {
  FilterPantryIngridientDto,
  SortPantryIngridientDto,
} from '../dto/query-pantry-ingridient.dto';
import { IPaginationOptions } from 'src/utils/types/pagination-options';

export abstract class PantryRepository {
  abstract create(
    data: Omit<
      PantryIngridient,
      'id' | 'createdAt' | 'deletedAt' | 'updatedAt'
    >,
  ): Promise<PantryIngridient>;

  abstract findManyWithPagination({
    filterOptions,
    sortOptions,
    paginationOptions,
  }: {
    filterOptions?: FilterPantryIngridientDto | null;
    sortOptions?: SortPantryIngridientDto[] | null;
    paginationOptions: IPaginationOptions;
  }): Promise<PantryIngridient[]>;

  abstract findAllByUserId(userId: string): Promise<PantryIngridient[]>;

  abstract findOne(
    fields: EntityCondition<PantryIngridient>,
  ): Promise<NullableType<PantryIngridient>>;

  abstract update(
    id: PantryIngridient['id'],
    payload: DeepPartial<PantryIngridient>,
  ): Promise<PantryIngridient | null>;

  abstract softDelete(id: PantryIngridient['id']): Promise<void>;
}
