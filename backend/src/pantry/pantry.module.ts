import { Module } from '@nestjs/common';
import { PantryService } from './pantry.service';
import { PantryController } from './pantry.controller';
import { DocumentPantryPersistenceModule } from './infrastructure/document/document-persistence.module';

/**
 * Feature module (composition root) for per-user pantry management; wired into
 * the application root module as `PantryModule`.
 * Source: backend/src/app.module.ts:L53.
 *
 * It composes the Pantry API by binding the document (Mongoose) persistence
 * implementation, the application service, and the JWT-guarded HTTP controller,
 * and re-exporting the persistence module and service for downstream consumers.
 */
@Module({
  // imports the document (Mongoose) persistence implementation
  imports: [DocumentPantryPersistenceModule],
  // registers the application service
  providers: [PantryService],
  // registers the JWT-guarded REST controller
  controllers: [PantryController],
  // re-exports persistence module + service for consumers
  exports: [DocumentPantryPersistenceModule, PantryService],
})
export class PantryModule {}
