"use client";

import { useEffect } from "react";
import { usePathname, useRouter } from "next/navigation";

function hasAgentSession(): boolean {
  try {
    const v = localStorage.getItem("agentId");
    return !!(v && v.trim());
  } catch {
    return false;
  }
}

export default function AuthGate({ children }: { children: React.ReactNode }) {
  const r = useRouter();
  const path = usePathname();

  useEffect(() => {
    const publicPaths = ["/onboarding", "/login"];
    const isPublic = publicPaths.some((p) => path === p || path.startsWith(p + "/"));

    if (!isPublic && !hasAgentSession()) {
      r.replace("/onboarding");
    }
  }, [path, r]);

  return <>{children}</>;
}
