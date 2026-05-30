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
 * Optional filter object passed to `UserRepository.findManyWithPagination`.
 *
 * The concrete `UsersDocumentRepository.findManyWithPagination` silently ignores
 * `filterOptions`: the parameter is declared in the abstract repository signature
 * (`../infrastructure/user.repository.ts` lines 13-21) but the concrete
 * implementation at `../infrastructure/document/repositories/user.repository.ts`
 * lines 27-35 destructures only `sortOptions` and `paginationOptions`, and the
 * resulting `where` clause is hardcoded to `{}`. As a result this DTO is
 * effectively unused at the persistence layer. Limitation documented in
 * `../README.md` § Known Limitations.
 *
 * The `roles?: [] | null` field is a placeholder; no current code path consumes it.
 */
export class FilterUserDto {
  @IsOptional()
  @ValidateNested({ each: true })
  roles?: [] | null;
}

/**
 * Sort directive for `GET /api/v1/users`.
 *
 * `orderBy` is compile-time constrained to `keyof User` (see `../domain/user.ts`).
 * Consumed by `UsersDocumentRepository.findManyWithPagination` at
 * `../infrastructure/document/repositories/user.repository.ts` lines 39-48: the
 * `orderBy === 'id'` branch maps to MongoDB's internal `_id`; all other field
 * names pass through unchanged. `order` is uppercased and compared to `'ASC'` —
 * exactly that uppercase literal yields `1` (ascending); any other value
 * (including `'asc'`, `'DESC'`, empty string, or garbage) yields `-1`
 * (descending).
 */
export class SortUserDto {
  @ApiProperty()
  @IsString()
  orderBy: keyof User;

  @ApiProperty()
  @IsString()
  order: string;
}

/**
 * Query string parser for `GET /api/v1/users`.
 *
 * `page` defaults to `1` and `limit` defaults to `10` via `@Transform` lambdas.
 * `UsersController.findAll` (`../users.controller.ts` lines 47-51) additionally
 * caps `limit` at `50` before calling `UsersService.findManyWithPagination`.
 * `filters` and `sort` arrive as JSON-encoded strings on the wire and are parsed
 * via `plainToInstance` into `FilterUserDto` and `SortUserDto[]` instances
 * respectively; the resulting nested objects are then validated by the global
 * `ValidationPipe` (registered in `../../main.ts` line 21).
 *
 * The controller wraps the final response with `infinityPagination` (see
 * `../../utils/infinity-pagination.ts`) which returns `{ data, hasNextPage }`
 * where `hasNextPage = data.length === limit` (no separate count query is
 * performed).
 */
export class QueryUserDto {
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
    value ? plainToInstance(FilterUserDto, JSON.parse(value)) : undefined,
  )
  @ValidateNested()
  @Type(() => FilterUserDto)
  filters?: FilterUserDto | null;

  @ApiProperty({ type: String, required: false })
  @IsOptional()
  @Transform(({ value }) => {
    return value ? plainToInstance(SortUserDto, JSON.parse(value)) : undefined;
  })
  @ValidateNested({ each: true })
  @Type(() => SortUserDto)
  sort?: SortUserDto[] | null;
}
