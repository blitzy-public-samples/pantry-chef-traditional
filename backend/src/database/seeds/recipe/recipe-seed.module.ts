import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { RecipeSeedService } from './recipe-seed.service';
import {
  RecipeSchema,
  RecipeSchemaClass,
} from 'src/recipe/infrastructure/document/entities/recipe.schema';
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
