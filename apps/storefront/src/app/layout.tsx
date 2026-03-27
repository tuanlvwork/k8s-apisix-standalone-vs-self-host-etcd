import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Storefront - Ecommerce',
  description: 'Customer-facing storefront',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body style={{ fontFamily: 'system-ui, sans-serif', margin: 0, padding: 0, backgroundColor: '#0a0a0a', color: '#ededed' }}>
        {children}
      </body>
    </html>
  );
}
