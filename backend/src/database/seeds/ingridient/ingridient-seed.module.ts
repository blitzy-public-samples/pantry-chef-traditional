import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
// NOTE: This file contains TWO different preserved spellings — 'IngridientSchemaClass',
// NOTE: 'IngridientSchema', 'IngridientSeedService' (all WITH 'ri') AND the module class
// NOTE: name 'IngdientSeedModule' at L21 (MISSING 'ri'). Both are intentional. Do not rename.
import { IngridientSeedService } from './ingridient-seed.service';
import {
  IngridientSchema,
  IngridientSchemaClass,
} from 'src/ingridient/infrastructure/document/entities/ingridient.schema';

/**
 * NestJS module registering IngridientSeedService (spelling preserved verbatim).
 *
 * Class name 'IngdientSeedModule' is preserved verbatim (note: MISSING the
 * 'ri' — distinct from IngridientSeedService inside the same feature folder).
 *
 * Imports MongooseModule.forFeature([{ name: IngridientSchemaClass.name,
 * schema: IngridientSchema }]) to bind the Ingridients collection model.
 */
@Module({
  imports: [
    MongooseModule.forFeature([
      {
        name: IngridientSchemaClass.name,
        schema: IngridientSchema,
      },
    ]),
  ],
  providers: [IngridientSeedService],
  exports: [IngridientSeedService],
})
export class IngdientSeedModule {}
