import "./globals.css";
import Link from "next/link";
import AuthGate from "./components/AuthGate";

export const metadata = {
  title: "Instadrafts • Agent Console",
  description: "Agent Workbench for portal execution and delivery",
};

function TopNav() {
  return (
    <div
      style={{
        height: 64,
        display: "flex",
        alignItems: "center",
        justifyContent: "space-between",
        padding: "0 22px",
        borderBottom: "1px solid rgba(255,255,255,0.06)",
        background: "rgba(0,0,0,0.25)",
        backdropFilter: "blur(10px)",
      }}
    >
      <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
        <div
          style={{
            width: 12,
            height: 12,
            borderRadius: 999,
            background: "linear-gradient(135deg, #6EE7F9, #A78BFA)",
            boxShadow: "0 0 0 4px rgba(255,255,255,0.06)",
          }}
        />
        <div>
          <div style={{ fontWeight: 900, lineHeight: 1 }}>Instadrafts</div>
          <div style={{ fontSize: 12, opacity: 0.75, marginTop: 2 }}>Agent Console</div>
        </div>
      </div>

      <div style={{ display: "flex", gap: 18, fontWeight: 700, opacity: 0.9 }}>
        <Link href="/tasks" style={{ textDecoration: "none", color: "inherit" }}>Tasks</Link>
        <Link href="/inbox" style={{ textDecoration: "none", color: "inherit" }}>Inbox</Link>
        <Link href="/payouts" style={{ textDecoration: "none", color: "inherit" }}>Payouts</Link>
      </div>
    </div>
  );
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <TopNav />
        <AuthGate>{children}</AuthGate>
      </body>
    </html>
  );
}
