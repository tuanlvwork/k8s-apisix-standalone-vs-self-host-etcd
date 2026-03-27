import { Module } from '@nestjs/common';
import { HealthController } from './health.controller';
import { ProductsV1Controller } from './v1/products.controller';

@Module({
  controllers: [HealthController, ProductsV1Controller],
})
export class AppModule {}
