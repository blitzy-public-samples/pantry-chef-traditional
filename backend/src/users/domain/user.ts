/**
 * Framework-agnostic domain model for a user account.
 *
 * Canonical cross-layer type contract shared by the controller, service,
 * repository, mapper, and DTOs. Mirrors the persisted `UserSchemaClass`
 * (../infrastructure/document/entities/user.schema.ts) and is produced by
 * `UserMapper.toDomain`.
 *
 */
export class User {
  // Unique identifier (string ObjectId at runtime from Mongo `_id`).
  id: number | string;
  // Account email; unique in persistence.
  email: string | null;
  // Hashed password; excluded from serialized output by the schema.
  password?: string;
  // Embedded dietary preferences.
  preferences?: {
    // Dietary tags the user follows.
    dietary?: string[];
    // Allergens the user must avoid.
    allergies?: string[];
    // Ingredients the user prefers to exclude.
    dislikedIngredients?: string[];
    // Preferred cooking time.
    cookingTime?: number;
  };
  // Saved recipe ids.
  favoriteRecipes?: string[];
  // Recent search terms.
  recentSearches?: string[];
  // Creation timestamp (Mongoose timestamps).
  createdAt?: Date;
  // Last-update timestamp (Mongoose timestamps).
  updatedAt?: Date;
  // Soft-delete timestamp.
  // KNOWN ISSUE: declared, but the user repository hard-deletes (deleteOne);
  // see the users module README (Known limitations) and docs/DATA_MODELS.md.
  deletedAt?: Date;
}
