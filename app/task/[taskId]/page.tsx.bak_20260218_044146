"use client";

import Link from "next/link";
import { useEffect, useMemo, useState } from "react";
import { agentGet, agentPost, getAgentId } from "../../lib/agentApi";

const STATUS_CHOICES = [
  "IN_PROGRESS",
  "WAITING_FOR_OTP",
  "WAITING_FOR_CAPTCHA",
  "SUBMITTED",
  "COMPLETED",
  "FAILED",
];

export default function TaskDetail({ params }: { params: { taskId: string } }) {
  const taskId = params.taskId;
  const [agentId, setAgentId] = useState("agent_1");
  const [data, setData] = useState<any>(null);
  const [err, setErr] = useState("");

  const task = data?.task;
  const c = data?.case;
  const attachments = data?.attachments || [];
  const sessions = data?.sessions || [];
  const latestSession = useMemo(() => (sessions?.length ? sessions[0] : null), [sessions]);

  async function refresh(aid: string) {
    setErr("");
    const d = await agentGet(`/v1/agent/tasks/${taskId}`, aid);
    if (!d?.ok) {
      setData(null);
      setErr(d?.error?.message || "FAILED");
      return;
    }
    setData(d);
  }

  useEffect(() => {
    const aid = getAgentId();
    setAgentId(aid);
    refresh(aid);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [taskId]);

  async function setStatus(status: string) {
    const r = await agentPost(`/v1/agent/tasks/${taskId}/status`, agentId, { status });
    if (!r?.ok) alert(r?.error?.message || "Status update failed");
    await refresh(agentId);
  }

  async function requestSession() {
    const r = await agentPost(`/v1/agent/tasks/${taskId}/request-session`, agentId, {});
    if (!r?.ok) alert(r?.error?.message || "Session request failed");
    await refresh(agentId);
  }

  return (
    <div style={{ maxWidth: 1200, margin: "0 auto", padding: 24 }}>
      <div style={{ display: "flex", justifyContent: "space-between", gap: 12 }}>
        <div>
          <h1 style={{ fontSize: 22, fontWeight: 950 }}>Task Detail</h1>
          <div style={{ marginTop: 6, opacity: 0.75 }}>
            <Link href="/tasks">Back</Link> • Agent: <b>{agentId}</b>
          </div>
          <div style={{ marginTop: 10, fontFamily: "monospace", opacity: 0.85 }}>{taskId}</div>
        </div>

        <div style={{ display: "flex", gap: 10, alignItems: "flex-end" }}>
          <button
            onClick={requestSession}
            style={{
              padding: "10px 14px",
              borderRadius: 10,
              border: "1px solid #111",
              background: "#111",
              color: "#fff",
              fontWeight: 950,
            }}
          >
            Start Session
          </button>
          <button
            onClick={() => refresh(agentId)}
            style={{ padding: "10px 14px", borderRadius: 10, border: "1px solid #ddd", fontWeight: 900 }}
          >
            Refresh
          </button>
        </div>
      </div>

      {err ? <p style={{ marginTop: 12, color: "crimson" }}>{err}</p> : null}

      <div style={{ display: "grid", gridTemplateColumns: "1.2fr 0.8fr", gap: 14, marginTop: 16 }}>
        <div style={{ border: "1px solid #e5e5e5", borderRadius: 14, padding: 14, background: "#fff" }}>
          <h2 style={{ fontSize: 16, fontWeight: 950 }}>Case Summary</h2>
          <div style={{ marginTop: 10, display: "grid", gap: 6, opacity: 0.9 }}>
            <div>caseId: <span style={{ fontFamily: "monospace" }}>{c?.id || "-"}</span></div>
            <div>state: <b>{c?.state || "-"}</b></div>
            <div>language: <b>{c?.language || "-"}</b></div>
            <div>docType: <b>{c?.docType || "-"}</b></div>
            <div>caseStatus: <b>{c?.status || "-"}</b></div>
          </div>

          <hr style={{ margin: "14px 0", borderColor: "#eee" }} />

          <h3 style={{ fontSize: 14, fontWeight: 950 }}>Task</h3>
          <div style={{ marginTop: 10, display: "grid", gap: 6, opacity: 0.9 }}>
            <div>type: <b>{task?.type || "-"}</b></div>
            <div>status: <b>{task?.status || "-"}</b></div>
            <div>assignedToId: <span style={{ fontFamily: "monospace" }}>{task?.assignedToId || "-"}</span></div>
          </div>

          <div style={{ marginTop: 14 }}>
            <div style={{ fontSize: 12, opacity: 0.7, marginBottom: 8 }}>Update status</div>
            <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
              {STATUS_CHOICES.map((s) => (
                <button
                  key={s}
                  onClick={() => setStatus(s)}
                  style={{
                    padding: "8px 10px",
                    borderRadius: 999,
                    border: "1px solid #ddd",
                    background: "#fff",
                    fontWeight: 900,
                    fontSize: 12,
                  }}
                >
                  {s}
                </button>
              ))}
            </div>
          </div>
        </div>

        <div style={{ display: "grid", gap: 14 }}>
          <div style={{ border: "1px solid #e5e5e5", borderRadius: 14, padding: 14, background: "#fff" }}>
            <h2 style={{ fontSize: 16, fontWeight: 950 }}>Session</h2>
            {latestSession ? (
              <div style={{ marginTop: 10, opacity: 0.9 }}>
                <div>sessionId: <span style={{ fontFamily: "monospace" }}>{latestSession.id}</span></div>
                <div style={{ marginTop: 6 }}>status: <b>{latestSession.status}</b></div>
                <div style={{ marginTop: 6, opacity: 0.75 }}>expiresAt: {latestSession.expiresAt || "-"}</div>
              </div>
            ) : (
              <div style={{ marginTop: 10, opacity: 0.7 }}>No sessions yet. Click “Start Session”.</div>
            )}
          </div>

          <div style={{ border: "1px solid #e5e5e5", borderRadius: 14, padding: 14, background: "#fff" }}>
            <h2 style={{ fontSize: 16, fontWeight: 950 }}>Attachments</h2>
            <div style={{ marginTop: 10, display: "grid", gap: 10 }}>
              {attachments.map((a: any) => (
                <div key={a.id} style={{ border: "1px solid #eee", borderRadius: 12, padding: 10 }}>
                  <div style={{ fontWeight: 900 }}>{a.fileName || "Attachment"}</div>
                  {a.url ? (
                    <a href={a.url} target="_blank" rel="noreferrer" style={{ fontSize: 12 }}>
                      Open
                    </a>
                  ) : (
                    <div style={{ fontSize: 12, opacity: 0.7 }}>No URL</div>
                  )}
                </div>
              ))}
              {!attachments.length ? <div style={{ opacity: 0.7 }}>No attachments.</div> : null}
            </div>
          </div>
        </div>
      </div>

      <div style={{ marginTop: 14, opacity: 0.65, fontSize: 12 }}>
        Playwright will be integrated later via session worker. OTP/Captcha stays manual per policy.
      </div>
    </div>
  );
}
