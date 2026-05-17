/**
 * Backend base URL. No trailing slash.
 * - Boş: aynı origin üzerinden `/api` (Vite dev proxy, Docker nginx, Render rewrite)
 * - Dolu: doğrudan tam URL (ayrı backend host — build-time `VITE_API_BASE_URL`)
 */
export function getApiBaseUrl(): string {
  const raw = import.meta.env.VITE_API_BASE_URL as string | undefined;
  if (raw !== undefined && raw.trim() !== "") {
    return raw.replace(/\/$/, "");
  }
  return "";
}
