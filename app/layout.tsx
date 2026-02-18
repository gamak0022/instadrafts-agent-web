import "./globals.css";
import Link from "next/link";
import AuthGate from "./components/AuthGate";

export const metadata = {
  title: "Instadrafts • Agent Console",
  description: "Agent Workbench for portal execution and delivery",
};

function TopNav() {
  return (
    <div className="nav">
      <div className="brand">
        <div className="logo" />
        <div>
          <div className="brandTitle">INSTADRAFTS</div>
          <div className="brandSub">Agent Console</div>
        </div>
      </div>

      <div className="navLinks">
        <Link href="/tasks">Tasks</Link>
        <Link href="/inbox">Inbox</Link>
        <Link href="/payouts">Payouts</Link>
      </div>
    </div>
  );
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <TopNav />
        <AuthGate>
          <div className="shell">{children}</div>
        </AuthGate>
      </body>
    </html>
  );
}
