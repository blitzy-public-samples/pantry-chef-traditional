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

@ApiBearerAuth()
@UseGuards(AuthGuard('jwt'))
@ApiTags('Pantry')
@Controller({
  path: 'pantry',
  version: '1',
})
export class PantryController {
  constructor(private readonly pantryService: PantryService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(
    @Request() req,
    @Body() createPantryIngridientDto: CreatePantryIngridientDto,
  ): Promise<PantryIngridient> {
    const userId = req.user?.id;
    return this.pantryService.create(createPantryIngridientDto, userId);
  }

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
