import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { SessionSchema, SessionSchemaClass } from './entities/session.schema';
import { SessionRepository } from '../session.repository';
import { SessionDocumentRepository } from './repositories/session.repository';

/**
 * Document (MongoDB / Mongoose) persistence module for the session feature.
 *
 * `DocumentSessionPersistenceModule` wires the Mongoose-backed session persistence so the
 * surrounding feature module depends on an abstraction rather than the storage technology.
 * It performs declarative module wiring only and carries no imperative runtime behavior.
 * It fulfills three composition responsibilities:
 *
 * - Registers the Mongoose model for `SessionSchemaClass` via `MongooseModule.forFeature`,
 *   binding the model name `SessionSchemaClass.name` to the generated `SessionSchema`.
 *   Source: backend/src/session/infrastructure/document/document-persistence.module.ts:L9-L11
 * - Binds the abstract `SessionRepository` token to the concrete `SessionDocumentRepository`
 *   via `{ provide: SessionRepository, useClass: SessionDocumentRepository }`, so the
 *   application/auth layer depends on the abstraction, not the storage technology.
 *   Source: backend/src/session/infrastructure/document/document-persistence.module.ts:L14-L17
 * - Exports `SessionRepository` so consumers (e.g. `SessionModule` -> `AuthModule`) inject
 *   the abstraction rather than the implementation.
 *   Source: backend/src/session/infrastructure/document/document-persistence.module.ts:L19
 *
 * Re-exported by `SessionModule`, the session feature module.
 * Source: backend/src/session/session.module.ts:L6,L8
 *
 * Source: backend/src/session/infrastructure/document/document-persistence.module.ts:L7-L21
 */
@Module({
  // imports: registers the SessionSchemaClass Mongoose model for this feature
  imports: [
    MongooseModule.forFeature([
      { name: SessionSchemaClass.name, schema: SessionSchema },
    ]),
  ],
  // providers: bind abstract SessionRepository -> concrete SessionDocumentRepository
  providers: [
    {
      provide: SessionRepository,
      useClass: SessionDocumentRepository,
    },
  ],
  // exports: re-export the SessionRepository contract for downstream consumers
  exports: [SessionRepository],
})
export class DocumentSessionPersistenceModule {}
