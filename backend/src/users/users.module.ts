import { Module } from '@nestjs/common';

import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { DocumentUserPersistenceModule } from './infrastructure/document/document-persistence.module';

/**
 * NestJS feature module that composes the Users bounded context.
 *
 * Imports `DocumentUserPersistenceModule`, which provides the `UserRepository`
 * binding; registers `UsersController` (REST surface) and `UsersService`
 * (application logic); and re-exports `UsersService` together with
 * `DocumentUserPersistenceModule` so that other modules consume users
 * functionality through this feature boundary rather than reaching into the
 * persistence layer directly.
 *
 * Wired into the application root module. Source: backend/src/app.module.ts:L30
 *
 * Consumed by `AuthModule`, which imports this module for the registration and
 * login flows (Source: backend/src/auth/auth.module.ts:L14); the re-exported
 * `UsersService` is injected by `AuthService`
 * (Source: backend/src/auth/auth.service.ts:L28).
 */
@Module({
  // Persistence layer: binds the abstract `UserRepository` to its Mongoose
  // implementation and is re-exported below.
  imports: [DocumentUserPersistenceModule],
  // HTTP layer: exposes the versioned `/v1/users` REST routes.
  controllers: [UsersController],
  // Application layer: user CRUD, bcrypt hashing, preferences and favorites.
  providers: [UsersService],
  // Re-exported so AuthModule/SessionModule consume users via this boundary.
  exports: [UsersService, DocumentUserPersistenceModule],
})
export class UsersModule {}
