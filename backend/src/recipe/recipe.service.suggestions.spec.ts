import { Test, TestingModule } from '@nestjs/testing';
import { RecipeService } from './recipe.service';
import { RecipeRepository } from './infrastructure/recipe.repository';
import { PantryService } from '../pantry/pantry.service';
import { UsersService } from '../users/users.service';
import { Recipe } from './domain/recipe';
import { Ingridient } from '../ingridient/domain/ingrident';
import { PantryIngridient } from '../pantry/domain/pantryIngridient';

/**
 * Unit spec for RecipeService.getSuggestions() — the "What Can I Make Tonight?"
 * post-processing layer. The matching pipeline (recipeRepository.matches) is
 * fully mocked to return a PRE-SORTED Recipe[] (matchScore DESC), so these
 * tests isolate getSuggestions()'s own behavior: order pass-through (the
 * service must NOT re-sort), the three derived fields (status / isQuickMake /
 * missingIngredients computed from the domain `ingridient.id` and `.name`), and
 * the { data, hasMore } pagination envelope (default page=1/limit=10, limit
 * capped at 50).
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

    expect(recipeRepositoryMock.matches).toHaveBeenCalledWith(
      { dietary: ['vegan'] },
      defaultPantry,
      filters,
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
});
