import { Module } from '@nestjs/common';
import { AiService } from './ai.service';
import { AiController } from './ai.controller';
// NOTE: 'IngridientModule' spelling is preserved verbatim across the backend codebase.
// Do not rename.
import { IngridientModule } from 'src/ingridient/ingridient.module';

/**
 * NestJS module wiring the AI vision feature.
 *
 * Imports `IngridientModule` (spelling preserved verbatim) so that
 * `AiService` can call `IngridientService.findManyWithPagination` to
 * resolve detected labels to domain Ingridient records.
 */
@Module({
  imports: [IngridientModule],
  providers: [AiService],
  controllers: [AiController],
})
export class AiModule {}
