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
 * Mongoose document adapter that implements the abstract `RecipeRepository`
 * contract (Source: backend/src/recipe/infrastructure/recipe.repository.ts:L24).
 *
 * Acts as the persistence gateway for recipes: create, single lookup,
 * paginated listing, pantry/preference matching, partial update, and soft
 * delete. Every method translates between Mongoose persistence documents and
 * domain `Recipe` objects through `RecipeMapper`.
 *
 * The constructor injects a Mongoose `Model<RecipeSchemaClass>` via
 * `@InjectModel(RecipeSchemaClass.name)`. The abstract `RecipeRepository`
 * token is bound to this class through dependency injection
 * (`{ provide: RecipeRepository, useClass: RecipeDocumentRepository }`).
 * Source: backend/src/recipe/infrastructure/document/document-persistence.module.ts:L33-L36
 */
@Injectable()
export class RecipeDocumentRepository implements RecipeRepository {
  constructor(
    @InjectModel(RecipeSchemaClass.name)
    private readonly recipeModel: Model<RecipeSchemaClass>,
  ) {}

  /**
   * Maps the domain `Recipe` to a persistence model via
   * `RecipeMapper.toPersistence`, constructs and `save()`s a new `recipeModel`
   * document, then populates `ingridientList.ingridient` before mapping the
   * saved document back to the domain model via `RecipeMapper.toDomain`.
   *
   * @param data the domain `Recipe` to persist.
   * @returns the created `Recipe` with its `ingridientList.ingridient`
   * references populated.
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
   * Looks up a single recipe through one of two branches. When `fields.id`
   * is present it loads by id via `findById`; otherwise it runs a general
   * `findOne(fields)`. Both branches populate `ingridientList.ingridient`
   * and map the document to the domain model, returning `null` when no
   * document matches.
   *
   * @param fields an `EntityCondition<Recipe>` (for example `{ id }` or
   * other recipe fields).
   * @returns the matching `Recipe`, or `null` when no document matches.
   */
  async findOne(
    fields: EntityCondition<Recipe>,
  ): Promise<NullableType<Recipe>> {
    if (fields.id) {
      // Id branch: look up by primary key, then populate ingridient refs.
      const recipeObject = await this.recipeModel
        .findById(fields.id)
        .populate('ingridientList.ingridient');
      return recipeObject ? RecipeMapper.toDomain(recipeObject) : null;
    }

    // General branch: query by the given fields, then populate refs.
    const recipeObject = await this.recipeModel
      .findOne(fields)
      .populate('ingridientList.ingridient');
    return recipeObject ? RecipeMapper.toDomain(recipeObject) : null;
  }

  /**
   * Returns a filtered, sorted, and paginated page of recipes, always
   * excluding soft-deleted records via `deletedAt: null`.
   *
   * @param options the query options object: `filterOptions?`
   * (`FilterRecipeDto` with `name` -> `$regex` and `ids` -> `$in`),
   * `sortOptions?` (`SortRecipeDto[] | null` reduced into a Mongoose sort
   * map), and `paginationOptions` (`IPaginationOptions` with `page` and
   * `limit`).
   * @returns the recipes for the requested page, mapped to the domain model.
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
      // Case-insensitive `name` filter using `$regex` with `$options: 'i'`.
      // KNOWN ISSUE: `name` is not a field on RecipeSchemaClass (its title
      // field is `title`), so this $regex targets a non-schema key and does
      // not filter recipes by title.
      // Source: backend/src/recipe/infrastructure/document/entities/recipe.schema.ts:L86-L88
      if (filterOptions.name) {
        where['name'] = { $regex: filterOptions.name, $options: 'i' } as any;
      }
      // Id-inclusion filter on `_id` using `$in: filterOptions.ids`.
      if (filterOptions.ids && Array.isArray(filterOptions.ids)) {
        where['_id'] = { $in: filterOptions.ids } as any;
      }
    }

    const recipeObjects = await this.recipeModel
      .find({
        ...where,
        // Always exclude soft-deleted records via `deletedAt: null`.
        deletedAt: null,
      })
      .populate('ingridientList.ingridient')
      // Build the Mongoose sort map from sortOptions, mapping `id` -> `_id`
      // and 'ASC' -> 1 (else -1).
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
      // Skip/limit pagination: skip((page - 1) * limit) then limit(limit).
      .skip((paginationOptions.page - 1) * paginationOptions.limit)
      .limit(paginationOptions.limit);

    return recipeObjects.map((recipeObject) =>
      RecipeMapper.toDomain(recipeObject),
    );
  }

  /**
   * Scores recipes against the user's pantry and dietary preferences and
   * returns them ordered by descending `matchScore`. Preferences narrow the
   * candidate set (excluded ingridients, required dietary tags, max
   * `cookTime`); pantry contents then drive the per-recipe availability
   * score.
   *
   * @param preferences the user's `Preferences` (`allergies`,
   * `dislikedIngredients`, `dietary`, `cookingTime`).
   * @param pantryIngredients the user's `PantryIngridient[]` whose ingredient
   * ids drive availability scoring.
   * @param filterOptions a `FilterType` of post-scoring flags
   * (`isQuickMake`, `isAlmostThere`).
   * @returns the scored recipes sorted by descending `matchScore`.
   */
  async matches(
    preferences: Preferences,
    pantryIngredients: PantryIngridient[],
    filterOptions: FilterType,
  ): Promise<Recipe[]> {
    // Collect the pantry's ingridient ids via pantryIngredients.map((pi) =>
    // pi.ingridient.id); these drive the availability scoring below.
    const pantryIngredientIds = pantryIngredients.map((pi) => pi.ingridient.id);
    // Step 2: Build the query criteria based on preferences
    // Seed the query with `{ deletedAt: null }` to exclude soft-deleted
    // recipes from the candidate set.
    const query: any = { deletedAt: null };

    // Exclude recipes containing allergens or disliked ingredients
    // Combine allergies and dislikedIngredients into one exclusion list.
    const excludedIngredients = [
      ...(preferences.allergies || []),
      ...(preferences.dislikedIngredients || []),
    ];

    if (excludedIngredients.length > 0) {
      // When non-empty, exclude recipes whose `ingridientList.ingridient`
      // references any excluded ingridient via a `$nin` constraint.
      query['ingridientList.ingridient'] = { $nin: excludedIngredients };
    }

    // Include recipes matching dietary preferences
    if (preferences.dietary && preferences.dietary.length > 0) {
      // Require all configured dietary tags via `$all` on `tags`.
      query['tags'] = { $all: preferences.dietary };
    }

    // Limit recipes to those within the desired cooking time
    if (preferences.cookingTime) {
      // Cap `cookTime` at the preferred cooking time via `$lte`.
      query['cookTime'] = { $lte: preferences.cookingTime };
    }

    // Step 3: Retrieve and process recipes
    // Load candidate recipes: find(query), populate ingridient refs, exec().
    const recipeObjects = await this.recipeModel
      .find(query)
      .populate('ingridientList.ingridient')
      .exec();

    const recipesWithScores = recipeObjects
      .map((recipe) => {
        // Расчёт matchScore на основе доступных ингредиентов
        // totalIngredients counts every ingridient the recipe requires.
        const totalIngredients = recipe.ingridientList.length;
        // availableIngredients keeps the recipe ingridients whose
        // `ingridient._id` is present in the pantry (exact `_id` membership).
        // KNOWN ISSUE: availability is matched by exact ingredient _id only —
        // there is no unit/quantity normalization. An ingridient counts as
        // "available" when its id is in the pantry, regardless of the amount
        // or unit the recipe requires.
        const availableIngredients = recipe.ingridientList.filter((il) =>
          pantryIngredientIds.includes(il.ingridient._id.toString()),
        );

        // missingIngredientsCount is how many required ingridients are
        // absent from the pantry; matchScore = availableIngredients.length /
        // totalIngredients (range 0..1).
        const missingIngredientsCount =
          totalIngredients - availableIngredients.length;
        const matchScore = availableIngredients.length / totalIngredients;

        // isQuickMake flags recipes needing five or fewer total ingridients.
        const isQuickMake = totalIngredients <= 5;

        // isAlmostThere flags recipes missing exactly one or two ingridients.
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
      // Filter pass: keep quick-make and/or almost-there recipes; when
      // neither flag is set, keep every scored recipe.
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
      // Rank by descending matchScore (best matches first).
      .sort((a, b) => b.matchScore - a.matchScore)
      // Map the scored persistence objects back to domain `Recipe`.
      .map((recipe) => RecipeMapper.toDomain(recipe));

    return recipesWithScores;
  }

  /**
   * Applies a partial update by id via
   * `findByIdAndUpdate(id, payload, { new: true })` (returning the updated
   * document), then populates `ingridientList.ingridient` before mapping
   * back to the domain model.
   *
   * @param id the recipe id (`Recipe['id']`).
   * @param payload a `Partial<Recipe>` of fields to update.
   * @returns the updated `Recipe`, or `null` when the id does not exist.
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
   * Performs a TRUE soft delete: sets `deletedAt` to the current date via
   * `updateOne({ _id: id }, { deletedAt: new Date() })`, so later queries
   * exclude the record through the `deletedAt: null` constraint.
   *
   * This contrasts with the sibling repositories, which HARD-delete:
   * - users (`deleteOne`):
   *   backend/src/users/infrastructure/document/repositories/user.repository.ts:L172-L174
   * - pantry (`deleteOne`):
   *   backend/src/pantry/infrastructure/document/repositories/pantryIngridient.repository.ts:L184-L186
   * - session (`deleteMany`):
   *   backend/src/session/infrastructure/document/repositories/session.repository.ts:L106
   *
   * @param id the recipe id (`Recipe['id']`).
   * @returns nothing once the soft delete is applied.
   */
  async softDelete(id: Recipe['id']): Promise<void> {
    await this.recipeModel.updateOne({ _id: id }, { deletedAt: new Date() });
  }
}
