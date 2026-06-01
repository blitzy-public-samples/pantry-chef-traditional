import { Injectable } from '@nestjs/common';
import { EntityCondition } from 'src/utils/types/entity-condition.type';
import { IPaginationOptions } from 'src/utils/types/pagination-options';
import { NullableType } from '../../../../utils/types/nullable.type';
import { FilterUserDto, SortUserDto } from '../../../dto/query-user.dto';
import { User } from '../../../domain/user';
import { UserRepository } from '../../user.repository';
import { UserSchemaClass } from '../entities/user.schema';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { UserMapper } from '../mappers/user.mapper';

/**
 * Mongoose-backed (document) implementation of the abstract `UserRepository`
 * persistence contract for the users bounded context.
 *
 * Registered as an `@Injectable()` NestJS provider built around the injected
 * `Model<UserSchemaClass>` obtained via `@InjectModel(UserSchemaClass.name)`.
 * Source: backend/src/users/infrastructure/document/repositories/user.repository.ts:L13-L18
 *
 * Delegates all schema<->domain conversion to `UserMapper`
 * (`toPersistence` / `toDomain`).
 * Source: backend/src/users/infrastructure/document/mappers/user.mapper.ts:L5-L58
 *
 * Fulfills the abstract persistence contract `UserRepository`.
 * Source: backend/src/users/infrastructure/user.repository.ts:L8-L31
 *
 * DI-bound to that abstract token via
 * `{ provide: UserRepository, useClass: UsersDocumentRepository }`.
 * Source: backend/src/users/infrastructure/document/document-persistence.module.ts:L13-L18
 */
@Injectable()
export class UsersDocumentRepository implements UserRepository {
  constructor(
    @InjectModel(UserSchemaClass.name)
    private readonly usersModel: Model<UserSchemaClass>,
  ) {}

  /**
   * Persists a new user: maps the domain `User` to a persistence entity via
   * `UserMapper.toPersistence`, instantiates `this.usersModel`, `save()`s it,
   * and returns the saved document mapped back to domain via
   * `UserMapper.toDomain`.
   *
   * @param data - the domain `User` to persist.
   * @returns Promise<User> the created (persisted) domain user.
   * Source: backend/src/users/infrastructure/document/repositories/user.repository.ts:L20-L25
   */
  async create(data: User): Promise<User> {
    // NOTE: The concrete signature accepts `User`, whereas the abstract
    // contract types the parameter as
    // `Omit<User, 'id' | 'createdAt' | 'deletedAt' | 'updatedAt'>`. The
    // divergence is documented as-is and intentionally not reconciled.
    // Source: backend/src/users/infrastructure/user.repository.ts:L9-L11
    const persistenceModel = UserMapper.toPersistence(data);
    const createdUser = new this.usersModel(persistenceModel);
    const userObject = await createdUser.save();
    return UserMapper.toDomain(userObject);
  }

  /**
   * Returns a paginated list of users.
   *
   * Initializes an always-empty filter (`where = {}`), so `filterOptions` is
   * accepted by the type but NOT applied here (no server-side filtering
   * occurs). Builds the Mongoose sort object from `sortOptions` via `reduce`,
   * mapping `orderBy === 'id'` to `_id` and `order` `ASC` to `1`, otherwise to
   * `-1`. Applies skip/limit pagination, then maps each document to the domain
   * via `UserMapper.toDomain`.
   *
   * @param options - the single destructured query-options argument.
   * @param options.filterOptions - `FilterUserDto | null`; accepted but unused.
   * @param options.sortOptions - `SortUserDto[] | null`; sort directives.
   * @param options.paginationOptions - `IPaginationOptions`; required paging.
   * @returns Promise<User[]> the mapped domain users for the requested page.
   * Source: backend/src/users/infrastructure/document/repositories/user.repository.ts:L27-L53
   * Sort-object reduce mapping orderBy/order to Mongoose sort directions:
   * Source: backend/src/users/infrastructure/document/repositories/user.repository.ts:L40-L47
   * Skip/limit pagination `skip((page - 1) * limit).limit(limit)`:
   * Source: backend/src/users/infrastructure/document/repositories/user.repository.ts:L49-L50
   */
  async findManyWithPagination({
    sortOptions,
    paginationOptions,
  }: {
    filterOptions?: FilterUserDto | null;
    sortOptions?: SortUserDto[] | null;
    paginationOptions: IPaginationOptions;
  }): Promise<User[]> {
    // The filter is intentionally always empty; `filterOptions` from the
    // signature is never applied, so this method returns every user (subject
    // only to sort + pagination).
    // Source: backend/src/users/infrastructure/document/repositories/user.repository.ts:L35
    const where: EntityCondition<User> = {};

    const userObjects = await this.usersModel
      .find(where)
      .sort(
        sortOptions?.reduce(
          (accumulator, sort) => ({
            ...accumulator,
            [sort.orderBy === 'id' ? '_id' : sort.orderBy]:
              sort.order.toUpperCase() === 'ASC' ? 1 : -1,
          }),
          {},
        ),
      )
      .skip((paginationOptions.page - 1) * paginationOptions.limit)
      .limit(paginationOptions.limit);

    return userObjects.map((userObject) => UserMapper.toDomain(userObject));
  }

  /**
   * Resolves a single user. When `fields.id` is present, resolves via
   * `findById(fields.id)`; otherwise resolves via `findOne(fields)`. Returns
   * the mapped domain `User`, or `null` when no document matches.
   *
   * @param fields - the `EntityCondition<User>` lookup criteria.
   * @returns Promise<NullableType<User>> the matching user, or `null`.
   * Source: backend/src/users/infrastructure/document/repositories/user.repository.ts:L55-L63
   */
  async findOne(fields: EntityCondition<User>): Promise<NullableType<User>> {
    if (fields.id) {
      const userObject = await this.usersModel.findById(fields.id);
      return userObject ? UserMapper.toDomain(userObject) : null;
    }

    const userObject = await this.usersModel.findOne(fields);
    return userObject ? UserMapper.toDomain(userObject) : null;
  }

  /**
   * Applies a partial update by id. Clones `payload` into `clonedPayload` and
   * `delete`s its `id` to prevent primary-key mutation, builds the
   * `filter = { _id: id }`, then runs
   * `findOneAndUpdate(filter, clonedPayload, { new: true })`, returning the
   * mapped domain `User`, or `null` when no document matches.
   *
   * @param id - the target user id (`User['id']`).
   * @param payload - the `Partial<User>` of fields to change.
   * @returns Promise<User | null> the updated domain user, or `null`.
   * Source: backend/src/users/infrastructure/document/repositories/user.repository.ts:L65-L78
   */
  async update(id: User['id'], payload: Partial<User>): Promise<User | null> {
    // NOTE: The concrete `payload` type is `Partial<User>` while the abstract
    // contract uses `DeepPartial<User>`. The divergence is documented as-is
    // and intentionally not reconciled.
    // Source: backend/src/users/infrastructure/user.repository.ts:L25-L28
    const clonedPayload: any = { ...payload };
    delete clonedPayload.id;

    const filter = { _id: id };
    // TODO: Remove this stray debug log left in the update path; it prints the
    // update payload contents to stdout on every call.
    // Source: backend/src/users/infrastructure/document/repositories/user.repository.ts:L70
    console.log('clonedPayload-->', clonedPayload);
    const userObject = await this.usersModel.findOneAndUpdate(
      filter,
      clonedPayload,
      { new: true },
    );

    return userObject ? UserMapper.toDomain(userObject) : null;
  }

  /**
   * Removes a user by id.
   *
   * @param id - the target user id (`User['id']`).
   * @returns Promise<void>.
   * Source: backend/src/users/infrastructure/document/repositories/user.repository.ts:L80-L83
   */
  async softDelete(id: User['id']): Promise<void> {
    // KNOWN ISSUE: Despite the method name `softDelete`, this performs a HARD
    // delete via `deleteOne({ _id: id })`; the document is physically removed
    // from MongoDB even though the schema declares a `deletedAt` field meant
    // for soft deletion. Captured verbatim per the additive-only / capture-
    // known-issues rules; the code is intentionally left unchanged.
    // Source: backend/src/users/infrastructure/document/repositories/user.repository.ts:L81
    // Cross-ref, the unused soft-delete field on the schema:
    // Source: backend/src/users/infrastructure/document/entities/user.schema.ts:L67-L68
    await this.usersModel.deleteOne({
      _id: id,
    });
  }
}
