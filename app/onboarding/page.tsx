"use client";

import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";

export default function OnboardingPage() {
  const r = useRouter();
  const [agentId, setAgentId] = useState("agent_1");

  useEffect(() => {
    const existing = localStorage.getItem("agentId");
    if (existing) setAgentId(existing);
  }, []);

  return (
    <div className="container">
      <div className="grid2" style={{ alignItems: "start" }}>
        <div className="card cardPad">
          <div className="h1">Welcome to Agent Workbench</div>
          <p className="muted" style={{ marginTop: 10, lineHeight: 1.5 }}>
            Execute portal tasks assigned by Admin. Automation helps with typing/navigation.
            <b> OTP, captcha, and document collection remain manual</b> (human gates).
          </p>

          <div className="hr" />

          <div style={{ maxWidth: 520 }}>
            <div className="small muted" style={{ marginBottom: 8 }}>Agent ID</div>
            <input className="input" value={agentId} onChange={(e)=>setAgentId(e.target.value)} placeholder="agent_1" />

            <div className="row" style={{ marginTop: 12 }}>
              <button
                className="btn btnPrimary"
                onClick={() => {
                  localStorage.setItem("agentId", (agentId || "agent_1").trim());
                  r.push("/tasks");
                }}
              >
                Continue
              </button>
              <button className="btn" onClick={() => r.push("/login")}>Use Login screen</button>
            </div>

            <div className="small muted" style={{ marginTop: 14 }}>
              Next: proper auth (password + Google), session worker (VNC), and step-run buttons.
            </div>
          </div>
        </div>

        <div className="card cardPad">
          <div className="h2">How execution works</div>
          <div style={{ marginTop: 12, display: "grid", gap: 10 }}>
            <div className="card cardPad" style={{ background: "rgba(255,255,255,.55)" }}>
              <div style={{ fontWeight: 950 }}>1) Admin assigns you a task</div>
              <div className="small muted" style={{ marginTop: 6 }}>It appears under Tasks with status ASSIGNED.</div>
            </div>
            <div className="card cardPad" style={{ background: "rgba(255,255,255,.55)" }}>
              <div style={{ fontWeight: 950 }}>2) Start Session</div>
              <div className="small muted" style={{ marginTop: 6 }}>Opens a time-boxed session (Playwright worker later).</div>
            </div>
            <div className="card cardPad" style={{ background: "rgba(255,255,255,.55)" }}>
              <div style={{ fontWeight: 950 }}>3) Human gates</div>
              <div className="small muted" style={{ marginTop: 6 }}>OTP/captcha handled by you. Mark status accordingly.</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
