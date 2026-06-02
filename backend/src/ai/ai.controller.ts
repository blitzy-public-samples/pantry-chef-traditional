import {
  BadRequestException,
  Controller,
  Post,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { memoryStorage } from 'multer';
import { AiService } from './ai.service';

// SECURITY NOTE: This endpoint has NO JWT guard and is therefore unauthenticated,
// unlike every other resource controller (auth/users/pantry/recipe/ingridient),
// which apply `@UseGuards(AuthGuard('jwt'))`. Documented as-is; do NOT add a guard.
// Source: backend/src/ai/ai.controller.ts:L12-L16
/**
 * REST controller exposing the AI image-to-ingredient recognition endpoint.
 *
 * The controller base path is `ai`, mounted under the global `api` prefix, so
 * the served route is `POST /api/ai/vision`. No version segment is declared on
 * the controller, so there is NO `/v1/` segment in the path.
 * Source: backend/src/main.ts:L14-L15
 *
 * Recognition is delegated to `AiService.detectIngredientsFromBuffer`, which
 * performs Google Cloud Vision label detection and dictionary matching.
 */
@Controller('ai')
export class AiController {
  constructor(private readonly aiService: AiService) {}

  /**
   * Handles a multipart image upload and returns the matched ingredient.
   *
   * @param file - The uploaded image, an `Express.Multer.File` captured from the
   *   multipart field named `image` via `FileInterceptor('image')` with in-memory
   *   storage (`memoryStorage()`) and a 10 MB size limit.
   * @returns The matched ingredient object
   *   `{ id, name, category, quantity, unit, confidence }`, or an empty object `{}`
   *   when Google Vision is disabled or no label matches (the service degrades
   *   gracefully). Source: backend/src/ai/ai.service.ts:L114-L126
   * @throws BadRequestException With message `'Image empty'` when no file is
   *   provided. Source: backend/src/ai/ai.controller.ts:L33-L34
   */
  @Post('vision')
  @UseInterceptors(
    FileInterceptor('image', {
      storage: memoryStorage(),
      // KNOWN ISSUE: The MIME-type fileFilter below is commented out, so non-image
      // uploads are NOT rejected at the interceptor level.
      // Source: backend/src/ai/ai.controller.ts:L20-L28
      // fileFilter: (req, file, callback) => {
      //   if (!file.mimetype.match(/\/(jpg|jpeg|png)$/)) {
      //     return callback(
      //       new BadRequestException('Only JPG, JPEG and PNG allow!'),
      //       false,
      //     );
      //   }
      //   callback(null, true);
      // },
      // Caps the upload size at 10 MB (10 * 1024 * 1024 bytes).
      limits: { fileSize: 10 * 1024 * 1024 },
    }),
  )
  async processImageRecognize(@UploadedFile() file: Express.Multer.File) {
    // Guard: reject an absent upload with HTTP 400 (BadRequestException).
    if (!file) {
      throw new BadRequestException('Image empty');
    }

    // Read the raw bytes held in memory by memoryStorage().
    const buffer = file.buffer;

    // Delegate recognition to the AI service (Vision label detection + matching).
    const ingredients =
      await this.aiService.detectIngredientsFromBuffer(buffer);

    // Return the matched ingredient object (or {} when nothing matched).
    return ingredients;
  }
}
