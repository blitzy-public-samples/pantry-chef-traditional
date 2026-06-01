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
 * Controller routing `/api/users/*` requests to {@link UsersService}.
 *
 * All endpoints are protected by `AuthGuard('jwt')` applied at the class
 * level, so `request.user` (populated by `JwtStrategy`) is available in
 * every handler. The `/me` route returns the authenticated user's
 * profile based on `request.user?.id`; the other routes accept the
 * payload from the body or path.
 *
 * @see UsersService for business orchestration.
 * @see ../../../ARCHITECTURE.md for the JWT Authentication Flow.
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
   * `POST /api/users` — Create a new user record.
   *
   * Delegates to {@link UsersService.create}, which hashes the password
   * via bcryptjs before persisting and rejects duplicate emails with a
   * 422 Unprocessable Entity response.
   *
   * @param createProfileDto Validated {@link CreateUserDto} payload from
   *   the request body (email, password, preferences, etc.).
   * @returns The newly created {@link User} domain entity.
   */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(@Body() createProfileDto: CreateUserDto): Promise<User> {
    return this.usersService.create(createProfileDto);
  }

  /**
   * `GET /api/users` — Paginated list of users.
   *
   * Page and limit default to `1` and `10` respectively when omitted.
   * `limit` is capped at `50` per the project's pagination convention.
   * Returns the project's `InfinityPaginationResultType` shape
   * (`{ data, hasNextPage }`) produced by {@link infinityPagination}.
   *
   * @param query Optional {@link QueryUserDto} with `page`, `limit`,
   *   `filters`, and `sort`.
   * @returns Paginated wrapper of {@link User} entries.
   */
  @Get()
  @HttpCode(HttpStatus.OK)
  async findAll(
    @Query() query: QueryUserDto,
  ): Promise<InfinityPaginationResultType<User>> {
    const page = query?.page ?? 1;
    let limit = query?.limit ?? 10;
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
   * `GET /api/users/me` — Fetch the authenticated user's profile.
   *
   * Reads `request.user.id` populated by `JwtStrategy` and delegates to
   * {@link UsersService.findOne}. Returns `null` if the user no longer
   * exists.
   *
   * @param req Express request with `user` injected by `AuthGuard('jwt')`.
   * @returns The current {@link User} or `null`.
   */
  @Get('me')
  @HttpCode(HttpStatus.OK)
  findMe(@Request() req): Promise<NullableType<User>> {
    const id = req.user?.id;
    return this.usersService.findOne({ id });
  }

  /**
   * `PATCH /api/users` — Partially update the authenticated user.
   *
   * Uses `request.user.id` as the target id; the body is an
   * {@link UpdateUserDto} (a `PartialType(CreateUserDto)`). Note that
   * {@link UsersService.update} does NOT re-hash a `password` field if
   * one is supplied — the typical password-change flow goes through
   * `AuthService.update` instead.
   *
   * @param req Express request with `user` injected by `AuthGuard('jwt')`.
   * @param updateProfileDto Validated {@link UpdateUserDto} payload.
   * @returns The updated {@link User} or `null` if not found.
   */
  @Patch()
  @HttpCode(HttpStatus.OK)
  update(
    @Request() req,
    @Body() updateProfileDto: UpdateUserDto,
  ): Promise<User | null> {
    const id = req.user?.id;
    return this.usersService.update(id, updateProfileDto);
  }

  /**
   * `DELETE /api/users/:id` — "Soft"-delete a user by id.
   *
   * Per README § Known Limitations, the underlying repository
   * implementation ({@link UsersDocumentRepository.softDelete}) currently
   * calls `deleteOne` and physically removes the document from MongoDB,
   * despite the `softDelete` method name. Responds with `204 No Content`.
   *
   * @param id The user `_id` to remove (URL path parameter).
   * @returns A `Promise<void>` resolving once the document is removed.
   */
  @Delete(':id')
  @ApiParam({
    name: 'id',
    type: String,
    required: true,
  })
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id') id: User['id']): Promise<void> {
    return this.usersService.softDelete(id);
  }
}
