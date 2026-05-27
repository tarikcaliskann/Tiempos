import { BrowserRouter } from "react-router-dom";
import { SessionPreConfirmDock } from "./components/session/SessionPreConfirmDock";
import { useTheme } from "next-themes";
import { Toaster } from "sonner";
import { AppRoutes } from "./navigation/AppRoutes";

// Sayfa türü — navbar ve yönlendirme ile aynı isim
export type PageType =
  | "landing"
  | "browse"
  | "dashboard"
  | "profile"
  | "how-it-works"
  | "add-skill"
  | "past-sessions"
  | "edit-profile"
  | "settings"
  | "messages"
  | "signup"
  | "login"
  | "forgot-password"
  | "reset-password"
  | "skill-detail"
  | "user-profile"
  | "notifications"
  | "about"
  | "community"
  | "contact"
  | "support"
  | "terms"
  | "privacy"
  | "policy-cancellation"
  | "instructor-guide"
  | "faq"
  | "buy-credits"
  | "payment";

export default function App() {
  const { resolvedTheme } = useTheme();

  return (
    <BrowserRouter>
      <div className="flex h-full min-h-0 w-full flex-1 flex-col">
        <div className="app-view">
          <AppRoutes />
        </div>
        <Toaster
          position="top-right"
          richColors
          theme={(resolvedTheme as "light" | "dark") ?? "dark"}
        />
        {/*
          Seans öncesi onay dock’u: route’tan bağımsız, girişli tüm sayfalarda aktif.
          Davranış / env: docs/session-pre-confirm-dock.md
        */}
        <SessionPreConfirmDock />
      </div>
    </BrowserRouter>
  );
}
