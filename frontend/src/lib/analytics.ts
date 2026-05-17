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

export function initAnalytics(): boolean {
  if (initialized) return true;
  const id = getGaMeasurementId();
  if (!id) return false;
  ReactGA.initialize(id);
  initialized = true;
  return true;
}

/** SPA route değişiminde sayfa görüntüleme */
export function trackPageView(path: string): void {
  if (!initAnalytics()) return;
  ReactGA.send({ hitType: "pageview", page: path });
}
