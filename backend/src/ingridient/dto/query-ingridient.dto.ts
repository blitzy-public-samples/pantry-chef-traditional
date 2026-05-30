import { ApiProperty } from '@nestjs/swagger';
import {
  IsNumber,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import { Transform, Type, plainToInstance } from 'class-transformer';
import { Ingridient } from '../domain/ingrident';

// NOTE: 'Ingridient' / 'ingridient' spellings preserved verbatim across the backend codebase. Do not rename.

/**
 * Optional filter shape consumed by `QueryIngridientDto.filters`.
 *
 * `query` is a free-text fragment matched case-insensitively against the
 * Ingridient `name` field by `IngridientDocumentRepository.findManyWithPagination`
 * (Source: infrastructure/document/repositories/ingridient.repository.ts:L52-L54).
 *
 * Spelling 'Ingridient' preserved verbatim.
 */
export class FilterIngridientDto {
  @IsOptional()
  query?: string | null;
}

/**
 * Sort directive for ingridient listing queries (spelling preserved verbatim).
 *
 * `orderBy` is constrained at compile time to `keyof Ingridient`; `order`
 * is a free-text 'ASC' or 'DESC' string (case-insensitive at runtime).
 */
export class SortIngridientDto {
  @ApiProperty()
  @IsString()
  orderBy: keyof Ingridient;

  @ApiProperty()
  @IsString()
  order: string;
}

/**
 * Validation contract for `GET /api/v1/ingredient` list/search requests
 * (spelling preserved verbatim).
 *
 * Supports pagination (`page` default 1, `limit` default 10; the
 * controller hard-caps `limit` at 50 — Source:
 * ingridient.controller.ts:L89-L91), an optional free-text `query`
 * string, and JSON-encoded `filters` and `sort` query parameters parsed
 * via `plainToInstance` with nested validation.
 */
export class QueryIngridientDto {
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

  @ApiProperty()
  @IsString()
  @IsOptional()
  query?: string;

  @ApiProperty({ type: String, required: false })
  @IsOptional()
  @Transform(({ value }) =>
    value ? plainToInstance(FilterIngridientDto, JSON.parse(value)) : undefined,
  )
  @ValidateNested()
  @Type(() => FilterIngridientDto)
  filters?: FilterIngridientDto | null;

  @ApiProperty({ type: String, required: false })
  @IsOptional()
  @Transform(({ value }) => {
    return value
      ? plainToInstance(SortIngridientDto, JSON.parse(value))
      : undefined;
  })
  @ValidateNested({ each: true })
  @Type(() => SortIngridientDto)
  sort?: SortIngridientDto[] | null;
}
