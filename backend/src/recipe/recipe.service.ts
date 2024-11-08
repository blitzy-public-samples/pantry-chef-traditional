import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { EntityCondition } from 'src/utils/types/entity-condition.type';
import { IPaginationOptions } from 'src/utils/types/pagination-options';
import { NullableType } from '../utils/types/nullable.type';
import { RecipeRepository } from './infrastructure/recipe.repository';
import { DeepPartial } from 'src/utils/types/deep-partial.type';
import { Recipe } from './domain/recipe';
import { CreateRecipeDto } from './dto/create-recipe.dto';
import { FilterRecipeDto, SortRecipeDto } from './dto/query-recipe.dto';
import { UsersService } from 'src/users/users.service';
import { PantryService } from 'src/pantry/pantry.service';
import { FilterType } from './types/filter.types';

@Injectable()
export class RecipeService {
  constructor(
    private readonly userService: UsersService,
    private readonly pantryService: PantryService,
    private readonly recipeRepository: RecipeRepository,
  ) {}

  async create(createRecipeDto: CreateRecipeDto): Promise<Recipe> {
    const clonedPayload = {
      ...createRecipeDto,
    };

    if (clonedPayload.title) {
      const userObject = await this.recipeRepository.findOne({
        title: clonedPayload.title,
      });
      if (userObject) {
        throw new HttpException(
          {
            status: HttpStatus.UNPROCESSABLE_ENTITY,
            errors: {
              email: 'recipeAlreadyExists',
            },
          },
          HttpStatus.UNPROCESSABLE_ENTITY,
        );
      }
    }

    return this.recipeRepository.create(clonedPayload);
  }

  findManyWithPagination({
    filterOptions,
    sortOptions,
    paginationOptions,
  }: {
    filterOptions?: FilterRecipeDto;
    sortOptions?: SortRecipeDto[] | null;
    paginationOptions: IPaginationOptions;
  }): Promise<Recipe[]> {
    return this.recipeRepository.findManyWithPagination({
      filterOptions,
      sortOptions,
      paginationOptions,
    });
  }

  findOne(fields: EntityCondition<Recipe>): Promise<NullableType<Recipe>> {
    return this.recipeRepository.findOne(fields);
  }

  async matches(userId: string, filterOptions: FilterType): Promise<Recipe[]> {
    const user = await this.userService.findOne({ id: userId });
    const { preferences } = user;
    const pantryIngredients = await this.pantryService.findAllByUserId(userId);
    return this.recipeRepository.matches(
      preferences,
      pantryIngredients,
      filterOptions,
    );
  }

  async update(
    id: Recipe['id'],
    payload: DeepPartial<Recipe>,
  ): Promise<Recipe | null> {
    const clonedPayload = { ...payload };

    const ingredientObject = await this.recipeRepository.findOne({ id });
    if (!ingredientObject?.id) {
      throw new HttpException(
        {
          status: HttpStatus.UNPROCESSABLE_ENTITY,
          errors: {
            email: 'recipeNotExists',
          },
        },
        HttpStatus.UNPROCESSABLE_ENTITY,
      );
    }

    return this.recipeRepository.update(id, clonedPayload);
  }

  async softDelete(id: Recipe['id']): Promise<void> {
    await this.recipeRepository.softDelete(id);
  }
}
