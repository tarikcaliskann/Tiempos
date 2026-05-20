/** Render static site — /api proxy yoksa doğrudan Spring API. */
const PRODUCTION_API_HOSTS = new Set([
  "tiempos.site",
  "www.tiempos.site",
  "tiempo-project.onrender.com",
]);

const DEFAULT_PRODUCTION_API =
  "https://tiempos-backend-w26e.onrender.com";

/** Sondaki / ve yanlışlıkla eklenen /api sonekini kaldırır (çift /api → 403). */
function normalizeApiBaseUrl(raw: string): string {
  let s = raw.trim().replace(/\/+$/, "");
  if (s.endsWith("/api")) {
    s = s.slice(0, -4).replace(/\/+$/, "");
  }
  return s;
}

/**
 * Backend base URL. No trailing slash.
 * - Boş: aynı origin `/api` (Vite proxy, Docker nginx, Render /api rewrite)
 * - Dolu: `VITE_API_BASE_URL` (build-time)
 * - Canlı domain, env boş: `VITE_PRODUCTION_API_URL` veya varsayılan Render API
 */
export function getApiBaseUrl(): string {
  const raw = import.meta.env.VITE_API_BASE_URL as string | undefined;
  if (raw !== undefined && raw.trim() !== "") {
    return normalizeApiBaseUrl(raw);
  }
  if (typeof window !== "undefined" && PRODUCTION_API_HOSTS.has(window.location.hostname)) {
    const fallback = import.meta.env.VITE_PRODUCTION_API_URL as string | undefined;
    const url = normalizeApiBaseUrl(fallback?.trim() || DEFAULT_PRODUCTION_API);
    return url;
  }
  return "";
}
