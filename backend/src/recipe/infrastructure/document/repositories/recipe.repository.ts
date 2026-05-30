// NOTE: 'IngridientList', 'ingridientList', 'PantryIngridient' spellings
// preserved verbatim. Do not rename.
import { Injectable } from '@nestjs/common';
import { EntityCondition } from 'src/utils/types/entity-condition.type';
import { NullableType } from 'src/utils/types/nullable.type';
import { Recipe } from 'src/recipe/domain/recipe';
import { RecipeRepository } from '../../recipe.repository';
import { RecipeSchemaClass } from '../entities/recipe.schema';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { RecipeMapper } from '../mappers/recipe.mapper';
import { FilterRecipeDto, SortRecipeDto } from '../../../dto/query-recipe.dto';
import { IPaginationOptions } from 'src/utils/types/pagination-options';
import { Preferences } from 'src/users/infrastructure/document/entities/user.schema';
import { PantryIngridient } from 'src/pantry/domain/pantryIngridient';
import { FilterType } from 'src/recipe/types/filter.types';

/**
 * Mongoose-backed concrete implementation of the abstract RecipeRepository.
 *
 * Persists Recipe documents via RecipeSchemaClass and maps to/from the
 * Recipe domain entity via RecipeMapper. Embedded IngridientList sub-schema
 * (spelling preserved verbatim) holds required ingredients for matching.
 */
@Injectable()
export class RecipeDocumentRepository implements RecipeRepository {
  constructor(
    @InjectModel(RecipeSchemaClass.name)
    private readonly recipeModel: Model<RecipeSchemaClass>,
  ) {}

  /**
   * Persist a new recipe document and return the populated domain entity.
   *
   * Maps the domain payload to a Mongoose document via RecipeMapper.toPersistence,
   * saves it, then populates `ingridientList.ingridient` references before
   * mapping back to the domain via RecipeMapper.toDomain.
   *
   * @param data Recipe payload (the `id` field, if provided as a string, is
   *   copied into `_id` by the mapper).
   * @returns Newly persisted Recipe domain entity with populated ingredients.
   */
  async create(data: Recipe): Promise<Recipe> {
    const persistenceModel = RecipeMapper.toPersistence(data);
    const createdRecipe = new this.recipeModel(persistenceModel);
    const recipeObject = await createdRecipe.save();
    return RecipeMapper.toDomain(
      await recipeObject.populate('ingridientList.ingridient'),
    );
  }

  /**
   * Find a single recipe by id (preferred) or by arbitrary EntityCondition.
   *
   * When `fields.id` is present, uses `findById` to leverage the primary key
   * index. Otherwise falls back to `findOne(fields)` with the provided shape.
   * Always populates `ingridientList.ingridient` references for downstream use.
   *
   * @param fields Partial Recipe condition (typically `{ id }` or `{ title }`).
   * @returns Recipe domain entity, or null when no document matches.
   */
  async findOne(
    fields: EntityCondition<Recipe>,
  ): Promise<NullableType<Recipe>> {
    if (fields.id) {
      const recipeObject = await this.recipeModel
        .findById(fields.id)
        .populate('ingridientList.ingridient');
      return recipeObject ? RecipeMapper.toDomain(recipeObject) : null;
    }

    const recipeObject = await this.recipeModel
      .findOne(fields)
      .populate('ingridientList.ingridient');
    return recipeObject ? RecipeMapper.toDomain(recipeObject) : null;
  }

  /**
   * List recipes with pagination, filtering, and sorting.
   *
   * Builds a Mongo `find` query that:
   *  - applies a case-insensitive `$regex` on `name` when `filterOptions.name`
   *    is provided,
   *  - applies an `$in` filter on `_id` when `filterOptions.ids` is provided,
   *  - always filters out soft-deleted documents via `deletedAt: null`,
   *  - populates `ingridientList.ingridient` references,
   *  - applies sortOptions (mapping `id` -> `_id` and uppercasing direction),
   *  - skips/limits per paginationOptions (page is 1-indexed).
   *
   * @param params filterOptions, sortOptions, paginationOptions.
   * @returns Recipe[] for the requested page, mapped via RecipeMapper.toDomain.
   */
  async findManyWithPagination({
    filterOptions,
    sortOptions,
    paginationOptions,
  }: {
    filterOptions?: FilterRecipeDto;
    sortOptions?: SortRecipeDto[] | null;
    paginationOptions: IPaginationOptions;
  }): Promise<Recipe[]> {
    const where: EntityCondition<Recipe> = {};

    if (filterOptions) {
      if (filterOptions.name) {
        where['name'] = { $regex: filterOptions.name, $options: 'i' } as any;
      }
      if (filterOptions.ids && Array.isArray(filterOptions.ids)) {
        where['_id'] = { $in: filterOptions.ids } as any;
      }
    }

    const recipeObjects = await this.recipeModel
      .find({
        ...where,
        deletedAt: null,
      })
      .populate('ingridientList.ingridient')
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

    return recipeObjects.map((recipeObject) =>
      RecipeMapper.toDomain(recipeObject),
    );
  }

  /**
   * Pantry-aware recipe matching pipeline.
   *
   * Given the authenticated user's Preferences and current pantry contents,
   * return recipes ranked by how well they match available ingredients.
   *
   * Algorithm overview (Source: this file — the matches() method below):
   *
   * 1. Mongo pre-filter chain — build a query object with:
   *    - deletedAt: null (exclude soft-deleted recipes)
   *    - ingridientList.ingridient: { $nin: [...allergies, ...dislikedIngredients] }
   *      (exclude recipes containing user's allergens or dislikes)
   *    - tags: { $all: preferences.dietary } (match dietary tags)
   *    - cookTime: { $lte: preferences.cookingTime } (respect time constraint)
   * 2. Per-recipe scoring loop:
   *    - totalIngredients = recipe.ingridientList.length
   *    - availableIngredients = ingridientList filtered by exact _id match against pantry
   *    - matchScore = available / total (range [0, 1])
   *    - isQuickMake = totalIngredients <= 5
   *    - isAlmostThere = missingCount >= 1 && missingCount <= 2
   * 3. FilterType post-filter: include only quick-make / almost-there as flagged.
   * 4. Sort by matchScore descending.
   *
   * Spelling: 'IngridientList', 'ingridientList', 'PantryIngridient' preserved verbatim
   * across the backend codebase. See ../../../../../../ARCHITECTURE.md § Recipe Matching Pipeline.
   *
   * @param preferences User dietary preferences and constraints.
   * @param pantryIngredients Current pantry contents (user-scoped).
   * @param filterOptions Optional flags (isQuickMake, isAlmostThere).
   * @returns Array of Recipe domain objects sorted by matchScore (DESC).
   */
  // TODO(prod): No unit normalization.
  // TODO(prod): No quantity sufficiency check.
  // TODO(prod): Exact _id match only — substitutes and equivalents are ignored.
  async matches(
    preferences: Preferences,
    pantryIngredients: PantryIngridient[],
    filterOptions: FilterType,
  ): Promise<Recipe[]> {
    const pantryIngredientIds = pantryIngredients.map((pi) => pi.ingridient.id);
    // Step 2: Build the query criteria based on preferences
    const query: any = { deletedAt: null };

    // Exclude recipes containing allergens or disliked ingredients
    const excludedIngredients = [
      ...(preferences.allergies || []),
      ...(preferences.dislikedIngredients || []),
    ];

    if (excludedIngredients.length > 0) {
      query['ingridientList.ingridient'] = { $nin: excludedIngredients };
    }

    // Include recipes matching dietary preferences
    if (preferences.dietary && preferences.dietary.length > 0) {
      query['tags'] = { $all: preferences.dietary };
    }

    // Limit recipes to those within the desired cooking time
    if (preferences.cookingTime) {
      query['cookTime'] = { $lte: preferences.cookingTime };
    }

    // Step 3: Retrieve and process recipes
    // TODO(prod): No compound index on (deletedAt, tags) — will degrade at scale.
    const recipeObjects = await this.recipeModel
      .find(query)
      .populate('ingridientList.ingridient')
      .exec();

    const recipesWithScores = recipeObjects
      .map((recipe) => {
        // Расчёт matchScore на основе доступных ингредиентов
        const totalIngredients = recipe.ingridientList.length;
        const availableIngredients = recipe.ingridientList.filter((il) =>
          pantryIngredientIds.includes(il.ingridient._id.toString()),
        );

        const missingIngredientsCount =
          totalIngredients - availableIngredients.length;
        const matchScore = availableIngredients.length / totalIngredients;

        const isQuickMake = totalIngredients <= 5;

        const isAlmostThere =
          missingIngredientsCount >= 1 && missingIngredientsCount <= 2;

        return {
          ...recipe.toObject(),
          matchScore,
          isQuickMake,
          isAlmostThere,
          missingIngredientsCount,
        };
      })
      .filter((recipe) => {
        if (filterOptions.isQuickMake && recipe.isQuickMake) {
          return true;
        }

        if (filterOptions.isAlmostThere && recipe.isAlmostThere) {
          return true;
        }

        if (!filterOptions.isQuickMake && !filterOptions.isAlmostThere) {
          return true;
        }

        return false;
      })
      .sort((a, b) => b.matchScore - a.matchScore)
      .map((recipe) => RecipeMapper.toDomain(recipe));

    return recipesWithScores;
  }

  /**
   * Apply a partial update to an existing recipe.
   *
   * Uses Mongoose `findByIdAndUpdate(id, payload, { new: true })` so the
   * returned document reflects the post-update state. Populates
   * `ingridientList.ingridient` before mapping back to the domain entity.
   *
   * @param id Recipe identifier (MongoDB ObjectId as string).
   * @param payload Partial<Recipe> update payload.
   * @returns The updated Recipe domain entity, or null when no document matches.
   */
  async update(
    id: Recipe['id'],
    payload: Partial<Recipe>,
  ): Promise<Recipe | null> {
    const updatedRecipe = await this.recipeModel
      .findByIdAndUpdate(id, payload, { new: true })
      .populate('ingridientList.ingridient');

    return updatedRecipe ? RecipeMapper.toDomain(updatedRecipe) : null;
  }

  /**
   * Proper soft-delete via `updateOne({ _id }, { deletedAt: new Date() })`.
   *
   * This is the PROPER soft-delete contract — the document is retained on disk
   * and subsequent paginated listings exclude it via the `deletedAt: null`
   * filter. In deliberate contrast to the pantry module's `softDelete` (which
   * physically removes the document via `deleteOne` despite the method name —
   * see ../../../../pantry/README.md § Known Limitations). Cross-reference:
   * ../../../../../../ARCHITECTURE.md § Soft-Delete Contract.
   *
   * @param id Recipe identifier (MongoDB ObjectId as string).
   * @returns void on success.
   */
  async softDelete(id: Recipe['id']): Promise<void> {
    await this.recipeModel.updateOne({ _id: id }, { deletedAt: new Date() });
  }
}
