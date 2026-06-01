import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import {
  PantryIngridientSchema,
  PantryIngridientSchemaClass,
} from './entities/pantryIngridient.schema';
import { PantryRepository } from '../pantry.repository';
import { PantryIngridientDocumentRepository } from './repositories/pantryIngridient.repository';

/**
 * Mongoose persistence module for the pantry document (MongoDB) layer.
 *
 * `DocumentPantryPersistenceModule` registers the `PantryIngridient` schema and
 * binds the abstract `PantryRepository` to `PantryIngridientDocumentRepository`,
 * so consumers depend on the abstraction rather than the concrete adapter. It
 * performs three composition responsibilities:
 *
 * - Registers the Mongoose feature model for `PantryIngridientSchemaClass` via
 *   `MongooseModule.forFeature`, mapping `PantryIngridientSchemaClass.name` to
 *   the generated `PantryIngridientSchema`.
 *   Source: backend/src/pantry/infrastructure/document/document-persistence.module.ts:L11-L18
 * - Binds the abstract `PantryRepository` token to the concrete
 *   `PantryIngridientDocumentRepository` via
 *   `{ provide: PantryRepository, useClass: PantryIngridientDocumentRepository }`.
 *   Source: backend/src/pantry/infrastructure/document/document-persistence.module.ts:L19-L24
 * - Exports the `PantryRepository` token so consumer modules (e.g.,
 *   `PantryModule`) resolve the repository transparently without depending on
 *   the concrete implementation.
 *   Source: backend/src/pantry/infrastructure/document/document-persistence.module.ts:L25
 *
 * Imported and re-exported by `PantryModule`, the pantry feature module.
 * Source: backend/src/pantry/pantry.module.ts:L6-L11
 *
 * Source: backend/src/pantry/infrastructure/document/document-persistence.module.ts:L10-L27
 */
@Module({
  imports: [
    // registers PantryIngridientSchemaClass/PantryIngridientSchema via MongooseModule.forFeature
    MongooseModule.forFeature([
      {
        name: PantryIngridientSchemaClass.name,
        schema: PantryIngridientSchema,
      },
    ]),
  ],
  providers: [
    // binds DI token PantryRepository -> useClass PantryIngridientDocumentRepository
    {
      provide: PantryRepository,
      useClass: PantryIngridientDocumentRepository,
    },
  ],
  // exports PantryRepository for consumer modules
  exports: [PantryRepository],
})
export class DocumentPantryPersistenceModule {}
