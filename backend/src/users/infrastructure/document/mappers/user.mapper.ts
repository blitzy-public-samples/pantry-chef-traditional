import { User } from '../../../domain/user';
import { UserSchemaClass } from '../entities/user.schema';

export class UserMapper {
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
