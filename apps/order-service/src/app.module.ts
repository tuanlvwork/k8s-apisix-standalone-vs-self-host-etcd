import { Module } from '@nestjs/common';
import { HealthController } from './health.controller';
import { OrdersV1Controller } from './v1/orders.controller';

@Module({
  controllers: [HealthController, OrdersV1Controller],
})
export class AppModule {}
