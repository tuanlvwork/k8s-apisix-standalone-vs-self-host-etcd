'use client';

import { useState, useEffect } from 'react';

interface Product {
  id: number;
  name: string;
  price: number;
  category: string;
}

interface Order {
  id: number;
  productId: number;
  quantity: number;
  status: string;
  total: number;
}

export default function StorefrontPage() {
  const [products, setProducts] = useState<Product[]>([]);
  const [orders, setOrders] = useState<Order[]>([]);
  const [productsLoading, setProductsLoading] = useState(true);
  const [ordersLoading, setOrdersLoading] = useState(true);
  const [productsError, setProductsError] = useState('');
  const [ordersError, setOrdersError] = useState('');

  useEffect(() => {
    fetch('/services/storefront/api/v1/products')
      .then((r) => r.json())
      .then((data) => { setProducts(data.items || []); setProductsLoading(false); })
      .catch((e) => { setProductsError(e.message); setProductsLoading(false); });

    fetch('/services/storefront/api/v1/orders')
      .then((r) => r.json())
      .then((data) => { setOrders(data.items || []); setOrdersLoading(false); })
      .catch((e) => { setOrdersError(e.message); setOrdersLoading(false); });
  }, []);

  return (
    <div style={{ maxWidth: 900, margin: '0 auto', padding: '2rem' }}>
      <h1 style={{ borderBottom: '2px solid #333', paddingBottom: '0.5rem' }}>
        🛍️ Storefront
      </h1>
      <p style={{ color: '#888', fontSize: '0.9rem' }}>
        Customer-facing storefront — served via APISIX at
        <code style={{ color: '#4fc3f7' }}> /services/storefront/</code>
      </p>

      {/* Products Section */}
      <section style={{ marginTop: '2rem' }}>
        <h2>📦 Products</h2>
        <p style={{ color: '#888', fontSize: '0.8rem' }}>
          API: <code>GET /services/storefront/api/v1/products</code>
          → proxied to <code>product-svc:80/api/v1/products</code>
        </p>
        {productsLoading ? (
          <p>Loading products...</p>
        ) : productsError ? (
          <p style={{ color: '#ff6b6b' }}>Error: {productsError}</p>
        ) : (
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(200px, 1fr))', gap: '1rem' }}>
            {products.map((p) => (
              <div key={p.id} style={{ background: '#1a1a2e', borderRadius: 8, padding: '1rem', border: '1px solid #333' }}>
                <h3 style={{ margin: '0 0 0.5rem', fontSize: '1rem' }}>{p.name}</h3>
                <p style={{ color: '#888', margin: '0 0 0.5rem', fontSize: '0.85rem' }}>{p.category}</p>
                <p style={{ color: '#4fc3f7', fontWeight: 'bold', margin: 0 }}>${p.price}</p>
              </div>
            ))}
          </div>
        )}
      </section>

      {/* Orders Section */}
      <section style={{ marginTop: '2rem' }}>
        <h2>🧾 My Orders</h2>
        <p style={{ color: '#888', fontSize: '0.8rem' }}>
          API: <code>GET /services/storefront/api/v1/orders</code>
          → proxied to <code>order-svc:80/api/v1/orders</code>
        </p>
        {ordersLoading ? (
          <p>Loading orders...</p>
        ) : ordersError ? (
          <p style={{ color: '#ff6b6b' }}>Error: {ordersError}</p>
        ) : (
          <table style={{ width: '100%', borderCollapse: 'collapse' }}>
            <thead>
              <tr style={{ borderBottom: '1px solid #333' }}>
                <th style={{ textAlign: 'left', padding: '0.5rem' }}>Order #</th>
                <th style={{ textAlign: 'left', padding: '0.5rem' }}>Product ID</th>
                <th style={{ textAlign: 'left', padding: '0.5rem' }}>Qty</th>
                <th style={{ textAlign: 'left', padding: '0.5rem' }}>Status</th>
                <th style={{ textAlign: 'right', padding: '0.5rem' }}>Total</th>
              </tr>
            </thead>
            <tbody>
              {orders.map((o) => (
                <tr key={o.id} style={{ borderBottom: '1px solid #222' }}>
                  <td style={{ padding: '0.5rem' }}>#{o.id}</td>
                  <td style={{ padding: '0.5rem' }}>{o.productId}</td>
                  <td style={{ padding: '0.5rem' }}>{o.quantity}</td>
                  <td style={{ padding: '0.5rem' }}>
                    <span style={{
                      padding: '2px 8px',
                      borderRadius: 4,
                      fontSize: '0.8rem',
                      background: o.status === 'delivered' ? '#1b5e20' : o.status === 'shipped' ? '#0d47a1' : '#e65100',
                    }}>
                      {o.status}
                    </span>
                  </td>
                  <td style={{ padding: '0.5rem', textAlign: 'right', color: '#4fc3f7' }}>${o.total}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>
    </div>
  );
}
