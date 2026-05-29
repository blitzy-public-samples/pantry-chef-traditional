import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';
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

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [databaseConfig, authConfig, appConfig],
      envFilePath: ['.env'],
    }),
    MongooseModule.forRootAsync({
      useClass: MongooseConfigService,
    }),
    // SECURITY(SEC-A1): Rate-limiting infrastructure. This default throttler config is driven by the
    // AUTH_THROTTLE_TTL / AUTH_THROTTLE_LIMIT env vars (operator-tunable; defaults 60000ms / 10 requests).
    // ThrottlerGuard is bound globally via APP_GUARD (see providers below), so this default (10 requests
    // per 60s) applies to every route. The credential endpoints (login/register) carry a stricter
    // per-route @Throttle({ default: { limit: 5, ttl: 60000 } }) override in auth.controller.ts.
    ThrottlerModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (cfg: ConfigService) => [
        {
          ttl: +cfg.get('AUTH_THROTTLE_TTL') || 60000,
          limit: +cfg.get('AUTH_THROTTLE_LIMIT') || 10,
        },
      ],
    }),
    AuthModule,
    SessionModule,
    UsersModule,
    IngridientModule,
    PantryModule,
    RecipeModule,
    AiModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    // SECURITY(SEC-A1): Globally bind ThrottlerGuard so the module default (10/60s) applies to ALL
    // routes and the per-route @Throttle override on login/register (5/60s) takes effect.
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
})
export class AppModule {}
