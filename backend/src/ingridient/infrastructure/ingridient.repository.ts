import { Ingridient } from '../domain/ingrident';
import { NullableType } from 'src/utils/types/nullable.type';
import { EntityCondition } from 'src/utils/types/entity-condition.type';
import { DeepPartial } from 'src/utils/types/deep-partial.type';
import { IPaginationOptions } from 'src/utils/types/pagination-options';
import { SortIngridientDto } from '../dto/query-ingridient.dto';

export abstract class IngridientRepository {
  abstract create(
    data: Omit<Ingridient, 'id' | 'createdAt' | 'deletedAt' | 'updatedAt'>,
  ): Promise<Ingridient>;

  abstract findManyWithPagination({
    filterOptions,
    sortOptions,
    paginationOptions,
  }: {
    filterOptions?: string | null;
    sortOptions?: SortIngridientDto[] | null;
    paginationOptions: IPaginationOptions;
  }): Promise<Ingridient[]>;

  abstract findOne(
    fields: EntityCondition<Ingridient>,
  ): Promise<NullableType<Ingridient>>;

  abstract update(
    id: Ingridient['id'],
    payload: DeepPartial<Ingridient>,
  ): Promise<Ingridient | null>;

  abstract softDelete(id: Ingridient['id']): Promise<void>;
}
