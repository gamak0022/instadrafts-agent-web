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
