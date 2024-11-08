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

@ApiBearerAuth()
@UseGuards(AuthGuard('jwt'))
@ApiTags('Ingredient')
@Controller({
  path: 'ingredient',
  version: '1',
})
export class IngridientController {
  constructor(private readonly ingridientService: IngridientService) {}

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

  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(
    @Body() createIngridientDto: CreateIngridientDto,
  ): Promise<Ingridient> {
    return this.ingridientService.create(createIngridientDto);
  }

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
