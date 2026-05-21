import type { SkillDto } from "../api/skills";

export function skillCardDescriptionPreview(description: string): string {
  const sep = "\n\n———\n";
  const idx = description.indexOf(sep);
  if (idx >= 0) {
    return description.slice(0, idx).trim();
  }

  const filtered = description
    .split("\n")
    .map((line) => line.trim())
    .filter(Boolean)
    .filter((line) => {
      const lower = line.toLowerCase();
      return !(
        lower.startsWith("session type") ||
        lower.startsWith("oturum türü") ||
        lower.startsWith("location") ||
        lower.startsWith("konum") ||
        lower.startsWith("available days") ||
        lower.startsWith("müsait günler") ||
        lower.startsWith("available from") ||
        lower.startsWith("başlangıç") ||
        lower.startsWith("available until") ||
        lower.startsWith("bitiş") ||
        lower.startsWith("tags") ||
        lower.startsWith("etiketler")
      );
    });

  return filtered.join(" ").trim();
}

export function fallbackSessionTypeFromDescription(
  description: string,
): string | null {
  const m = description.match(
    /(?:Session Type \*|Oturum türü \*)\s*:\s*([^\n]+)/i,
  );
  return m?.[1]?.trim() || null;
}

export function fallbackLocationFromDescription(
  description: string,
): string | null {
  const m = description.match(/(?:Location|Konum)\s*:\s*([^\n]+)/i);
  return m?.[1]?.trim() || null;
}

const WEEKDAY_LABEL_INDEX: Record<string, number> = {
  MONDAY: 0,
  TUESDAY: 1,
  WEDNESDAY: 2,
  THURSDAY: 3,
  FRIDAY: 4,
  SATURDAY: 5,
  SUNDAY: 6,
};

const WEEKDAY_SORT_ORDER: Record<string, number> = {
  MONDAY: 0,
  TUESDAY: 1,
  WEDNESDAY: 2,
  THURSDAY: 3,
  FRIDAY: 4,
  SATURDAY: 5,
  SUNDAY: 6,
};

export type SkillAvailabilityParts = { days: string; hours: string };

function localizeSkillDays(dayKeys: string[], dayLabels: string[]): string {
  return dayKeys
    .map((key) => ({
      key: key.toUpperCase(),
      label: dayLabels[WEEKDAY_LABEL_INDEX[key.toUpperCase()]] ?? key,
      order: WEEKDAY_SORT_ORDER[key.toUpperCase()] ?? 99,
    }))
    .filter((d) => Boolean(d.label))
    .sort((a, b) => a.order - b.order)
    .map((d) => d.label)
    .join(", ");
}

export function getSkillAvailabilityParts(
  skill: SkillDto,
  dayLabels: string[],
): SkillAvailabilityParts | null {
  const days = skill.availableDays ?? [];
  const from = skill.availableFrom;
  const until = skill.availableUntil;
  if (!days.length || !from || !until) return null;
  return {
    days: localizeSkillDays(days, dayLabels),
    hours: `${from} – ${until}`,
  };
}

export function fallbackAvailabilityFromDescription(
  description: string,
  dayLabels: string[],
): SkillAvailabilityParts | null {
  const raw =
    description.match(
      /(Available Days \*|Müsait günler \*):\s*([^\n]+?)\s+(Available From \*|Başlangıç \*)[–-](Available Until \*|Bitiş \*):\s*(\d{2}:\d{2})\s*[–-]\s*(\d{2}:\d{2})/i,
    ) ??
    description.match(
      /(Available Days \*|Müsait günler \*):\s*([^\n]+)\n(?:.*)\s*(\d{2}:\d{2})\s*[–-]\s*(\d{2}:\d{2})/i,
    );
  if (!raw) return null;
  const daysRaw = raw[2]?.trim();
  const from = raw[5] ?? raw[3];
  const until = raw[6] ?? raw[4];
  if (!daysRaw || !from || !until) return null;
  const dayKeys = daysRaw
    .split(",")
    .map((d) => d.trim())
    .filter(Boolean)
    .map((d) => d.toUpperCase().replace(/\s+/g, "_"));
  return {
    days: localizeSkillDays(dayKeys, dayLabels),
    hours: `${from} – ${until}`,
  };
}
