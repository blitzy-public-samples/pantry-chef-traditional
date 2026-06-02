import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import {
  IngridientSchema,
  IngridientSchemaClass,
} from './entities/ingridient.schema';
import { IngridientRepository } from '../ingridient.repository';
import { IngridientDocumentRepository } from './repositories/ingridient.repository';

/**
 * Wires the MongoDB/Mongoose persistence stack for the ingredient feature.
 *
 * Registers the `IngridientSchemaClass` model via `MongooseModule.forFeature`,
 * binds the abstract `IngridientRepository` token to the concrete
 * `IngridientDocumentRepository` implementation, and exports the repository
 * token so consuming modules depend only on the abstraction.
 *
 * The misspelling `Ingridient` is an intentional, preserved identifier.
 */
@Module({
  imports: [
    // Register the Ingridient Mongoose model for this feature.
    MongooseModule.forFeature([
      { name: IngridientSchemaClass.name, schema: IngridientSchema },
    ]),
  ],
  providers: [
    // Bind the abstract repository token to its document implementation.
    {
      provide: IngridientRepository,
      useClass: IngridientDocumentRepository,
    },
  ],
  // Export the abstract token so other modules inject the contract, not impl.
  exports: [IngridientRepository],
})
export class DocumentIngridientPersistenceModule {}
