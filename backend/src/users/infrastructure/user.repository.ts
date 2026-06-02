import { User } from '../domain/user';
import { NullableType } from 'src/utils/types/nullable.type';
import { FilterUserDto, SortUserDto } from '../dto/query-user.dto';
import { IPaginationOptions } from 'src/utils/types/pagination-options';
import { EntityCondition } from 'src/utils/types/entity-condition.type';
import { DeepPartial } from 'src/utils/types/deep-partial.type';

/**
 * Abstract persistence contract (port) for the users bounded context. It is the
 * compile-time interface that any user-storage adapter must implement, declaring the five
 * repository operations below. It contains no runtime logic, decorators, or direct
 * database access.
 *
 * The concrete document/Mongoose implementation is `UsersDocumentRepository`, bound to this
 * abstract token via `{ provide: UserRepository, useClass: UsersDocumentRepository }`.
 * Source: backend/src/users/infrastructure/document/document-persistence.module.ts:L36-L37.
 *
 * Consumed through dependency injection by `UsersService`.
 * Source: backend/src/users/users.service.ts:L20-L21.
 */
export abstract class UserRepository {
  /**
   * Persists a new user. The input type
   * `Omit<User, 'id' | 'createdAt' | 'deletedAt' | 'updatedAt'>` deliberately excludes the
   * server-managed fields (the id plus the lifecycle timestamps).
   *
   * @param data - The user attributes to persist.
   * @returns A promise resolving to the created domain `User`.
   */
  abstract create(
    data: Omit<User, 'id' | 'createdAt' | 'deletedAt' | 'updatedAt'>,
  ): Promise<User>;

  /**
   * Retrieves a paginated list of users.
   *
   * @param options - The destructured query-options object.
   * @param options.filterOptions - Optional `FilterUserDto | null` filter criteria.
   * @param options.sortOptions - Optional `SortUserDto[] | null` sort directives.
   * @param options.paginationOptions - Required `IPaginationOptions` (page and limit).
   * @returns A promise resolving to the matching `User[]`.
   */
  abstract findManyWithPagination({
    filterOptions,
    sortOptions,
    paginationOptions,
  }: {
    filterOptions?: FilterUserDto | null;
    sortOptions?: SortUserDto[] | null;
    paginationOptions: IPaginationOptions;
  }): Promise<User[]>;

  /**
   * Resolves a single user matching the supplied typed entity condition.
   *
   * @param fields - The `EntityCondition<User>` query criteria.
   * @returns A promise resolving to the matching `User`, or null when none matches.
   */
  abstract findOne(fields: EntityCondition<User>): Promise<NullableType<User>>;

  /**
   * Applies a partial update to the user identified by `id`.
   *
   * Note: this abstract contract types `payload` as `DeepPartial<User>`, whereas the
   * concrete document adapter types it as `Partial<User>`; the divergence is documented
   * as-is and is intentionally not reconciled.
   * Source: backend/src/users/infrastructure/document/repositories/user.repository.ts:L137.
   *
   * @param id - The target user identifier (`User['id']`).
   * @param payload - A `DeepPartial<User>` describing the fields to change.
   * @returns A promise resolving to the updated `User`, or null when not found.
   */
  abstract update(
    id: User['id'],
    payload: DeepPartial<User>,
  ): Promise<User | null>;

  /**
   * Removes the user identified by `id`.
   *
   * @param id - The target user identifier (`User['id']`).
   * @returns A promise that resolves once the removal completes.
   */
  // KNOWN ISSUE: although the contract name implies a soft delete, the concrete document
  // implementation performs a HARD delete via `deleteOne({ _id: id })`, physically
  // removing the document despite the schema's `deletedAt` field. The fix is intentionally
  // not applied.
  // Source: backend/src/users/infrastructure/document/repositories/user.repository.ts:L172-L174.
  abstract softDelete(id: User['id']): Promise<void>;
}
