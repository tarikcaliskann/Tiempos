import { apiFetch } from "./client";

export type CreditCheckoutDto = {
  sessionId: string;
  packageId: string;
  displayHours: number;
  amountTry: number;
  totalMinutes: number;
  provider: string;
  demoMode: boolean;
  checkoutUrl: string | null;
};

export type CreditPurchaseCompleteDto = {
  timeCreditMinutes: number;
  minutesAdded: number;
  displayHours: number;
  amountTry: number;
};

export async function startCreditCheckout(
  packageId: string,
  token: string,
): Promise<CreditCheckoutDto> {
  return apiFetch<CreditCheckoutDto>("/api/credits/checkout", {
    method: "POST",
    token,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ packageId }),
  });
}

export async function completeCreditPurchase(
  sessionId: string,
  token: string,
): Promise<CreditPurchaseCompleteDto> {
  return apiFetch<CreditPurchaseCompleteDto>(
    `/api/credits/complete/${encodeURIComponent(sessionId)}`,
    {
      method: "POST",
      token,
    },
  );
}
