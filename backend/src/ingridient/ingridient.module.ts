import { Module } from '@nestjs/common';
import { IngridientService } from './ingridient.service';
import { IngridientController } from './ingridient.controller';
import { DocumentIngridientPersistenceModule } from './infrastructure/document/document-persistence.module';

@Module({
  imports: [DocumentIngridientPersistenceModule],
  providers: [IngridientService],
  controllers: [IngridientController],
  exports: [IngridientService, DocumentIngridientPersistenceModule],
})
export class IngridientModule {}
