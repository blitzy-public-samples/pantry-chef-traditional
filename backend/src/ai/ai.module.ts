import { Module } from '@nestjs/common';
import { AiService } from './ai.service';
import { AiController } from './ai.controller';
import { IngridientModule } from 'src/ingridient/ingridient.module';

/**
 * NestJS feature module (composition root) for the AI image-to-ingredient
 * recognition feature.
 *
 * Imports `IngridientModule` so `AiService` can resolve labels recognized by
 * Google Cloud Vision to persisted ingredient records via `IngridientService`.
 * Source: backend/src/ai/ai.module.ts:L7
 *
 * Provides `AiService` (the recognition logic) and registers `AiController`
 * (the REST surface exposing the `POST ai/vision` image-upload endpoint).
 *
 * Wired into the root `AppModule`. Source: backend/src/app.module.ts:L34
 *
 * Note: the `Ingridient` spelling is an intentional, stable identifier used
 * throughout the backend and is documented as-is (never renamed).
 */
@Module({
  // Reuses IngridientService (from IngridientModule) for ingredient lookups.
  imports: [IngridientModule],
  providers: [AiService],
  controllers: [AiController],
})
export class AiModule {}
