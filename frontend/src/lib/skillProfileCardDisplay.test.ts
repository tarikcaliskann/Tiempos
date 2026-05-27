import { describe, expect, it } from "vitest";
import { skillCardDescriptionPreview } from "./skillProfileCardDisplay";

describe("skillCardDescriptionPreview", () => {
  it("strips structured metadata block after separator", () => {
    const input = "Short intro.\n\n———\nSession Type *: online";
    expect(skillCardDescriptionPreview(input)).toBe("Short intro.");
  });

  it("filters availability lines from plain description", () => {
    const input = "Learn guitar.\nAvailable days *: Monday\nTags *: music";
    expect(skillCardDescriptionPreview(input)).toBe("Learn guitar.");
  });
});
