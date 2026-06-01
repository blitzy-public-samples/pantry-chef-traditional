import { ApiProperty } from '@nestjs/swagger';
import {
  IsNumber,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import { Transform, Type, plainToInstance } from 'class-transformer';
import { Ingridient } from '../domain/ingrident';

/**
 * Filter DTO for ingredient listing queries.
 *
 * Holds the optional free-text query used to filter ingredient results.
 */
export class FilterIngridientDto {
  // Optional free-text search term used to filter ingredients.
  @IsOptional()
  query?: string | null;
}

/**
 * Sort directive DTO for ingredient listing queries.
 *
 * Pairs a sortable Ingridient field name with a sort direction.
 */
export class SortIngridientDto {
  // Name of the Ingridient field to sort by (keyof Ingridient).
  @ApiProperty()
  @IsString()
  orderBy: keyof Ingridient;

  // Sort direction string (e.g. 'asc' or 'desc').
  @ApiProperty()
  @IsString()
  order: string;
}

/**
 * Query container DTO for ingredient listing endpoints.
 *
 * Combines pagination (page, limit), free-text query, JSON-encoded filters,
 * and JSON-encoded sort directives into a single validated query contract.
 */
export class QueryIngridientDto {
  // Page number; @Transform defaults it to 1 when the query param is absent.
  @ApiProperty({
    required: false,
  })
  @Transform(({ value }) => (value ? Number(value) : 1))
  @IsNumber()
  @IsOptional()
  page: number;

  // Page size; @Transform defaults it to 10 when the query param is absent.
  @ApiProperty({
    required: false,
  })
  @Transform(({ value }) => (value ? Number(value) : 10))
  @IsNumber()
  @IsOptional()
  limit: number;

  // Optional free-text search term.
  @ApiProperty()
  @IsString()
  @IsOptional()
  query?: string;

  // Optional filter object accepted as a JSON string.
  // Parsed via plainToInstance(FilterIngridientDto, JSON.parse(value)).
  @ApiProperty({ type: String, required: false })
  @IsOptional()
  @Transform(({ value }) =>
    value ? plainToInstance(FilterIngridientDto, JSON.parse(value)) : undefined,
  )
  @ValidateNested()
  @Type(() => FilterIngridientDto)
  filters?: FilterIngridientDto | null;

  // Optional sort directives accepted as a JSON string.
  // Parsed into SortIngridientDto[] via plainToInstance(JSON.parse(value)).
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
