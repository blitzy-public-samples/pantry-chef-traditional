import { NestFactory } from '@nestjs/core';
import { useContainer } from 'class-validator';
import { AppModule } from './app.module';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import { AllConfigType } from './config/config.type';
import validationOptions from './utils/validation-options';
import { ValidationPipe } from '@nestjs/common';
import helmet from 'helmet';

async function bootstrap() {
  const app = await NestFactory.create(AppModule); // SECURITY(SEC-C1): CORS configured explicitly below
  useContainer(app.select(AppModule), { fallbackOnErrors: true });
  const configService = app.get(ConfigService<AllConfigType>);
  app.setGlobalPrefix(
    configService.getOrThrow('app.apiPrefix', { infer: true }),
    {
      exclude: ['/'],
    },
  );

  app.useGlobalPipes(new ValidationPipe(validationOptions));

  // TODO(security): If Swagger UI at /docs breaks under Helmet's default CSP, scope a narrow CSP exception for /docs only — DO NOT disable Helmet globally.
  // SECURITY(SEC-A2): Enables CSP, HSTS, X-Frame-Options, X-Content-Type-Options, Referrer-Policy, and 8 more headers (subsumes SEC-C2)
  app.use(helmet());

  // SECURITY(SEC-C1): Explicit CORS allowlist — empty default falls CLOSED (no cross-origin allowed when ALLOWED_ORIGINS unset)
  app.enableCors({ origin: process.env.ALLOWED_ORIGINS?.split(',') ?? [] });

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
