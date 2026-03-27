import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Admin Dashboard - Ecommerce',
  description: 'Admin dashboard for product and order management',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body style={{ fontFamily: 'system-ui, sans-serif', margin: 0, padding: 0, backgroundColor: '#0d1117', color: '#ededed' }}>
        {children}
      </body>
    </html>
  );
}
