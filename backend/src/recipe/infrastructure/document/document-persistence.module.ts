import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { RecipeSchema, RecipeSchemaClass } from './entities/recipe.schema';
import { RecipeRepository } from '../recipe.repository';
import { RecipeDocumentRepository } from './repositories/recipe.repository';

/**
 * NestJS persistence module for the recipe feature; the composition root that
 * wires recipe storage to MongoDB through Mongoose.
 *
 * Registers the recipe Mongoose model (`RecipeSchemaClass` / `RecipeSchema`)
 * via `MongooseModule.forFeature([...])`, binds the abstract `RecipeRepository`
 * token to the concrete `RecipeDocumentRepository`
 * (`{ provide: RecipeRepository, useClass: RecipeDocumentRepository }`), and
 * exports `RecipeRepository` so upstream modules depend only on the
 * abstraction rather than the Mongoose implementation.
 *
 * Note: the class name retains "Pantry" although it serves the recipe feature;
 * this is a pre-existing identifier and is preserved deliberately.
 *
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
  providers: [
    {
      provide: RecipeRepository,
      useClass: RecipeDocumentRepository,
    },
  ],
  exports: [RecipeRepository],
})
export class DocumentPantryPersistenceModule {}
