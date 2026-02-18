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
