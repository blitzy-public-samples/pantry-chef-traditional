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
 * Filter options applied at the persistence layer.
 *
 * `name` becomes a case-insensitive `$regex` query, but the repository writes
 * it to a `name` field that the Recipe schema does NOT define (the schema
 * field is `title`; there is no `name`). The filter is NOT remapped to
 * `title`, so a `name` filter currently matches no documents. `ids` becomes a
 * Mongo `$in` clause against `_id`.
 */
export class FilterRecipeDto {
  // FIXME: repository queries a nonexistent `name` field; schema field is
  // `title`. Filter matches nothing. Document only; do not fix.
  @IsString()
  @IsOptional()
  name?: string | null;
  @IsString()
  @IsOptional()
  ids?: string[] | null;
}

/**
 * A single sort directive for the recipe listing endpoint.
 *
 * `orderBy` is a Recipe field key (the special value `'id'` is mapped to
 * Mongo's `_id` by the repository). `order` is `'ASC'` or `'DESC'`
 * (case-insensitive).
 */
export class SortRecipeDto {
  @ApiProperty()
  @IsString()
  orderBy: keyof Recipe;

  @ApiProperty()
  @IsString()
  order: string;
}

/**
 * Query string contract for GET /api/v1/recipe (the paginated list endpoint).
 *
 * Carries pagination (`page`, `limit`), free-text search (`query` → name regex),
 * id whitelist (`ids`), and optional `sort` directives. The controller enforces
 * a maximum `limit` of 50 — values above are clamped. The `sort` field accepts
 * a JSON-encoded array of `SortRecipeDto` entries, decoded via
 * `class-transformer`'s `plainToInstance`.
 */
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
