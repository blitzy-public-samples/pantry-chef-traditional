import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { RecipeSchema, RecipeSchemaClass } from './entities/recipe.schema';
import { RecipeRepository } from '../recipe.repository';
import { RecipeDocumentRepository } from './repositories/recipe.repository';

/**
 * Document-persistence module for the Recipe feature.
 *
 * Registers the Mongoose model for RecipeSchemaClass via MongooseModule.forFeature
 * and binds the abstract `RecipeRepository` token to the concrete
 * `RecipeDocumentRepository` provider. Re-exports `RecipeRepository` so the
 * feature service can consume the abstract contract.
 *
 * NOTE: the class name `DocumentPantryPersistenceModule` is preserved verbatim
 * despite belonging to the Recipe feature.
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
