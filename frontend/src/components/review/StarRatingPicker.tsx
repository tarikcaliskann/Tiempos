import { Star } from "lucide-react";
import { cn } from "../ui/utils";

type Props = {
  value: number;
  onChange: (rating: number) => void;
  disabled?: boolean;
  size?: "sm" | "md" | "lg";
  ariaLabel: string;
};

export function StarRatingPicker({ value, onChange, disabled, size = "md", ariaLabel }: Props) {
  const iconClass =
    size === "sm" ? "h-6 w-6" : size === "lg" ? "h-10 w-10" : "h-8 w-8";
  return (
    <div className="flex gap-0.5" role="group" aria-label={ariaLabel}>
      {[1, 2, 3, 4, 5].map((n) => (
        <button
          key={n}
          type="button"
          disabled={disabled}
          className={cn(
            "rounded p-0.5 transition-transform hover:scale-105 disabled:opacity-50",
          )}
          onClick={() => onChange(n)}
          aria-label={`${n}`}
          aria-pressed={n <= value}
        >
          <Star
            className={cn(
              iconClass,
              n <= value ? "fill-amber-400 text-amber-400" : "text-muted-foreground/35",
            )}
          />
        </button>
      ))}
    </div>
  );
}
