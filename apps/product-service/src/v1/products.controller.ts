import { Controller, Get, Param, Post, Body } from '@nestjs/common';

@Controller({ path: 'products', version: '1' })
export class ProductsV1Controller {
  private products = [
    { id: 1, name: 'Wireless Headphones', price: 79.99, category: 'Electronics' },
    { id: 2, name: 'Running Shoes', price: 129.99, category: 'Sports' },
    { id: 3, name: 'Coffee Maker', price: 49.99, category: 'Kitchen' },
    { id: 4, name: 'Backpack', price: 59.99, category: 'Accessories' },
  ];

  @Get()
  findAll() {
    return {
      message: 'Product catalog',
      version: 'v1',
      items: this.products,
    };
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    const product = this.products.find((p) => p.id === +id);
    if (!product) {
      return { error: 'Product not found', id };
    }
    return { version: 'v1', product };
  }

  @Post()
  create(@Body() body: { name: string; price: number; category: string }) {
    const newProduct = {
      id: this.products.length + 1,
      name: body.name,
      price: body.price,
      category: body.category,
    };
    this.products.push(newProduct);
    return { message: 'Product created', version: 'v1', product: newProduct };
  }
}
