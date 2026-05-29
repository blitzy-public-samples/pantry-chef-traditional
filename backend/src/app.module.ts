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
    // SECURITY(SEC-A1): Rate-limiting infrastructure ONLY. ThrottlerGuard is intentionally NOT bound globally
    // (no APP_GUARD), so throttling does NOT apply to every route. Enforcement is scoped exclusively to the
    // login/register credential endpoints via @UseGuards(ThrottlerGuard) + @Throttle(...) on those handlers.
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
  providers: [AppService],
})
export class AppModule {}
