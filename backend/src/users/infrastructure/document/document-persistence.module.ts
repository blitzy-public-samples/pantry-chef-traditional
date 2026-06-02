import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { UserSchema, UserSchemaClass } from './entities/user.schema';
import { UserRepository } from '../user.repository';
import { UsersDocumentRepository } from './repositories/user.repository';

/**
 * Persistence composition root for the users document (MongoDB) layer.
 *
 * `DocumentUserPersistenceModule` wires the Mongoose-backed user persistence so the
 * surrounding feature module depends on an abstraction rather than a concrete adapter.
 * It performs three composition responsibilities:
 *
 * - Registers the Mongoose feature model for `UserSchemaClass` via
 *   `MongooseModule.forFeature`, binding the model name `UserSchemaClass.name` to the
 *   generated `UserSchema`.
 * - Binds the abstract `UserRepository` token to the concrete `UsersDocumentRepository`
 *   implementation via `{ provide: UserRepository, useClass: UsersDocumentRepository }`.
 * - Exports `UserRepository` so the feature module (`UsersModule`) and downstream
 *   consumers inject the abstraction instead of the implementation.
 *
 * Imported and re-exported by `UsersModule`, the users feature module.
 * Source: backend/src/users/users.module.ts:L27,L33
 *
 */
@Module({
  // imports: register the Mongoose UserSchemaClass model for this scope
  imports: [
    MongooseModule.forFeature([
      { name: UserSchemaClass.name, schema: UserSchema },
    ]),
  ],
  // providers: bind abstract UserRepository -> concrete UsersDocumentRepository
  providers: [
    {
      provide: UserRepository,
      useClass: UsersDocumentRepository,
    },
  ],
  // exports: re-export the UserRepository contract for consumers
  exports: [UserRepository],
})
export class DocumentUserPersistenceModule {}
