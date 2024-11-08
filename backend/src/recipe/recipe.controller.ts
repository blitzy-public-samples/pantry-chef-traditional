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
export class RecipeController {
  constructor(private readonly recipeService: RecipeService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(@Body() createRecipeDto: CreateRecipeDto): Promise<Recipe> {
    return this.recipeService.create(createRecipeDto);
  }

  @Get('matches')
  @HttpCode(HttpStatus.OK)
  async matches(@Request() req, @Query() filterQuery: FilterType) {
    const id = req.user?.id;
    return this.recipeService.matches(id, filterQuery);
  }

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
