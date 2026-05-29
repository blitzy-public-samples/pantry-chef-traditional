import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { ThrottlerModule } from '@nestjs/throttler';
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
    // SECURITY(SEC-A1): Rate-limiting INFRASTRUCTURE ONLY. ThrottlerModule provides the throttler
    // storage + named-default config (driven by AUTH_THROTTLE_TTL / AUTH_THROTTLE_LIMIT env vars;
    // defaults 60000ms / 10 requests). ThrottlerGuard is intentionally NOT bound globally here (no
    // APP_GUARD): per AAP §0.11 "Do not apply [throttling] globally" and "All other endpoints continue
    // to dispatch without throttling enforcement", and AAP §0.5.1.1 "no default throttle on un-decorated
    // routes". With @nestjs/throttler v6, a global APP_GUARD + a default throttler config rate-limits
    // EVERY route (empirically: GET / returns 429 after 10 req/60s) — that would throttle legitimate
    // non-auth traffic (e.g. multiple mobile clients behind shared/CGNAT IPs hitting the same endpoint),
    // a functional regression. Enforcement is therefore scoped per-route via @UseGuards(ThrottlerGuard)
    // + @Throttle on the login/register credential endpoints ONLY (see auth.controller.ts). This config
    // supplies the throttler those decorated routes resolve against.
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
  // SECURITY(SEC-A1): No global APP_GUARD->ThrottlerGuard binding (would throttle ALL routes, violating
  // AAP §0.11). ThrottlerGuard is attached per-route in auth.controller.ts so only login/register throttle.
  providers: [AppService],
})
export class AppModule {}
