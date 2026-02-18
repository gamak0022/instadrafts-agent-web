#!/usr/bin/env bash
set -euo pipefail

# Set this to your deploy repo path:
#   export APP_DIR=~/instadrafts-agent-web
# OR (monorepo):
#   export APP_DIR=~/Instadrafts-final/apps/agent-web
: "${APP_DIR:?Set APP_DIR to agent-web root folder}"

cd "$APP_DIR"

mkdir -p app/onboarding app/tasks

echo "== Writing app/layout.tsx (nav + clean shell) =="
cat > app/layout.tsx <<'TSX'
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
TSX

echo "== Writing app/page.tsx (smart redirect to onboarding/dashboard) =="
cat > app/page.tsx <<'TSX'
"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";

export default function Home() {
  const router = useRouter();

  useEffect(() => {
    const done = localStorage.getItem("agent_onboarding_done") === "true";
    const agentId = (localStorage.getItem("agent_id") || "").trim();

    if (!done || !agentId) {
      router.replace("/onboarding");
      return;
    }
    router.replace("/tasks");
  }, [router]);

  return (
    <div className="pageCenter">
      <div className="card">
        <div className="h1">Loading…</div>
        <p className="muted">Preparing your agent console.</p>
      </div>
    </div>
  );
}
TSX

echo "== Writing app/onboarding/page.tsx (clean onboarding) =="
cat > app/onboarding/page.tsx <<'TSX'
"use client";

import { useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";

function Badge({ ok, text }: { ok: boolean; text: string }) {
  return (
    <span className={ok ? "badge badge--ok" : "badge badge--warn"}>
      <span className="badge__dot" />
      {text}
    </span>
  );
}

export default function Onboarding() {
  const router = useRouter();
  const [agentId, setAgentId] = useState("");
  const [apiOk, setApiOk] = useState<boolean | null>(null);
  const [checking, setChecking] = useState(false);

  const apiBase = useMemo(() => {
    // If you already use NEXT_PUBLIC_API_BASE in your repo, keep this.
    // Otherwise this will still work if /api proxy is configured.
    return (process.env.NEXT_PUBLIC_API_BASE || "").trim();
  }, []);

  useEffect(() => {
    const prev = (localStorage.getItem("agent_id") || "").trim();
    if (prev) setAgentId(prev);
  }, []);

  async function checkHealth() {
    setChecking(true);
    setApiOk(null);
    try {
      // Prefer local proxy if present
      const res = await fetch("/api/health", { cache: "no-store" });
      if (res.ok) {
        setApiOk(true);
      } else {
        // fallback: if someone configured direct base
        if (apiBase) {
          const r2 = await fetch(`${apiBase}/health`, { cache: "no-store" });
          setApiOk(r2.ok);
        } else {
          setApiOk(false);
        }
      }
    } catch {
      setApiOk(false);
    } finally {
      setChecking(false);
    }
  }

  function continueNext() {
    const id = agentId.trim();
    if (!id) return;

    localStorage.setItem("agent_id", id);
    localStorage.setItem("agent_onboarding_done", "true");
    router.replace("/tasks");
  }

  return (
    <div className="pageCenter">
      <div className="card card--wide">
        <div className="h1">Welcome, Agent</div>
        <p className="muted">
          This console helps you execute assigned tasks. You will manually handle OTP / uploads.
          Automation is used only for portal navigation and form-filling.
        </p>

        <div className="grid2">
          <div>
            <div className="label">Agent ID</div>
            <input
              className="input"
              placeholder="agent_1"
              value={agentId}
              onChange={(e) => setAgentId(e.target.value)}
            />
            <div className="hint">Ask admin for your Agent ID (example: <b>agent_1</b>).</div>
          </div>

          <div>
            <div className="label">Connectivity</div>
            <div className="row">
              <button className="btn btn--secondary" onClick={checkHealth} disabled={checking}>
                {checking ? "Checking…" : "Check API"}
              </button>
              {apiOk === null ? (
                <Badge ok={false} text="Not checked" />
              ) : apiOk ? (
                <Badge ok={true} text="Connected" />
              ) : (
                <Badge ok={false} text="Not reachable" />
              )}
            </div>
            <div className="hint">
              If this fails, set <code>NEXT_PUBLIC_API_BASE</code> in Vercel to your Cloud Run URL.
            </div>
          </div>
        </div>

        <div className="divider" />

        <div className="row row--right">
          <button className="btn" onClick={continueNext} disabled={!agentId.trim()}>
            Continue to Dashboard
          </button>
        </div>
      </div>
    </div>
  );
}
TSX

echo "== Writing app/tasks/page.tsx (real dashboard + tasks list) =="
cat > app/tasks/page.tsx <<'TSX'
"use client";

import { useEffect, useMemo, useState } from "react";

type Task = {
  id: string;
  caseId: string;
  type: string;
  status: string;
  assignedRole: string;
  assignedToId?: string | null;
  updatedAt?: string;
  createdAt?: string;
};

function Stat({ label, value }: { label: string; value: number }) {
  return (
    <div className="stat">
      <div className="stat__value">{value}</div>
      <div className="stat__label">{label}</div>
    </div>
  );
}

function fmt(ts?: string) {
  if (!ts) return "—";
  const d = new Date(ts);
  if (Number.isNaN(d.getTime())) return "—";
  return d.toLocaleString();
}

export default function TasksDashboard() {
  const [agentId, setAgentId] = useState<string>("");
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [err, setErr] = useState<string>("");

  const counts = useMemo(() => {
    const c = { ASSIGNED: 0, IN_PROGRESS: 0, BLOCKED: 0, DONE: 0, OTHER: 0 };
    for (const t of tasks) {
      const s = (t.status || "").toUpperCase();
      if (s === "ASSIGNED") c.ASSIGNED++;
      else if (s === "IN_PROGRESS") c.IN_PROGRESS++;
      else if (s === "BLOCKED") c.BLOCKED++;
      else if (s === "DONE" || s === "COMPLETED") c.DONE++;
      else c.OTHER++;
    }
    return c;
  }, [tasks]);

  async function load() {
    setLoading(true);
    setErr("");
    try {
      const id = (localStorage.getItem("agent_id") || "").trim();
      setAgentId(id);

      if (!id) {
        setErr("Missing Agent ID. Please complete onboarding.");
        setTasks([]);
        return;
      }

      const res = await fetch("/api/v1/agent/tasks", {
        cache: "no-store",
        headers: {
          "x-user-role": "AGENT",
          "x-user-id": id,
        },
      });

      const json = await res.json().catch(() => null);

      if (!res.ok) {
        setErr(json?.error?.message || `API_ERROR_${res.status}`);
        setTasks([]);
        return;
      }

      setTasks(Array.isArray(json?.tasks) ? json.tasks : []);
    } catch (e: any) {
      setErr(String(e?.message || e || "UNKNOWN_ERROR"));
      setTasks([]);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    load();
  }, []);

  return (
    <div className="stack">
      <div className="pageHead">
        <div>
          <div className="h1">Dashboard</div>
          <div className="muted">
            Agent: <b>{agentId || "—"}</b>
          </div>
        </div>
        <div className="row">
          <button className="btn btn--secondary" onClick={load} disabled={loading}>
            {loading ? "Refreshing…" : "Refresh"}
          </button>
          <a className="btn" href="/onboarding">
            Settings
          </a>
        </div>
      </div>

      <div className="stats">
        <Stat label="Assigned" value={counts.ASSIGNED} />
        <Stat label="In progress" value={counts.IN_PROGRESS} />
        <Stat label="Blocked" value={counts.BLOCKED} />
        <Stat label="Done" value={counts.DONE} />
      </div>

      <div className="card">
        <div className="card__title">My Tasks</div>

        {err ? (
          <div className="empty">
            <div className="empty__title">Cannot load tasks</div>
            <div className="empty__desc">{err}</div>
            <div className="row">
              <a className="btn" href="/onboarding">Fix onboarding</a>
              <button className="btn btn--secondary" onClick={load}>Retry</button>
            </div>
          </div>
        ) : loading ? (
          <div className="empty">
            <div className="empty__title">Loading…</div>
            <div className="empty__desc">Fetching assigned tasks.</div>
          </div>
        ) : tasks.length === 0 ? (
          <div className="empty">
            <div className="empty__title">No tasks yet</div>
            <div className="empty__desc">
              Ask Admin to assign a case to you. Once assigned, it will appear here automatically.
            </div>
            <div className="row">
              <button className="btn btn--secondary" onClick={load}>Refresh</button>
            </div>
          </div>
        ) : (
          <div className="list">
            {tasks.map((t) => (
              <div className="item" key={t.id}>
                <div className="item__main">
                  <div className="item__title">
                    <span className="mono">{t.caseId}</span>
                    <span className="dot" />
                    <span className="pill">{(t.status || "—").toUpperCase()}</span>
                  </div>
                  <div className="item__meta">
                    Task: <span className="mono">{t.id}</span> • Updated: {fmt(t.updatedAt)}
                  </div>
                </div>
                <div className="item__cta">
                  <a className="btn btn--secondary" href={`/tasks/${t.id}`}>
                    Open
                  </a>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
TSX

echo "== Writing app/tasks/[taskId]/page.tsx (detail scaffold) =="
mkdir -p app/tasks/[taskId]
cat > app/tasks/[taskId]/page.tsx <<'TSX'
"use client";

import { useEffect, useState } from "react";

export default function TaskDetail({ params }: { params: { taskId: string } }) {
  const taskId = params.taskId;
  const [agentId, setAgentId] = useState("");
  const [status, setStatus] = useState("IN_PROGRESS");
  const [saving, setSaving] = useState(false);
  const [msg, setMsg] = useState("");

  useEffect(() => {
    setAgentId((localStorage.getItem("agent_id") || "").trim());
  }, []);

  async function update(next: string) {
    setSaving(true);
    setMsg("");
    try {
      const res = await fetch(`/api/v1/agent/tasks/${taskId}/update`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-user-role": "AGENT",
          "x-user-id": agentId,
        },
        body: JSON.stringify({ status: next }),
      });
      const json = await res.json().catch(() => null);
      if (!res.ok) {
        setMsg(json?.error?.message || `API_ERROR_${res.status}`);
        return;
      }
      setStatus(json?.task?.status || next);
      setMsg("Updated.");
    } catch (e: any) {
      setMsg(String(e?.message || e));
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="stack">
      <div className="pageHead">
        <div>
          <div className="h1">Task</div>
          <div className="muted">
            <span className="mono">{taskId}</span>
          </div>
        </div>
        <a className="btn btn--secondary" href="/tasks">Back</a>
      </div>

      <div className="card">
        <div className="card__title">Execution</div>
        <p className="muted">
          Use this page while running Playwright. OTP / uploads are manual. Update status as you progress.
        </p>

        <div className="row">
          <button className="btn btn--secondary" disabled={saving} onClick={() => update("IN_PROGRESS")}>
            In Progress
          </button>
          <button className="btn btn--secondary" disabled={saving} onClick={() => update("BLOCKED")}>
            Blocked
          </button>
          <button className="btn" disabled={saving} onClick={() => update("DONE")}>
            Done
          </button>
        </div>

        <div className="hint">
          Current: <b>{status}</b> {msg ? <>• <span>{msg}</span></> : null}
        </div>
      </div>
    </div>
  );
}
TSX

echo "== Writing app/globals.css (Anthropic-ish minimal styling) =="
cat > app/globals.css <<'CSS'
:root{
  --bg:#070A12;
  --panel:#0B1020;
  --panel2:#0E1630;
  --text:#EAF0FF;
  --muted:#9AA7C7;
  --line:rgba(255,255,255,.10);
  --line2:rgba(255,255,255,.14);
  --accent:#7C5CFF;
  --accent2:#2DE3A6;
  --warn:#F5C451;
  --danger:#FF5C7A;
  --mono: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;
}

*{ box-sizing:border-box; }
html,body{ height:100%; }
body{
  margin:0;
  background: radial-gradient(1000px 400px at 20% 0%, rgba(124,92,255,.20), transparent 60%),
              radial-gradient(900px 500px at 80% 10%, rgba(45,227,166,.12), transparent 55%),
              var(--bg);
  color:var(--text);
  font-family: ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Arial, "Noto Sans", "Liberation Sans", sans-serif;
}

a{ color:inherit; text-decoration:none; }
code{ font-family:var(--mono); color:#cfe0ff; }

.container{
  max-width: 1100px;
  margin: 0 auto;
  padding: 28px 16px 80px;
}

.nav{
  position:sticky; top:0; z-index:10;
  background: rgba(7,10,18,.75);
  backdrop-filter: blur(10px);
  border-bottom:1px solid var(--line);
}
.nav__inner{
  max-width: 1100px;
  margin: 0 auto;
  padding: 14px 16px;
  display:flex;
  align-items:center;
  justify-content:space-between;
}
.brand{ display:flex; align-items:center; gap:12px; }
.brand__dot{
  width:12px;height:12px;border-radius:999px;
  background: linear-gradient(135deg, var(--accent), var(--accent2));
  box-shadow: 0 0 0 4px rgba(124,92,255,.12);
}
.brand__title{ font-weight:700; letter-spacing:.2px; }
.brand__sub{ color:var(--muted); font-size:12px; margin-top:2px; }
.nav__links{ display:flex; gap:14px; }
.nav__link{ color:var(--muted); font-size:14px; }
.nav__link:hover{ color:var(--text); }

.pageCenter{
  min-height: calc(100vh - 120px);
  display:flex;
  align-items:center;
  justify-content:center;
}

.stack{ display:flex; flex-direction:column; gap:16px; }

.pageHead{
  display:flex;
  align-items:flex-start;
  justify-content:space-between;
  gap:12px;
}

.h1{ font-size:28px; font-weight:750; }
.muted{ color:var(--muted); }
.mono{ font-family:var(--mono); }

.card{
  border:1px solid var(--line);
  background: linear-gradient(180deg, rgba(14,22,48,.70), rgba(11,16,32,.65));
  border-radius: 16px;
  padding: 18px;
  box-shadow: 0 12px 40px rgba(0,0,0,.35);
}
.card--wide{ width:min(820px, 100%); }
.card__title{ font-weight:700; margin-bottom:10px; }

.grid2{
  display:grid;
  grid-template-columns: 1fr 1fr;
  gap:14px;
}
@media (max-width: 860px){
  .grid2{ grid-template-columns: 1fr; }
}

.label{ font-size:13px; color:var(--muted); margin-bottom:8px; }
.input{
  width:100%;
  border-radius:12px;
  border:1px solid var(--line2);
  background: rgba(8,12,22,.60);
  color:var(--text);
  padding:12px 12px;
  outline:none;
}
.input:focus{ border-color: rgba(124,92,255,.55); box-shadow:0 0 0 4px rgba(124,92,255,.12); }

.hint{ margin-top:10px; font-size:13px; color:var(--muted); }

.row{ display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
.row--right{ justify-content:flex-end; }

.btn{
  border:1px solid rgba(124,92,255,.45);
  background: rgba(124,92,255,.18);
  color: var(--text);
  padding: 10px 12px;
  border-radius: 12px;
  cursor:pointer;
  font-weight:650;
}
.btn:hover{ background: rgba(124,92,255,.24); }
.btn:disabled{ opacity:.6; cursor:not-allowed; }

.btn--secondary{
  border:1px solid var(--line2);
  background: rgba(255,255,255,.06);
}
.btn--secondary:hover{ background: rgba(255,255,255,.09); }

.badge{
  display:inline-flex;
  align-items:center;
  gap:8px;
  border-radius:999px;
  padding:8px 10px;
  font-size:13px;
  border:1px solid var(--line2);
}
.badge__dot{ width:8px;height:8px;border-radius:999px; background: var(--warn); }
.badge--ok .badge__dot{ background: var(--accent2); }
.badge--ok{ color: var(--text); }
.badge--warn{ color: var(--muted); }

.divider{ height:1px; background: var(--line); margin: 14px 0; }

.stats{
  display:grid;
  grid-template-columns: repeat(4, 1fr);
  gap:10px;
}
@media (max-width: 860px){
  .stats{ grid-template-columns: repeat(2, 1fr); }
}
.stat{
  border:1px solid var(--line);
  background: rgba(255,255,255,.04);
  border-radius: 16px;
  padding: 14px;
}
.stat__value{ font-size:24px; font-weight:800; }
.stat__label{ color:var(--muted); font-size:13px; margin-top:6px; }

.empty{
  padding: 18px;
  border:1px dashed var(--line2);
  border-radius: 14px;
  background: rgba(255,255,255,.03);
}
.empty__title{ font-weight:750; margin-bottom:6px; }
.empty__desc{ color:var(--muted); margin-bottom:12px; max-width: 720px; }

.list{ display:flex; flex-direction:column; gap:10px; margin-top:10px; }
.item{
  display:flex;
  align-items:center;
  justify-content:space-between;
  gap:12px;
  padding: 12px 12px;
  border-radius: 14px;
  border:1px solid var(--line);
  background: rgba(255,255,255,.04);
}
.item__title{ display:flex; align-items:center; gap:10px; font-weight:700; }
.item__meta{ color:var(--muted); font-size:13px; margin-top:6px; }
.dot{ width:4px;height:4px;border-radius:999px;background:var(--line2); }

.pill{
  font-size:12px;
  padding: 5px 8px;
  border-radius: 999px;
  border:1px solid var(--line2);
  background: rgba(255,255,255,.05);
  color: var(--text);
}

TSX

echo "== Done. Run build =="
npm run build
