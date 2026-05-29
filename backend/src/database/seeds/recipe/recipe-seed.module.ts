import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { RecipeSeedService } from './recipe-seed.service';
// NOTE: References to 'IngridientList' embedded in RecipeSchemaClass are preserved
// NOTE: verbatim. Do not rename.
import {
  RecipeSchema,
  RecipeSchemaClass,
} from 'src/recipe/infrastructure/document/entities/recipe.schema';
/**
 * NestJS module registering RecipeSeedService.
 *
 * Imports MongooseModule.forFeature([{ name: RecipeSchemaClass.name,
 * schema: RecipeSchema }]) to bind the Recipes collection model.
 */
@Module({
  imports: [
    MongooseModule.forFeature([
      {
        name: RecipeSchemaClass.name,
        schema: RecipeSchema,
      },
    ]),
  ],
  providers: [RecipeSeedService],
  exports: [RecipeSeedService],
})
export class RecipeSeedModule {}
