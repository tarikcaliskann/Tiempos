import type { ReactNode } from "react";
import type { PageType } from "../../App";
import { Navbar } from "./Navbar";
import { Footer } from "./Footer";
import { cn } from "../ui/utils";

interface PageLayoutProps {
  children: ReactNode;
  onNavigate?: (page: PageType) => void;
  className?: string;
  /** Tam ekran sayfalar (mesajlar): alt footer gizlenir, içerik kalan yüksekliği doldurur */
  hideFooter?: boolean;
}

export function PageLayout({
  children,
  onNavigate,
  className,
  hideFooter = false,
}: PageLayoutProps) {
  return (
    <div
      className={cn(
        "flex flex-col bg-background text-foreground antialiased transition-colors",
        hideFooter
          ? "h-dvh max-h-dvh min-h-0 overflow-hidden overscroll-none"
          : "min-h-dvh",
        className,
      )}
    >
      <Navbar onNavigate={onNavigate} />
      <main
        className={cn(
          "flex min-h-0 w-full max-w-full flex-1 flex-col",
          hideFooter && "overflow-hidden",
        )}
      >
        {children}
      </main>
      {!hideFooter ? <Footer /> : null}
    </div>
  );
}
