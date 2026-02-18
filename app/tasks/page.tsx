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

function badgeClass(status?: string){
  const s = String(status||"").toUpperCase();
  if (s.includes("OTP") || s.includes("CAPTCHA")) return "badge badgeAmber";
  if (s.includes("IN_PROGRESS")) return "badge badgeBlue";
  if (s.includes("COMPLETE")) return "badge badgeGreen";
  if (s.includes("FAIL")) return "badge badgeRed";
  return "badge";
}

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
    <div className="container">
      <div className="row" style={{ justifyContent: "space-between", alignItems: "flex-end" }}>
        <div>
          <div className="h1">My Tasks</div>
          <div className="muted" style={{ marginTop: 10 }}>
            Agent: <b>{agentId}</b> • <Link href="/onboarding">change</Link>
          </div>
        </div>

        <div className="row">
          <div>
            <div className="small muted" style={{ marginBottom: 8 }}>Status</div>
            <select
              className="select"
              value={status}
              onChange={(e) => {
                const v = e.target.value;
                setStatus(v);
                load(agentId, v);
              }}
              style={{ minWidth: 220 }}
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
          <button className="btn btnPrimary" onClick={() => load(agentId, status)}>Refresh</button>
        </div>
      </div>

      {err ? <div className="card cardPad" style={{ marginTop: 14, borderColor: "rgba(239,68,68,.30)", background:"rgba(239,68,68,.08)" }}>{err}</div> : null}

      <div style={{ marginTop: 16, display: "grid", gap: 12 }}>
        {tasks.map((t) => (
          <Link key={t.id} href={`/task/${t.id}`} style={{ textDecoration: "none" }}>
            <div className="card cardPad">
              <div className="row" style={{ justifyContent: "space-between" }}>
                <div style={{ fontWeight: 950 }}>{t.type || "TASK"}</div>
                <span className={badgeClass(t.status)}>{t.status}</span>
              </div>
              <div className="muted" style={{ marginTop: 10 }}>
                <span style={{ fontFamily: "ui-monospace, SFMono-Regular, Menlo, monospace" }}>{t.id}</span>
                {" • case: "}
                <span style={{ fontFamily: "ui-monospace, SFMono-Regular, Menlo, monospace" }}>{t.caseId}</span>
              </div>
              {t.updatedAt ? <div className="small muted" style={{ marginTop: 8 }}>updated: {t.updatedAt}</div> : null}
            </div>
          </Link>
        ))}

        {!tasks.length && !err ? (
          <div className="card cardPad" style={{ marginTop: 4 }}>
            <div style={{ fontWeight: 950 }}>No tasks assigned yet</div>
            <div className="muted" style={{ marginTop: 6 }}>
              Once Admin assigns tasks to your Agent ID, they will appear here. You can keep this page open and hit Refresh.
            </div>
          </div>
        ) : null}
      </div>
    </div>
  );
}
