"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";

export default function Home() {
  const router = useRouter();

  useEffect(() => {
    const done = localStorage.getItem("agent_onboarding_done") === "true";
    const agentId = (localStorage.getItem("agent_id") || "").trim();

    if (!done || !agentId) {
      router.replace("/onboarding");
      return;
    }
    router.replace("/tasks");
  }, [router]);

  return (
    <div className="pageCenter">
      <div className="card">
        <div className="h1">Loading…</div>
        <p className="muted">Preparing your agent console.</p>
      </div>
    </div>
  );
}
