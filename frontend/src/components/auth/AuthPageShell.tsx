import type { ReactNode } from "react";

/**
 * Auth screens: primary dark blue gradient (#1D4ED8 → #1E3A8A) + light depth.
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
