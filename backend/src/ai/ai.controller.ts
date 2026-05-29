import {
  BadRequestException,
  Controller,
  HttpCode,
  HttpStatus,
  Post,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { memoryStorage } from 'multer';
import { AuthGuard } from '@nestjs/passport';
import { AiService } from './ai.service';

@Controller('ai')
export class AiController {
  constructor(private readonly aiService: AiService) {}

  @Post('vision')
  // AI vision success contract is HTTP 200 (AAP §0.8.1 — SEC-A3 expected outcome), overriding the
  // NestJS default of 201 for POST handlers so the graceful-degradation empty body returns 200.
  @HttpCode(HttpStatus.OK)
  // SECURITY(SEC-A3): Require valid JWT to prevent unauthenticated Google Cloud Vision quota abuse
  @UseGuards(AuthGuard('jwt'))
  @UseInterceptors(
    FileInterceptor('image', {
      storage: memoryStorage(),
      // SECURITY(SEC-A4): Restrict uploads to image MIME types — CWE-434 mitigation
      fileFilter: (req, file, callback) => {
        if (!file.mimetype.match(/\/(jpg|jpeg|png)$/)) {
          return callback(
            new BadRequestException('Only JPG, JPEG and PNG allow!'),
            false,
          );
        }
        callback(null, true);
      },
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
