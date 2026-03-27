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

export default function AdminPage() {
  const [products, setProducts] = useState<Product[]>([]);
  const [orders, setOrders] = useState<Order[]>([]);
  const [productsLoading, setProductsLoading] = useState(true);
  const [ordersLoading, setOrdersLoading] = useState(true);
  const [productsError, setProductsError] = useState('');
  const [ordersError, setOrdersError] = useState('');

  useEffect(() => {
    fetch('/services/admin/api/v1/products')
      .then((r) => r.json())
      .then((data) => { setProducts(data.items || []); setProductsLoading(false); })
      .catch((e) => { setProductsError(e.message); setProductsLoading(false); });

    fetch('/services/admin/api/v1/orders')
      .then((r) => r.json())
      .then((data) => { setOrders(data.items || []); setOrdersLoading(false); })
      .catch((e) => { setOrdersError(e.message); setOrdersLoading(false); });
  }, []);

  return (
    <div style={{ maxWidth: 1000, margin: '0 auto', padding: '2rem' }}>
      <h1 style={{ borderBottom: '2px solid #30363d', paddingBottom: '0.5rem' }}>
        ⚙️ Admin Dashboard
      </h1>
      <p style={{ color: '#8b949e', fontSize: '0.9rem' }}>
        Management panel — served via APISIX at
        <code style={{ color: '#f0883e' }}> /services/admin/</code>
      </p>

      {/* Product Management */}
      <section style={{ marginTop: '2rem' }}>
        <h2>📦 Product Management</h2>
        <p style={{ color: '#8b949e', fontSize: '0.8rem' }}>
          API: <code>GET /services/admin/api/v1/products</code>
          → proxied to <code>product-svc:80/api/v1/products</code>
        </p>
        {productsLoading ? (
          <p>Loading...</p>
        ) : productsError ? (
          <p style={{ color: '#f85149' }}>Error: {productsError}</p>
        ) : (
          <table style={{ width: '100%', borderCollapse: 'collapse' }}>
            <thead>
              <tr style={{ borderBottom: '1px solid #30363d' }}>
                <th style={{ textAlign: 'left', padding: '0.5rem' }}>ID</th>
                <th style={{ textAlign: 'left', padding: '0.5rem' }}>Name</th>
                <th style={{ textAlign: 'left', padding: '0.5rem' }}>Category</th>
                <th style={{ textAlign: 'right', padding: '0.5rem' }}>Price</th>
              </tr>
            </thead>
            <tbody>
              {products.map((p) => (
                <tr key={p.id} style={{ borderBottom: '1px solid #21262d' }}>
                  <td style={{ padding: '0.5rem', color: '#8b949e' }}>{p.id}</td>
                  <td style={{ padding: '0.5rem' }}>{p.name}</td>
                  <td style={{ padding: '0.5rem', color: '#8b949e' }}>{p.category}</td>
                  <td style={{ padding: '0.5rem', textAlign: 'right', color: '#3fb950' }}>${p.price}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>

      {/* Order Management */}
      <section style={{ marginTop: '2rem' }}>
        <h2>🧾 Order Management</h2>
        <p style={{ color: '#8b949e', fontSize: '0.8rem' }}>
          API: <code>GET /services/admin/api/v1/orders</code>
          → proxied to <code>order-svc:80/api/v1/orders</code>
        </p>
        {ordersLoading ? (
          <p>Loading...</p>
        ) : ordersError ? (
          <p style={{ color: '#f85149' }}>Error: {ordersError}</p>
        ) : (
          <table style={{ width: '100%', borderCollapse: 'collapse' }}>
            <thead>
              <tr style={{ borderBottom: '1px solid #30363d' }}>
                <th style={{ textAlign: 'left', padding: '0.5rem' }}>Order #</th>
                <th style={{ textAlign: 'left', padding: '0.5rem' }}>Product ID</th>
                <th style={{ textAlign: 'left', padding: '0.5rem' }}>Qty</th>
                <th style={{ textAlign: 'left', padding: '0.5rem' }}>Status</th>
                <th style={{ textAlign: 'right', padding: '0.5rem' }}>Total</th>
              </tr>
            </thead>
            <tbody>
              {orders.map((o) => (
                <tr key={o.id} style={{ borderBottom: '1px solid #21262d' }}>
                  <td style={{ padding: '0.5rem' }}>#{o.id}</td>
                  <td style={{ padding: '0.5rem', color: '#8b949e' }}>{o.productId}</td>
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
                  <td style={{ padding: '0.5rem', textAlign: 'right', color: '#3fb950' }}>${o.total}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>
    </div>
  );
}
