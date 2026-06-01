// NOTE: 'Ingridient', 'IngridientModule', 'IngridientService' spellings
// preserved verbatim across the backend codebase. Do not rename.
import { Module } from '@nestjs/common';
import { IngridientService } from './ingridient.service';
import { IngridientController } from './ingridient.controller';
import { DocumentIngridientPersistenceModule } from './infrastructure/document/document-persistence.module';

/**
 * NestJS module wiring the Ingridient feature (spelling preserved verbatim).
 *
 * Exports IngridientService for consumption by AiModule, PantryModule,
 * and RecipeModule.
 */
@Module({
  imports: [DocumentIngridientPersistenceModule],
  providers: [IngridientService],
  controllers: [IngridientController],
  exports: [IngridientService, DocumentIngridientPersistenceModule],
})
export class IngridientModule {}
