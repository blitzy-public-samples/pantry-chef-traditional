/**
 * Domain entity for a PantryChef user.
 *
 * Returned by `UsersService` and consumed by `AuthService` (email login, register, me,
 * refresh, logout, update, and delete flows) and by `RecipeService.matches`, which reads
 * `preferences` to drive the pre-filter chain of the recipe matching pipeline. The
 * embedded `preferences` shape mirrors the Mongoose `Preferences` subdocument declared in
 * `../infrastructure/document/entities/user.schema.ts` (`dietary`, `allergies`,
 * `dislikedIngredients`, `cookingTime`).
 *
 * `password` is optional because the Mongoose schema applies
 * `@Exclude({ toPlainOnly: true })` on the password field. NOTE: that decorator is
 * DECLARED but NOT enforced at runtime — no `ClassSerializerInterceptor` is registered
 * (neither `useGlobalInterceptors` in `main.ts` nor an `APP_INTERCEPTOR` provider in
 * `app.module.ts`), so class-transformer never strips it. The bcrypt password hash is
 * therefore returned in JSON responses today (e.g. `GET /api/auth/me`, `GET /api/users/me`).
 * See `../../../../PRODUCTION_READINESS.md` § Security Hardening. The field IS populated
 * when the document is hydrated from MongoDB (for example, during the `bcrypt.compare`
 * step in `AuthService.validateLogin`).
 *
 * `id` is typed `number | string` for compatibility, but in practice
 * `UsersDocumentRepository` (via `UserMapper.toDomain`) always produces a string via
 * `raw._id.toString()`.
 *
 * `favoriteRecipes` and `recentSearches` are unbounded arrays — see `../README.md`
 * § Known Limitations for the data-growth caveat. The `deletedAt` field is the
 * soft-delete slot, though `UsersDocumentRepository.softDelete` currently calls
 * `deleteOne` (also documented in `../README.md` § Known Limitations).
 *
 * See `../../../../DATA_MODEL.md` § User for the canonical schema reference.
 */
export class User {
  id: number | string;
  email: string | null;
  password?: string;
  preferences?: {
    dietary?: string[];
    allergies?: string[];
    dislikedIngredients?: string[];
    cookingTime?: number;
  };
  favoriteRecipes?: string[];
  recentSearches?: string[];
  createdAt?: Date;
  updatedAt?: Date;
  deletedAt?: Date;
}
