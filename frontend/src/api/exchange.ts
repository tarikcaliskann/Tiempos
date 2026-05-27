import { apiFetch } from "./client";

export type ExchangeRequestDto = {
  id: string;
  skillId: string;
  skillTitle: string;
  requesterId: string;
  requesterName: string;
  requesterEmail?: string;
  ownerId: string;
  ownerName: string;
  ownerEmail?: string;
  message: string;
  bookedMinutes: number;
  /** ISO-8601 instant */
  scheduledStartAt?: string | null;
  pendingFromOwner?: boolean;
  /** Mesaj / tanışma talebi: kredi eğitmen kabulünde düşer */
  inquiryOnly?: boolean;
  status: string;
  createdAt: string;
  sessionMeetingUrl?: string | null;
  requesterAttendanceAckAt?: string | null;
  ownerAttendanceAckAt?: string | null;
  preSessionConfirmSent?: boolean;
  requesterPreSessionResponse?: string | null;
  ownerPreSessionResponse?: string | null;
  preSessionBothConfirmedAt?: string | null;
  /** PRE_CONFIRM | WAITING_START | LIVE | DONE | ENDED */
  sessionDockPhase?: string | null;
  scheduledEndAt?: string | null;
  creditsSettledAt?: string | null;
  settledMinutes?: number | null;
  sessionStoppedAt?: string | null;
  sessionStopReason?: string | null;
};

export type ExchangeMessageDto = {
  id: string;
  senderId: string;
  senderName: string;
  body: string;
  createdAt: string;
};

export function createExchangeRequest(
  token: string,
  skillId: string,
  body: {
    message: string;
    bookedMinutes: number;
    scheduledStartAt: string;
    /** true: mesaj / tanışma talebi — kredi eğitmen kabulünde düşer */
    inquiryOnly?: boolean;
  },
) {
  return apiFetch<ExchangeRequestDto>(
    `/api/exchange-requests/skill/${skillId}`,
    {
      method: "POST",
      token,
      body: JSON.stringify(body),
    },
  );
}

export function fetchSentExchangeRequests(token: string) {
  return apiFetch<ExchangeRequestDto[]>("/api/exchange-requests/sent", {
    method: "GET",
    token,
  });
}

export function fetchReceivedExchangeRequests(token: string) {
  return apiFetch<ExchangeRequestDto[]>("/api/exchange-requests/received", {
    method: "GET",
    token,
  });
}

export function fetchExchangeMessages(token: string, exchangeRequestId: string) {
  return apiFetch<ExchangeMessageDto[]>(
    `/api/exchange-requests/${exchangeRequestId}/messages`,
    { method: "GET", token },
  );
}

export function postExchangeMessage(
  token: string,
  exchangeRequestId: string,
  body: string,
) {
  return apiFetch<ExchangeMessageDto>(
    `/api/exchange-requests/${exchangeRequestId}/messages`,
    {
      method: "POST",
      token,
      body: JSON.stringify({ body }),
    },
  );
}

export function acceptExchangeRequest(token: string, requestId: string) {
  return apiFetch<ExchangeRequestDto>(
    `/api/exchange-requests/${requestId}/accept`,
    { method: "PUT", token },
  );
}

export function rejectExchangeRequest(token: string, requestId: string) {
  return apiFetch<ExchangeRequestDto>(
    `/api/exchange-requests/${requestId}/reject`,
    { method: "PUT", token },
  );
}

export function cancelExchangeRequest(token: string, requestId: string) {
  return apiFetch<ExchangeRequestDto>(
    `/api/exchange-requests/${requestId}/cancel`,
    { method: "PUT", token },
  );
}

export function createCounterOffer(
  token: string,
  requestId: string,
  body: {
    message: string;
    bookedMinutes: number;
    scheduledStartAt: string;
  },
) {
  return apiFetch<ExchangeRequestDto>(
    `/api/exchange-requests/${requestId}/counter-offer`,
    {
      method: "POST",
      token,
      body: JSON.stringify(body),
    },
  );
}

/** Öğrenci: eğitmenin reddedilmiş karşı teklifinden sonra yeni tarih önerir. */
export function createRequesterCounterOffer(
  token: string,
  requestId: string,
  body: {
    message: string;
    bookedMinutes: number;
    scheduledStartAt: string;
  },
) {
  return apiFetch<ExchangeRequestDto>(
    `/api/exchange-requests/${requestId}/requester-counter-offer`,
    {
      method: "POST",
      token,
      body: JSON.stringify(body),
    },
  );
}

export function updateExchangeSessionMeeting(
  token: string,
  exchangeId: string,
  meetingUrl: string,
) {
  return apiFetch<ExchangeRequestDto>(
    `/api/exchange-requests/${encodeURIComponent(exchangeId)}/meeting`,
    {
      method: "PUT",
      token,
      body: JSON.stringify({ meetingUrl: meetingUrl.trim() }),
    },
  );
}

export function acknowledgeRequesterAttendance(
  token: string,
  exchangeId: string,
) {
  return apiFetch<ExchangeRequestDto>(
    `/api/exchange-requests/${encodeURIComponent(exchangeId)}/ack-attendance`,
    {
      method: "POST",
      token,
    },
  );
}

export function acknowledgeOwnerAttendance(token: string, exchangeId: string) {
  return apiFetch<ExchangeRequestDto>(
    `/api/exchange-requests/${encodeURIComponent(exchangeId)}/ack-owner-attendance`,
    {
      method: "POST",
      token,
    },
  );
}

export function fetchOpenPreSessionConfirmations(token: string) {
  return apiFetch<ExchangeRequestDto[]>("/api/exchange-requests/pre-session-open", {
    method: "GET",
    token,
  });
}

export function submitPreSessionResponse(
  token: string,
  exchangeId: string,
  decision: "CONFIRM" | "DECLINE",
) {
  return apiFetch<ExchangeRequestDto>(
    `/api/exchange-requests/${encodeURIComponent(exchangeId)}/pre-session-response`,
    {
      method: "POST",
      token,
      body: JSON.stringify({ decision }),
    },
  );
}

export function reportSessionProblem(token: string, exchangeId: string, message: string) {
  return apiFetch<ExchangeRequestDto>(
    `/api/exchange-requests/${encodeURIComponent(exchangeId)}/report-session-problem`,
    {
      method: "POST",
      token,
      body: JSON.stringify({ message }),
    },
  );
}

export type PendingCancelSurveyDto = {
  exchangeRequestId: string;
  skillTitle: string;
  cancelledAt: string;
};

export type CancelSurveyReasonCode = "SCHEDULE" | "NOT_NEEDED" | "OTHER";

export function fetchPendingCancelSurveys(token: string) {
  return apiFetch<PendingCancelSurveyDto[]>("/api/exchange-requests/pending-cancel-survey", {
    method: "GET",
    token,
  });
}

export function submitCancelSurvey(
  token: string,
  exchangeId: string,
  body: { reasonCode: CancelSurveyReasonCode; note?: string },
) {
  return apiFetch<void>(
    `/api/exchange-requests/${encodeURIComponent(exchangeId)}/cancel-survey`,
    {
      method: "POST",
      token,
      body: JSON.stringify(body),
    },
  );
}
