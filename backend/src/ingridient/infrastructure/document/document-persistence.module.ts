import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import {
  IngridientSchema,
  IngridientSchemaClass,
} from './entities/ingridient.schema';
import { IngridientRepository } from '../ingridient.repository';
import { IngridientDocumentRepository } from './repositories/ingridient.repository';

// NOTE: 'Ingridient', 'IngridientSchemaClass', 'IngridientRepository', 'IngridientDocumentRepository' spellings preserved verbatim. Do not rename.

/**
 * NestJS module wiring the Mongoose-backed persistence implementation
 * for the Ingridient feature (spelling preserved verbatim).
 *
 * Registers the IngridientSchemaClass with `MongooseModule.forFeature(...)`
 * and binds the abstract `IngridientRepository` token to the concrete
 * `IngridientDocumentRepository` via `useClass`.
 */
@Module({
  imports: [
    MongooseModule.forFeature([
      { name: IngridientSchemaClass.name, schema: IngridientSchema },
    ]),
  ],
  providers: [
    {
      provide: IngridientRepository,
      useClass: IngridientDocumentRepository,
    },
  ],
  exports: [IngridientRepository],
})
export class DocumentIngridientPersistenceModule {}
