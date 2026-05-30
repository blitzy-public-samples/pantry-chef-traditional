import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { EntityCondition } from 'src/utils/types/entity-condition.type';
import { IPaginationOptions } from 'src/utils/types/pagination-options';
import { NullableType } from '../utils/types/nullable.type';
import { RecipeRepository } from './infrastructure/recipe.repository';
import { DeepPartial } from 'src/utils/types/deep-partial.type';
import { Recipe } from './domain/recipe';
import { CreateRecipeDto } from './dto/create-recipe.dto';
import { FilterRecipeDto, SortRecipeDto } from './dto/query-recipe.dto';
// Added for "What Can I Make Tonight?" suggestions feature
import {
  RecipeSuggestionsResponseDto,
  RecipeSuggestionDto,
} from './dto/recipe-suggestion.dto';
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

  // Added for "What Can I Make Tonight?" suggestions feature
  async getSuggestions(
    userId: string,
    filters: FilterType,
    page?: number,
    limit?: number,
  ): Promise<RecipeSuggestionsResponseDto> {
    // Mirror matches(): load preferences and pantry, then reuse the matching
    // pipeline (already pre-filtered, scored, and sorted by matchScore DESC).
    const user = await this.userService.findOne({ id: userId });
    const { preferences } = user;
    const pantry = await this.pantryService.findAllByUserId(userId);
    const recipes = await this.recipeRepository.matches(
      preferences,
      pantry,
      filters,
    );

    // The domain mapper drops isQuickMake/isAlmostThere/missingIngredientsCount,
    // so recompute the derived fields here using the DOMAIN-level ingridient ids
    // (sic spelling preserved to match the backend conventions).
    const pantryIds = new Set(pantry.map((pi) => pi.ingridient.id));

    const mapped: RecipeSuggestionDto[] = recipes.map((recipe) => {
      // Ingredients on the recipe that are not present in the user's pantry.
      const missing = recipe.ingridientList.filter(
        (il) => !pantryIds.has(il.ingridient.id),
      );
      // Guard zero-ingredient recipes FIRST: matchScore is NaN when the recipe
      // has no ingredients, so the matchScore === 1 check below would not catch
      // them. A recipe with nothing to gather is considered READY.
      const status: 'READY' | 'ALMOST_THERE' | 'MISSING' =
        recipe.ingridientList.length === 0
          ? 'READY'
          : recipe.matchScore === 1
            ? 'READY'
            : missing.length <= 2
              ? 'ALMOST_THERE'
              : 'MISSING';
      // isQuickMake is orthogonal to status: it only reflects recipe simplicity.
      const isQuickMake = recipe.ingridientList.length <= 5;
      const missingIngredients = missing.map((il) => ({
        id: il.ingridient.id,
        name: il.ingridient.name,
      }));
      return {
        recipe,
        matchScore: recipe.matchScore,
        status,
        isQuickMake,
        missingIngredients,
      };
    });

    // In-memory pagination over the already-sorted list. Cap the page size at 50
    // to mirror findAll, and coerce query params (which arrive as strings) with
    // Number(). The matches() ordering (matchScore DESC) is preserved by map/slice.
    const pageNum = page ? Number(page) : 1;
    let limitNum = limit ? Number(limit) : 10;
    if (limitNum > 50) {
      limitNum = 50;
    }
    const total = mapped.length;
    const data = mapped.slice((pageNum - 1) * limitNum, pageNum * limitNum);
    const hasMore = pageNum * limitNum < total;

    return { data, hasMore };
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
