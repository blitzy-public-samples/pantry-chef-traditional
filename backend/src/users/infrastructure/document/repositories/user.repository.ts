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
 * Mongoose-backed concrete implementation of the abstract
 * `UserRepository`.
 *
 * Bound to the `UserRepository` token in
 * `../document-persistence.module.ts` via
 * `{ provide: UserRepository, useClass: UsersDocumentRepository }`.
 * The class name preserves the plural `Users` prefix from the source
 * — do not rename per the AAP minimal-change clause.
 *
 * As-is behaviors documented for accuracy (see also
 * `../../../README.md` § Known Limitations):
 *  - `softDelete` calls `this.usersModel.deleteOne(...)` on the Mongo
 *    collection — physically destructive despite the method name. The
 *    same structural issue is flagged with a `// FIXME:` annotation
 *    in
 *    `backend/src/pantry/infrastructure/document/repositories/pantryIngridient.repository.ts`,
 *    but per AAP §0.8.1 the users folder documents the behavior in
 *    PROSE only and does NOT carry inline `// FIXME:` /
 *    `// TODO(prod):` / `// NOTE:` tags.
 *  - `findManyWithPagination` accepts `filterOptions` in its input
 *    shape but never uses it; the Mongo `where` clause is hardcoded
 *    to `{}`.
 *  - `findOne` special-cases the `fields.id` branch via `findById`.
 *  - `update` deletes `payload.id` from a cloned payload before
 *    applying the patch and emits a debug
 *    `console.log('clonedPayload-->', clonedPayload)` statement,
 *    preserved as-is per the minimal-change clause.
 */
@Injectable()
export class UsersDocumentRepository implements UserRepository {
  /**
   * Injects the Mongoose `Model<UserSchemaClass>` resolved by NestJS
   * via the `@InjectModel(UserSchemaClass.name)` provider token. The
   * token is registered by `MongooseModule.forFeature(...)` inside
   * `../document-persistence.module.ts`.
   */
  constructor(
    @InjectModel(UserSchemaClass.name)
    private readonly usersModel: Model<UserSchemaClass>,
  ) {}

  /**
   * Persists a new user document.
   *
   * Translates the domain entity to a `UserSchemaClass` via
   * `UserMapper.toPersistence`, instantiates a Mongoose document,
   * calls `save()`, and translates the returned document back to a
   * domain `User` via `UserMapper.toDomain`. The caller is
   * responsible for ensuring `data.password` is already bcrypt-hashed
   * — `UsersService.create` performs the hash before invoking this
   * method (see `../../../users.service.ts:L21-L24`).
   *
   * @param data Domain `User` to persist (the caller passes a
   *   payload with `id` / `createdAt` / `updatedAt` / `deletedAt`
   *   unset; Mongo assigns these).
   * @returns The persisted `User` with database-assigned id and
   *   timestamps.
   */
  async create(data: User): Promise<User> {
    const persistenceModel = UserMapper.toPersistence(data);
    const createdUser = new this.usersModel(persistenceModel);
    const userObject = await createdUser.save();
    return UserMapper.toDomain(userObject);
  }

  /**
   * Returns a page of users sorted and paginated according to the
   * supplied options.
   *
   * `filterOptions` is silently ignored — although the input shape
   * destructures `filterOptions`, the Mongo `where` clause is
   * hardcoded to `{}`. Limitation documented in
   * `../../../README.md` § Known Limitations.
   *
   * `sortOptions` is reduced into a Mongo sort object: each sort
   * directive's `orderBy === 'id'` branch maps to `_id`, otherwise
   * the property name is used verbatim; `order` is ASC (`1`) or DESC
   * (`-1`). Pagination uses skip/limit derived from
   * `paginationOptions.page` and `paginationOptions.limit`.
   *
   * @param options.filterOptions Currently ignored (see above).
   * @param options.sortOptions Optional array of sort directives.
   * @param options.paginationOptions Required `{ page, limit }`.
   * @returns Page of domain `User` entities.
   */
  async findManyWithPagination({
    sortOptions,
    paginationOptions,
  }: {
    filterOptions?: FilterUserDto | null;
    sortOptions?: SortUserDto[] | null;
    paginationOptions: IPaginationOptions;
  }): Promise<User[]> {
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
   * Returns a single user matching `fields`, or `null`.
   *
   * Special-cases the `fields.id` branch — when an `id` is provided
   * the lookup uses Mongoose's `findById(fields.id)` instead of
   * `findOne(fields)`, so the caller does not have to convert the id
   * to an ObjectId condition explicitly. All other field shapes are
   * forwarded as a normal `findOne(fields)` query.
   *
   * @param fields `EntityCondition<User>` — typically `{ id }` or
   *   `{ email }`.
   * @returns The matching domain `User` or `null` if no document
   *   matched.
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
   * Applies a partial update to a user document.
   *
   * The `payload` is shallow-cloned into `clonedPayload` and the `id`
   * property is then deleted from the clone (preventing accidental
   * `_id` overwrites). The method also emits a debug
   * `console.log('clonedPayload-->', clonedPayload)` statement —
   * preserved as-is per the AAP minimal-change clause. The Mongo
   * update uses `findOneAndUpdate({ _id: id }, clonedPayload,
   * { new: true })`, so the returned document reflects the patched
   * state.
   *
   * This method does NOT bcrypt-hash a `password` field if the
   * payload includes one — password changes are intended to flow
   * through `AuthService.update`, which verifies the old password
   * upstream. See `../../../README.md` § Known Limitations.
   *
   * @param id User id to update (matched against `_id`).
   * @param payload Partial user fields to merge into the document.
   * @returns The updated domain `User`, or `null` when no document
   *   matched.
   */
  async update(id: User['id'], payload: Partial<User>): Promise<User | null> {
    const clonedPayload: any = { ...payload };
    delete clonedPayload.id;

    const filter = { _id: id };
    console.log('clonedPayload-->', clonedPayload);
    const userObject = await this.usersModel.findOneAndUpdate(
      filter,
      clonedPayload,
      { new: true },
    );

    return userObject ? UserMapper.toDomain(userObject) : null;
  }

  /**
   * Removes a user document from MongoDB.
   *
   * **Currently destructive** — despite the method name this
   * implementation calls `this.usersModel.deleteOne({ _id: id })`
   * rather than writing a `deletedAt` timestamp. The same structural
   * issue is flagged with a `// FIXME:` annotation in
   * `backend/src/pantry/infrastructure/document/repositories/pantryIngridient.repository.ts`,
   * but per AAP §0.8.1 the users folder documents this behavior in
   * PROSE only and does NOT carry an inline `// FIXME:` annotation.
   * See `../../../README.md` § Known Limitations and
   * `../../../../../../PRODUCTION_READINESS.md` § Database.
   *
   * @param id User id to remove.
   * @returns `Promise<void>` that resolves once the Mongo
   *   `deleteOne` call completes.
   */
  async softDelete(id: User['id']): Promise<void> {
    await this.usersModel.deleteOne({
      _id: id,
    });
  }
}
