import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { IngridientSeedService } from './ingridient-seed.service';
import {
  IngridientSchema,
  IngridientSchemaClass,
} from 'src/ingridient/infrastructure/document/entities/ingridient.schema';

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
