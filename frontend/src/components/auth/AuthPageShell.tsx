import type { ReactNode } from "react";

/**
 * Auth screens: outer fills the app column (gradient, no empty band);
 * inner is at least full height and centers content; inner scrolls when the form is taller than the viewport.
 */
export function AuthPageShell({ children }: { children: ReactNode }) {
  return (
    <div
      className={
        "flex min-h-0 w-full flex-1 flex-col overflow-hidden " +
        "bg-gradient-to-br from-blue-500 via-purple-600 to-indigo-700"
      }
    >
      <div
        className={
          "flex w-full flex-1 min-h-0 flex-col items-center justify-center overflow-x-hidden overflow-y-auto overscroll-y-contain " +
          "px-4 sm:px-6 " +
          "py-6 sm:py-10 " +
          "pt-[max(1.25rem,calc(0.5rem+env(safe-area-inset-top,0px)))] " +
          "pb-[max(1.25rem,calc(0.5rem+env(safe-area-inset-bottom,0px)))]"
        }
      >
        <div className="mx-auto w-full max-w-md shrink-0 py-1 sm:py-2">{children}</div>
      </div>
    </div>
  );
}
