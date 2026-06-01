import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { SessionModule } from './session/session.module';
import { UsersModule } from './users/users.module';
import databaseConfig from './database/config/database.config';
import appConfig from './config/app.config';
import authConfig from './auth/config/auth.config';
import { MongooseConfigService } from './database/mongoose-config.service';
import { IngridientModule } from './ingridient/ingridient.module';
import { PantryModule } from './pantry/pantry.module';
import { RecipeModule } from './recipe/recipe.module';
import { AiModule } from './ai/ai.module';

/**
 * Root application module for the PantryChef NestJS backend.
 *
 * Assembled by `NestFactory` in `main.ts`, this module composes the
 * application's cross-cutting infrastructure together with every feature
 * module that exposes the REST API:
 * - Registers `ConfigModule` globally so typed configuration (database, auth,
 *   and app settings) is injectable everywhere without re-importing it.
 * - Initializes the MongoDB/Mongoose connection asynchronously by delegating
 *   option construction to `MongooseConfigService`.
 * - Aggregates the feature modules: Auth, Session, Users, Ingridient, Pantry,
 *   Recipe, and Ai.
 *
 * Source: backend/src/app.module.ts:L18-L35
 */
@Module({
  imports: [
    // Global configuration: loads databaseConfig, authConfig and appConfig
    // from .env. `isGlobal: true` exposes the typed config across the app.
    ConfigModule.forRoot({
      isGlobal: true,
      load: [databaseConfig, authConfig, appConfig],
      envFilePath: ['.env'],
    }),
    // Asynchronous Mongoose connection; connection options are built by
    // MongooseConfigService. Source: app.module.ts:L25-L27
    MongooseModule.forRootAsync({
      useClass: MongooseConfigService,
    }),
    // Feature modules: each encapsulates one domain area of the API.
    // Note: AiModule imports IngridientModule.
    // Source: backend/src/ai/ai.module.ts:L7
    AuthModule,
    SessionModule,
    UsersModule,
    IngridientModule,
    PantryModule,
    RecipeModule,
    AiModule,
  ],
  // Root example controller (Hello World landing route).
  controllers: [AppController],
  // Root example service backing AppController.
  providers: [AppService],
})
export class AppModule {}
