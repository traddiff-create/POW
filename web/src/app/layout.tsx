import type { Metadata, Viewport } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "A Piece of Whole",
  description: "Co-regulation, community, and civic practice — together.",
  manifest: "/manifest.json",
  appleWebApp: {
    capable: true,
    statusBarStyle: "default",
    title: "A Piece of Whole",
  },
};

export const viewport: Viewport = {
  themeColor: "#7A9E7E",
  width: "device-width",
  initialScale: 1,
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="h-full">
      <body className="min-h-full flex flex-col bg-[#F9F7F4] text-[#2C2A28]">
        {children}
      </body>
    </html>
  );
}
