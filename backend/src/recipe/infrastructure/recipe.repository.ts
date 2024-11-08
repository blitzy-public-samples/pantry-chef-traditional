import { Recipe } from '../domain/recipe';
import { NullableType } from 'src/utils/types/nullable.type';
import { EntityCondition } from 'src/utils/types/entity-condition.type';
import { DeepPartial } from 'src/utils/types/deep-partial.type';
import { IPaginationOptions } from 'src/utils/types/pagination-options';
import { FilterRecipeDto, SortRecipeDto } from '../dto/query-recipe.dto';
import { Preferences } from 'src/users/infrastructure/document/entities/user.schema';
import { PantryIngridient } from 'src/pantry/domain/pantryIngridient';
import { FilterType } from '../types/filter.types';

export abstract class RecipeRepository {
  abstract create(
    data: Omit<Recipe, 'id' | 'createdAt' | 'deletedAt' | 'updatedAt'>,
  ): Promise<Recipe>;

  abstract findManyWithPagination({
    filterOptions,
    sortOptions,
    paginationOptions,
  }: {
    filterOptions?: FilterRecipeDto;
    sortOptions?: SortRecipeDto[] | null;
    paginationOptions: IPaginationOptions;
  }): Promise<Recipe[]>;

  abstract matches(
    preferences: Preferences,
    pantryIngredients: PantryIngridient[],
    filterOptions: FilterType,
  ): Promise<Recipe[]>;

  abstract findOne(
    fields: EntityCondition<Recipe>,
  ): Promise<NullableType<Recipe>>;

  abstract update(
    id: Recipe['id'],
    payload: DeepPartial<Recipe>,
  ): Promise<Recipe | null>;

  abstract softDelete(id: Recipe['id']): Promise<void>;
}
