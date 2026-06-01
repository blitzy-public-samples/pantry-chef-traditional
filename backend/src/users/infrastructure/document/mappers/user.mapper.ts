import { User } from '../../../domain/user';
import { UserSchemaClass } from '../entities/user.schema';

/**
 * Stateless, bidirectional converter between the domain `User` model and the
 * persistence `UserSchemaClass` Mongoose document. Centralizes all schema and
 * domain field translation for the users document/infrastructure layer so that
 * repositories do not duplicate mapping rules. Exposes only static methods and
 * holds no state.
 * Source: backend/src/users/infrastructure/document/mappers/user.mapper.ts:L4
 */
export class UserMapper {
  /**
   * Converts a persistence document into the domain `User`.
   *
   * Maps `raw._id.toString()` to `user.id` (L7), copies `email`/`password`
   * (L8-L9), reconstructs the embedded `preferences` object when present and
   * otherwise assigns `undefined` (L11-L18), defaults `recentSearches` and
   * `favoriteRecipes` to `[]` via `|| []` (L20, L22), then copies
   * `createdAt`/`updatedAt`/`deletedAt` (L24-L26).
   *
   * @param raw - The `UserSchemaClass` persistence document to convert.
   * @returns The reconstructed domain `User` model.
   * Source: backend/src/users/infrastructure/document/mappers/user.mapper.ts:L5-L29
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
   * Converts a domain `User` into a `UserSchemaClass` persistence entity.
   *
   * Conditionally assigns `_id` only when `user.id` is a string
   * (`if (user.id && typeof user.id === 'string')`, L33-L35), copies
   * `email`/`password` (L37-L38), reconstructs `preferences` when present and
   * otherwise assigns `undefined` (L40-L47), defaults `recentSearches` and
   * `favoriteRecipes` to `[]` via `|| []` (L49, L51), then copies
   * `createdAt`/`updatedAt`/`deletedAt` (L53-L55).
   *
   * @param user - The domain `User` to convert.
   * @returns The `UserSchemaClass` persistence entity.
   * Source: backend/src/users/infrastructure/document/mappers/user.mapper.ts:L31-L58
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
