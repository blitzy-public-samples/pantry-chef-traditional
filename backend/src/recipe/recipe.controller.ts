import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Query,
  HttpStatus,
  HttpCode,
  Request,
} from '@nestjs/common';
import { ApiBearerAuth, ApiParam, ApiTags } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { infinityPagination } from 'src/utils/infinity-pagination';
import { InfinityPaginationResultType } from '../utils/types/infinity-pagination-result.type';
import { NullableType } from '../utils/types/nullable.type';
import { Recipe } from './domain/recipe';
import { RecipeService } from './recipe.service';
import { QueryRecipeDto } from './dto/query-recipe.dto';
import { UpdateRecipeDto } from './dto/update-recipe.dto';
import { CreateRecipeDto } from './dto/create-recipe.dto';
import { FilterType } from './types/filter.types';

/**
 * REST controller exposing the recipe HTTP API: CRUD operations plus the
 * ingredient-matching engine. All request handling is delegated to
 * `RecipeService`; this class only wires routes, status codes, and Swagger
 * metadata.
 *
 * Auth: every route is JWT-guarded via `@UseGuards(AuthGuard('jwt'))`, so a
 * valid bearer token is required (advertised to Swagger via `@ApiBearerAuth()`).
 *
 * Served base path: `/api/recipe`. The global `api` prefix is applied during
 * bootstrap (Source: backend/src/main.ts:L30-L35). Although `@Controller`
 * declares `version: '1'`, URI versioning is never enabled (no
 * `app.enableVersioning()` call), so that declaration is inert and no version
 * segment appears in the served path.
 */
@ApiBearerAuth()
@UseGuards(AuthGuard('jwt'))
@ApiTags('Recipe')
@Controller({
  path: 'recipe',
  version: '1',
})
export class RecipeController {
  constructor(private readonly recipeService: RecipeService) {}

  /**
   * Creates a new recipe.
   *
   * Maps to `POST /api/recipe` and responds with `201 Created`.
   *
   * @param createRecipeDto - The recipe payload to persist.
   * @returns A promise resolving to the created `Recipe`.
   * @throws HttpException `422 Unprocessable Entity` when a recipe with the same
   * `title` already exists (validated in `RecipeService.create`,
   * Source: backend/src/recipe/recipe.service.ts:L44-L59).
   */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(@Body() createRecipeDto: CreateRecipeDto): Promise<Recipe> {
    return this.recipeService.create(createRecipeDto);
  }

  /**
   * Returns recipes scored and ranked against the authenticated user's pantry
   * contents and saved preferences.
   *
   * Maps to `GET /api/recipe/matches` and responds with `200 OK`. The user id
   * is read from `req.user?.id` and forwarded to `RecipeService.matches`.
   *
   * Note: this route is declared BEFORE the `:id` route, so the literal
   * `matches` segment is matched first and is not shadowed by the `:id` param
   * route.
   *
   * @param req - The authenticated request; supplies the user id via
   * `req.user?.id`.
   * @param filterQuery - `FilterType` flags (`isQuickMake` / `isAlmostThere`).
   * @returns A promise resolving to the matched, score-ranked recipes.
   */
  @Get('matches')
  @HttpCode(HttpStatus.OK)
  async matches(@Request() req, @Query() filterQuery: FilterType) {
    const id = req.user?.id;
    return this.recipeService.matches(id, filterQuery);
  }

  /**
   * Lists recipes using infinity-style pagination with optional filtering and
   * sorting.
   *
   * Maps to `GET /api/recipe` and responds with `200 OK`.
   *
   * @param query - `QueryRecipeDto` carrying `page`, `limit`, `query`, `ids`,
   * and `sort`.
   * @returns A promise resolving to an `InfinityPaginationResultType<Recipe>`.
   *
   * Pagination: `limit` defaults to 10 and is clamped to a hard maximum of 50
   */
  @Get()
  @HttpCode(HttpStatus.OK)
  async findAll(
    @Query() query: QueryRecipeDto,
  ): Promise<InfinityPaginationResultType<Recipe>> {
    const page = query?.page ?? 1;
    let limit = query?.limit ?? 10;
    // Clamp page size to a hard maximum of 50 items
    if (limit > 50) {
      limit = 50;
    }

    return infinityPagination(
      await this.recipeService.findManyWithPagination({
        filterOptions: { name: query?.query || null, ids: query?.ids || null },
        sortOptions: query?.sort,
        paginationOptions: {
          page,
          limit,
        },
      }),
      { page, limit },
    );
  }

  /**
   * Retrieves a single recipe by its id.
   *
   * Maps to `GET /api/recipe/:id` and responds with `200 OK`.
   *
   * @param id - The recipe id to look up.
   * @returns A promise resolving to the `Recipe`, or `null` when it is not
   * found (`NullableType<Recipe>`).
   */
  @Get(':id')
  @HttpCode(HttpStatus.OK)
  @ApiParam({
    name: 'id',
    type: String,
    required: true,
  })
  findOne(@Param('id') id: Recipe['id']): Promise<NullableType<Recipe>> {
    return this.recipeService.findOne({ id });
  }

  /**
   * Applies a partial update to an existing recipe.
   *
   * Maps to `PATCH /api/recipe/:id` and responds with `200 OK`.
   *
   * @param id - The id of the recipe to update.
   * @param updateRecipeDto - The partial recipe payload (`UpdateRecipeDto`).
   * @returns A promise resolving to the updated `Recipe`, or `null`.
   * @throws HttpException `422 Unprocessable Entity` when the recipe id does
   * not exist (validated in `RecipeService.update`,
   * Source: backend/src/recipe/recipe.service.ts:L138-L148).
   */
  @Patch(':id')
  @HttpCode(HttpStatus.OK)
  @ApiParam({
    name: 'id',
    type: String,
    required: true,
  })
  update(
    @Param('id') id: Recipe['id'],
    @Body() updateRecipeDto: UpdateRecipeDto,
  ): Promise<Recipe | null> {
    return this.recipeService.update(id, updateRecipeDto);
  }

  /**
   * Soft-deletes a recipe by its id.
   *
   * Maps to `DELETE /api/recipe/:id` and responds with `204 No Content`.
   *
   * Performs a TRUE soft delete: the service/repository sets `deletedAt`
   * instead of removing the document.
   * Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L310-L311
   *
   * @param id - The id of the recipe to soft-delete.
   * @returns A promise that resolves once the soft delete completes (`void`).
   */
  @Delete(':id')
  @ApiParam({
    name: 'id',
    type: String,
    required: true,
  })
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id') id: Recipe['id']): Promise<void> {
    return this.recipeService.softDelete(id);
  }
}
