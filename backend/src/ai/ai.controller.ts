// NOTE: 'Ingridient' spelling preserved verbatim across the backend. Do not rename.
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

// TODO(prod): No JWT guard. Add @UseGuards(AuthGuard('jwt')) before production deployment.
/**
 * Controller exposing the AI vision endpoint.
 *
 * Lives at `/api/ai/vision` (no version prefix — see README endpoint table).
 *
 * UNGUARDED: this controller has no `@UseGuards(AuthGuard('jwt'))` decorator.
 * Anonymous clients can upload 10MB images. See README § Known Limitations.
 */
@Controller('ai')
export class AiController {
  /**
   * @param aiService Performs label detection and Ingridient lookup
   *   (spelling preserved verbatim).
   */
  constructor(private readonly aiService: AiService) {}

  /**
   * Receive a multipart image upload and return the object produced by
   * `AiService.detectIngredientsFromBuffer`.
   *
   * The `FileInterceptor` reads the request field `image` into memory (≤10MB).
   * Throws `BadRequestException` when no file is provided; otherwise delegates
   * to the service and returns its result verbatim.
   *
   * @param file Uploaded image file buffer (10MB limit, memoryStorage).
   * @returns The service result: resolved `Ingridient` (spelling preserved
   *   verbatim) fields `{ id, name, category, quantity, unit, confidence }`, or
   *   `{}` when Vision is disabled or returns no labels. It does NOT return
   *   null; when no dictionary label matches, the service's unfiltered lookup
   *   returns an unrelated first Ingridient — see ai.service.ts and README
   *   § Known Limitations.
   * @throws BadRequestException when the `image` file is missing.
   */
  @Post('vision')
  @UseInterceptors(
    FileInterceptor('image', {
      storage: memoryStorage(),
      // TODO(prod): MIME-type filter commented out. Uncomment to enforce image/jpeg
      // and image/png before production.
      // fileFilter: (req, file, callback) => {
      //   if (!file.mimetype.match(/\/(jpg|jpeg|png)$/)) {
      //     return callback(
      //       new BadRequestException('Only JPG, JPEG and PNG allow!'),
      //       false,
      //     );
      //   }
      //   callback(null, true);
      // },
      limits: { fileSize: 10 * 1024 * 1024 },
    }),
  )
  async processImageRecognize(@UploadedFile() file: Express.Multer.File) {
    if (!file) {
      throw new BadRequestException('Image empty');
    }

    const buffer = file.buffer;

    const ingredients =
      await this.aiService.detectIngredientsFromBuffer(buffer);

    return ingredients;
  }
}
