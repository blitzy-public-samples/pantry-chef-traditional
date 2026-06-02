import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Query,
  HttpStatus,
  HttpCode,
  Request,
} from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { ApiBearerAuth, ApiParam, ApiTags } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { infinityPagination } from 'src/utils/infinity-pagination';
import { InfinityPaginationResultType } from '../utils/types/infinity-pagination-result.type';
import { NullableType } from '../utils/types/nullable.type';
import { QueryUserDto } from './dto/query-user.dto';
import { User } from './domain/user';
import { UsersService } from './users.service';

/**
 * Route-facing controller for the `users` resource and the HTTP entry point
 * for user management. Delegates all business logic to {@link UsersService}.
 *
 * Routes are served under the global `api` prefix as `/api/users`. Although
 * this controller declares `version: '1'`, `main.ts` never calls
 * `app.enableVersioning()`, so NO `/v1/` segment is added to any path.
 * Source: backend/src/main.ts:L30-L35
 *
 * The whole controller is JWT-guarded at the class level via
 * `@UseGuards(AuthGuard('jwt'))` and documented for bearer auth with
 * `@ApiBearerAuth()` under the `Users` Swagger tag.
 */
@ApiBearerAuth()
@UseGuards(AuthGuard('jwt'))
@ApiTags('Users')
@Controller({
  path: 'users',
  version: '1',
})
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  /**
   * Creates a user from the supplied {@link CreateUserDto}.
   *
   * Route: `POST /api/users` -> `201 Created`. Delegates to
   * `usersService.create`, which hashes the password and enforces email
   * uniqueness before the user is persisted.
   *
   * @param createProfileDto - Attributes for the new user (email, password,
   *   preferences, favorites, recent searches).
   * @returns A `Promise<User>` resolving to the newly created user.
   */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(@Body() createProfileDto: CreateUserDto): Promise<User> {
    return this.usersService.create(createProfileDto);
  }

  /**
   * Lists users with pagination, wrapping the service result in the project's
   * infinite-pagination envelope via `infinityPagination`.
   *
   * Route: `GET /api/users` -> `200 OK`. Applies pagination defaults of
   * `page = 1` and `limit = 10`, and clamps the page size to a maximum of 50
   * items (`if (limit > 50) limit = 50;`).
   *
   * @param query - Pagination, filtering, and sorting options.
   * @returns A `Promise<InfinityPaginationResultType<User>>` page of users.
   */
  @Get()
  @HttpCode(HttpStatus.OK)
  async findAll(
    @Query() query: QueryUserDto,
  ): Promise<InfinityPaginationResultType<User>> {
    // Apply pagination defaults (page 1, limit 10).
    const page = query?.page ?? 1;
    let limit = query?.limit ?? 10;
    // KNOWN cap: clamp the page size to a maximum of 50 items.
    if (limit > 50) {
      limit = 50;
    }

    return infinityPagination(
      await this.usersService.findManyWithPagination({
        filterOptions: query?.filters,
        sortOptions: query?.sort,
        paginationOptions: {
          page,
          limit,
        },
      }),
      { page, limit },
    );
  }

  /**
   * Returns the currently authenticated user.
   *
   * Route: `GET /api/users/me` -> `200 OK`. Resolves the user id from the
   * JWT-authenticated request (`req.user?.id`) and looks the user up.
   *
   * @param req - The HTTP request carrying the authenticated `user` payload.
   * @returns A `Promise<NullableType<User>>`; `null` when no user matches.
   */
  @Get('me')
  @HttpCode(HttpStatus.OK)
  findMe(@Request() req): Promise<NullableType<User>> {
    // Resolve the user id from the JWT-authenticated request (req.user).
    const id = req.user?.id;
    return this.usersService.findOne({ id });
  }

  /**
   * Updates the currently authenticated user.
   *
   * Route: `PATCH /api/users` -> `200 OK`. Resolves the user id from the
   * JWT-authenticated request (`req.user?.id`) and applies the changes in
   * {@link UpdateUserDto}.
   *
   * @param req - The HTTP request carrying the authenticated `user` payload.
   * @param updateProfileDto - Partial set of user fields to update.
   * @returns A `Promise<User | null>`; `null` when the user is not found.
   */
  @Patch()
  @HttpCode(HttpStatus.OK)
  update(
    @Request() req,
    @Body() updateProfileDto: UpdateUserDto,
  ): Promise<User | null> {
    // Resolve the user id from the JWT-authenticated request (req.user).
    const id = req.user?.id;
    return this.usersService.update(id, updateProfileDto);
  }

  /**
   * Removes a user by id.
   *
   * Route: `DELETE /api/users/:id` -> `204 No Content`. Delegates to
   * `usersService.softDelete`.
   *
   * @param id - Identifier of the user to remove.
   * @returns A `Promise<void>` that resolves once the deletion completes.
   */
  @Delete(':id')
  @ApiParam({
    name: 'id',
    type: String,
    required: true,
  })
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id') id: User['id']): Promise<void> {
    // KNOWN ISSUE: despite the `softDelete` name, the underlying document
    // repository performs a HARD delete via `deleteOne`, permanently removing
    // the record (no `deletedAt` tombstone is written).
    // Source: backend/src/users/infrastructure/document/repositories/user.repository.ts:L172-L174
    return this.usersService.softDelete(id);
  }
}
