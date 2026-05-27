import { describe, expect, it } from "vitest";
import { ApiError, apiErrorDisplayMessage } from "./client";

describe("apiErrorDisplayMessage", () => {
  it("returns ApiError message when meaningful", () => {
    const err = new ApiError("Sunucu hatası", 500);
    expect(apiErrorDisplayMessage(err, "Yedek")).toBe("Sunucu hatası");
  });

  it("uses fallback for generic Forbidden", () => {
    const err = new ApiError("Forbidden", 403);
    expect(apiErrorDisplayMessage(err, "Erişim yok")).toBe("Erişim yok");
  });

  it("uses fallback for unknown errors", () => {
    expect(apiErrorDisplayMessage(new Error(), "Bir şeyler ters gitti")).toBe(
      "Bir şeyler ters gitti",
    );
  });
});
