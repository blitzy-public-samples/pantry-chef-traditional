import { User } from '../domain/user';
import { NullableType } from 'src/utils/types/nullable.type';
import { FilterUserDto, SortUserDto } from '../dto/query-user.dto';
import { IPaginationOptions } from 'src/utils/types/pagination-options';
import { EntityCondition } from 'src/utils/types/entity-condition.type';
import { DeepPartial } from 'src/utils/types/deep-partial.type';

/**
 * Abstract repository contract for the User aggregate.
 *
 * The concrete Mongoose-backed implementation lives in
 * `document/repositories/user.repository.ts` as `UsersDocumentRepository`
 * (note the plural `Users` prefix is preserved verbatim in the
 * implementation class name). The provider binding is established in
 * `document/document-persistence.module.ts` via
 * `{ provide: UserRepository, useClass: UsersDocumentRepository }`.
 *
 * The contract is consumed directly by `UsersService` (the only direct
 * consumer in this module) and indirectly by `AuthService` and
 * `RecipeService.matches` through the `UsersService` re-export from
 * `UsersModule`.
 *
 * Limitations of the concrete implementation are documented in prose on
 * the affected method JSDocs below; the canonical inventory lives in
 * `../README.md` § Known Limitations. The single most important
 * limitation: `softDelete` is currently physically destructive (the
 * implementation calls `deleteOne`).
 */
export abstract class UserRepository {
  /**
   * Persists a new `User` document.
   *
   * The caller is responsible for ensuring `data.password` is already
   * bcrypt-hashed. `UsersService.create` performs the bcrypt salt and
   * hash (`backend/src/users/users.service.ts:L21-L24`) before invoking
   * this method, so the abstract contract treats `password` as opaque.
   *
   * @param data Domain `User` with `id`, `createdAt`, `updatedAt`, and
   *   `deletedAt` omitted (these are assigned by the persistence layer).
   * @returns The persisted `User` including the assigned `id` and
   *   timestamps.
   */
  abstract create(
    data: Omit<User, 'id' | 'createdAt' | 'deletedAt' | 'updatedAt'>,
  ): Promise<User>;

  /**
   * Returns a page of users.
   *
   * The concrete `UsersDocumentRepository.findManyWithPagination`
   * implementation accepts `filterOptions` in the input shape but does
   * NOT apply it to the Mongo query — the `where` clause is hardcoded to
   * `{}`. Sort is applied via `sortOptions` (with the `id` alias mapped
   * to `_id`), and pagination uses skip/limit derived from
   * `paginationOptions.page` and `paginationOptions.limit`.
   *
   * @param options.filterOptions Currently ignored by the concrete impl.
   * @param options.sortOptions Optional array of sort directives.
   * @param options.paginationOptions Required `{ page, limit }`.
   * @returns Page of domain `User` entities.
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
   * Returns a single user matching `fields`, or `null` if no document
   * exists.
   *
   * The concrete implementation special-cases the `fields.id` branch:
   * when an `id` is provided the lookup uses Mongoose's `findById`,
   * otherwise the entire `fields` object is forwarded to `findOne`.
   *
   * @param fields `EntityCondition<User>` — typically `{ id }` or
   *   `{ email }`.
   * @returns The matched `User` or `null`.
   */
  abstract findOne(fields: EntityCondition<User>): Promise<NullableType<User>>;

  /**
   * Applies a partial update to an existing user document.
   *
   * The concrete implementation clones the payload and deletes the `id`
   * property before forwarding to Mongo, so the caller cannot
   * accidentally overwrite `_id`. The implementation does NOT re-hash a
   * `password` field if one is present — password changes are intended
   * to flow through `AuthService.update`, which verifies the old
   * password upstream.
   *
   * @param id User id to update (matched against `_id`).
   * @param payload Partial user fields to merge into the document.
   * @returns The updated `User` or `null` when no document matched.
   */
  abstract update(
    id: User['id'],
    payload: DeepPartial<User>,
  ): Promise<User | null>;

  /**
   * Removes a user by id.
   *
   * The concrete `UsersDocumentRepository.softDelete` implementation is
   * physically destructive: it calls `this.usersModel.deleteOne(...)`
   * rather than writing a `deletedAt` timestamp, despite the method
   * name. The same structural issue is flagged with a `// FIXME:`
   * annotation in
   * `backend/src/pantry/infrastructure/document/repositories/pantryIngridient.repository.ts`;
   * the users folder is intentionally NOT in `// FIXME:` scope per the
   * AAP, so this behavior is documented in prose only. See
   * `../README.md` § Known Limitations and
   * `../../../../PRODUCTION_READINESS.md` § Database.
   *
   * @param id User id to remove.
   * @returns `Promise<void>` that resolves once the Mongo call completes.
   */
  abstract softDelete(id: User['id']): Promise<void>;
}
