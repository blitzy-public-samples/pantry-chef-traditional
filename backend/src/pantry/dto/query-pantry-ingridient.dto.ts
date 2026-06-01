import { ApiProperty } from '@nestjs/swagger';
import {
  IsNumber,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import { Transform, Type, plainToInstance } from 'class-transformer';
import { PantryIngridient } from '../domain/pantryIngridient';

/** Optional filter criteria for listing pantry ingredients. */
export class FilterPantryIngridientDto {
  // Optional pantry-record id to filter the list by.
  @ApiProperty()
  @IsString()
  @IsOptional()
  id?: string;
}

/** Sort directive (field + order) for listing pantry ingredients. */
export class SortPantryIngridientDto {
  // Field to sort by; a key of PantryIngridient (e.g., createdAt, quantity).
  @ApiProperty()
  @IsString()
  orderBy: keyof PantryIngridient;

  // Sort direction string (e.g., asc / desc).
  @ApiProperty()
  @IsString()
  order: string;
}

/** Query params for the paginated pantry list endpoint. */
export class QueryPantryIngridientDto {
  // Page number; @Transform coerces to Number and defaults to 1 when absent.
  @ApiProperty({
    required: false,
  })
  @Transform(({ value }) => (value ? Number(value) : 1))
  @IsNumber()
  @IsOptional()
  page: number;

  // Page size; @Transform coerces to Number and defaults to 10 when absent.
  @ApiProperty({
    required: false,
  })
  @Transform(({ value }) => (value ? Number(value) : 10))
  @IsNumber()
  @IsOptional()
  limit: number;

  // Optional filter; JSON string parsed into FilterPantryIngridientDto via plainToInstance.
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

  // Optional sort list; JSON string parsed into SortPantryIngridientDto[] via plainToInstance.
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
