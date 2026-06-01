import { Module } from '@nestjs/common';
import { RecipeService } from './recipe.service';
import { RecipeController } from './recipe.controller';
import { DocumentPantryPersistenceModule } from './infrastructure/document/document-persistence.module';
import { UsersModule } from 'src/users/users.module';
import { PantryModule } from 'src/pantry/pantry.module';

/**
 * NestJS feature module that assembles the recipe subsystem (controller, service, and
 * persistence) into the application dependency-injection graph. It performs DI wiring only
 * and contains no business logic of its own.
 *
 * Imports `DocumentPantryPersistenceModule` (which binds the abstract `RecipeRepository` to
 * its Mongoose document implementation), `UsersModule`, and `PantryModule`, so that
 * `RecipeService` can read user preferences and pantry ingredients when matching recipes.
 * Source: backend/src/recipe/recipe.module.ts:L9
 *
 * Registers `RecipeController` and provides and exports `RecipeService`, while also
 * re-exporting `DocumentPantryPersistenceModule` for downstream modules.
 * Source: backend/src/recipe/recipe.module.ts:L10-L12
 *
 * Wired into the application root module. Source: backend/src/app.module.ts:L33
 *
 * Note: the imported persistence module retains the pre-existing name
 * `DocumentPantryPersistenceModule` even though this is the recipe feature; the identifier is
 * preserved as-is and intentionally not renamed.
 */
@Module({
  imports: [DocumentPantryPersistenceModule, UsersModule, PantryModule],
  exports: [DocumentPantryPersistenceModule, RecipeService],
  providers: [RecipeService],
  controllers: [RecipeController],
})
export class RecipeModule {}
