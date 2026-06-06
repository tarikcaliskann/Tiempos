/**
 * Kapak görselleri artık tarayıcıdan Pollinations’a değil, backend proxy’den yüklenir:
 * GET /api/skills/{id}/cover (rate limit / 429 ve hotlink sorunlarını aşar).
 */
import { getApiBaseUrl } from "../config/env";
import type { SkillDto } from "../api/skills";

export function skillCoverProxyUrl(skillId: string): string {
  const base = getApiBaseUrl().trim().replace(/\/$/, "");
  const path = `/api/skills/${skillId}/cover`;
  return base ? `${base}${path}` : path;
}

export function resolveSkillCoverImageUrl(skill: SkillDto): string {
  return skillCoverProxyUrl(skill.id);
}

/** Proxy 503 / octet-stream vb. olduğunda tarayıcıda tek seferlik yedek (API’deki kayıtlı URL). */
export function skillCoverImageFallbackUrl(skill: SkillDto): string | undefined {
  const u = skill.coverImageUrl?.trim();
  return u || undefined;
}
