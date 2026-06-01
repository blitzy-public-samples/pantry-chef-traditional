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
 * Application service that enforces user business rules before delegating
 * persistence to the injected abstract {@link UserRepository}.
 *
 * Responsibilities include hashing passwords with bcryptjs, rejecting
 * duplicate email addresses, and validating user existence on update.
 *
 * Source: backend/src/users/users.service.ts:L13
 */
@Injectable()
export class UsersService {
  constructor(private readonly usersRepository: UserRepository) {}

  /**
   * Creates a user, hashing the password with bcryptjs using 10 salt rounds
   * before persistence and rejecting duplicate email addresses.
   *
   * The password is hashed when present.
   * Source: backend/src/users/users.service.ts:L22-L23 (hashing).
   * A duplicate email yields HTTP 422 (emailAlreadyExists).
   * Source: backend/src/users/users.service.ts:L26-L41 (duplicate check).
   *
   * @param createProfileDto - The user creation payload to persist.
   * @returns A promise resolving to the persisted {@link User}.
   * @throws HttpException 422 Unprocessable Entity when the email exists.
   */
  async create(createProfileDto: CreateUserDto): Promise<User> {
    const clonedPayload = {
      ...createProfileDto,
    };

    if (clonedPayload.password) {
      // Hash the password with bcryptjs using 10 salt rounds.
      const salt = await bcrypt.genSalt(10);
      clonedPayload.password = await bcrypt.hash(clonedPayload.password, salt);
    }

    if (clonedPayload.email) {
      // Reject creation when the email is already registered (HTTP 422).
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
   * Returns a paginated list of users, forwarding filter, sort, and
   * pagination options to the repository.
   *
   * @param options - Query options wrapper.
   * @param options.filterOptions - Optional filter criteria.
   * @param options.sortOptions - Optional sort directives.
   * @param options.paginationOptions - Page and limit settings.
   * @returns A promise resolving to the matching {@link User} list.
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
   * Resolves a single user matching the supplied entity condition.
   *
   * @param fields - The entity condition used to locate the user.
   * @returns A promise resolving to the {@link User} or null when absent.
   */
  findOne(fields: EntityCondition<User>): Promise<NullableType<User>> {
    return this.usersRepository.findOne(fields);
  }

  /**
   * Updates a user. When `payload.id` is supplied, validates that the user
   * exists, throwing HTTP 422 (userNotFound) otherwise.
   * Source: backend/src/users/users.service.ts:L72-L88 (existence check).
   *
   * @param id - The identifier of the user to update.
   * @param payload - The partial user fields to apply.
   * @returns A promise resolving to the updated {@link User} or null.
   * @throws HttpException 422 Unprocessable Entity when the user is not found.
   */
  async update(
    id: User['id'],
    payload: DeepPartial<User>,
  ): Promise<User | null> {
    const clonedPayload = { ...payload };

    if (clonedPayload.id) {
      // Confirm the target user exists before applying the update.
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
   * Delegates user deletion to the repository.
   *
   * @param id - The identifier of the user to delete.
   * @returns A promise that resolves once the operation completes.
   */
  async softDelete(id: User['id']): Promise<void> {
    // KNOWN ISSUE: The repository performs a HARD delete (deleteOne) despite
    // the soft-delete naming.
    // Source: backend/src/users/infrastructure/document/repositories/user.repository.ts:L81
    await this.usersRepository.softDelete(id);
  }
}
