import ReactGA from "react-ga4";

let initialized = false;

/** GA4 ölçüm kimliği (G-XXXXXXXX). Tanımlı değilse analitik kapalı kalır. */
export function getGaMeasurementId(): string | undefined {
  const raw = import.meta.env.VITE_GA_MEASUREMENT_ID as string | undefined;
  const id = raw?.trim();
  if (!id || !id.startsWith("G-")) return undefined;
  return id;
}

export function isAnalyticsEnabled(): boolean {
  return getGaMeasurementId() != null;
}

function gtagOnWindow(): boolean {
  return (
    typeof window !== "undefined" &&
    typeof window.gtag === "function"
  );
}

export function initAnalytics(): boolean {
  if (initialized) return true;
  const id = getGaMeasurementId();
  if (!id) return false;
  // index.html'e build sırasında eklenen resmi gtag varsa tekrar initialize etme
  if (gtagOnWindow()) {
    initialized = true;
    return true;
  }
  ReactGA.initialize(id);
  initialized = true;
  return true;
}

/** SPA route değişiminde sayfa görüntüleme */
export function trackPageView(path: string): void {
  const id = getGaMeasurementId();
  if (!id) return;

  if (gtagOnWindow()) {
    window.gtag!("config", id, { page_path: path });
    return;
  }

  if (!initAnalytics()) return;
  ReactGA.send({ hitType: "pageview", page: path });
}

declare global {
  interface Window {
    gtag?: (...args: unknown[]) => void;
    dataLayer?: unknown[];
  }
}
