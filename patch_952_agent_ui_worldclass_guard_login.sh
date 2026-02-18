#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"
APP="$ROOT/app"
TS="$(date +%Y%m%d_%H%M%S)"

backup() { [ -f "$1" ] && cp -v "$1" "$1.bak_$TS"; }

mkdir -p "$APP/components" "$APP/lib"

# ------------------------------------------------------------
# 1) Client-side Auth Gate (route guard)
# ------------------------------------------------------------
cat > "$APP/components/AuthGate.tsx" <<'TSX'
"use client";

import { useEffect } from "react";
import { usePathname, useRouter } from "next/navigation";

function hasAgentSession(): boolean {
  try {
    const v = localStorage.getItem("agentId");
    return !!(v && v.trim());
  } catch {
    return false;
  }
}

export default function AuthGate({ children }: { children: React.ReactNode }) {
  const r = useRouter();
  const path = usePathname();

  useEffect(() => {
    const publicPaths = ["/onboarding", "/login"];
    const isPublic = publicPaths.some((p) => path === p || path.startsWith(p + "/"));

    if (!isPublic && !hasAgentSession()) {
      r.replace("/onboarding");
    }
  }, [path, r]);

  return <>{children}</>;
}
TSX

# ------------------------------------------------------------
# 2) Fix nav + wrap layout with AuthGate
# ------------------------------------------------------------
# Your repo has app/layout.tsx already. We'll patch it safely.
LAY="$APP/layout.tsx"
if [ -f "$LAY" ]; then backup "$LAY"; fi

# Replace layout.tsx with a clean world-class shell (keeps your globals.css)
cat > "$LAY" <<'TSX'
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
TSX

# ------------------------------------------------------------
# 3) Make /login correct (Agent Login, not Lawyer Portal)
# ------------------------------------------------------------
mkdir -p "$APP/login"
backup "$APP/login/page.tsx"
backup "$APP/login/page.js"

cat > "$APP/login/page.tsx" <<'TSX'
"use client";

import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";

export default function LoginPage() {
  const r = useRouter();
  const [agentId, setAgentId] = useState("");
  const [password, setPassword] = useState("");

  useEffect(() => {
    const existing = localStorage.getItem("agentId");
    if (existing) r.replace("/tasks");
  }, [r]);

  return (
    <div style={{ maxWidth: 820, margin: "0 auto", padding: 28 }}>
      <h1 style={{ fontSize: 44, fontWeight: 950, letterSpacing: -0.5 }}>Agent Login</h1>
      <p style={{ marginTop: 10, opacity: 0.8, maxWidth: 640 }}>
        Login to access your assigned execution tasks. (For MVP, Agent ID is stored locally. Password / Google login will be enabled next.)
      </p>

      <div style={{ marginTop: 18, display: "grid", gap: 12, maxWidth: 520 }}>
        <div>
          <div style={{ fontSize: 12, opacity: 0.7, marginBottom: 6 }}>Agent ID</div>
          <input
            value={agentId}
            onChange={(e) => setAgentId(e.target.value)}
            placeholder="agent_1"
            style={{ width: "100%", padding: 12, borderRadius: 12, border: "1px solid rgba(255,255,255,0.12)", background: "rgba(255,255,255,0.04)", color: "white" }}
          />
        </div>

        <div>
          <div style={{ fontSize: 12, opacity: 0.7, marginBottom: 6 }}>Password</div>
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="••••••••"
            style={{ width: "100%", padding: 12, borderRadius: 12, border: "1px solid rgba(255,255,255,0.12)", background: "rgba(255,255,255,0.04)", color: "white" }}
          />
          <div style={{ fontSize: 12, opacity: 0.65, marginTop: 6 }}>
            Password is not enforced yet (MVP). We will wire real auth next.
          </div>
        </div>

        <div style={{ display: "flex", gap: 10, marginTop: 6 }}>
          <button
            onClick={() => {
              const id = (agentId || "agent_1").trim();
              localStorage.setItem("agentId", id);
              r.push("/tasks");
            }}
            style={{
              padding: "10px 14px",
              borderRadius: 12,
              border: "1px solid #111",
              background: "#fff",
              color: "#111",
              fontWeight: 950,
            }}
          >
            Login
          </button>

          <button
            onClick={() => alert("Google login will be enabled next.")}
            style={{
              padding: "10px 14px",
              borderRadius: 12,
              border: "1px solid rgba(255,255,255,0.16)",
              background: "rgba(255,255,255,0.06)",
              color: "white",
              fontWeight: 900,
            }}
          >
            Continue with Google (soon)
          </button>
        </div>
      </div>
    </div>
  );
}
TSX

# ------------------------------------------------------------
# 4) Improve onboarding (send to tasks, nicer copy)
# ------------------------------------------------------------
mkdir -p "$APP/onboarding"
backup "$APP/onboarding/page.tsx"
backup "$APP/onboarding/page.js"

cat > "$APP/onboarding/page.tsx" <<'TSX'
"use client";

import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";

export default function OnboardingPage() {
  const r = useRouter();
  const [agentId, setAgentId] = useState("agent_1");

  useEffect(() => {
    const existing = localStorage.getItem("agentId");
    if (existing) {
      setAgentId(existing);
    }
  }, []);

  return (
    <div style={{ maxWidth: 920, margin: "0 auto", padding: 28 }}>
      <h1 style={{ fontSize: 40, fontWeight: 950, letterSpacing: -0.5 }}>
        Welcome to Agent Workbench
      </h1>
      <p style={{ marginTop: 10, opacity: 0.8, maxWidth: 720 }}>
        This console is for executing portal tasks assigned by Admin. You may be asked for OTP or captcha confirmation during sessions.
      </p>

      <div style={{ marginTop: 18, maxWidth: 520 }}>
        <div style={{ fontSize: 12, opacity: 0.7, marginBottom: 6 }}>Agent ID</div>
        <input
          value={agentId}
          onChange={(e) => setAgentId(e.target.value)}
          placeholder="agent_1"
          style={{
            width: "100%",
            padding: 12,
            borderRadius: 12,
            border: "1px solid rgba(255,255,255,0.12)",
            background: "rgba(255,255,255,0.04)",
            color: "white",
          }}
        />

        <div style={{ display: "flex", gap: 10, marginTop: 12 }}>
          <button
            onClick={() => {
              localStorage.setItem("agentId", (agentId || "agent_1").trim());
              r.push("/tasks");
            }}
            style={{
              padding: "10px 14px",
              borderRadius: 12,
              border: "1px solid #111",
              background: "#fff",
              color: "#111",
              fontWeight: 950,
            }}
          >
            Continue
          </button>

          <button
            onClick={() => r.push("/login")}
            style={{
              padding: "10px 14px",
              borderRadius: 12,
              border: "1px solid rgba(255,255,255,0.16)",
              background: "rgba(255,255,255,0.06)",
              color: "white",
              fontWeight: 900,
            }}
          >
            Use Login screen
          </button>
        </div>

        <div style={{ marginTop: 14, opacity: 0.65, fontSize: 12 }}>
          Next: proper auth (password + Google), role-based inbox, and session worker (VNC).
        </div>
      </div>
    </div>
  );
}
TSX

# ------------------------------------------------------------
# 5) Make Tasks empty-state world-class (soften wording)
# ------------------------------------------------------------
TASKS="$APP/tasks/page.tsx"
if [ -f "$TASKS" ]; then
  backup "$TASKS"
  python - <<'PY'
import pathlib, re
p = pathlib.Path("app/tasks/page.tsx")
t = p.read_text()

t = t.replace(
  "No tasks found. Admin must assign a Task with assignedRole=AGENT and assignedToId={agentId}.",
  "No tasks assigned yet. Once Admin assigns tasks to your Agent ID, they will appear here."
)

p.write_text(t)
print("✅ Updated tasks empty state text")
PY
fi

echo "✅ patch_952 applied: guard + correct login/onboarding + cleaner shell"
