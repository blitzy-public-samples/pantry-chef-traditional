import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { PantrySeedService } from './pantry-seed.service';
// NOTE: 'PantryIngridientSchemaClass' and 'PantryIngridientSchema' spellings
// NOTE: preserved verbatim. Do not rename.
import {
  PantryIngridientSchema,
  PantryIngridientSchemaClass,
} from 'src/pantry/infrastructure/document/entities/pantryIngridient.schema';

/**
 * NestJS module registering PantrySeedService.
 *
 * Imports MongooseModule.forFeature([{
 *   name: PantryIngridientSchemaClass.name (spelling preserved verbatim),
 *   schema: PantryIngridientSchema (spelling preserved verbatim),
 * }]) to bind the PantryIngridients collection model.
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
  providers: [PantrySeedService],
  exports: [PantrySeedService],
})
export class PantrySeedModule {}
