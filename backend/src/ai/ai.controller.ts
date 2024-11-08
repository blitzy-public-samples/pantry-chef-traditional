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

@Controller('ai')
export class AiController {
  constructor(private readonly aiService: AiService) {}

  @Post('vision')
  @UseInterceptors(
    FileInterceptor('image', {
      storage: memoryStorage(),
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
