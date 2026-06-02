/**
 * Query shape for the `GET /api/recipe/matches` endpoint, bound via `@Query()`.
 * The two optional boolean flags select which scored recipes the matcher's
 * filter step returns; when neither flag is set, every scored recipe is
 * returned (ranked by descending matchScore).
 * Source: backend/src/recipe/recipe.controller.ts:L85-L90
 * Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L250-L264
 */
export type FilterType = {
  // Return only "quick make" recipes (totalIngredients <= 5).
  // Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L234
  isQuickMake?: boolean;
  // Return only "almost there" recipes (missing only 1-2 ingredients).
  // Source: backend/src/recipe/infrastructure/document/repositories/recipe.repository.ts:L237-L238
  isAlmostThere?: boolean;
};
