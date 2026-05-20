import { PageLayout } from "../components/layout/PageLayout";
import { Card } from "../components/ui/card";
import { Button } from "../components/ui/button";
import { Badge } from "../components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "../components/ui/tabs";
import { useLanguage } from "../contexts/LanguageContext";
import { useAuth } from "../contexts/AuthContext";
import { useCallback, useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import type { PageType } from "../App";
import {
  fetchPublicUserProfile,
  PUBLIC_PROFILE_USER_ID_KEY,
  type PublicUserProfileDto,
} from "../api/user";
import { apiErrorDisplayMessage } from "../api/client";
import { ImageWithFallback } from "../components/common/ImageWithFallback";
import { fetchPublicSkills, type SkillDto } from "../api/skills";
import { resolveSkillCoverImageUrl } from "../lib/skillCoverImageUrl";
import {
  Star,
  MapPin,
  ArrowLeft,
  Calendar,
  Link2,
  Globe,
  MessageCircle,
} from "lucide-react";
import { initialsFromFullName } from "../lib/initials";
import { formatTemplate } from "../language";
import { PATHS } from "../navigation/paths";

type Props = { onNavigate?: (page: PageType) => void };

function normalizeUrl(raw: string): string {
  const t = raw.trim();
  if (!t) return t;
  if (t.startsWith("http://") || t.startsWith("https://")) return t;
  return `https://${t}`;
}

export function PublicUserProfilePage({ onNavigate }: Props) {
  const navigate = useNavigate();
  const { userId: userIdParam } = useParams<{ userId: string }>();
  const { t, locale } = useLanguage();
  const p = t.publicUserProfile;
  const { user, token } = useAuth();
  const [profile, setProfile] = useState<PublicUserProfileDto | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [skillsLoading, setSkillsLoading] = useState(false);
  const [skills, setSkills] = useState<SkillDto[]>([]);
  const [avatarBroken, setAvatarBroken] = useState(false);

  const load = useCallback(async () => {
    if (!token) {
      setProfile(null);
      setLoading(false);
      return;
    }
    let id: string | null =
      userIdParam && userIdParam.trim() ? userIdParam.trim() : null;
    if (!id) {
      try {
        id = sessionStorage.getItem(PUBLIC_PROFILE_USER_ID_KEY);
      } catch {
        /* ignore */
      }
    }
    if (!id) {
      setError(p.notFound);
      setProfile(null);
      setLoading(false);
      return;
    }
    if (user?.id && id.toLowerCase() === user.id.toLowerCase()) {
      onNavigate?.("profile");
      setLoading(false);
      return;
    }
    setLoading(true);
    setError(null);
    try {
      const data = await fetchPublicUserProfile(token, id);
      setProfile(data);
    } catch (e) {
      setError(apiErrorDisplayMessage(e, p.loadError));
      setProfile(null);
    } finally {
      setLoading(false);
    }
  }, [token, user?.id, onNavigate, p.loadError, p.notFound, userIdParam]);

  useEffect(() => {
    void load();
  }, [load]);

  useEffect(() => {
    if (!profile?.id) {
      setSkills([]);
      setSkillsLoading(false);
      return;
    }
    let cancelled = false;
    setSkillsLoading(true);
    fetchPublicSkills()
      .then((rows) => {
        if (cancelled) return;
        const mine = rows.filter(
          (s) => s.ownerId?.trim().toLowerCase() === profile.id.trim().toLowerCase(),
        );
        setSkills(mine);
      })
      .catch(() => {
        if (!cancelled) setSkills([]);
      })
      .finally(() => {
        if (!cancelled) setSkillsLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [profile?.id]);

  useEffect(() => {
    setAvatarBroken(false);
  }, [profile?.avatarUrl]);

  return (
    <PageLayout onNavigate={onNavigate}>
      <div className="bg-gradient-to-r from-blue-500 to-purple-600 px-4 pb-8 pt-20 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-6xl">
          <Button
            type="button"
            variant="outline"
            className="mb-4 border-white/35 bg-white/10 text-white backdrop-blur-sm hover:bg-white/20 hover:text-white"
            onClick={() => onNavigate?.("messages")}
          >
            <ArrowLeft className="mr-2 h-4 w-4" />
            {p.backToMessages}
          </Button>
        </div>
      </div>

      <div className="mx-auto max-w-6xl px-4 pb-10 sm:px-6 lg:px-8">
        {loading ? (
          <p className="text-sm text-muted-foreground">{t.common.loading}</p>
        ) : null}
        {error && !loading ? (
          <p className="text-sm text-destructive">{error}</p>
        ) : null}
        {profile && !loading ? (
          <>
            <Card className="mt-[-4.5rem] rounded-2xl border-0 bg-card/95 p-6 shadow-xl backdrop-blur-sm">
              <div className="grid grid-cols-1 gap-6 md:grid-cols-[auto_1fr] md:items-center">
                <div className="shrink-0">
                  {profile.avatarUrl && !avatarBroken ? (
                    <div className="h-20 w-20 shrink-0 overflow-hidden rounded-2xl shadow-md md:h-24 md:w-24">
                      <img
                        src={profile.avatarUrl}
                        alt=""
                        className="block h-full w-full max-h-full max-w-full object-cover object-center"
                        onError={() => setAvatarBroken(true)}
                      />
                    </div>
                  ) : (
                    <div className="flex h-20 w-20 shrink-0 items-center justify-center rounded-2xl bg-muted text-xl font-semibold text-muted-foreground shadow-md md:h-24 md:w-24">
                      {initialsFromFullName(profile.fullName)}
                    </div>
                  )}
                </div>
                <div className="min-w-0">
                  <h1 className="text-2xl font-semibold text-foreground md:text-3xl">
                    {profile.fullName}
                  </h1>
                  <div className="mt-3 flex flex-wrap items-center gap-x-5 gap-y-2 text-sm text-muted-foreground">
                    {profile.location ? (
                      <span className="inline-flex items-center gap-1.5">
                        <MapPin className="h-4 w-4" aria-hidden />
                        {profile.location}
                      </span>
                    ) : null}
                    {profile.memberSince ? (
                      <span className="inline-flex items-center gap-1.5">
                        <Calendar className="h-4 w-4" aria-hidden />
                        {p.memberSince}:{" "}
                        {new Date(profile.memberSince).toLocaleDateString(
                          locale === "tr" ? "tr-TR" : "en-US",
                          { year: "numeric", month: "long" },
                        )}
                      </span>
                    ) : null}
                  </div>
                  <div className="mt-4 flex flex-wrap items-center gap-2 text-sm text-foreground">
                    <Star
                      className="h-4 w-4 shrink-0 fill-amber-500 text-amber-500"
                      aria-hidden
                    />
                    <span>
                      {formatTemplate(p.reviewsSummary, {
                        rating: profile.averageRating.toFixed(1),
                        count: String(profile.totalReviews),
                      })}
                    </span>
                  </div>
                  <div className="mt-5 flex flex-wrap gap-2">
                    <Button
                      type="button"
                      className="bg-gradient-to-r from-blue-500 to-purple-600 text-white shadow-sm"
                      onClick={() => {
                        try {
                          sessionStorage.setItem("tiempos_open_user", profile.id);
                        } catch {
                          /* ignore */
                        }
                        onNavigate?.("messages");
                      }}
                    >
                      <MessageCircle className="mr-2 h-4 w-4" />
                      {p.sendMessage}
                    </Button>
                  </div>
                </div>
              </div>
            </Card>

            <Tabs defaultValue="about" className="mt-6">
              <TabsList className="mb-5">
                <TabsTrigger value="about">{p.tabAbout}</TabsTrigger>
                <TabsTrigger value="skills">{p.tabSkills}</TabsTrigger>
                <TabsTrigger value="reviews">{p.tabReviews}</TabsTrigger>
              </TabsList>

              <TabsContent value="about">
                <Card className="rounded-2xl border-0 p-6 shadow-lg">
                  <p className="whitespace-pre-wrap text-sm text-foreground">
                    {profile.bio?.trim() ? profile.bio : p.noBio}
                  </p>
                  {profile.languages?.trim() ? (
                    <p className="mt-4 text-sm text-muted-foreground">
                      {profile.languages}
                    </p>
                  ) : null}
                  <div className="mt-5 flex flex-wrap gap-x-4 gap-y-2 text-sm">
                    {profile.website?.trim() ? (
                      <a
                        className="inline-flex items-center gap-1 text-primary hover:underline"
                        href={normalizeUrl(profile.website)}
                        target="_blank"
                        rel="noopener noreferrer"
                      >
                        <Globe className="h-4 w-4" />
                        {profile.website}
                      </a>
                    ) : null}
                    {profile.linkedin?.trim() ? (
                      <a
                        className="inline-flex items-center gap-1 text-primary hover:underline"
                        href={normalizeUrl(profile.linkedin)}
                        target="_blank"
                        rel="noopener noreferrer"
                      >
                        <Link2 className="h-4 w-4" />
                        LinkedIn
                      </a>
                    ) : null}
                    {profile.twitter?.trim() ? (
                      <a
                        className="inline-flex items-center gap-1 text-primary hover:underline"
                        href={normalizeUrl(profile.twitter)}
                        target="_blank"
                        rel="noopener noreferrer"
                      >
                        <Link2 className="h-4 w-4" />
                        X / Twitter
                      </a>
                    ) : null}
                  </div>
                </Card>
              </TabsContent>

              <TabsContent value="skills">
                <Card className="rounded-2xl border-0 p-6 shadow-lg">
                  <h2 className="mb-5 text-xl text-foreground">{p.skillsTitle}</h2>
                  {skillsLoading ? (
                    <p className="text-sm text-muted-foreground">{t.common.loading}</p>
                  ) : skills.length === 0 ? (
                    <p className="py-8 text-center text-muted-foreground">{p.noSkills}</p>
                  ) : (
                    <div className="grid grid-cols-1 gap-5 md:grid-cols-2">
                      {skills.map((skill) => (
                        <Card
                          key={skill.id}
                          className="overflow-hidden rounded-xl border border-border bg-muted/25 p-0"
                        >
                          <div className="relative h-40 w-full overflow-hidden sm:h-44">
                            <ImageWithFallback
                              src={resolveSkillCoverImageUrl(skill)}
                              alt={skill.title}
                              className="h-full w-full object-cover"
                            />
                          </div>
                          <div className="p-5">
                            <h3 className="text-lg text-foreground">{skill.title}</h3>
                            <div className="mt-2 flex flex-wrap gap-2">
                              {skill.category ? (
                                <Badge variant="secondary">{skill.category}</Badge>
                              ) : null}
                              {skill.level ? <Badge variant="outline">{skill.level}</Badge> : null}
                            </div>
                            <p className="mt-3 line-clamp-3 text-sm text-muted-foreground">
                              {skill.description}
                            </p>
                            <Button
                              type="button"
                              variant="outline"
                              className="mt-4 w-full"
                              onClick={() => navigate(PATHS.skill(skill.id))}
                            >
                              {p.viewDetails}
                            </Button>
                          </div>
                        </Card>
                      ))}
                    </div>
                  )}
                </Card>
              </TabsContent>

              <TabsContent value="reviews">
                <Card className="rounded-2xl border-0 p-6 shadow-lg">
                  <h2 className="mb-3 text-xl text-foreground">{p.tabReviews}</h2>
                  <p className="text-sm text-muted-foreground">
                    {formatTemplate(p.reviewsSummary, {
                      rating: profile.averageRating.toFixed(1),
                      count: String(profile.totalReviews),
                    })}
                  </p>
                </Card>
              </TabsContent>
            </Tabs>
          </>
        ) : null}
      </div>
    </PageLayout>
  );
}
