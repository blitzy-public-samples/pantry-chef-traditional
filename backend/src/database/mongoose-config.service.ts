import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  MongooseModuleOptions,
  MongooseOptionsFactory,
} from '@nestjs/mongoose';
import { AllConfigType } from '../config/config.type';

/**
 * Implements `MongooseOptionsFactory` for `MongooseModule.forRootAsync({ useClass })`.
 *
 * Reads database connection parameters from `AllConfigType.database` (sourced
 * from `DATABASE_*` environment variables via `ConfigService.get('database')`)
 * and returns a `MongooseModuleOptions` object consumed by Mongoose at
 * application bootstrap.
 *
 * Wired into the application graph at `backend/src/app.module.ts:L25-L27` and
 * additionally consumed by the seed module at
 * `backend/src/database/seeds/seed.module.ts` for standalone seed runs.
 *
 * See `backend/src/database/README.md` for the full database module overview.
 */
@Injectable()
export class MongooseConfigService implements MongooseOptionsFactory {
  constructor(private configService: ConfigService<AllConfigType>) {}

  /**
   * Build the `MongooseModuleOptions` consumed by `@nestjs/mongoose`.
   *
   * Maps the typed `DatabaseConfig` shape into the Mongoose-native field
   * names: `url -> uri`, `name -> dbName`, `username -> user`,
   * `password -> pass`.
   *
   * @returns A `MongooseModuleOptions` object ready for `MongooseModule.forRootAsync`.
   */
  createMongooseOptions(): MongooseModuleOptions {
    return {
      uri: this.configService.get('database').url,
      dbName: this.configService.get('database').name,
      user: this.configService.get('database').username,
      pass: this.configService.get('database').password,
    };
  }
}
