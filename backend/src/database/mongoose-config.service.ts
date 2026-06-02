import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  MongooseModuleOptions,
  MongooseOptionsFactory,
} from '@nestjs/mongoose';
import { AllConfigType } from '../config/config.type';

/**
 * Supplies Mongoose connection options to NestJS from the `database` config namespace.
 *
 * Implements {@link MongooseOptionsFactory}; registered in the root module via
 * `MongooseModule.forRootAsync({ useClass: MongooseConfigService })`, so Nest calls
 * {@link MongooseConfigService.createMongooseOptions} during Mongoose initialization.
 */
@Injectable()
export class MongooseConfigService implements MongooseOptionsFactory {
  constructor(private configService: ConfigService<AllConfigType>) {}

  /**
   * Assembles the Mongoose connection options from the typed `database` config.
   *
   * @returns A {@link MongooseModuleOptions} object whose `uri`, `dbName`, `user`, and
   * `pass` are resolved from `database.url`, `database.name`, `database.username`, and
   * `database.password` respectively.
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
