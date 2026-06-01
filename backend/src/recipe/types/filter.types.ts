/**
 * Post-filter flags for the matches() flow.
 *
 * - `isQuickMake?: boolean` — recipes with totalIngredients <= 5
 * - `isAlmostThere?: boolean` — recipes with missing-count between 1 and 2
 *
 * Both flags are derived per-recipe inside RecipeRepository.matches()
 * (see infrastructure/document/repositories/recipe.repository.ts:L92-L171).
 */
export type FilterType = {
  isQuickMake?: boolean;
  isAlmostThere?: boolean;
};
