import { NestFactory } from '@nestjs/core';
import { useContainer } from 'class-validator';
import { AppModule } from './app.module';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import { AllConfigType } from './config/config.type';
import validationOptions from './utils/validation-options';
import { ValidationPipe, VersioningType } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { cors: true });
  useContainer(app.select(AppModule), { fallbackOnErrors: true });
  const configService = app.get(ConfigService<AllConfigType>);
  app.setGlobalPrefix(
    configService.getOrThrow('app.apiPrefix', { infer: true }),
    {
      exclude: ['/'],
    },
  );

  // Enable URI versioning so the controller-level `version: '1'` declarations
  // (RecipeController, AuthController, PantryController, UsersController,
  // IngridientController) take effect and the routes resolve under `/api/v1/*`
  // as the AAP contract and the e2e suite already assume (e.g.
  // `/api/v1/recipe/suggestions`, `/api/v1/recipe/matches`,
  // `/api/v1/auth/email/login`). `defaultVersion: '1'` keeps the version-less
  // controllers (AiController, AppController root health check) reachable under
  // v1 too, so no module is left stranded.
  // [QA FINAL Issue #1 / AAP §0.1.1.1 / Rule R2 — was missing; routes had been
  // served unversioned at `/api/*` despite every controller declaring v1.]
  app.enableVersioning({
    type: VersioningType.URI,
    defaultVersion: '1',
  });

  app.useGlobalPipes(new ValidationPipe(validationOptions));

  const options = new DocumentBuilder()
    .setTitle('API')
    .setDescription('API docs')
    .setVersion('1.0')
    .addBearerAuth()
    .build();

  const document = SwaggerModule.createDocument(app, options);
  SwaggerModule.setup('docs', app, document);

  await app.listen(configService.getOrThrow('app.port', { infer: true }));
}
bootstrap();
