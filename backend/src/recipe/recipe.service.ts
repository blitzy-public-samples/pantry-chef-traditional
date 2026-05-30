// NOTE: 'PantryIngridient' / 'IngridientList' / 'ingridientList' spellings
// preserved verbatim. Do not rename.
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
 * Recipe orchestration: CRUD plus the pantry-aware matches() flow.
 *
 * For matches(userId, filterOptions), the service fetches the user's
 * Preferences via UsersService and the user's PantryIngridient list
 * (spelling preserved verbatim) via PantryService, then delegates to
 * RecipeRepository.matches for the scoring algorithm.
 */
@Injectable()
export class RecipeService {
  constructor(
    private readonly userService: UsersService,
    private readonly pantryService: PantryService,
    private readonly recipeRepository: RecipeRepository,
  ) {}

  /**
   * Persist a new recipe after enforcing a unique-title constraint.
   *
   * Looks up an existing recipe by title; if one is found, throws an
   * HttpException with UNPROCESSABLE_ENTITY. Otherwise delegates to
   * the repository's create() to persist the document.
   *
   * @param createRecipeDto Validated create payload, including the embedded
   *   `ingridientList` (spelling preserved verbatim) and `instructions`.
   * @returns The newly persisted Recipe domain entity.
   * @throws HttpException 422 (UNPROCESSABLE_ENTITY) when a recipe with
   *   the same title already exists.
   */
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

  /**
   * List recipes with pagination support.
   *
   * Pure pass-through to RecipeRepository.findManyWithPagination. The
   * controller is responsible for capping the page size (50).
   *
   * @param params filterOptions (name regex search, ids whitelist),
   *   sortOptions (optional list of sort directives), paginationOptions
   *   (page and limit).
   * @returns Recipe[] for the requested page.
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
   * Find a single recipe matching the provided entity condition.
   *
   * @param fields Partial Recipe condition (typically `{ id }` or `{ title }`).
   * @returns The Recipe domain entity, or null when no document matches.
   */
  findOne(fields: EntityCondition<Recipe>): Promise<NullableType<Recipe>> {
    return this.recipeRepository.findOne(fields);
  }

  /**
   * Compute pantry-aware recipe matches for the given user.
   *
   * @param userId Authenticated user's MongoDB _id.
   * @param filterOptions FilterType with optional isQuickMake/isAlmostThere flags.
   * @returns Recipe[] sorted by matchScore descending.
   * @throws NotFoundException if the user is not found.
   */
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

  /**
   * Partial update of an existing recipe.
   *
   * Verifies the recipe exists via repository.findOne({ id }); if it
   * does not, throws an HttpException with UNPROCESSABLE_ENTITY. Then
   * delegates to repository.update() to apply the partial payload.
   *
   * @param id Recipe identifier (MongoDB ObjectId as string).
   * @param payload DeepPartial<Recipe> update payload.
   * @returns The updated Recipe domain entity, or null when the post-update
   *   findByIdAndUpdate returns no document.
   * @throws HttpException 422 (UNPROCESSABLE_ENTITY) when the recipe is
   *   not found prior to the update attempt.
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
   * Proper soft-delete: marks the recipe document with `deletedAt = new Date()`.
   *
   * Delegates to RecipeRepository.softDelete which executes a Mongoose
   * `updateOne({ _id }, { deletedAt: new Date() })`. This is a PROPER
   * soft-delete contract — in contrast to the pantry module's destructive
   * variant that physically removes the document. See
   * ../../../ARCHITECTURE.md § Soft-Delete Contract.
   *
   * @param id Recipe identifier (MongoDB ObjectId as string).
   * @returns void on success; the document is not removed, only flagged.
   */
  async softDelete(id: Recipe['id']): Promise<void> {
    await this.recipeRepository.softDelete(id);
  }
}
