import { Module } from '@nestjs/common';
import { DocumentSessionPersistenceModule } from './infrastructure/document/document-persistence.module';
import { SessionService } from './session.service';

/**
 * NestJS feature module that composes the Session bounded context.
 *
 * Acts as the composition root that wires the session feature into the
 * application's dependency-injection graph; it performs declarative module
 * assembly only and carries no imperative runtime behavior of its own.
 *
 * Imports `DocumentSessionPersistenceModule`, which provides the
 * MongoDB/Mongoose-backed `SessionRepository` binding; registers
 * `SessionService` as a provider; and re-exports both `SessionService` and
 * `DocumentSessionPersistenceModule` so that consumers such as `AuthModule`
 * and `AuthService` can inject session capabilities for JWT refresh-token
 * rotation.
 *
 * Wired into the application root module. Source: backend/src/app.module.ts:L29
 *
 * Consumed by `AuthModule`, which imports this module
 * (Source: backend/src/auth/auth.module.ts:L15); the re-exported
 * `SessionService` is injected by `AuthService` for refresh-token rotation.
 */
@Module({
  // Persistence layer: brings in the document persistence module that binds the
  // abstract `SessionRepository` to its `SessionDocumentRepository` implementation.
  imports: [DocumentSessionPersistenceModule],
  // Application layer: registers the session application service in this DI scope.
  providers: [SessionService],
  // Re-exported so consumers such as `AuthModule` can inject session capabilities.
  exports: [SessionService, DocumentSessionPersistenceModule],
})
export class SessionModule {}
