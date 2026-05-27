
import { useEffect } from "react";
import { createPortal } from "react-dom";
import { cn } from "./utils";

interface ModalProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  children: React.ReactNode;
  /** false: arka plan tıklaması kapatmaz (zorunlu onay diyalogları) */
  closeOnBackdropClick?: boolean;
}

/**
 * Tam ekran diyalog. `document.body` üzerine portallanır (stacking / overflow sorunlarını azaltır).
 * z-index: 1200–1201 — sayfa içeriği üstünde; takvim popover’ı (PopoverContent ~1300) modal panelinin üstünde kalır.
 */
export function Modal({ open, onOpenChange, children, closeOnBackdropClick = true }: ModalProps) {
  useEffect(() => {
    if (open) {
      document.body.style.overflow = "hidden";
    } else {
      document.body.style.overflow = "unset";
    }
    return () => {
      document.body.style.overflow = "unset";
    };
  }, [open]);

  if (!open) return null;

  return createPortal(
    <div
      className="fixed inset-0 z-[1200] flex items-center justify-center p-4"
      role="presentation"
    >
      <div
        className="fixed inset-0 z-[1200] bg-black/50 backdrop-blur-sm dark:bg-black/70"
        onClick={() => {
          if (closeOnBackdropClick) {
            onOpenChange(false);
          }
        }}
        aria-hidden
      />
      <div
        className="relative z-[1201] flex w-full max-w-lg justify-center"
        onMouseDown={(e) => e.stopPropagation()}
      >
        <div className="max-h-[90vh] w-full overflow-y-auto rounded-2xl bg-card text-card-foreground shadow-2xl">
          {children}
        </div>
      </div>
    </div>,
    document.body,
  );
}

export function ModalContent({
  children,
  className,
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return <div className={cn("p-6", className)}>{children}</div>;
}

export function ModalHeader({
  children,
  className,
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return <div className={cn("mb-4", className)}>{children}</div>;
}

export function ModalTitle({ children }: { children: React.ReactNode }) {
  return (
    <h2 className="break-words text-lg leading-tight text-card-foreground sm:text-xl">
      {children}
    </h2>
  );
}

export function ModalDescription({ children }: { children: React.ReactNode }) {
  return <p className="mt-2 text-sm text-muted-foreground">{children}</p>;
}

export function ModalFooter({ children }: { children: React.ReactNode }) {
  return <div className="mt-6 flex justify-end gap-3">{children}</div>;
}
