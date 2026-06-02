import { NestFactory } from '@nestjs/core';
import { useContainer } from 'class-validator';
import { AppModule } from './app.module';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import { AllConfigType } from './config/config.type';
import validationOptions from './utils/validation-options';
import { ValidationPipe } from '@nestjs/common';

/**
 * Application entrypoint that bootstraps the NestJS HTTP server.
 *
 * Creates the Nest application from {@link AppModule}, wires class-validator into
 * the DI container, applies the global route prefix and the global ValidationPipe,
 * builds and mounts the Swagger/OpenAPI UI, then starts the HTTP listener.
 *
 *
 * @returns A promise that resolves once the server is listening on `app.port`.
 */
async function bootstrap() {
  // Create the Nest app with CORS enabled for all origins.
  const app = await NestFactory.create(AppModule, { cors: true });
  // Enable class-validator to resolve providers from the Nest DI container.
  useContainer(app.select(AppModule), { fallbackOnErrors: true });
  const configService = app.get(ConfigService<AllConfigType>);
  // Apply the global route prefix from config (value 'api'); exclude the root '/'.
  // REST routes are therefore served under the 'api' prefix, e.g. /api/recipe.
  // KNOWN ISSUE: controllers declare version: '1' but enableVersioning() is never
  // called, so served paths contain no /v1/ segment (e.g. /api/recipe, not /api/v1).
  app.setGlobalPrefix(
    configService.getOrThrow('app.apiPrefix', { infer: true }),
    {
      exclude: ['/'],
    },
  );

  // Register the global ValidationPipe (whitelist/transform via validationOptions).
  app.useGlobalPipes(new ValidationPipe(validationOptions));

  // Build the OpenAPI/Swagger document (title 'API', bearer auth).
  const options = new DocumentBuilder()
    .setTitle('API')
    .setDescription('API docs')
    .setVersion('1.0')
    .addBearerAuth()
    .build();

  const document = SwaggerModule.createDocument(app, options);
  // Mount Swagger UI at /docs.
  // Note: Swagger is at /docs, NOT /api/docs; the global prefix is not applied here.
  SwaggerModule.setup('docs', app, document);

  // Start the HTTP server on the configured app.port (3000).
  await app.listen(configService.getOrThrow('app.port', { infer: true }));
}
bootstrap();
