import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { UserSchema, UserSchemaClass } from './entities/user.schema';
import { UserRepository } from '../user.repository';
import { UsersDocumentRepository } from './repositories/user.repository';

/**
 * NestJS persistence module wiring the Users aggregate to MongoDB.
 *
 * Registers `UserSchemaClass` with `MongooseModule.forFeature([...])`
 * (which makes the Mongoose `Model<UserSchemaClass>` available to
 * providers in this module scope) and binds the abstract
 * `UserRepository` token to the concrete Mongoose-backed
 * `UsersDocumentRepository` via `useClass`. Exports `UserRepository`
 * so that `UsersModule` can re-export it to downstream consumers
 * (notably `AuthModule` for register/login/me/refresh flows and,
 * transitively, `RecipeModule` for the recipe matching pipeline).
 *
 * This is the only place where the abstract contract is bound to a
 * concrete implementation in the Users feature — alternative
 * persistence backends would be wired through a sibling module that
 * exports the same `UserRepository` token.
 */
@Module({
  imports: [
    MongooseModule.forFeature([
      { name: UserSchemaClass.name, schema: UserSchema },
    ]),
  ],
  providers: [
    {
      provide: UserRepository,
      useClass: UsersDocumentRepository,
    },
  ],
  exports: [UserRepository],
})
export class DocumentUserPersistenceModule {}
