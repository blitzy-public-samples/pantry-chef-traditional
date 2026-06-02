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

/**
 * Business-layer service that orchestrates recipe use cases for the recipe module.
 *
 * Coordinates recipe creation, paginated listing, single lookups, preference- and
 * pantry-aware matching, updates, and soft-deletion. Persistence is delegated to the
 * abstract RecipeRepository; cross-domain reads come from UsersService (user
 * preferences) and PantryService (available pantry ingredients).
 *
 */
@Injectable()
export class RecipeService {
  constructor(
    private readonly userService: UsersService,
    private readonly pantryService: PantryService,
    private readonly recipeRepository: RecipeRepository,
  ) {}

  /**
   * Creates a recipe, rejecting duplicates that share an existing title.
   *
   * @param createRecipeDto - Recipe creation payload (title, ingredients, steps, etc.).
   * @returns A promise resolving to the newly persisted Recipe.
   * @throws HttpException 422 UNPROCESSABLE_ENTITY when a recipe with the same title
   *   already exists.
   */
  async create(createRecipeDto: CreateRecipeDto): Promise<Recipe> {
    const clonedPayload = {
      ...createRecipeDto,
    };

    if (clonedPayload.title) {
      // Enforce unique recipe title before persisting
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

  /**
   * Lists recipes with pagination, plus optional filtering and sorting.
   *
   * @param options - Query options grouping the filter, sort, and pagination inputs.
   * @param options.filterOptions - Optional filters such as name or recipe ids.
   * @param options.sortOptions - Optional ordering directives, or null when unsorted.
   * @param options.paginationOptions - Required page and limit controls.
   * @returns A promise resolving to the matching Recipe array.
   */
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

  /**
   * Finds a single recipe matching the supplied entity condition.
   *
   * @param fields - Partial recipe condition used to locate one document.
   * @returns A promise resolving to the matching Recipe, or null when none match.
   */
  findOne(fields: EntityCondition<Recipe>): Promise<NullableType<Recipe>> {
    return this.recipeRepository.findOne(fields);
  }

  /**
   * Ranks recipes for a user by available pantry ingredients and preferences.
   *
   * Loads the user's stored preferences and current pantry, then delegates scoring
   * and ranking to the repository matcher.
   *
   * @param userId - Identifier of the authenticated user requesting matches.
   * @param filterOptions - FilterType flags (isQuickMake, isAlmostThere).
   * @returns A promise resolving to scored and ranked Recipe results.
   */
  async matches(userId: string, filterOptions: FilterType): Promise<Recipe[]> {
    // Load the user's stored dietary preferences for match pre-filtering
    const user = await this.userService.findOne({ id: userId });
    const { preferences } = user;
    // Load the user's current pantry ingredients available for matching
    const pantryIngredients = await this.pantryService.findAllByUserId(userId);
    return this.recipeRepository.matches(
      preferences,
      pantryIngredients,
      filterOptions,
    );
  }

  /**
   * Updates an existing recipe after confirming it exists.
   *
   * @param id - Identifier of the recipe to update.
   * @param payload - Deep-partial recipe fields to merge into the stored document.
   * @returns A promise resolving to the updated Recipe, or null when not updated.
   * @throws HttpException 422 UNPROCESSABLE_ENTITY when no recipe matches the id.
   */
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

  /**
   * Soft-deletes a recipe by delegating to the repository.
   *
   * @param id - Identifier of the recipe to soft-delete.
   * @returns A promise that resolves once the soft-delete completes.
   */
  async softDelete(id: Recipe['id']): Promise<void> {
    // Repository performs a TRUE soft delete (sets deletedAt). Source:
    // backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L310-L311
    await this.recipeRepository.softDelete(id);
  }
}
