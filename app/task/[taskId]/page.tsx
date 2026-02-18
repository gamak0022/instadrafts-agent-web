"use client";

import Link from "next/link";
import { useEffect, useMemo, useState } from "react";
import { agentGet, agentPost, getAgentId } from "../../lib/agentApi";

const HUMAN_GATES = [
  { key: "WAITING_FOR_OTP", label: "Waiting for OTP", tone: "btn" },
  { key: "WAITING_FOR_CAPTCHA", label: "Captcha needed", tone: "btn" },
];

function badgeClass(status?: string){
  const s = String(status||"").toUpperCase();
  if (s.includes("OTP") || s.includes("CAPTCHA")) return "badge badgeAmber";
  if (s.includes("IN_PROGRESS")) return "badge badgeBlue";
  if (s.includes("COMPLETE")) return "badge badgeGreen";
  if (s.includes("FAIL")) return "badge badgeRed";
  return "badge";
}

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
  const vncUrl = latestSession?.vncUrl || latestSession?.noVncUrl || latestSession?.viewerUrl || null;

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

  function openSession() {
    if (!vncUrl) return alert("Session viewer/VNC URL will appear once worker integration is enabled.");
    window.open(vncUrl, "_blank", "noopener,noreferrer");
  }

  // Placeholder controls until worker exists
  function runStep(step: number) {
    alert(`Step ${step} will run via Playwright worker soon.\n\nFor now: Start Session → do portal actions manually → update status gates (OTP/Captcha) → mark Submitted/Completed.`);
  }

  return (
    <div className="container">
      <div className="row" style={{ justifyContent: "space-between", alignItems: "flex-end" }}>
        <div>
          <div className="h1">Task</div>
          <div className="muted" style={{ marginTop: 10 }}>
            <Link href="/tasks">← Back</Link> • Agent: <b>{agentId}</b>
          </div>
          <div className="small muted" style={{ marginTop: 8, fontFamily: "ui-monospace, SFMono-Regular, Menlo, monospace" }}>
            {taskId}
          </div>
        </div>

        <div className="row">
          <button className="btn btnPrimary" onClick={requestSession}>Start Session</button>
          <button className="btn" onClick={openSession}>Open Session</button>
          <button className="btn" onClick={() => refresh(agentId)}>Refresh</button>
        </div>
      </div>

      {err ? <div className="card cardPad" style={{ marginTop: 14, borderColor:"rgba(239,68,68,.30)", background:"rgba(239,68,68,.08)" }}>{err}</div> : null}

      <div className="grid2" style={{ marginTop: 16 }}>
        {/* LEFT */}
        <div className="card cardPad">
          <div className="row" style={{ justifyContent:"space-between" }}>
            <div className="h2">Case Summary</div>
            <span className={badgeClass(task?.status)}>{task?.status || "-"}</span>
          </div>

          <div className="hr" />

          <div className="grid3">
            <div>
              <div className="small muted">Case ID</div>
              <div style={{ fontWeight: 900, fontFamily:"ui-monospace, Menlo, monospace" }}>{c?.id || "-"}</div>
            </div>
            <div>
              <div className="small muted">State</div>
              <div style={{ fontWeight: 900 }}>{c?.state || "-"}</div>
            </div>
            <div>
              <div className="small muted">Language</div>
              <div style={{ fontWeight: 900 }}>{c?.language || "-"}</div>
            </div>
          </div>

          <div className="hr" />

          <div className="grid3">
            <div>
              <div className="small muted">DocType</div>
              <div style={{ fontWeight: 900 }}>{c?.docType || "-"}</div>
            </div>
            <div>
              <div className="small muted">Task Type</div>
              <div style={{ fontWeight: 900 }}>{task?.type || "-"}</div>
            </div>
            <div>
              <div className="small muted">Assigned To</div>
              <div style={{ fontWeight: 900, fontFamily:"ui-monospace, Menlo, monospace" }}>{task?.assignedToId || "-"}</div>
            </div>
          </div>

          <div className="hr" />

          <div className="h2">Playwright controls</div>
          <div className="muted" style={{ marginTop: 6, lineHeight: 1.5 }}>
            Playwright is used only for <b>navigation + form fill</b>. OTP/Captcha remains manual. Use “human gate” buttons below to keep Admin informed.
          </div>

          <div className="row" style={{ marginTop: 12, flexWrap:"wrap" }}>
            <button className="btn btnPrimary" onClick={() => setStatus("IN_PROGRESS")}>Start Work</button>
            <button className="btn" onClick={() => runStep(1)}>Run Step 1</button>
            <button className="btn" onClick={() => runStep(2)}>Run Step 2</button>
            <button className="btn" onClick={() => setStatus("SUBMITTED")}>Mark Submitted</button>
            <button className="btn btnDanger" onClick={() => setStatus("FAILED")}>Mark Failed</button>
          </div>

          <div className="row" style={{ marginTop: 10, flexWrap:"wrap" }}>
            {HUMAN_GATES.map(g => (
              <button key={g.key} className="btn" onClick={() => setStatus(g.key)}>{g.label}</button>
            ))}
            <button className="btn" onClick={() => setStatus("COMPLETED")}>Completed</button>
          </div>
        </div>

        {/* RIGHT */}
        <div style={{ display: "grid", gap: 14 }}>
          <div className="card cardPad">
            <div className="row" style={{ justifyContent:"space-between" }}>
              <div className="h2">Session</div>
              {latestSession ? <span className="badge badgeBlue">{latestSession.status || "SESSION"}</span> : <span className="badge">NONE</span>}
            </div>
            <div className="muted" style={{ marginTop: 8 }}>
              {latestSession ? (
                <>
                  <div className="small muted">sessionId</div>
                  <div style={{ fontFamily:"ui-monospace, Menlo, monospace", fontWeight: 900 }}>{latestSession.id}</div>
                  <div className="small muted" style={{ marginTop: 8 }}>expiresAt</div>
                  <div style={{ fontWeight: 900 }}>{latestSession.expiresAt || "-"}</div>
                  <div className="small muted" style={{ marginTop: 8 }}>viewer</div>
                  <div style={{ fontWeight: 900 }}>{vncUrl ? "Ready" : "Worker not attached yet"}</div>
                </>
              ) : (
                <div style={{ lineHeight: 1.5 }}>
                  No sessions yet. Click <b>Start Session</b> to request one.
                </div>
              )}
            </div>
          </div>

          <div className="card cardPad">
            <div className="h2">Attachments</div>
            <div style={{ marginTop: 10, display: "grid", gap: 10 }}>
              {attachments.map((a: any) => (
                <div key={a.id} className="card cardPad" style={{ background:"rgba(255,255,255,.55)", boxShadow:"none" }}>
                  <div style={{ fontWeight: 950 }}>{a.fileName || "Attachment"}</div>
                  {a.url ? (
                    <a href={a.url} target="_blank" rel="noreferrer" className="small" style={{ color:"rgba(59,130,246,.95)", fontWeight:900 }}>
                      Open
                    </a>
                  ) : (
                    <div className="small muted">No URL</div>
                  )}
                </div>
              ))}
              {!attachments.length ? <div className="muted">No attachments.</div> : null}
            </div>
          </div>
        </div>
      </div>

      <div className="small muted" style={{ marginTop: 14 }}>
        Tip: Keep statuses honest. Admin & Client see these states. Use WAITING_FOR_OTP / WAITING_FOR_CAPTCHA to show human gates clearly.
      </div>
    </div>
  );
}
