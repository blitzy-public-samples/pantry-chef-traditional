import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import {
  UserSchema,
  UserSchemaClass,
} from 'src/users/infrastructure/document/entities/user.schema';
import { UserSeedService } from './user-seed.service';

/**
 * NestJS module registering UserSeedService.
 *
 * Imports MongooseModule.forFeature([{ name: UserSchemaClass.name,
 * schema: UserSchema }]) to bind the Users collection model for injection
 * into UserSeedService.
 */
@Module({
  imports: [
    MongooseModule.forFeature([
      {
        name: UserSchemaClass.name,
        schema: UserSchema,
      },
    ]),
  ],
  providers: [UserSeedService],
  exports: [UserSeedService],
})
export class UserSeedModule {}
