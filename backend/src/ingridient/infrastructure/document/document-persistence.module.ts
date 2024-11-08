import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import {
  IngridientSchema,
  IngridientSchemaClass,
} from './entities/ingridient.schema';
import { IngridientRepository } from '../ingridient.repository';
import { IngridientDocumentRepository } from './repositories/ingridient.repository';

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
