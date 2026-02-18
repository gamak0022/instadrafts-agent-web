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
