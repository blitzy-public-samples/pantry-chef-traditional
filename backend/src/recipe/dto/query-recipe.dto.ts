import { ApiProperty } from '@nestjs/swagger';
import {
  IsArray,
  IsNumber,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import { Transform, Type, plainToInstance } from 'class-transformer';
import { Recipe } from '../domain/recipe';

export class FilterRecipeDto {
  @IsString()
  @IsOptional()
  name?: string | null;
  @IsString()
  @IsOptional()
  ids?: string[] | null;
}

export class SortRecipeDto {
  @ApiProperty()
  @IsString()
  orderBy: keyof Recipe;

  @ApiProperty()
  @IsString()
  order: string;
}

export class QueryRecipeDto {
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

  @IsString()
  @IsOptional()
  query?: string | null;

  @IsArray()
  @IsOptional()
  @IsString({ each: true })
  @Transform(({ value }) => (typeof value === 'string' ? [value] : value))
  ids?: string[] | null;

  @ApiProperty({ type: String, required: false })
  @IsOptional()
  @Transform(({ value }) => {
    return value
      ? plainToInstance(SortRecipeDto, JSON.parse(value))
      : undefined;
  })
  @ValidateNested({ each: true })
  @Type(() => SortRecipeDto)
  sort?: SortRecipeDto[] | null;
}
