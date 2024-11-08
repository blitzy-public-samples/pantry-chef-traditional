import { Module } from '@nestjs/common';
import { PantryService } from './pantry.service';
import { PantryController } from './pantry.controller';
import { DocumentPantryPersistenceModule } from './infrastructure/document/document-persistence.module';

@Module({
  imports: [DocumentPantryPersistenceModule],
  providers: [PantryService],
  controllers: [PantryController],
  exports: [DocumentPantryPersistenceModule, PantryService],
})
export class PantryModule {}
