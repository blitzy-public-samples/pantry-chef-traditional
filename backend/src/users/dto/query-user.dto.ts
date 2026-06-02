import { ApiProperty } from '@nestjs/swagger';
import {
  IsNumber,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import { Transform, Type, plainToInstance } from 'class-transformer';
import { User } from '../domain/user';

/**
 * Optional role-based filter sub-contract for the user list query.
 *
 * Embedded within `QueryUserDto.filters`; arrives as a JSON query-string
 * value and is hydrated into an instance via `plainToInstance` before
 * nested validation runs.
 */
export class FilterUserDto {
  // Optional list of role objects to filter users by; validated per-item.
  @IsOptional()
  @ValidateNested({ each: true })
  roles?: [] | null;
}

/**
 * Sort instruction sub-contract: a single sort key plus a direction.
 *
 * Embedded within `QueryUserDto.sort`; arrives as a JSON query-string
 * value and is hydrated into an instance via `plainToInstance` before
 * nested validation runs.
 */
export class SortUserDto {
  // Sort key constrained to a property name of the User domain model (keyof User).
  @ApiProperty()
  @IsString()
  orderBy: keyof User;

  // Sort direction string, e.g. 'asc' or 'desc'.
  @ApiProperty()
  @IsString()
  order: string;
}

/**
 * List/query contract for the paginated `GET /api/users` listing.
 *
 * Query-string scalars (`page`, `limit`) are coerced to numbers via
 * `@Transform`, while the nested `filters` and `sort` parameters arrive
 * as JSON strings and are hydrated into DTO instances via
 * `plainToInstance`. The controller additionally clamps `limit` to a
 * maximum of 50.
 * Source: backend/src/users/users.controller.ts:L83-L88
 */
export class QueryUserDto {
  // Page number; coerced from query string, defaults to 1 when absent.
  @ApiProperty({
    required: false,
  })
  @Transform(({ value }) => (value ? Number(value) : 1))
  @IsNumber()
  @IsOptional()
  page: number;

  // Page size; coerced from query string, defaults to 10 (controller clamps to max 50).
  @ApiProperty({
    required: false,
  })
  @Transform(({ value }) => (value ? Number(value) : 10))
  @IsNumber()
  @IsOptional()
  limit: number;

  // Optional filter object parsed from a JSON string into FilterUserDto, then validated.
  @ApiProperty({ type: String, required: false })
  @IsOptional()
  @Transform(({ value }) =>
    value ? plainToInstance(FilterUserDto, JSON.parse(value)) : undefined,
  )
  @ValidateNested()
  @Type(() => FilterUserDto)
  filters?: FilterUserDto | null;

  // Optional sort array parsed from a JSON string into SortUserDto[], then validated.
  @ApiProperty({ type: String, required: false })
  @IsOptional()
  @Transform(({ value }) => {
    return value ? plainToInstance(SortUserDto, JSON.parse(value)) : undefined;
  })
  @ValidateNested({ each: true })
  @Type(() => SortUserDto)
  sort?: SortUserDto[] | null;
}
