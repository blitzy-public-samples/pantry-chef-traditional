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
   * Receive a multipart image upload and return one recognized Ingridient.
   *
   * The `FileInterceptor` reads the request field `image` into memory (≤10MB).
   * Delegates to `AiService.detectIngredientsFromBuffer` for label detection
   * and ingredient resolution. Returns `null` if no label matched the
   * hardcoded ingredient dictionary.
   *
   * @param file Uploaded image file buffer (10MB limit, memoryStorage).
   * @returns Resolved Ingridient or null. Spelling 'Ingridient' preserved verbatim.
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
