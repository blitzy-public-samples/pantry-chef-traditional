import { Module } from '@nestjs/common';
import { AiService } from './ai.service';
import { AiController } from './ai.controller';
import { IngridientModule } from 'src/ingridient/ingridient.module';

@Module({
  imports: [IngridientModule],
  providers: [AiService],
  controllers: [AiController],
})
export class AiModule {}
