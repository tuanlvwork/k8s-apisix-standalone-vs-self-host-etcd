import { NestFactory } from '@nestjs/core';
import { VersioningType } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Global prefix for versioned business APIs only
  // Health endpoint is excluded via `exclude` in controller
  app.setGlobalPrefix('api', {
    exclude: ['health'],
  });

  app.enableVersioning({
    type: VersioningType.URI,
  });

  await app.listen(3001);
  console.log('Product Service listening on port 3001');
}

bootstrap();
