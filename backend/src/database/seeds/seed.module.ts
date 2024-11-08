import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import appConfig from 'src/config/app.config';
import databaseConfig from 'src/database/config/database.config';
import { MongooseModule } from '@nestjs/mongoose';
import { MongooseConfigService } from 'src/database/mongoose-config.service';
import { UserSeedModule } from './user/user-seed.module';
import { IngdientSeedModule } from './ingridient/ingridient-seed.module';
import { RecipeSeedModule } from './recipe/recipe-seed.module';
import { PantrySeedModule } from './pantry/pantry-seed.module';

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
