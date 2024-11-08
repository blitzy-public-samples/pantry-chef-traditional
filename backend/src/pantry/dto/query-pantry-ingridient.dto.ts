import { ApiProperty } from '@nestjs/swagger';
import {
  IsNumber,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import { Transform, Type, plainToInstance } from 'class-transformer';
import { PantryIngridient } from '../domain/pantryIngridient';

export class FilterPantryIngridientDto {
  @ApiProperty()
  @IsString()
  @IsOptional()
  id?: string;
}

export class SortPantryIngridientDto {
  @ApiProperty()
  @IsString()
  orderBy: keyof PantryIngridient;

  @ApiProperty()
  @IsString()
  order: string;
}

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
