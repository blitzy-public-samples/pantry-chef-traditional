import { Module } from '@nestjs/common';

import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { DocumentUserPersistenceModule } from './infrastructure/document/document-persistence.module';

/**
 * NestJS feature module wiring the Users bounded context.
 *
 * Imports {@link DocumentUserPersistenceModule} (which binds the
 * abstract {@link UserRepository} token to the Mongoose-backed
 * {@link UsersDocumentRepository}). Registers {@link UsersController}
 * and {@link UsersService}, and re-exports both the service and the
 * persistence module so consumers can inject `UsersService` or the
 * raw `UserRepository` token.
 *
 * Consumed by `AuthModule` (for login, register, me, refresh, update,
 * logout) and by `RecipeModule` (for fetching the authenticated user's
 * embedded `Preferences` subdocument inside the recipe matching
 * pipeline). See `../../../ARCHITECTURE.md` for the full module graph.
 */
@Module({
  imports: [DocumentUserPersistenceModule],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService, DocumentUserPersistenceModule],
})
export class UsersModule {}
