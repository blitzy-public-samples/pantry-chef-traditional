import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { PantrySeedService } from './pantry-seed.service';
import {
  PantryIngridientSchema,
  PantryIngridientSchemaClass,
} from 'src/pantry/infrastructure/document/entities/pantryIngridient.schema';

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
