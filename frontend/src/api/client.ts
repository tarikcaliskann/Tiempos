import { getApiBaseUrl } from "../config/env";

export class ApiError extends Error {
  status: number;
  body?: unknown;

  constructor(message: string, status: number, body?: unknown) {
    super(message);
    this.name = "ApiError";
    this.status = status;
    this.body = body;
  }
}

export type ApiFetchOptions = RequestInit & {
  token?: string | null;
  /** Varsayılan: sınırsız. Render cold start için auth çağrılarında kullanın. */
  timeoutMs?: number;
};

/** Boş veya anlamsız API mesajlarında yerelleştirilmiş fallback kullanın. */
export function apiErrorDisplayMessage(err: unknown, fallback: string): string {
  if (err instanceof ApiError) {
    const m = err.message.trim();
    if (m && m !== "Forbidden" && m !== "Unauthorized") {
      return m;
    }
    return fallback;
  }
  if (err instanceof Error) {
    const m = err.message.trim();
    return m || fallback;
  }
  return fallback;
}

export async function apiFetch<T>(
  path: string,
  opts: ApiFetchOptions = {},
): Promise<T> {
  const { token, timeoutMs, headers, signal: callerSignal, ...rest } = opts;
  const base = getApiBaseUrl();
  const url = `${base}${path.startsWith("/") ? path : `/${path}`}`;

  const h = new Headers(headers);
  if (
    rest.body != null &&
    !(rest.body instanceof FormData) &&
    !h.has("Content-Type")
  ) {
    h.set("Content-Type", "application/json");
  }
  if (token) {
    h.set("Authorization", `Bearer ${token}`);
  }

  const controller = new AbortController();
  const timeout =
    timeoutMs != null && timeoutMs > 0
      ? window.setTimeout(() => controller.abort(), timeoutMs)
      : undefined;
  if (callerSignal) {
    if (callerSignal.aborted) {
      controller.abort();
    } else {
      callerSignal.addEventListener("abort", () => controller.abort(), {
        once: true,
      });
    }
  }

  let res: Response;
  try {
    res = await fetch(url, {
      ...rest,
      headers: h,
      cache: "no-store",
      signal: controller.signal,
    });
  } catch (err) {
    if (err instanceof Error && err.name === "AbortError") {
      throw new ApiError(
        timeoutMs != null && timeoutMs > 0
          ? "Sunucu yanıt vermedi. Birkaç saniye sonra tekrar deneyin."
          : "İstek iptal edildi.",
        0,
      );
    }
    throw err;
  } finally {
    if (timeout != null) {
      window.clearTimeout(timeout);
    }
  }
  const text = await res.text();
  let data: unknown = null;
  if (text) {
    try {
      data = JSON.parse(text) as unknown;
    } catch {
      data = text;
    }
  }

  if (!res.ok) {
    if (
      res.status === 401 &&
      token &&
      typeof window !== "undefined"
    ) {
      window.dispatchEvent(new Event("timelink:auth-expired"));
    }
    const msg =
      data &&
      typeof data === "object" &&
      data !== null &&
      "message" in data &&
      typeof (data as { message: unknown }).message === "string"
        ? (data as { message: string }).message
        : res.statusText || "";
    throw new ApiError(msg, res.status, data);
  }

  return data as T;
}
