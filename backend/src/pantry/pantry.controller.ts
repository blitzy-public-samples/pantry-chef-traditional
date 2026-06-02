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
import { QueryPantryIngridientDto } from './dto/query-pantry-ingridient.dto';
import { UpdatePantryIngridientDto } from './dto/update-pantry-ingridient.dto';
import { CreatePantryIngridientDto } from './dto/create-pantry-ingridient.dto';
import { PantryIngridient } from './domain/pantryIngridient';
import { PantryService } from './pantry.service';

/**
 * REST controller for the Pantry resource. Exposes CRUD over the ingredients
 * a user currently has and delegates all business logic to `PantryService`.
 *
 * All routes are JWT-guarded: every request must carry a Bearer JWT, enforced
 * by `@UseGuards(AuthGuard('jwt'))`, and the controller is grouped under the
 * `Pantry` Swagger tag.
 * Source: backend/src/pantry/pantry.controller.ts:L26-L28.
 *
 * The class declares `@Controller({ path: 'pantry', version: '1' })`, yet the
 * routes are served under the global `api` prefix as `/api/pantry`. There is
 * no version segment because `main.ts` never calls `app.enableVersioning()`, so
 * the declared `version: '1'` is inactive.
 * Source: backend/src/main.ts:L14-L15.
 */
@ApiBearerAuth()
@UseGuards(AuthGuard('jwt'))
@ApiTags('Pantry')
@Controller({
  path: 'pantry',
  version: '1',
})
export class PantryController {
  constructor(private readonly pantryService: PantryService) {}

  /**
   * Creates a pantry ingredient for the authenticated user.
   *
   * @param req - the Express request; the owner id is read from `req.user?.id`
   *   and passed to the service.
   * @param createPantryIngridientDto - the create payload
   *   (`CreatePantryIngridientDto`).
   * @returns a `Promise<PantryIngridient>` for the persisted record.
   */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(
    @Request() req,
    @Body() createPantryIngridientDto: CreatePantryIngridientDto,
  ): Promise<PantryIngridient> {
    // userId is taken from the authenticated JWT request, not the body.
    const userId = req.user?.id;
    return this.pantryService.create(createPantryIngridientDto, userId);
  }

  /**
   * Lists the authenticated user's pantry ingredients with pagination.
   * Results are scoped to the requesting `userId`.
   *
   * @param req - request providing the owner id (`req.user?.id`) used as the
   *   list filter.
   * @param query - the `QueryPantryIngridientDto` (page, limit, filters, sort).
   * @returns an `InfinityPaginationResultType<PantryIngridient>`.
   */
  @Get()
  @HttpCode(HttpStatus.OK)
  async findAll(
    @Request() req,
    @Query() query: QueryPantryIngridientDto,
  ): Promise<InfinityPaginationResultType<PantryIngridient>> {
    const userId = req.user?.id;
    // page defaults to 1 when absent.
    const page = query?.page ?? 1;
    // limit defaults to 10 when absent.
    let limit = query?.limit ?? 10;
    // pagination clamp: limit is capped at a maximum of 50 items per page.
    if (limit > 50) {
      limit = 50;
    }

    return infinityPagination(
      await this.pantryService.findManyWithPagination({
        // userId is merged into the filter so users only see their own items.
        filterOptions: { userId, ...query?.filters },
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
   * Retrieves a single pantry ingredient by its id.
   *
   * @param id - the pantry ingredient id (`PantryIngridient['id']`).
   * @returns a `NullableType<PantryIngridient>`; `null` when not found.
   */
  @Get(':id')
  @HttpCode(HttpStatus.OK)
  @ApiParam({
    name: 'id',
    type: String,
    required: true,
  })
  findOne(
    @Param('id') id: PantryIngridient['id'],
  ): Promise<NullableType<PantryIngridient>> {
    return this.pantryService.findOne({ id });
  }

  /**
   * Applies a partial update to a pantry ingredient by id.
   *
   * @param id - the pantry ingredient id.
   * @param updateIngridientDto - the `UpdatePantryIngridientDto` partial
   *   payload.
   * @returns the updated `PantryIngridient`, or `null` when no record matches.
   * @throws HttpException 422 (Unprocessable Entity) raised by
   *   `PantryService.update` when the target record does not exist.
   */
  @Patch(':id')
  @HttpCode(HttpStatus.OK)
  @ApiParam({
    name: 'id',
    type: String,
    required: true,
  })
  update(
    @Param('id') id: PantryIngridient['id'],
    @Body() updateIngridientDto: UpdatePantryIngridientDto,
  ): Promise<PantryIngridient | null> {
    return this.pantryService.update(id, updateIngridientDto);
  }

  /**
   * Deletes a pantry ingredient by id; responds with `204 No Content`.
   *
   * @param id - the pantry ingredient id.
   * @returns a `Promise<void>`.
   */
  @Delete(':id')
  @ApiParam({
    name: 'id',
    type: String,
    required: true,
  })
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id') id: PantryIngridient['id']): Promise<void> {
    // KNOWN ISSUE: despite the `softDelete` name, the document repository
    // performs a HARD delete via `deleteOne`; the record is physically
    // removed, not soft-deleted. Source:
    // backend/src/pantry/infrastructure/document/repositories/pantryIngridient.repository.ts:L120
    return this.pantryService.softDelete(id);
  }
}
