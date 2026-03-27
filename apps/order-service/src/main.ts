import { NestFactory } from '@nestjs/core';
import { VersioningType } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.setGlobalPrefix('api', {
    exclude: ['health'],
  });

  app.enableVersioning({
    type: VersioningType.URI,
  });

  await app.listen(3002);
  console.log('Order Service listening on port 3002');
}

bootstrap();
