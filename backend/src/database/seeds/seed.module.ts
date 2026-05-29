import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import appConfig from 'src/config/app.config';
import databaseConfig from 'src/database/config/database.config';
import { MongooseModule } from '@nestjs/mongoose';
import { MongooseConfigService } from 'src/database/mongoose-config.service';
import { UserSeedModule } from './user/user-seed.module';
// NOTE: 'IngdientSeedModule' (MISSING the 'ri') is preserved verbatim — this is a DIFFERENT
// NOTE: typo than 'IngridientSeedService' (which retains 'ri'). Both spellings are intentional
// NOTE: and must not be renamed.
import { IngdientSeedModule } from './ingridient/ingridient-seed.module';
import { RecipeSeedModule } from './recipe/recipe-seed.module';
import { PantrySeedModule } from './pantry/pantry-seed.module';

/**
 * Aggregate module wiring all four seed sub-modules consumed by run-seed.ts.
 *
 * Imports: PantrySeedModule, RecipeSeedModule, IngdientSeedModule (spelling
 * preserved verbatim — note: differs from IngridientSeedService), UserSeedModule.
 *
 * Also imports ConfigModule.forRoot with databaseConfig + appConfig, and
 * MongooseModule.forRootAsync({ useClass: MongooseConfigService }) which
 * mirrors the parent application's app.module.ts:L25-L27 wiring.
 *
 * Used exclusively by the standalone seed runner; see
 * backend/src/database/seeds/run-seed.ts.
 */
@Module({
  imports: [
    PantrySeedModule,
    RecipeSeedModule,
    IngdientSeedModule,
    UserSeedModule,
    ConfigModule.forRoot({
      isGlobal: true,
      load: [databaseConfig, appConfig],
      envFilePath: ['.env'],
    }),
    MongooseModule.forRootAsync({
      useClass: MongooseConfigService,
    }),
  ],
})
export class SeedModule {}
