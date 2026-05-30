// NOTE: 'Ingridient' spelling preserved verbatim across the backend codebase. Do not rename.
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
 * Controller routing /api/v1/ingredient/* requests to IngridientService.
 *
 * Spelling 'Ingridient' (class, module, file names) is preserved verbatim
 * across the backend codebase. The URL path uses the correct 'ingredient'
 * spelling.
 *
 * Exposes a GET /creation-data endpoint returning the hardcoded category
 * and unit reference data (5 categories + 9 units; see README § Data Flows).
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
   * GET /api/v1/ingredient/creation-data — hardcoded reference data.
   *
   * Returns the 5 categories (spice, vegetable, fruit, dairy, protein) and
   * 9 units (kg, g, lb, oz, ml, l, cup, tbsp, tsp) used by ingridient
   * creation. The reference data is hardcoded in this method
   * (Source: ingridient.controller.ts).
   *
   * @returns Object with `categories: Reference[]` and `units: Reference[]`.
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
   * POST /api/v1/ingredient — create a new Ingridient (spelling preserved verbatim).
   *
   * Validates `CreateIngridientDto` then delegates to `IngridientService.create()`.
   * Throws `UNPROCESSABLE_ENTITY` (422) if the name already exists.
   *
   * @param createIngridientDto Payload with name, category, optional quantity,
   *   optional unit, optional expirationDate, optional imageUrl, and confidence.
   * @returns The persisted `Ingridient` domain entity (spelling preserved verbatim).
   * @throws HttpException 422 when a duplicate name is detected.
   */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(
    @Body() createIngridientDto: CreateIngridientDto,
  ): Promise<Ingridient> {
    return this.ingridientService.create(createIngridientDto);
  }

  /**
   * GET /api/v1/ingredient — list ingridients with pagination (spelling preserved verbatim).
   *
   * Honors optional `query` (name filter), `sort` (orderBy/order), and
   * pagination (`page` default 1, `limit` default 10). The pagination cap
   * of 50 is enforced here (Source: ingridient.controller.ts).
   *
   * @param query `QueryIngridientDto` from the request querystring.
   * @returns Paginated result wrapping `Ingridient[]` plus `hasNextPage`.
   */
  @Get()
  @HttpCode(HttpStatus.OK)
  async findAll(
    @Query() query: QueryIngridientDto,
  ): Promise<InfinityPaginationResultType<Ingridient>> {
    const page = query?.page ?? 1;
    let limit = query?.limit ?? 10;
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
   * GET /api/v1/ingredient/:id — fetch one Ingridient by id (spelling preserved verbatim).
   *
   * Returns `null` if the record is not found or has been soft-deleted.
   *
   * @param id MongoDB ObjectId string of the target Ingridient.
   * @returns The matching `Ingridient` or `null` if absent / deleted.
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
   * PATCH /api/v1/ingredient/:id — partially update an Ingridient
   * (spelling preserved verbatim).
   *
   * Delegates to `IngridientService.update()` which throws
   * `UNPROCESSABLE_ENTITY` (422) with `ingridientNotExists` if the record
   * does not exist.
   *
   * @param id MongoDB ObjectId string of the target Ingridient.
   * @param updateIngridientDto Sparse payload of fields to update.
   * @returns The updated `Ingridient` or `null` if not found.
   * @throws HttpException 422 when the record does not exist.
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
   * DELETE /api/v1/ingredient/:id — soft-delete an Ingridient
   * (spelling preserved verbatim).
   *
   * Delegates to `IngridientService.softDelete()` which uses the proper
   * `updateOne({ deletedAt: new Date() })` pattern in
   * `IngridientDocumentRepository.softDelete()` (Source:
   * infrastructure/document/repositories/ingridient.repository.ts).
   * This contrasts with the destructive pantry softDelete; see
   * backend/src/pantry/README.md § Known Limitations.
   *
   * @param id MongoDB ObjectId string of the target Ingridient.
   * @returns `void` (HTTP 204 No Content).
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
