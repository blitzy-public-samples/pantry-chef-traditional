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

@Injectable()
export class RecipeDocumentRepository implements RecipeRepository {
  constructor(
    @InjectModel(RecipeSchemaClass.name)
    private readonly recipeModel: Model<RecipeSchemaClass>,
  ) {}

  async create(data: Recipe): Promise<Recipe> {
    const persistenceModel = RecipeMapper.toPersistence(data);
    const createdRecipe = new this.recipeModel(persistenceModel);
    const recipeObject = await createdRecipe.save();
    return RecipeMapper.toDomain(
      await recipeObject.populate('ingridientList.ingridient'),
    );
  }

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

  async update(
    id: Recipe['id'],
    payload: Partial<Recipe>,
  ): Promise<Recipe | null> {
    const updatedRecipe = await this.recipeModel
      .findByIdAndUpdate(id, payload, { new: true })
      .populate('ingridientList.ingridient');

    return updatedRecipe ? RecipeMapper.toDomain(updatedRecipe) : null;
  }

  async softDelete(id: Recipe['id']): Promise<void> {
    await this.recipeModel.updateOne({ _id: id }, { deletedAt: new Date() });
  }
}
