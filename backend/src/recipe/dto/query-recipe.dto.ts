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

/**
 * Filter criteria for recipe list/search queries.
 *
 * The repository turns these optional constraints into Mongoose query
 * operators: `name` becomes a `$regex` match and `ids` becomes an `$in` list.
 */
export class FilterRecipeDto {
  // Optional name filter; applied by the repository as a $regex match.
  @IsString()
  @IsOptional()
  name?: string | null;
  // Optional recipe id list; applied by the repository as an $in constraint.
  @IsString()
  @IsOptional()
  ids?: string[] | null;
}

/**
 * Sort specification: which Recipe field to order by and in which direction.
 */
export class SortRecipeDto {
  // Field to sort by; constrained to a key of the Recipe domain model.
  @ApiProperty()
  @IsString()
  orderBy: keyof Recipe;

  // Sort direction string, e.g. 'ASC' or 'DESC'.
  @ApiProperty()
  @IsString()
  order: string;
}

/**
 * Query contract for the paginated recipe list endpoint.
 *
 * Combines pagination (`page`/`limit`), an optional free-text `query`, an
 * optional `ids` list, and a JSON-encoded `sort` parsed into SortRecipeDto[].
 */
export class QueryRecipeDto {
  // Page number; @Transform coerces the query string, defaulting to 1.
  @ApiProperty({
    required: false,
  })
  @Transform(({ value }) => (value ? Number(value) : 1))
  @IsNumber()
  @IsOptional()
  page: number;

  // Page size; @Transform defaults to 10. The controller clamps the effective
  // value to a maximum of 50. Source: backend/src/recipe/recipe.controller.ts:L57-L58
  @ApiProperty({
    required: false,
  })
  @Transform(({ value }) => (value ? Number(value) : 10))
  @IsNumber()
  @IsOptional()
  limit: number;

  // Optional free-text search term (mapped to the name filter by the controller).
  @IsString()
  @IsOptional()
  query?: string | null;

  // Optional recipe id list; a single string value is normalized into an array.
  @IsArray()
  @IsOptional()
  @IsString({ each: true })
  @Transform(({ value }) => (typeof value === 'string' ? [value] : value))
  ids?: string[] | null;

  // Optional sort spec; a JSON string parsed into an array of SortRecipeDto.
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
