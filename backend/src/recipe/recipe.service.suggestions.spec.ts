import { Test, TestingModule } from '@nestjs/testing';
import { RecipeService } from './recipe.service';
import { RecipeRepository } from './infrastructure/recipe.repository';
import { PantryService } from '../pantry/pantry.service';
import { UsersService } from '../users/users.service';
import { Recipe } from './domain/recipe';
import { Ingridient } from '../ingridient/domain/ingrident';
import { PantryIngridient } from '../pantry/domain/pantryIngridient';
import { FilterType } from './types/filter.types';

/**
 * Unit spec for RecipeService.getSuggestions() — the "What Can I Make Tonight?"
 * post-processing layer. The matching pipeline (recipeRepository.matches) is
 * fully mocked to return a pre-sorted Recipe[] (matchScore DESC), so these
 * tests isolate getSuggestions()'s own behavior: DESC matchScore ordering (the
 * service re-sorts the mapped list by the NORMALIZED matchScore so a
 * zero-ingredient recipe — normalized from NaN to 1.0 — is ranked among the top
 * rather than stranded in the frozen pipeline's DB-scan position; see CP-1
 * Issue #1), the three derived fields (status / isQuickMake / missingIngredients
 * computed from the domain `ingridient.id` and `.name`), and the
 * { data, hasMore } pagination envelope (default page=1/limit=10, limit capped
 * at 50).
 *
 * Spelling note: the backend deliberately uses the (sic) `ingridient`,
 * `ingridientList`, and `PantryIngridient` spellings; the fixtures below
 * preserve them verbatim rather than "correcting" them.
 */

// ---------------------------------------------------------------------------
// Fixture builders. Each returns a minimal domain object cast to its domain
// type — getSuggestions() only reads `id`, `name`, `ingridientList`, and
// `matchScore`, so the fixtures provide just enough to type-check and exercise
// every derivation while staying concise.
// ---------------------------------------------------------------------------

const makeIngridient = (id: string, name: string): Ingridient =>
  ({
    id,
    name,
    confidence: 1,
    createdAt: new Date(),
    updatedAt: new Date(),
  }) as Ingridient;

const makeRecipe = (
  id: string,
  ingridientIds: Array<[string, string]>,
  matchScore: number,
): Recipe =>
  ({
    id,
    title: `Recipe ${id}`,
    description: 'A test recipe',
    ingridientList: ingridientIds.map(([ingridientId, ingridientName]) => ({
      ingridient: makeIngridient(ingridientId, ingridientName),
      amount: 1,
      unit: 'pcs',
      required: true,
    })),
    instructions: [],
    prepTime: 5,
    cookTime: 10,
    servings: 1,
    difficulty: 'easy',
    tags: [],
    matchScore,
  }) as Recipe;

const makePantry = (ids: Array<[string, string]>): PantryIngridient[] =>
  ids.map(
    ([ingridientId, ingridientName], index) =>
      ({
        id: `p${index}`,
        ingridient: makeIngridient(ingridientId, ingridientName),
        userId: 'u1',
        quantity: 1,
        unit: 'pcs',
        location: 'pantry',
        createdAt: new Date(),
        updatedAt: new Date(),
      }) as PantryIngridient,
  );

// ---------------------------------------------------------------------------
// Hand-written jest.fn() mocks for the three collaborators (no mocking library
// is declared in package.json). Only the methods getSuggestions() touches are
// stubbed. The RecipeRepository provider token is the ABSTRACT class.
// ---------------------------------------------------------------------------

const recipeRepositoryMock = { matches: jest.fn() };
const pantryServiceMock = { findAllByUserId: jest.fn() };
const usersServiceMock = { findOne: jest.fn() };

describe('RecipeService.getSuggestions', () => {
  let service: RecipeService;

  // A consistent 3-item pantry reused across tests unless a case overrides it.
  const defaultPantry = makePantry([
    ['i1', 'Egg'],
    ['i2', 'Milk'],
    ['i3', 'Flour'],
  ]);

  beforeEach(async () => {
    jest.clearAllMocks();

    const moduleRef: TestingModule = await Test.createTestingModule({
      providers: [
        RecipeService,
        { provide: RecipeRepository, useValue: recipeRepositoryMock },
        { provide: PantryService, useValue: pantryServiceMock },
        { provide: UsersService, useValue: usersServiceMock },
      ],
    }).compile();

    service = moduleRef.get<RecipeService>(RecipeService);

    // Sensible defaults. `preferences` MUST be present because the service
    // destructures `const { preferences } = user;`.
    usersServiceMock.findOne.mockResolvedValue({ id: 'u1', preferences: {} });
    pantryServiceMock.findAllByUserId.mockResolvedValue(defaultPantry);
  });

  it('preserves the descending matchScore ordering returned by matches()', async () => {
    const recipeA = makeRecipe(
      'A',
      [
        ['i1', 'Egg'],
        ['i2', 'Milk'],
      ],
      1,
    );
    const recipeB = makeRecipe(
      'B',
      [
        ['i1', 'Egg'],
        ['i2', 'Milk'],
        ['i4', 'Butter'],
        ['i5', 'Sugar'],
      ],
      0.5,
    );
    const recipeC = makeRecipe(
      'C',
      [
        ['i1', 'Egg'],
        ['i6', 'Salt'],
        ['i7', 'Pepper'],
        ['i8', 'Oil'],
        ['i9', 'Rice'],
        ['i10', 'Beans'],
      ],
      1 / 6,
    );
    recipeRepositoryMock.matches.mockResolvedValue([recipeA, recipeB, recipeC]);

    const result = await service.getSuggestions('u1', {});

    expect(result.data.map((suggestion) => suggestion.recipe.id)).toEqual([
      'A',
      'B',
      'C',
    ]);
  });

  it('classifies a fully-stocked recipe as READY with no missing ingredients', async () => {
    const recipeA = makeRecipe(
      'A',
      [
        ['i1', 'Egg'],
        ['i2', 'Milk'],
      ],
      1,
    );
    recipeRepositoryMock.matches.mockResolvedValue([recipeA]);

    const result = await service.getSuggestions('u1', {});

    expect(result.data[0].status).toBe('READY');
    expect(result.data[0].missingIngredients).toEqual([]);
  });

  it('classifies a recipe with 1-2 missing ingredients as ALMOST_THERE and lists them', async () => {
    const recipeB = makeRecipe(
      'B',
      [
        ['i1', 'Egg'],
        ['i2', 'Milk'],
        ['i4', 'Butter'],
        ['i5', 'Sugar'],
      ],
      0.5,
    );
    recipeRepositoryMock.matches.mockResolvedValue([recipeB]);

    const result = await service.getSuggestions('u1', {});

    expect(result.data[0].status).toBe('ALMOST_THERE');
    expect(
      result.data[0].missingIngredients.map((ingridient) => ingridient.name),
    ).toEqual(['Butter', 'Sugar']);
    expect(
      result.data[0].missingIngredients.map((ingridient) => ingridient.id),
    ).toEqual(['i4', 'i5']);
  });

  it('classifies a recipe with 3+ missing ingredients as MISSING', async () => {
    const recipeC = makeRecipe(
      'C',
      [
        ['i1', 'Egg'],
        ['i6', 'Salt'],
        ['i7', 'Pepper'],
        ['i8', 'Oil'],
        ['i9', 'Rice'],
        ['i10', 'Beans'],
      ],
      1 / 6,
    );
    recipeRepositoryMock.matches.mockResolvedValue([recipeC]);

    const result = await service.getSuggestions('u1', {});

    expect(result.data[0].status).toBe('MISSING');
  });

  it('flags isQuickMake true for <= 5 ingredients and false for > 5', async () => {
    const quickA = makeRecipe(
      'A',
      [
        ['i1', 'Egg'],
        ['i2', 'Milk'],
      ],
      1,
    );
    const quickB = makeRecipe(
      'B',
      [
        ['i1', 'Egg'],
        ['i2', 'Milk'],
        ['i4', 'Butter'],
        ['i5', 'Sugar'],
      ],
      0.5,
    );
    const slowC = makeRecipe(
      'C',
      [
        ['i1', 'Egg'],
        ['i6', 'Salt'],
        ['i7', 'Pepper'],
        ['i8', 'Oil'],
        ['i9', 'Rice'],
        ['i10', 'Beans'],
      ],
      1 / 6,
    );
    recipeRepositoryMock.matches.mockResolvedValue([quickA, quickB, slowC]);

    const result = await service.getSuggestions('u1', {});

    expect(result.data[0].isQuickMake).toBe(true);
    expect(result.data[1].isQuickMake).toBe(true);
    expect(result.data[2].isQuickMake).toBe(false);
  });

  it('still returns recipes when the pantry is empty (all ingredients missing)', async () => {
    pantryServiceMock.findAllByUserId.mockResolvedValue([]);
    const recipe = makeRecipe(
      'A',
      [
        ['i1', 'Egg'],
        ['i2', 'Milk'],
        ['i3', 'Flour'],
      ],
      0,
    );
    recipeRepositoryMock.matches.mockResolvedValue([recipe]);

    const result = await service.getSuggestions('u1', {});

    expect(result.data).toHaveLength(1);
    expect(result.data[0].status).toBe('MISSING');
    expect(result.data[0].missingIngredients).toHaveLength(3);
  });

  it('forwards the resolved user preferences and pantry to matches()', async () => {
    usersServiceMock.findOne.mockResolvedValue({
      id: 'u1',
      preferences: { dietary: ['vegan'] },
    });
    const filters = { isAlmostThere: true };
    recipeRepositoryMock.matches.mockResolvedValue([]);

    await service.getSuggestions('u1', filters);

    // getSuggestions() normalizes the filter flags to real booleans before
    // forwarding them, so the omitted isQuickMake is forwarded as an explicit
    // false alongside the resolved preferences and pantry.
    expect(recipeRepositoryMock.matches).toHaveBeenCalledWith(
      { dietary: ['vegan'] },
      defaultPantry,
      { isQuickMake: false, isAlmostThere: true },
    );
  });

  it('paginates the already-sorted list and computes hasMore', async () => {
    const recipeA = makeRecipe('A', [['i1', 'Egg']], 1);
    const recipeB = makeRecipe('B', [['i2', 'Milk']], 0.5);
    const recipeC = makeRecipe('C', [['i4', 'Butter']], 0.25);
    recipeRepositoryMock.matches.mockResolvedValue([recipeA, recipeB, recipeC]);

    const firstPage = await service.getSuggestions('u1', {}, 1, 2);
    expect(firstPage.data).toHaveLength(2);
    expect(firstPage.hasMore).toBe(true);

    const secondPage = await service.getSuggestions('u1', {}, 2, 2);
    expect(secondPage.data).toHaveLength(1);
    expect(secondPage.hasMore).toBe(false);
  });

  it('caps the page size at 50 even when a larger limit is requested', async () => {
    const recipes: Recipe[] = [];
    for (let index = 0; index < 60; index += 1) {
      recipes.push(makeRecipe(`r${index}`, [['i1', 'Egg']], 1));
    }
    recipeRepositoryMock.matches.mockResolvedValue(recipes);

    const result = await service.getSuggestions('u1', {}, 1, 100);

    expect(result.data).toHaveLength(50);
    expect(result.hasMore).toBe(true);
  });

  // -------------------------------------------------------------------------
  // Contract-path coverage added during code review: the mobile client sends
  // RecipeFiltersDto flags as HTTP query strings, so @Query() delivers them as
  // raw strings ('false'/'true') with no DTO transformation. Inside the frozen
  // matches() pipeline a string 'false' is TRUTHY, so getSuggestions() must
  // normalize the flags to real booleans before forwarding them; otherwise the
  // default request is silently filtered. Because matches() is mocked, these
  // tests assert the ARGUMENTS passed to matches() (the normalized flags) — the
  // proxy for "the default request stays unfiltered", since real booleans of
  // false take the pipeline's pass-through branch.
  // -------------------------------------------------------------------------

  it('normalizes mobile-style false-string filter flags to real booleans before calling matches()', async () => {
    recipeRepositoryMock.matches.mockResolvedValue([]);

    await service.getSuggestions('u1', {
      isQuickMake: 'false',
      isAlmostThere: 'false',
    } as unknown as FilterType);

    expect(recipeRepositoryMock.matches).toHaveBeenCalledWith(
      {},
      defaultPantry,
      { isQuickMake: false, isAlmostThere: false },
    );
  });

  it('normalizes string "true" and boolean true filter flags to real boolean true', async () => {
    recipeRepositoryMock.matches.mockResolvedValue([]);

    await service.getSuggestions('u1', {
      isQuickMake: 'true',
      isAlmostThere: true,
    } as unknown as FilterType);

    expect(recipeRepositoryMock.matches).toHaveBeenCalledWith(
      {},
      defaultPantry,
      { isQuickMake: true, isAlmostThere: true },
    );
  });

  it('normalizes a zero-ingredient recipe to a valid 0..1 matchScore (1) and READY', async () => {
    // matches() computes matchScore = available / total = 0 / 0 = NaN for a
    // zero-ingredient recipe; NaN serializes to null and breaks the documented
    // 0..1 contract (and the mobile non-null double). getSuggestions() must emit
    // a valid score (1) for both the top-level field and the nested recipe.
    const emptyRecipe = makeRecipe('Z', [], NaN);
    recipeRepositoryMock.matches.mockResolvedValue([emptyRecipe]);

    const result = await service.getSuggestions('u1', {});

    expect(result.data[0].status).toBe('READY');
    expect(result.data[0].matchScore).toBe(1);
    expect(Number.isNaN(result.data[0].matchScore)).toBe(false);
    expect(result.data[0].recipe.matchScore).toBe(1);
    expect(result.data[0].missingIngredients).toEqual([]);
  });

  it('re-sorts a zero-ingredient recipe (normalized to 1.0) into its correct DESC position', async () => {
    // QA CP-1 Issue #1 regression guard. The frozen matches() pipeline computes
    // matchScore = available / total = 0 / 0 = NaN for a zero-ingredient recipe,
    // and its `b.matchScore - a.matchScore` comparator returns NaN for any
    // comparison involving it — so JS leaves such a recipe in its DB-scan
    // position rather than at the top. matches() is mocked here to return that
    // degenerate order: a fully-matched recipe (1.0), then a low-score recipe
    // (0.25), then a zero-ingredient recipe stranded LAST. getSuggestions()
    // normalizes the zero-ingredient score to 1.0 and MUST re-sort so the
    // normalized-1.0 recipe is ranked among the top, restoring the strict-DESC
    // contract. Without the re-sort the result would be ['HIGH', 'LOW', 'ZERO']
    // with scores [1, 0.25, 1] — not descending.
    const high = makeRecipe('HIGH', [['i1', 'Egg']], 1);
    const low = makeRecipe(
      'LOW',
      [
        ['i1', 'Egg'],
        ['i4', 'Butter'],
        ['i5', 'Sugar'],
        ['i6', 'Salt'],
      ],
      0.25,
    );
    const zero = makeRecipe('ZERO', [], NaN);
    recipeRepositoryMock.matches.mockResolvedValue([high, low, zero]);

    const result = await service.getSuggestions('u1', {});

    // The whole result is strictly non-increasing (DESC) by matchScore.
    const scores = result.data.map((suggestion) => suggestion.matchScore);
    for (let index = 1; index < scores.length; index += 1) {
      expect(scores[index]).toBeLessThanOrEqual(scores[index - 1]);
    }
    // The zero-ingredient recipe (normalized 1.0) is lifted above the 0.25
    // recipe; with the stable sort the two 1.0 recipes keep their input order.
    expect(result.data.map((suggestion) => suggestion.recipe.id)).toEqual([
      'HIGH',
      'ZERO',
      'LOW',
    ]);
    expect(result.data[result.data.length - 1].recipe.id).toBe('LOW');
  });

  it('clamps non-positive / non-finite page and limit so a malformed limit cannot bypass the cap', async () => {
    const recipes: Recipe[] = [];
    for (let index = 0; index < 12; index += 1) {
      recipes.push(makeRecipe(`r${index}`, [['i1', 'Egg']], 1));
    }
    recipeRepositoryMock.matches.mockResolvedValue(recipes);

    // limit=-1 must NOT return slice(0, -1) (nearly the whole array) and page=-1
    // must NOT produce a negative-offset slice; both fall back to the safe
    // defaults (page=1, limit=10).
    const negative = await service.getSuggestions('u1', {}, -1, -1);
    expect(negative.data).toHaveLength(10);
    expect(negative.data[0].recipe.id).toBe('r0');
    expect(negative.hasMore).toBe(true);

    // Non-finite (NaN) values fall back to the same defaults.
    const notFinite = await service.getSuggestions(
      'u1',
      {},
      Number.NaN,
      Number.NaN,
    );
    expect(notFinite.data).toHaveLength(10);
    expect(notFinite.hasMore).toBe(true);
  });

  it('clamps positive fractional page/limit below 1 (which floor to 0) to the safe defaults', async () => {
    const recipes: Recipe[] = [];
    for (let index = 0; index < 12; index += 1) {
      recipes.push(makeRecipe(`r${index}`, [['i1', 'Egg']], 1));
    }
    recipeRepositoryMock.matches.mockResolvedValue(recipes);

    // page=0.5 and limit=0.5 are positive (> 0) but floor to 0. A "raw > 0 then
    // floor" check would let them through and create a bad slice — slice(-10, 0)
    // for page or slice(0, 0) for limit — returning empty data with
    // hasMore=true. Flooring FIRST and requiring >= 1 makes both fall back to the
    // safe defaults (page=1, limit=10) and return a valid first page.
    const fractional = await service.getSuggestions('u1', {}, 0.5, 0.5);
    expect(fractional.data).toHaveLength(10);
    expect(fractional.data[0].recipe.id).toBe('r0');
    expect(fractional.hasMore).toBe(true);

    // A fractional limit below 1 alone must also default to 10 rather than 0.
    const fractionalLimit = await service.getSuggestions('u1', {}, 1, 0.9);
    expect(fractionalLimit.data).toHaveLength(10);
    expect(fractionalLimit.hasMore).toBe(true);

    // Fractional values at or above 1 still floor to a valid integer (not the
    // default): page=1.9 floors to page 1 and limit=5.9 floors to 5.
    const fractionalAboveOne = await service.getSuggestions('u1', {}, 1.9, 5.9);
    expect(fractionalAboveOne.data).toHaveLength(5);
    expect(fractionalAboveOne.data[0].recipe.id).toBe('r0');
    expect(fractionalAboveOne.hasMore).toBe(true);
  });
});
