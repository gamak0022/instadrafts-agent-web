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
