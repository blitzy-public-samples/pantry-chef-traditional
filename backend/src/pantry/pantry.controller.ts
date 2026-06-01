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
// NOTE: 'PantryIngridient' spelling preserved verbatim across the backend codebase. Do not rename.
import { QueryPantryIngridientDto } from './dto/query-pantry-ingridient.dto';
import { UpdatePantryIngridientDto } from './dto/update-pantry-ingridient.dto';
import { CreatePantryIngridientDto } from './dto/create-pantry-ingridient.dto';
import { PantryIngridient } from './domain/pantryIngridient';
import { PantryService } from './pantry.service';

/**
 * Controller routing /api/pantry/* requests to PantryService.
 *
 * All endpoints require JWT authentication via AuthGuard('jwt'). User scoping
 * is enforced by extracting req.user.id (populated by JwtStrategy.validate)
 * and either filtering pantry queries by userId or attaching userId to the
 * create payload. Pagination is capped at 50 items per page.
 *
 * Spelling preserved verbatim: PantryIngridient, CreatePantryIngridientDto,
 * UpdatePantryIngridientDto, QueryPantryIngridientDto. Do not rename.
 *
 * @see PantryService for business-orchestration logic.
 * @see ../../../ARCHITECTURE.md (JWT Authentication Flow section).
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
   * POST /api/pantry — Create a new pantry item for the authenticated user.
   *
   * Extracts userId from req.user.id (populated by JwtStrategy.validate) and
   * forwards both userId and the validated DTO to PantryService.create.
   *
   * @param req Express request, with `req.user` populated by AuthGuard('jwt').
   * @param createPantryIngridientDto Validated payload (spelling preserved).
   * @returns The created PantryIngridient (spelling preserved verbatim).
   */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(
    @Request() req,
    @Body() createPantryIngridientDto: CreatePantryIngridientDto,
  ): Promise<PantryIngridient> {
    const userId = req.user?.id;
    return this.pantryService.create(createPantryIngridientDto, userId);
  }

  /**
   * GET /api/pantry — List the authenticated user's pantry items with
   * pagination, filtering, and sorting.
   *
   * The hard cap of `limit = 50` (after defaulting to 10) is enforced per the
   * Pagination Cap convention documented in ../../../ARCHITECTURE.md.
   * The userId is injected into filterOptions from req.user.id so the listing
   * is always user-scoped.
   *
   * @param req Express request carrying the authenticated user.
   * @param query Pagination/filter/sort query parameters.
   * @returns Page of PantryIngridient (spelling preserved) wrapped via
   *   infinityPagination helper.
   */
  @Get()
  @HttpCode(HttpStatus.OK)
  async findAll(
    @Request() req,
    @Query() query: QueryPantryIngridientDto,
  ): Promise<InfinityPaginationResultType<PantryIngridient>> {
    const userId = req.user?.id;
    const page = query?.page ?? 1;
    let limit = query?.limit ?? 10;
    if (limit > 50) {
      limit = 50;
    }

    return infinityPagination(
      await this.pantryService.findManyWithPagination({
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
   * GET /api/pantry/:id — Fetch a single pantry item by id.
   *
   * @param id PantryIngridient _id (string ObjectId).
   * @returns The PantryIngridient or null if not found.
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
   * PATCH /api/pantry/:id — Partially update a pantry item.
   *
   * Throws HttpException(UNPROCESSABLE_ENTITY) at the service layer when the
   * target id does not exist.
   *
   * @param id PantryIngridient _id to update.
   * @param updateIngridientDto Partial update payload (spelling preserved).
   * @returns The updated PantryIngridient, or null if the update did not match.
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
   * DELETE /api/pantry/:id — "Soft"-delete a pantry item.
   *
   * NOTE: Per README § Known Limitations, the underlying repository
   * implementation currently calls `deleteOne` and PHYSICALLY removes the
   * document despite the method name. The body of softDelete is preserved
   * as-is and flagged with `// FIXME:` and `// TODO(prod):` at
   * `infrastructure/document/repositories/pantryIngridient.repository.ts:L119`.
   * See ../../../ARCHITECTURE.md § Soft-Delete Contract and
   * ../../../PRODUCTION_READINESS.md § Database.
   *
   * @param id PantryIngridient _id to remove.
   * @returns 204 No Content (Promise<void>).
   */
  @Delete(':id')
  @ApiParam({
    name: 'id',
    type: String,
    required: true,
  })
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id') id: PantryIngridient['id']): Promise<void> {
    return this.pantryService.softDelete(id);
  }
}
