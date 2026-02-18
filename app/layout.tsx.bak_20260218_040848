import "./globals.css";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Instadrafts • Agent",
  description: "Agent execution console for Instadrafts",
};

function TopNav() {
  return (
    <header className="nav">
      <div className="nav__inner">
        <div className="brand">
          <div className="brand__dot" />
          <div className="brand__text">
            <div className="brand__title">Instadrafts</div>
            <div className="brand__sub">Agent Console</div>
          </div>
        </div>
        <nav className="nav__links">
          <a className="nav__link" href="/tasks">Dashboard</a>
          <a className="nav__link" href="/inbox">Inbox</a>
          <a className="nav__link" href="/payouts">Payouts</a>
        </nav>
      </div>
    </header>
  );
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <TopNav />
        <main className="container">{children}</main>
      </body>
    </html>
  );
}
