import type { ReactNode } from "react";

/**
 * Auth screens: blue–purple gradient (Tailwind from-blue-500 to-purple-600) + light depth.
 */
export function AuthPageShell({ children }: { children: ReactNode }) {
  return (
    <div className="tiempos-auth-shell">
      <div className="tiempos-auth-shell__backdrop" aria-hidden>
        <span className="tiempos-auth-shell__glow tiempos-auth-shell__glow--tr" />
        <span className="tiempos-auth-shell__glow tiempos-auth-shell__glow--bl" />
      </div>
      <div className="tiempos-auth-shell__scroll">
        <div className="tiempos-auth-shell__inner">{children}</div>
      </div>
    </div>
  );
}
