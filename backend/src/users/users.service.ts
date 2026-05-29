import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { EntityCondition } from 'src/utils/types/entity-condition.type';
import { IPaginationOptions } from 'src/utils/types/pagination-options';
import { CreateUserDto } from './dto/create-user.dto';
import { NullableType } from '../utils/types/nullable.type';
import { FilterUserDto, SortUserDto } from './dto/query-user.dto';
import { UserRepository } from './infrastructure/user.repository';
import { DeepPartial } from 'src/utils/types/deep-partial.type';
import { User } from './domain/user';
import * as bcrypt from 'bcryptjs';

/**
 * Service orchestrating User CRUD over the abstract {@link UserRepository}.
 *
 * The {@link UsersService.create} method hashes the supplied password
 * with `bcryptjs` (salt rounds = 10) before persistence and rejects
 * duplicate emails with a 422 Unprocessable Entity. The {@link
 * UsersService.update} method does NOT hash the `password` field — the
 * typical password-change flow is initiated by `AuthService.update`,
 * which verifies the old password with `bcrypt.compare` before
 * delegating to this service.
 *
 * Consumed by `AuthModule` (login, register, me) and by
 * `RecipeService.matches` (to fetch the authenticated user's
 * embedded `Preferences` subdocument).
 *
 * @see ../../../ARCHITECTURE.md for the JWT Authentication Flow and
 *   the Recipe Matching Pipeline.
 */
@Injectable()
export class UsersService {
  constructor(private readonly usersRepository: UserRepository) {}

  /**
   * Create a new user record with bcrypt-hashed password and unique-email
   * enforcement.
   *
   * If `password` is supplied it is hashed with `bcrypt.genSalt(10)` +
   * `bcrypt.hash` before persistence. If `email` is supplied, a duplicate
   * lookup is performed first and a 422 Unprocessable Entity exception is
   * thrown when the email already exists.
   *
   * @param createProfileDto Validated {@link CreateUserDto} payload.
   * @returns The persisted {@link User} domain entity.
   * @throws HttpException 422 when the email is already in use.
   */
  async create(createProfileDto: CreateUserDto): Promise<User> {
    const clonedPayload = {
      ...createProfileDto,
    };

    if (clonedPayload.password) {
      const salt = await bcrypt.genSalt(10);
      clonedPayload.password = await bcrypt.hash(clonedPayload.password, salt);
    }

    if (clonedPayload.email) {
      const userObject = await this.usersRepository.findOne({
        email: clonedPayload.email,
      });
      if (userObject) {
        throw new HttpException(
          {
            status: HttpStatus.UNPROCESSABLE_ENTITY,
            errors: {
              email: 'emailAlreadyExists',
            },
          },
          HttpStatus.UNPROCESSABLE_ENTITY,
        );
      }
    }

    return this.usersRepository.create(clonedPayload);
  }

  /**
   * Forward a paginated query to the repository.
   *
   * The current {@link UsersDocumentRepository.findManyWithPagination}
   * implementation accepts `filterOptions` in the signature but does not
   * apply them to the Mongo query — only `sortOptions` and
   * `paginationOptions` are honored at the database layer.
   *
   * @param params.filterOptions Optional {@link FilterUserDto}.
   * @param params.sortOptions Optional array of {@link SortUserDto}.
   * @param params.paginationOptions `{ page, limit }` for `skip`/`limit`.
   * @returns A page of {@link User} entries.
   */
  findManyWithPagination({
    filterOptions,
    sortOptions,
    paginationOptions,
  }: {
    filterOptions?: FilterUserDto | null;
    sortOptions?: SortUserDto[] | null;
    paginationOptions: IPaginationOptions;
  }): Promise<User[]> {
    return this.usersRepository.findManyWithPagination({
      filterOptions,
      sortOptions,
      paginationOptions,
    });
  }

  /**
   * Resolve a single user by an arbitrary field condition.
   *
   * Returns `null` when no document matches. Note: the underlying
   * repository handles `fields.id` specially by calling Mongoose's
   * `findById`; any other field is forwarded as a normal `findOne`
   * query object.
   *
   * @param fields Partial filter shape (`EntityCondition<User>`).
   * @returns The matched {@link User} or `null`.
   */
  findOne(fields: EntityCondition<User>): Promise<NullableType<User>> {
    return this.usersRepository.findOne(fields);
  }

  /**
   * Update an existing user by id with a deep-partial payload.
   *
   * If the payload contains an `id` field it is cross-checked against
   * the path `id` and a 422 Unprocessable Entity is thrown on mismatch.
   * The `password` field, if present, is forwarded VERBATIM to the
   * repository — this method does NOT re-hash passwords. Password
   * changes initiated by clients flow through `AuthService.update`
   * which validates the old password before reaching this method.
   *
   * @param id The user `_id` to update.
   * @param payload `DeepPartial<User>` fields to merge.
   * @returns The updated {@link User} or `null` if not found.
   * @throws HttpException 422 when `payload.id` does not match `id`.
   */
  async update(
    id: User['id'],
    payload: DeepPartial<User>,
  ): Promise<User | null> {
    const clonedPayload = { ...payload };

    if (clonedPayload.id) {
      const userObject = await this.usersRepository.findOne({
        id,
      });

      if (userObject?.id !== id) {
        throw new HttpException(
          {
            status: HttpStatus.UNPROCESSABLE_ENTITY,
            errors: {
              email: 'userNotFound',
            },
          },
          HttpStatus.UNPROCESSABLE_ENTITY,
        );
      }
    }

    return this.usersRepository.update(id, clonedPayload);
  }

  /**
   * "Soft"-delete a user by id.
   *
   * Per README § Known Limitations, the underlying repository
   * implementation ({@link UsersDocumentRepository.softDelete}) currently
   * calls `deleteOne` and physically removes the document from MongoDB,
   * despite the `softDelete` method name. This service method merely
   * forwards the call.
   *
   * @param id The user `_id` to remove.
   * @returns A `Promise<void>` resolving once the repository call
   *   completes.
   */
  async softDelete(id: User['id']): Promise<void> {
    await this.usersRepository.softDelete(id);
  }
}
