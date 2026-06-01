// NOTE: 'PantryIngridient' / 'IngridientList' / 'ingridientList' spellings
// preserved verbatim. Do not rename.
import { Module } from '@nestjs/common';
import { RecipeService } from './recipe.service';
import { RecipeController } from './recipe.controller';
import { DocumentPantryPersistenceModule } from './infrastructure/document/document-persistence.module';
import { UsersModule } from 'src/users/users.module';
import { PantryModule } from 'src/pantry/pantry.module';

/**
 * NestJS module wiring the Recipe feature.
 *
 * Imports DocumentPantryPersistenceModule for Mongoose binding,
 * plus UsersModule and PantryModule which RecipeService consumes
 * for the pantry-aware matches() flow.
 */
@Module({
  imports: [DocumentPantryPersistenceModule, UsersModule, PantryModule],
  exports: [DocumentPantryPersistenceModule, RecipeService],
  providers: [RecipeService],
  controllers: [RecipeController],
})
export class RecipeModule {}
