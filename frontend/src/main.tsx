import { createRoot } from "react-dom/client";
import { ThemeProvider } from "next-themes";
import App from "./App.tsx";
import { AuthProvider } from "./contexts/AuthContext";
import { LanguageProvider } from "./contexts/LanguageContext";
import { ErrorBoundary } from "./components/common/ErrorBoundary";
import "./index.css";
import { initAnalytics } from "./lib/analytics";

initAnalytics();

createRoot(document.getElementById("root")!).render(
  <ThemeProvider
    attribute="class"
    defaultTheme="dark"
    enableSystem={false}
    storageKey="tiempos-theme"
    disableTransitionOnChange
  >
    <LanguageProvider>
      <AuthProvider>
        <ErrorBoundary>
          <App />
        </ErrorBoundary>
      </AuthProvider>
    </LanguageProvider>
  </ThemeProvider>,
);
  