import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { RecipeSchema, RecipeSchemaClass } from './entities/recipe.schema';
import { RecipeRepository } from '../recipe.repository';
import { RecipeDocumentRepository } from './repositories/recipe.repository';

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
