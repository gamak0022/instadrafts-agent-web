#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"
APP="$ROOT/app"
TS="$(date +%Y%m%d_%H%M%S)"

if [ ! -d "$APP" ]; then
  echo "❌ Expected Next.js app router folder at $APP"
  exit 1
fi

backup_if_exists() {
  local f="$1"
  if [ -f "$f" ]; then
    cp -v "$f" "${f}.bak_${TS}"
  fi
}

mkdir -p "$APP/lib" "$APP/task/[taskId]" "$APP/tasks" "$APP/onboarding"

# -------------------------
# 1) Agent API client
# -------------------------
cat > "$APP/lib/agentApi.ts" <<'TS'
export const API_BASE =
  process.env.NEXT_PUBLIC_API_BASE || "http://localhost:8080";

export function getAgentId(): string {
  if (typeof window === "undefined") return "agent_1";
  return localStorage.getItem("agentId") || "agent_1";
}

export function setAgentId(id: string) {
  if (typeof window === "undefined") return;
  localStorage.setItem("agentId", id || "agent_1");
}

async function parseJsonSafe(res: Response) {
  const txt = await res.text();
  try { return JSON.parse(txt); } catch { return { ok: false, error: { message: txt || "NON_JSON_RESPONSE" } }; }
}

export async function agentGet(path: string, agentId: string) {
  const res = await fetch(`${API_BASE}${path}`, {
    headers: {
      "x-user-role": "AGENT",
      "x-user-id": agentId,
    },
    cache: "no-store",
  });
  return parseJsonSafe(res);
}

export async function agentPost(path: string, agentId: string, body?: any) {
  const res = await fetch(`${API_BASE}${path}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-user-role": "AGENT",
      "x-user-id": agentId,
    },
    body: JSON.stringify(body || {}),
  });
  return parseJsonSafe(res);
}
TS

# -------------------------
# 2) Onboarding page
# -------------------------
# If onboarding exists, back it up and replace with a clean v1
if [ -f "$APP/onboarding/page.tsx" ]; then backup_if_exists "$APP/onboarding/page.tsx"; fi
if [ -f "$APP/onboarding/page.js" ]; then backup_if_exists "$APP/onboarding/page.js"; fi

cat > "$APP/onboarding/page.tsx" <<'TSX'
"use client";

import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { getAgentId, setAgentId } from "../lib/agentApi";

export default function OnboardingPage() {
  const r = useRouter();
  const [agentId, setId] = useState("agent_1");

  useEffect(() => {
    setId(getAgentId());
  }, []);

  return (
    <div style={{ maxWidth: 760, margin: "0 auto", padding: 24 }}>
      <h1 style={{ fontSize: 28, fontWeight: 900 }}>Instadrafts Agent Workbench</h1>
      <p style={{ marginTop: 8, opacity: 0.8 }}>
        Sign-in is header-based for now. Set your Agent ID to load your assigned tasks.
      </p>

      <div style={{ marginTop: 16 }}>
        <label style={{ display: "block", fontWeight: 800 }}>Agent ID</label>
        <input
          value={agentId}
          onChange={(e) => setId(e.target.value)}
          style={{
            width: "100%",
            padding: 10,
            marginTop: 8,
            border: "1px solid #ddd",
            borderRadius: 10,
          }}
          placeholder="agent_1"
        />
      </div>

      <button
        onClick={() => {
          setAgentId((agentId || "agent_1").trim());
          r.push("/tasks");
        }}
        style={{
          marginTop: 16,
          padding: "10px 14px",
          borderRadius: 10,
          border: "1px solid #111",
          background: "#111",
          color: "#fff",
          fontWeight: 900,
        }}
      >
        Continue
      </button>
    </div>
  );
}
TSX

# -------------------------
# 3) Tasks list page (app/tasks/page.tsx)
# -------------------------
backup_if_exists "$APP/tasks/page.tsx"
backup_if_exists "$APP/tasks/page.js"

cat > "$APP/tasks/page.tsx" <<'TSX'
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
TSX

# -------------------------
# 4) Task detail page (app/task/[taskId]/page.tsx)
# -------------------------
backup_if_exists "$APP/task/[taskId]/page.tsx"
backup_if_exists "$APP/task/[taskId]/page.js"

cat > "$APP/task/[taskId]/page.tsx" <<'TSX'
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
TSX

echo "✅ Wired agent-web repo to Cloud Run Agent APIs"
echo "➡️ Set NEXT_PUBLIC_API_BASE in Vercel env to your API URL"
