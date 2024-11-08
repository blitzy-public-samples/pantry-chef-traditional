import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import {
  PantryIngridientSchema,
  PantryIngridientSchemaClass,
} from './entities/pantryIngridient.schema';
import { PantryRepository } from '../pantry.repository';
import { PantryIngridientDocumentRepository } from './repositories/pantryIngridient.repository';

@Module({
  imports: [
    MongooseModule.forFeature([
      {
        name: PantryIngridientSchemaClass.name,
        schema: PantryIngridientSchema,
      },
    ]),
  ],
  providers: [
    {
      provide: PantryRepository,
      useClass: PantryIngridientDocumentRepository,
    },
  ],
  exports: [PantryRepository],
})
export class DocumentPantryPersistenceModule {}
