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
