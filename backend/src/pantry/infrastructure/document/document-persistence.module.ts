// NOTE: 'PantryIngridientSchemaClass' / 'PantryIngridientDocumentRepository' spellings preserved verbatim. Do not rename.
import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import {
  PantryIngridientSchema,
  PantryIngridientSchemaClass,
} from './entities/pantryIngridient.schema';
import { PantryRepository } from '../pantry.repository';
import { PantryIngridientDocumentRepository } from './repositories/pantryIngridient.repository';

/**
 * NestJS persistence module wiring the abstract PantryRepository contract to
 * its Mongoose-backed implementation (PantryIngridientDocumentRepository).
 *
 * Registers the PantryIngridient schema with Mongoose via
 * MongooseModule.forFeature and provides PantryRepository (token) bound to
 * PantryIngridientDocumentRepository (class). Exports PantryRepository so
 * PantryService (and any other consumer module) can inject the abstract
 * contract without depending on the document implementation.
 *
 * Spelling preserved verbatim: PantryIngridient, PantryIngridientSchemaClass.
 */
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
