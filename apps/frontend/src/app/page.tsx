'use client';

import { useEffect, useState } from 'react';

interface HealthResponse {
  status: string;
  service: string;
  timestamp: string;
}

interface DataItem {
  id: number;
  name: string;
}

interface DataResponse {
  message: string;
  items: DataItem[];
}

export default function Home() {
  const [health, setHealth] = useState<HealthResponse | null>(null);
  const [data, setData] = useState<DataResponse | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetch('/api/health')
      .then((res) => res.json())
      .then(setHealth)
      .catch((err) => setError(`Health check failed: ${err.message}`));

    fetch('/api/data')
      .then((res) => res.json())
      .then(setData)
      .catch((err) => setError(`Data fetch failed: ${err.message}`));
  }, []);

  return (
    <main>
      <h1 style={{ fontSize: '2rem', marginBottom: '1rem' }}>
        🚀 APISIX Sandbox
      </h1>
      <p style={{ color: '#888', marginBottom: '2rem' }}>
        NextJS frontend → APISIX gateway → NestJS backend
      </p>

      {error && (
        <div style={{ padding: '1rem', backgroundColor: '#3a1a1a', borderRadius: '8px', marginBottom: '1rem', border: '1px solid #662222' }}>
          ❌ {error}
        </div>
      )}

      <section style={{ marginBottom: '2rem' }}>
        <h2>Health Check</h2>
        {health ? (
          <pre style={{ backgroundColor: '#1a1a2e', padding: '1rem', borderRadius: '8px', overflow: 'auto' }}>
            {JSON.stringify(health, null, 2)}
          </pre>
        ) : (
          <p style={{ color: '#888' }}>Loading...</p>
        )}
      </section>

      <section>
        <h2>Backend Data</h2>
        {data ? (
          <>
            <p style={{ color: '#4ade80' }}>{data.message}</p>
            <ul style={{ listStyle: 'none', padding: 0 }}>
              {data.items.map((item) => (
                <li
                  key={item.id}
                  style={{
                    padding: '0.75rem 1rem',
                    backgroundColor: '#1a1a2e',
                    marginBottom: '0.5rem',
                    borderRadius: '6px',
                    border: '1px solid #2a2a4e',
                  }}
                >
                  #{item.id} — {item.name}
                </li>
              ))}
            </ul>
          </>
        ) : (
          <p style={{ color: '#888' }}>Loading...</p>
        )}
      </section>
    </main>
  );
}
