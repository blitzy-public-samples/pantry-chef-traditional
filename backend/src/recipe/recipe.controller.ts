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

@ApiBearerAuth()
@UseGuards(AuthGuard('jwt'))
@ApiTags('Recipe')
@Controller({
  path: 'recipe',
  version: '1',
})
/**
 * Controller routing /api/v1/recipe/* requests to RecipeService.
 *
 * All endpoints require JWT authentication via @UseGuards(AuthGuard('jwt'))
 * and are tagged for Swagger as 'Recipe' with bearer auth. The pantry-aware
 * GET /matches endpoint is the headline feature (see README.md § Data Flows).
 */
export class RecipeController {
  constructor(private readonly recipeService: RecipeService) {}

  /**
   * POST /api/v1/recipe — create a new recipe.
   *
   * Delegates to RecipeService.create which enforces a unique-title check
   * before persisting via the recipe repository.
   *
   * @param createRecipeDto Validated payload describing the new recipe,
   *   including the embedded `ingridientList` (spelling preserved verbatim)
   *   and the `instructions` array.
   * @returns The newly persisted Recipe domain entity.
   * @throws HttpException 422 (UNPROCESSABLE_ENTITY) when a recipe with the
   *   same title already exists.
   */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(@Body() createRecipeDto: CreateRecipeDto): Promise<Recipe> {
    return this.recipeService.create(createRecipeDto);
  }

  /**
   * GET /api/v1/recipe/matches — pantry-aware recipe matches.
   *
   * Fetches the authenticated user's Preferences and PantryIngridient list,
   * delegates to RecipeService.matches, returns recipes sorted by matchScore.
   *
   * @param request Authenticated request (req.user populated by JwtStrategy).
   * @param query Optional FilterType (isQuickMake?, isAlmostThere?).
   * @returns Recipe[] sorted by matchScore descending.
   */
  @Get('matches')
  @HttpCode(HttpStatus.OK)
  async matches(@Request() req, @Query() filterQuery: FilterType) {
    const id = req.user?.id;
    return this.recipeService.matches(id, filterQuery);
  }

  /**
   * GET /api/v1/recipe — list recipes with pagination (hard cap 50 per page).
   *
   * Forwards filterOptions (name regex search, ids whitelist) and sortOptions
   * to RecipeService.findManyWithPagination, then wraps the result with the
   * shared infinityPagination helper.
   *
   * @param query QueryRecipeDto carrying page, limit, query (name), ids, sort.
   * @returns InfinityPaginationResultType<Recipe> for the requested page.
   */
  @Get()
  @HttpCode(HttpStatus.OK)
  async findAll(
    @Query() query: QueryRecipeDto,
  ): Promise<InfinityPaginationResultType<Recipe>> {
    const page = query?.page ?? 1;
    let limit = query?.limit ?? 10;
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
   * GET /api/v1/recipe/:id — fetch a single recipe by id.
   *
   * @param id Recipe identifier (MongoDB ObjectId as string).
   * @returns The Recipe domain entity, or null when no document matches.
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
   * PATCH /api/v1/recipe/:id — partial update of an existing recipe.
   *
   * Delegates to RecipeService.update which first verifies the recipe exists.
   *
   * @param id Recipe identifier (MongoDB ObjectId as string).
   * @param updateRecipeDto Partial update payload validated by class-validator.
   * @returns The updated Recipe domain entity, or null when no document
   *   matches the id.
   * @throws HttpException 422 (UNPROCESSABLE_ENTITY) when the recipe is not
   *   found prior to the update attempt.
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
   * DELETE /api/v1/recipe/:id — proper soft-delete of a recipe.
   *
   * Delegates to RecipeService.softDelete which performs a Mongoose
   * `updateOne({ _id }, { deletedAt: new Date() })` at
   * infrastructure/document/repositories/recipe.repository.ts:L184-L186.
   * This is a PROPER soft-delete (in contrast to the pantry module's
   * destructive softDelete variant — see ../../../ARCHITECTURE.md
   * § Soft-Delete Contract).
   *
   * @param id Recipe identifier (MongoDB ObjectId as string).
   * @returns void on success; responds with HTTP 204 (NO_CONTENT).
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
