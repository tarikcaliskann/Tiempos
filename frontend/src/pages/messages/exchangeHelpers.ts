import type { ExchangeRequestDto } from "../../api/exchange";

export type UiStatus =
  | "pending-incoming"
  | "pending-outgoing"
  | "accepted"
  | "rejected"
  | "cancelled"
  | "completed";

export type ConversationRow = {
  otherUserId: string;
  otherName: string;
  exchanges: ExchangeRequestDto[];
  listUiStatus: UiStatus;
  lastPreview: string;
  sortTime: number;
};

export function tomorrowDateStr(): string {
  const t = new Date();
  t.setDate(t.getDate() + 1);
  return t.toISOString().slice(0, 10);
}

export function firstBookableDefaultStartIso(): string {
  for (let addDays = 1; addDays <= 21; addDays++) {
    const d = new Date();
    d.setDate(d.getDate() + addDays);
    const y = d.getFullYear();
    const mo = String(d.getMonth() + 1).padStart(2, "0");
    const da = String(d.getDate()).padStart(2, "0");
    const dateStr = `${y}-${mo}-${da}`;
    const iso = localDateTimeToUtcIso(dateStr, "10:00");
    if (new Date(iso).getTime() >= Date.now() + 60 * 60 * 1000) {
      return iso;
    }
  }
  return localDateTimeToUtcIso(tomorrowDateStr(), "18:00");
}

export function localDateTimeToUtcIso(dateStr: string, timeStr: string): string {
  const [y, m, d] = dateStr.split("-").map(Number);
  const [hh, mm] = timeStr.split(":").map(Number);
  return new Date(y, m - 1, d, hh || 0, mm || 0, 0, 0).toISOString();
}

export function ymdToLocalDate(ymd: string): Date {
  const [y, m, d] = ymd.split("-").map(Number);
  return new Date(y, m - 1, d, 12, 0, 0, 0);
}

export function formatScheduledAt(
  iso: string | null | undefined,
  locale: string,
): string {
  if (!iso) return "—";
  return new Date(iso).toLocaleString(locale === "tr" ? "tr-TR" : "en-US", {
    dateStyle: "medium",
    timeStyle: "short",
  });
}

export function getOtherUserId(
  ex: ExchangeRequestDto,
  myId: string | undefined,
): string {
  return sameUserId(ex.requesterId, myId) ? ex.ownerId : ex.requesterId;
}

export function normalizeExchangeStatus(status: string | undefined): string {
  return String(status ?? "")
    .trim()
    .toUpperCase();
}

export function isPendingExchangeStatus(status: string | undefined): boolean {
  return normalizeExchangeStatus(status) === "PENDING";
}

export function isMessageEnabledStatus(status: string | undefined): boolean {
  const st = normalizeExchangeStatus(status);
  return (
    st === "ACCEPTED" ||
    st === "REJECTED" ||
    st === "CANCELLED" ||
    st === "COMPLETED"
  );
}

export function sameUserId(a: string | undefined, b: string | undefined): boolean {
  if (a == null || b == null) return false;
  return a.toLowerCase() === b.toLowerCase();
}

export function isRequesterSkillBookingSide(
  ex: ExchangeRequestDto,
  myId: string | undefined,
): boolean {
  if (!myId) return false;
  if (sameUserId(ex.requesterId, myId)) return true;
  const st = normalizeExchangeStatus(ex.status);
  if (
    ex.pendingFromOwner &&
    (st === "PENDING" || st === "REJECTED") &&
    !sameUserId(ex.ownerId, myId)
  ) {
    return true;
  }
  return false;
}

export function isPendingOutgoingForMe(
  ex: ExchangeRequestDto,
  myId: string | undefined,
): boolean {
  const pendingFromOwner = Boolean(ex.pendingFromOwner);
  if (pendingFromOwner) {
    return sameUserId(ex.ownerId, myId);
  }
  return sameUserId(ex.requesterId, myId);
}

export function isInitialMessageFromMe(
  ex: ExchangeRequestDto,
  myId: string | undefined,
): boolean {
  if (normalizeExchangeStatus(ex.status) === "PENDING" && ex.pendingFromOwner) {
    return sameUserId(ex.ownerId, myId);
  }
  return sameUserId(ex.requesterId, myId);
}

export function toUiStatus(
  ex: ExchangeRequestDto,
  myId: string | undefined,
): UiStatus {
  const st = normalizeExchangeStatus(ex.status);
  if (st === "CANCELLED") return "cancelled";
  if (st === "ACCEPTED") return "accepted";
  if (st === "REJECTED") return "rejected";
  if (st === "COMPLETED") return "completed";
  if (st === "PENDING") {
    if (!myId) return "pending-outgoing";
    return isPendingOutgoingForMe(ex, myId)
      ? "pending-outgoing"
      : "pending-incoming";
  }
  return "completed";
}

export function canCancelExchange(
  ex: ExchangeRequestDto,
  myId: string | undefined,
): boolean {
  if (!myId) return false;
  const st = normalizeExchangeStatus(ex.status);
  if (st === "PENDING" && sameUserId(ex.requesterId, myId)) return true;
  if (st === "ACCEPTED") {
    if (!sameUserId(ex.requesterId, myId) && !sameUserId(ex.ownerId, myId)) {
      return false;
    }
    if (!ex.scheduledStartAt) return true;
    return Date.now() < new Date(ex.scheduledStartAt).getTime();
  }
  return false;
}

export function mergeExchanges(
  sent: ExchangeRequestDto[],
  received: ExchangeRequestDto[],
  myId: string | undefined,
): ConversationRow[] {
  const map = new Map<string, ExchangeRequestDto>();
  for (const e of sent) map.set(e.id, e);
  for (const e of received) map.set(e.id, e);
  const byOther = new Map<string, ExchangeRequestDto[]>();
  for (const ex of map.values()) {
    const oid = getOtherUserId(ex, myId);
    const list = byOther.get(oid) ?? [];
    list.push(ex);
    byOther.set(oid, list);
  }
  const rows: ConversationRow[] = [];
  for (const [oid, exs] of byOther) {
    exs.sort(
      (a, b) =>
        new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime(),
    );
    const latest = exs[0];
    const otherName = sameUserId(latest.requesterId, myId)
      ? latest.ownerName
      : latest.requesterName;
    const sortTime = Math.max(
      ...exs.map((e) => new Date(e.createdAt).getTime()),
    );
    const last =
      latest.message.length > 100
        ? `${latest.message.slice(0, 100)}…`
        : latest.message;
    rows.push({
      otherUserId: oid,
      otherName,
      exchanges: exs,
      listUiStatus: toUiStatus(latest, myId),
      lastPreview: last,
      sortTime,
    });
  }
  rows.sort((a, b) => b.sortTime - a.sortTime);
  return rows;
}

export function findExchangeInRows(
  rows: ConversationRow[],
  exchangeId: string,
): ExchangeRequestDto | undefined {
  const id = exchangeId.toLowerCase();
  for (const r of rows) {
    const ex = r.exchanges.find((e) => e.id.toLowerCase() === id);
    if (ex) return ex;
  }
  return undefined;
}
