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
    // Normalize the incoming filter flags before reusing the frozen matches()
    // pipeline. RecipeFiltersDto flags arrive from the mobile client as HTTP
    // query strings with no DTO transformation, and inside matches() a raw
    // string 'false' is TRUTHY — which would silently filter the default
    // suggestions request down to quick/almost-there recipes. Treat ONLY a real
    // boolean true or the string 'true' as enabled; everything else (including
    // the string 'false') is disabled, so the default request returns the full
    // ranked list.
    const isFlagEnabled = (value: unknown): boolean =>
      value === true || value === 'true';
    const normalizedFilters: FilterType = {
      isQuickMake: isFlagEnabled(filters.isQuickMake),
      isAlmostThere: isFlagEnabled(filters.isAlmostThere),
    };
    const recipes = await this.recipeRepository.matches(
      preferences,
      pantry,
      normalizedFilters,
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
      // Normalize the zero-ingredient matchScore. matches() computes
      // matchScore = available / total, so a zero-ingredient recipe yields
      // 0 / 0 = NaN, which JSON-serializes to null and violates the documented
      // 0..1 contract (and the mobile non-null double). A recipe that needs
      // nothing gathered is fully matched, so emit 1; the nested recipe score is
      // updated too so the embedded object stays consistent with matchScore.
      const matchScore =
        recipe.ingridientList.length === 0 ? 1 : recipe.matchScore;
      recipe.matchScore = matchScore;
      return {
        recipe,
        matchScore,
        status,
        isQuickMake,
        missingIngredients,
      };
    });

    // In-memory pagination over the already-sorted list. Query params arrive as
    // strings and may be malformed (negative, zero, fractional, non-numeric), so
    // sanitize them: clamp page to a finite integer >= 1 (default 1) and limit to
    // a finite integer in 1..50 (default 10, cap 50 to mirror findAll).
    // Floor FIRST, then require the floored value to be >= 1. Doing it in this
    // order is what closes the fractional-below-1 hole: a value such as page=0.5
    // or limit=0.5 is positive but floors to 0, so a "raw > 0 then floor" check
    // would let it through and produce a bad slice (slice(-10, 0) / slice(0, 0))
    // with hasMore=true and empty data. Flooring up front means those values are
    // compared as 0, fail the >= 1 test, and fall back to the safe defaults. The
    // >= 1 floor also stops limit=-1 from bypassing the 50-item cap via
    // slice(0, -1). The matches() ordering (matchScore DESC) is preserved by
    // map/slice.
    const flooredPage = Math.floor(Number(page));
    const pageNum =
      Number.isFinite(flooredPage) && flooredPage >= 1 ? flooredPage : 1;
    const flooredLimit = Math.floor(Number(limit));
    let limitNum =
      Number.isFinite(flooredLimit) && flooredLimit >= 1 ? flooredLimit : 10;
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
