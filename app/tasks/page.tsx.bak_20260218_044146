"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { agentGet, getAgentId } from "../lib/agentApi";

type Task = {
  id: string;
  caseId: string;
  type: string;
  status: string;
  updatedAt?: string;
};

export default function TasksPage() {
  const [agentId, setAgentId] = useState("agent_1");
  const [status, setStatus] = useState("ASSIGNED");
  const [tasks, setTasks] = useState<Task[]>([]);
  const [err, setErr] = useState("");

  async function load(aid: string, st: string) {
    setErr("");
    const q = st ? `?status=${encodeURIComponent(st)}` : "";
    const d = await agentGet(`/v1/agent/tasks${q}`, aid);
    if (!d?.ok) {
      setTasks([]);
      setErr(d?.error?.message || "FAILED");
      return;
    }
    setTasks(d?.tasks || []);
  }

  useEffect(() => {
    const aid = getAgentId();
    setAgentId(aid);
    load(aid, status);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <div style={{ maxWidth: 1200, margin: "0 auto", padding: 24 }}>
      <div style={{ display: "flex", justifyContent: "space-between", gap: 12 }}>
        <div>
          <h1 style={{ fontSize: 26, fontWeight: 950 }}>My Tasks</h1>
          <div style={{ marginTop: 6, opacity: 0.75 }}>
            Agent: <b>{agentId}</b> • <Link href="/onboarding">change</Link>
          </div>
        </div>

        <div style={{ display: "flex", gap: 10, alignItems: "flex-end" }}>
          <div>
            <div style={{ fontSize: 12, opacity: 0.7, marginBottom: 6 }}>Status</div>
            <select
              value={status}
              onChange={(e) => {
                const v = e.target.value;
                setStatus(v);
                load(agentId, v);
              }}
              style={{ padding: 10, borderRadius: 10, border: "1px solid #ddd" }}
            >
              <option value="ASSIGNED">ASSIGNED</option>
              <option value="IN_PROGRESS">IN_PROGRESS</option>
              <option value="WAITING_FOR_OTP">WAITING_FOR_OTP</option>
              <option value="WAITING_FOR_CAPTCHA">WAITING_FOR_CAPTCHA</option>
              <option value="SUBMITTED">SUBMITTED</option>
              <option value="COMPLETED">COMPLETED</option>
              <option value="">(All)</option>
            </select>
          </div>

          <button
            onClick={() => load(agentId, status)}
            style={{ padding: "10px 14px", borderRadius: 10, border: "1px solid #ddd", fontWeight: 900 }}
          >
            Refresh
          </button>
        </div>
      </div>

      {err ? <p style={{ marginTop: 12, color: "crimson" }}>{err}</p> : null}

      <div style={{ marginTop: 16, display: "grid", gap: 12 }}>
        {tasks.map((t) => (
          <Link
            key={t.id}
            href={`/task/${t.id}`}
            style={{
              border: "1px solid #e5e5e5",
              borderRadius: 14,
              padding: 14,
              textDecoration: "none",
              color: "inherit",
              background: "#fff",
            }}
          >
            <div style={{ display: "flex", justifyContent: "space-between", gap: 12 }}>
              <div style={{ fontWeight: 950 }}>{t.type || "TASK"}</div>
              <div style={{ opacity: 0.85, fontWeight: 900 }}>{t.status}</div>
            </div>
            <div style={{ marginTop: 8, opacity: 0.75 }}>
              <span style={{ fontFamily: "monospace" }}>{t.id}</span> • case:{" "}
              <span style={{ fontFamily: "monospace" }}>{t.caseId}</span>
            </div>
            {t.updatedAt ? (
              <div style={{ marginTop: 6, opacity: 0.6, fontSize: 12 }}>
                updated: {t.updatedAt}
              </div>
            ) : null}
          </Link>
        ))}

        {!tasks.length && !err ? (
          <div style={{ marginTop: 12, opacity: 0.7 }}>
            No tasks found. Admin must assign a Task with assignedRole=AGENT and assignedToId={agentId}.
          </div>
        ) : null}
      </div>
    </div>
  );
}
