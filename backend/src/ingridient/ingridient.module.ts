import { Module } from '@nestjs/common';
import { IngridientService } from './ingridient.service';
import { IngridientController } from './ingridient.controller';
import { DocumentIngridientPersistenceModule } from './infrastructure/document/document-persistence.module';

/**
 * NestJS feature module (composition root) for the ingredient catalog feature.
 *
 * Imports `DocumentIngridientPersistenceModule` (the Mongoose-backed persistence
 * wiring), provides `IngridientService` (business logic), and registers
 * `IngridientController` (the JWT-guarded REST surface mounted at `/api/ingredient`).
 *
 * Exports `IngridientService` and `DocumentIngridientPersistenceModule` so other
 * NestJS modules can reuse the ingredient feature without re-declaring its
 * providers. Source: backend/src/ingridient/ingridient.module.ts:L10
 *
 * Wired into the root `AppModule` (Source: backend/src/app.module.ts:L31) and,
 * among feature modules, currently consumed only by `AiModule` for ingredient
 * lookups during image recognition (Source: backend/src/ai/ai.module.ts:L7); the
 * Pantry and Recipe modules do not import it.
 *
 * Note: the `Ingridient` spelling is an intentional, stable identifier used
 * throughout the backend and is documented as-is (never renamed).
 */
@Module({
  // Mongoose-backed persistence wiring; provides/exports IngridientRepository.
  imports: [DocumentIngridientPersistenceModule],
  // Ingredient business logic: CRUD, duplicate-name rejection, creation data.
  providers: [IngridientService],
  // JWT-guarded REST controller mounted at /api/ingredient.
  controllers: [IngridientController],
  // Re-exported so consumers (e.g. AiModule) reuse the service + persistence.
  exports: [IngridientService, DocumentIngridientPersistenceModule],
})
export class IngridientModule {}
