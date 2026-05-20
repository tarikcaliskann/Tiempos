import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from "react";
import { fetchMyProfile } from "../api/user";

const AUTH_STORAGE_KEY = "tiempos_auth";
const AUTH_SESSION_KEY = "tiempos_auth_session";
const LEGACY_USER_KEY = "tiempos_user";

/** localStorage ~5MB; base64 profil fotoğrafı diske yazılmaz (API tek kaynak). Bellekte tam URL kalır. */
function userForLocalStorage(u: AuthUser): AuthUser {
  const av = u.avatarUrl;
  if (av != null && av.startsWith("data:")) {
    return { ...u, avatarUrl: null };
  }
  return u;
}

export type AuthUser = {
  /** Backend user id (UUID string) when logged in via API */
  id?: string;
  name: string;
  email: string;
  role?: string;
  /** Profil fotoğrafı (data URL veya URL), isteğe bağlı */
  avatarUrl?: string | null;
};

type AuthContextValue = {
  user: AuthUser | null;
  token: string | null;
  isAuthenticated: boolean;
  login: (user: AuthUser, token: string, rememberMe?: boolean) => void;
  logout: () => void;
  /** Oturumdaki kullanıcıyı günceller (ör. profil kaydından sonra ad). */
  patchUser: (patch: Partial<AuthUser>) => void;
};

const AuthContext = createContext<AuthContextValue | null>(null);

function readStoredSession(): { user: AuthUser; token: string } | null {
  const tryParse = (raw: string | null) => {
    if (!raw) return null;
    const parsed = JSON.parse(raw) as {
      token?: string;
      user?: AuthUser;
    };
    if (parsed?.token && parsed?.user?.email && parsed?.user?.name) {
      return { token: parsed.token, user: parsed.user };
    }
    return null;
  };

  try {
    const persistent = tryParse(localStorage.getItem(AUTH_STORAGE_KEY));
    if (persistent) return persistent;

    const session = tryParse(sessionStorage.getItem(AUTH_SESSION_KEY));
    if (session) return session;

    if (localStorage.getItem(LEGACY_USER_KEY)) {
      localStorage.removeItem(LEGACY_USER_KEY);
    }
  } catch {
    /* ignore */
  }
  return null;
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(() => {
    if (typeof window === "undefined") return null;
    return readStoredSession()?.user ?? null;
  });
  const [token, setToken] = useState<string | null>(() => {
    if (typeof window === "undefined") return null;
    return readStoredSession()?.token ?? null;
  });

  const login = useCallback(
    (next: AuthUser, nextToken: string, rememberMe = true) => {
      const payload = JSON.stringify({
        user: userForLocalStorage(next),
        token: nextToken,
      });

      setUser(next);
      setToken(nextToken);
      if (rememberMe) {
        localStorage.setItem(AUTH_STORAGE_KEY, payload);
        sessionStorage.removeItem(AUTH_SESSION_KEY);
      } else {
        sessionStorage.setItem(AUTH_SESSION_KEY, payload);
        localStorage.removeItem(AUTH_STORAGE_KEY);
      }
      localStorage.removeItem(LEGACY_USER_KEY);
    },
    [],
  );

  const logout = useCallback(() => {
    setUser(null);
    setToken(null);
    localStorage.removeItem(AUTH_STORAGE_KEY);
    sessionStorage.removeItem(AUTH_SESSION_KEY);
    localStorage.removeItem(LEGACY_USER_KEY);
  }, []);

  useEffect(() => {
    const onAuthExpired = () => logout();
    window.addEventListener("tiempos:auth-expired", onAuthExpired);
    return () =>
      window.removeEventListener("tiempos:auth-expired", onAuthExpired);
  }, [logout]);

  const patchUser = useCallback((patch: Partial<AuthUser>) => {
    setUser((prev) => {
      if (!prev) return prev;
      const next = { ...prev, ...patch };
      try {
        const raw = localStorage.getItem(AUTH_STORAGE_KEY);
        if (raw) {
          const parsed = JSON.parse(raw) as {
            token?: string;
            user?: AuthUser;
          };
          if (parsed?.token) {
            localStorage.setItem(
              AUTH_STORAGE_KEY,
              JSON.stringify({
                user: userForLocalStorage(next),
                token: parsed.token,
              }),
            );
          }
        }
        const sessionRaw = sessionStorage.getItem(AUTH_SESSION_KEY);
        if (sessionRaw) {
          const parsed = JSON.parse(sessionRaw) as {
            token?: string;
            user?: AuthUser;
          };
          if (parsed?.token) {
            sessionStorage.setItem(
              AUTH_SESSION_KEY,
              JSON.stringify({
                user: userForLocalStorage(next),
                token: parsed.token,
              }),
            );
          }
        }
      } catch {
        /* ignore */
      }
      return next;
    });
  }, []);

  /** Eski kayıtlı oturumlarda `id` eksik olabilir; UUID olmadan talep sahibi eşleşmesi çalışmaz (ör. mesajlar rezervasyon modalı). */
  useEffect(() => {
    if (!token || !user || user.id) return;
    let cancelled = false;
    void (async () => {
      try {
        const p = await fetchMyProfile(token);
        if (!cancelled && p?.id) {
          patchUser({ id: p.id });
        }
      } catch {
        /* ağ / 401 — sessiz */
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [token, user, patchUser]);

  const value = useMemo(
    () => ({
      user,
      token,
      isAuthenticated: user !== null && token !== null,
      login,
      logout,
      patchUser,
    }),
    [user, token, login, logout, patchUser],
  );

  return (
    <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
  );
}

export function useAuth(): AuthContextValue {
  const ctx = useContext(AuthContext);
  if (!ctx) {
    throw new Error("useAuth must be used within AuthProvider");
  }
  return ctx;
}
