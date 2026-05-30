// NOTE: 'PantryIngridient' / 'pantry-ingridient' spellings preserved verbatim. Do not rename.
import { ApiProperty } from '@nestjs/swagger';
import {
  IsNumber,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import { Transform, Type, plainToInstance } from 'class-transformer';
import { PantryIngridient } from '../domain/pantryIngridient';

/**
 * Filter contract for GET /api/v1/pantry list queries (spelling preserved
 * verbatim).
 *
 * Declares an optional `id` field, but the repository's
 * `findManyWithPagination` applies ONLY user scoping: it reads
 * `filterOptions.userId` (injected by the controller from `req.user.id`) and
 * does NOT apply `id`. The `id` field below is accepted on the request but is
 * ignored by the query, so list results are scoped solely by `userId`.
 */
export class FilterPantryIngridientDto {
  // FIXME: `id` is accepted here but ignored by the repository query
  // (findManyWithPagination applies only userId). Document only; do not fix.
  @ApiProperty()
  @IsString()
  @IsOptional()
  id?: string;
}

/**
 * Sort directive for GET /api/v1/pantry list queries (spelling preserved
 * verbatim).
 *
 * `orderBy` is one of the keys of PantryIngridient; `order` is 'ASC' or
 * 'DESC' (case-insensitive). The repository maps 'id' to '_id' and converts
 * the case-insensitive order to Mongoose's 1/-1 representation.
 */
export class SortPantryIngridientDto {
  @ApiProperty()
  @IsString()
  orderBy: keyof PantryIngridient;

  @ApiProperty()
  @IsString()
  order: string;
}

/**
 * Top-level query contract for GET /api/v1/pantry (spelling preserved
 * verbatim).
 *
 * Combines pagination (`page`, `limit`), `filters` (FilterPantryIngridientDto
 * passed as a JSON-encoded string), and `sort` (SortPantryIngridientDto[]
 * passed as a JSON-encoded string). The controller enforces a hard cap of
 * `limit = 50` per the pagination convention in
 * ../../../../ARCHITECTURE.md § Pagination Cap.
 */
export class QueryPantryIngridientDto {
  @ApiProperty({
    required: false,
  })
  @Transform(({ value }) => (value ? Number(value) : 1))
  @IsNumber()
  @IsOptional()
  page: number;

  @ApiProperty({
    required: false,
  })
  @Transform(({ value }) => (value ? Number(value) : 10))
  @IsNumber()
  @IsOptional()
  limit: number;

  @ApiProperty({ type: String, required: false })
  @IsOptional()
  @Transform(({ value }) =>
    value
      ? plainToInstance(FilterPantryIngridientDto, JSON.parse(value))
      : undefined,
  )
  @ValidateNested()
  @Type(() => FilterPantryIngridientDto)
  filters?: FilterPantryIngridientDto | null;

  @ApiProperty({ type: String, required: false })
  @IsOptional()
  @Transform(({ value }) => {
    return value
      ? plainToInstance(SortPantryIngridientDto, JSON.parse(value))
      : undefined;
  })
  @ValidateNested({ each: true })
  @Type(() => SortPantryIngridientDto)
  sort?: SortPantryIngridientDto[] | null;
}
