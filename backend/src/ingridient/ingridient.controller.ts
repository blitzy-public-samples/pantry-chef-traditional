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
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiParam,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { infinityPagination } from 'src/utils/infinity-pagination';
import { InfinityPaginationResultType } from '../utils/types/infinity-pagination-result.type';
import { NullableType } from '../utils/types/nullable.type';
import { Ingridient } from './domain/ingrident';
import { IngridientService } from './ingridient.service';
import { QueryIngridientDto } from './dto/query-ingridient.dto';
import { UpdateIngridientDto } from './dto/update-ingridient.dto';
import { CreateIngridientDto } from './dto/create-ingridient.dto';

/**
 * REST controller exposing the ingredient catalog API.
 *
 * All routes require a Bearer JWT via `@UseGuards(AuthGuard('jwt'))` and are
 * grouped under the Swagger tag `Ingredient`.
 *
 * The served route base is `ingredient` under the global `api` prefix. Despite
 * the declared `version: '1'`, `main.ts` never calls `enableVersioning()`, so
 * the served paths contain no version segment (e.g. `GET /api/ingredient`).
 * Source: backend/src/main.ts:L30-L35
 *
 * Delegates all business logic to `IngridientService`.
 */
@ApiBearerAuth()
@UseGuards(AuthGuard('jwt'))
@ApiTags('Ingredient')
@Controller({
  path: 'ingredient',
  version: '1',
})
export class IngridientController {
  constructor(private readonly ingridientService: IngridientService) {}

  /**
   * Returns reference data used by clients when creating an ingredient.
   *
   * @returns an object with `categories` and `units` arrays, each element
   * shaped `{ id, name }`. The 5 categories are `spice`, `vegetable`, `fruit`,
   * `dairy`, `protein`; the 9 units are `kg`, `g`, `lb`, `oz`, `ml`, `l`,
   * `cup`, `tbsp`, `tsp`.
   */
  @Get('/creation-data')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get data for ingredient creation' })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Returns data for creating an ingredient.',
  })
  async getCreationData(): Promise<{
    categories: { id: number; name: string }[];
    units: { id: number; name: string }[];
  }> {
    // KNOWN ISSUE: these category/unit reference values are hardcoded in the
    // controller rather than sourced from the database.
    return {
      categories: [
        { id: 1, name: 'spice' },
        { id: 2, name: 'vegetable' },
        { id: 3, name: 'fruit' },
        { id: 4, name: 'dairy' },
        { id: 5, name: 'protein' },
      ],
      units: [
        { id: 1, name: 'kg' },
        { id: 2, name: 'g' },
        { id: 3, name: 'lb' },
        { id: 4, name: 'oz' },
        { id: 5, name: 'ml' },
        { id: 6, name: 'l' },
        { id: 7, name: 'cup' },
        { id: 8, name: 'tbsp' },
        { id: 9, name: 'tsp' },
      ],
    };
  }

  /**
   * Creates a new ingredient.
   *
   * @param createIngridientDto the new ingredient payload to persist.
   * @returns the created `Ingridient`.
   * @throws HttpException 422 (Unprocessable Entity) when an ingredient with
   * the same `name` already exists, thrown by `IngridientService.create`.
   * Source: backend/src/ingridient/ingridient.service.ts:L24-L34
   */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(
    @Body() createIngridientDto: CreateIngridientDto,
  ): Promise<Ingridient> {
    return this.ingridientService.create(createIngridientDto);
  }

  /**
   * Lists ingredients with cursor-style infinity pagination, filtering, and
   * sorting.
   *
   * @param query pagination, filter, and sort options.
   * @returns an `InfinityPaginationResultType<Ingridient>` of matching items.
   */
  @Get()
  @HttpCode(HttpStatus.OK)
  async findAll(
    @Query() query: QueryIngridientDto,
  ): Promise<InfinityPaginationResultType<Ingridient>> {
    // Default to page 1 and a page size of 10 when query params are absent.
    const page = query?.page ?? 1;
    let limit = query?.limit ?? 10;
    // Clamp the requested page size to a maximum of 50 items per page.
    if (limit > 50) {
      limit = 50;
    }

    return infinityPagination(
      await this.ingridientService.findManyWithPagination({
        filterOptions: query?.query,
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
   * Retrieves a single ingredient by its identifier.
   *
   * @param id the ingredient id to look up.
   * @returns the matching `Ingridient`, or `null` when no record is found.
   */
  @Get(':id')
  @HttpCode(HttpStatus.OK)
  @ApiParam({
    name: 'id',
    type: String,
    required: true,
  })
  findOne(
    @Param('id') id: Ingridient['id'],
  ): Promise<NullableType<Ingridient>> {
    return this.ingridientService.findOne({ id });
  }

  /**
   * Updates an existing ingredient identified by `id`.
   *
   * @param id the id of the ingredient to update.
   * @param updateIngridientDto the partial fields to apply.
   * @returns the updated `Ingridient`, or `null` when the update yields none.
   * @throws HttpException 422 (Unprocessable Entity) when no ingredient exists
   * for the given `id`, thrown by `IngridientService.update`.
   * Source: backend/src/ingridient/ingridient.service.ts:L124-L134
   */
  @Patch(':id')
  @HttpCode(HttpStatus.OK)
  @ApiParam({
    name: 'id',
    type: String,
    required: true,
  })
  update(
    @Param('id') id: Ingridient['id'],
    @Body() updateIngridientDto: UpdateIngridientDto,
  ): Promise<Ingridient | null> {
    return this.ingridientService.update(id, updateIngridientDto);
  }

  /**
   * Deletes an ingredient by its identifier.
   *
   * Delegates to `IngridientService.softDelete`.
   *
   * @param id the id of the ingredient to delete.
   * @returns `void` once the deletion completes (HTTP 204 No Content).
   */
  @Delete(':id')
  @ApiParam({
    name: 'id',
    type: String,
    required: true,
  })
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id') id: Ingridient['id']): Promise<void> {
    return this.ingridientService.softDelete(id);
  }
}
