import { Controller, Get, Param, Post, Body } from '@nestjs/common';

@Controller({ path: 'orders', version: '1' })
export class OrdersV1Controller {
  private orders = [
    { id: 1, productId: 1, quantity: 2, status: 'delivered', total: 159.98 },
    { id: 2, productId: 3, quantity: 1, status: 'processing', total: 49.99 },
    { id: 3, productId: 2, quantity: 1, status: 'shipped', total: 129.99 },
  ];

  @Get()
  findAll() {
    return {
      message: 'Order list',
      version: 'v1',
      items: this.orders,
    };
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    const order = this.orders.find((o) => o.id === +id);
    if (!order) {
      return { error: 'Order not found', id };
    }
    return { version: 'v1', order };
  }

  @Post()
  create(@Body() body: { productId: number; quantity: number }) {
    const newOrder = {
      id: this.orders.length + 1,
      productId: body.productId,
      quantity: body.quantity,
      status: 'pending',
      total: 0,
    };
    this.orders.push(newOrder);
    return { message: 'Order created', version: 'v1', order: newOrder };
  }
}
