import { User } from '../../../domain/user';
import { UserSchemaClass } from '../entities/user.schema';

/**
 * Stateless mapper between the Mongoose schema class
 * (`UserSchemaClass`) and the domain entity (`User`).
 *
 * Used by `UsersDocumentRepository` to translate between persistence
 * and domain representations on every read/write. The class is
 * stateless — both methods are static — and preserves the embedded
 * `Preferences` subdocument shape in both directions.
 */
export class UserMapper {
  /**
   * Converts a Mongoose `UserSchemaClass` document into the domain
   * `User` entity.
   *
   * Stringifies `raw._id` via `.toString()` into `user.id`. Defaults
   * `recentSearches` and `favoriteRecipes` to empty arrays when the
   * source document has them as `null` or `undefined`. Preserves the
   * embedded `Preferences` subdocument shape (or sets `undefined`
   * when the source document has no preferences), timestamps, and
   * `deletedAt`.
   *
   * @param raw Mongoose document hydrated from the `users` collection.
   * @returns The corresponding domain `User` entity.
   */
  static toDomain(raw: UserSchemaClass): User {
    const user = new User();
    user.id = raw._id.toString();
    user.email = raw.email;
    user.password = raw.password;

    user.preferences = raw.preferences
      ? {
          dietary: raw.preferences.dietary,
          allergies: raw.preferences.allergies,
          dislikedIngredients: raw.preferences.dislikedIngredients,
          cookingTime: raw.preferences.cookingTime,
        }
      : undefined;

    user.recentSearches = raw.recentSearches || [];

    user.favoriteRecipes = raw.favoriteRecipes || [];

    user.createdAt = raw.createdAt;
    user.updatedAt = raw.updatedAt;
    user.deletedAt = raw.deletedAt;

    return user;
  }

  /**
   * Converts a domain `User` entity into a `UserSchemaClass` instance
   * ready for Mongoose persistence.
   *
   * If `user.id` is a non-empty string, assigns it to `userEntity._id`
   * so the resulting Mongo document is created with the known id
   * (used by `UsersDocumentRepository.create` for upsert-style flows).
   * Defaults `recentSearches` and `favoriteRecipes` to empty arrays.
   * Preserves the embedded `Preferences` subdocument shape (or sets
   * `undefined` when absent), timestamps, and `deletedAt`.
   *
   * @param user Domain entity to persist.
   * @returns A `UserSchemaClass` instance suitable for the Mongoose
   *   `Model<UserSchemaClass>`.
   */
  static toPersistence(user: User): UserSchemaClass {
    const userEntity = new UserSchemaClass();
    if (user.id && typeof user.id === 'string') {
      userEntity._id = user.id;
    }

    userEntity.email = user.email;
    userEntity.password = user.password;

    userEntity.preferences = user.preferences
      ? {
          dietary: user.preferences.dietary,
          allergies: user.preferences.allergies,
          dislikedIngredients: user.preferences.dislikedIngredients,
          cookingTime: user.preferences.cookingTime,
        }
      : undefined;

    userEntity.recentSearches = user.recentSearches || [];

    userEntity.favoriteRecipes = user.favoriteRecipes || [];

    userEntity.createdAt = user.createdAt;
    userEntity.updatedAt = user.updatedAt;
    userEntity.deletedAt = user.deletedAt;

    return userEntity;
  }
}
