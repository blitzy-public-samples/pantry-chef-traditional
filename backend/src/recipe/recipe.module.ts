import { Module } from '@nestjs/common';
import { RecipeService } from './recipe.service';
import { RecipeController } from './recipe.controller';
import { DocumentPantryPersistenceModule } from './infrastructure/document/document-persistence.module';
import { UsersModule } from 'src/users/users.module';
import { PantryModule } from 'src/pantry/pantry.module';

@Module({
  imports: [DocumentPantryPersistenceModule, UsersModule, PantryModule],
  exports: [DocumentPantryPersistenceModule, RecipeService],
  providers: [RecipeService],
  controllers: [RecipeController],
})
export class RecipeModule {}
