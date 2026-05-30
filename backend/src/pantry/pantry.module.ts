import { Module } from '@nestjs/common';
// NOTE: 'PantryIngridient' / 'PantryIngridientSchemaClass' spellings preserved
// verbatim. Do not rename.
import { PantryService } from './pantry.service';
import { PantryController } from './pantry.controller';
import { DocumentPantryPersistenceModule } from './infrastructure/document/document-persistence.module';

/**
 * NestJS module wiring the Pantry feature.
 *
 * Imports DocumentPantryPersistenceModule to bind the abstract
 * PantryRepository contract to its Mongoose-backed implementation
 * (PantryIngridientDocumentRepository), provides PantryService for business
 * orchestration, and registers PantryController for the /api/v1/pantry/*
 * HTTP surface. The module re-exports DocumentPantryPersistenceModule and
 * PantryService so RecipeModule can consume them for the pantry-aware
 * matches() flow (see ../../../ARCHITECTURE.md § Recipe Matching Pipeline).
 *
 * Schema spelling 'PantryIngridient' (with embedded 'Ingridient') is
 * preserved verbatim throughout this module and the backend codebase.
 */
@Module({
  imports: [DocumentPantryPersistenceModule],
  providers: [PantryService],
  controllers: [PantryController],
  exports: [DocumentPantryPersistenceModule, PantryService],
})
export class PantryModule {}
