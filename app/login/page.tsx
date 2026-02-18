"use client";

import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";

export default function LoginPage() {
  const r = useRouter();
  const [agentId, setAgentId] = useState("");
  const [password, setPassword] = useState("");

  useEffect(() => {
    const existing = localStorage.getItem("agentId");
    if (existing) r.replace("/tasks");
  }, [r]);

  return (
    <div style={{ maxWidth: 820, margin: "0 auto", padding: 28 }}>
      <h1 style={{ fontSize: 44, fontWeight: 950, letterSpacing: -0.5 }}>Agent Login</h1>
      <p style={{ marginTop: 10, opacity: 0.8, maxWidth: 640 }}>
        Login to access your assigned execution tasks. (For MVP, Agent ID is stored locally. Password / Google login will be enabled next.)
      </p>

      <div style={{ marginTop: 18, display: "grid", gap: 12, maxWidth: 520 }}>
        <div>
          <div style={{ fontSize: 12, opacity: 0.7, marginBottom: 6 }}>Agent ID</div>
          <input
            value={agentId}
            onChange={(e) => setAgentId(e.target.value)}
            placeholder="agent_1"
            style={{ width: "100%", padding: 12, borderRadius: 12, border: "1px solid rgba(255,255,255,0.12)", background: "rgba(255,255,255,0.04)", color: "white" }}
          />
        </div>

        <div>
          <div style={{ fontSize: 12, opacity: 0.7, marginBottom: 6 }}>Password</div>
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="••••••••"
            style={{ width: "100%", padding: 12, borderRadius: 12, border: "1px solid rgba(255,255,255,0.12)", background: "rgba(255,255,255,0.04)", color: "white" }}
          />
          <div style={{ fontSize: 12, opacity: 0.65, marginTop: 6 }}>
            Password is not enforced yet (MVP). We will wire real auth next.
          </div>
        </div>

        <div style={{ display: "flex", gap: 10, marginTop: 6 }}>
          <button
            onClick={() => {
              const id = (agentId || "agent_1").trim();
              localStorage.setItem("agentId", id);
              r.push("/tasks");
            }}
            style={{
              padding: "10px 14px",
              borderRadius: 12,
              border: "1px solid #111",
              background: "#fff",
              color: "#111",
              fontWeight: 950,
            }}
          >
            Login
          </button>

          <button
            onClick={() => alert("Google login will be enabled next.")}
            style={{
              padding: "10px 14px",
              borderRadius: 12,
              border: "1px solid rgba(255,255,255,0.16)",
              background: "rgba(255,255,255,0.06)",
              color: "white",
              fontWeight: 900,
            }}
          >
            Continue with Google (soon)
          </button>
        </div>
      </div>
    </div>
  );
}
