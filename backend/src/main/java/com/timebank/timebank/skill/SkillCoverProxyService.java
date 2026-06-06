package com.timebank.timebank.skill;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.CacheControl;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.LinkedHashSet;
import java.util.Locale;
import java.util.UUID;

/**
 * Pollinations’a tarayıcıdan direkt gitmek 429 / hotlink sorunlarına yol açabiliyor.
 * Görsel sunucu tarafında çekilip aynı origin üzerinden servis edilir.
 */
@Service
public class SkillCoverProxyService {

    private static final Logger log = LoggerFactory.getLogger(SkillCoverProxyService.class);

    private final SkillRepository skillRepository;

    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(20))
            .followRedirects(HttpClient.Redirect.NORMAL)
            .build();

    public SkillCoverProxyService(SkillRepository skillRepository) {
        this.skillRepository = skillRepository;
    }

    public ResponseEntity<byte[]> fetchCover(UUID skillId) {
        Skill skill = skillRepository.findById(skillId)
                .orElseThrow(() -> new IllegalArgumentException("Skill bulunamadı"));

        LinkedHashSet<String> urls = new LinkedHashSet<>();
        String stored = skill.getCoverImageUrl();
        if (stored != null && !stored.isBlank()) {
            urls.add(sanitizePollinationsUrl(stored.trim()));
        }
        urls.add(SkillCoverImageUrlBuilder.fromSkillContent(
                skill.getTitle(),
                skill.getDescription(),
                skill.getCategory(),
                skill.getId()
        ));
        urls.add(SkillCoverImageUrlBuilder.minimalCoverUrl(skill.getTitle(), skill.getId()));

        for (String url : urls) {
            try {
                HttpResponse<byte[]> res = httpGet(url);
                if (res.statusCode() != 200 || res.body() == null || res.body().length < 64) {
                    continue;
                }
                byte[] body = res.body();
                String ctRaw = res.headers().firstValue(HttpHeaders.CONTENT_TYPE).orElse("");
                String ct = ctRaw.split(";")[0].trim();
                boolean declaredImage = ct.toLowerCase(Locale.ROOT).startsWith("image/");
                boolean sniffedImage = looksLikeRasterImage(body);
                if (!declaredImage && !sniffedImage) {
                    continue;
                }
                if (!declaredImage) {
                    ct = sniffContentType(body);
                } else if (ct.isEmpty()) {
                    ct = MediaType.IMAGE_JPEG_VALUE;
                }
                MediaType mediaType;
                try {
                    mediaType = MediaType.parseMediaType(ct);
                } catch (Exception ignored) {
                    mediaType = MediaType.IMAGE_JPEG;
                }
                return ResponseEntity.ok()
                        .cacheControl(CacheControl.maxAge(Duration.ofHours(6)).cachePublic())
                        .contentType(mediaType)
                        .body(body);
            } catch (Exception e) {
                log.debug("cover fetch failed for {}: {}", url, e.getMessage());
            }
        }
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).build();
    }

    /** Pollinations / CDN bazen {@code application/octet-stream} döner; gövde gerçekten görsel ise kabul et. */
    private static boolean looksLikeRasterImage(byte[] b) {
        if (b == null || b.length < 12) {
            return false;
        }
        if (b[0] == (byte) 0xFF && b[1] == (byte) 0xD8 && b[2] == (byte) 0xFF) {
            return true;
        }
        if (b[0] == (byte) 0x89 && b[1] == 'P' && b[2] == 'N' && b[3] == 'G') {
            return true;
        }
        if (b[0] == 'G' && b[1] == 'I' && b[2] == 'F') {
            return true;
        }
        return b[0] == 'R'
                && b[1] == 'I'
                && b[2] == 'F'
                && b[3] == 'F'
                && b[8] == 'W'
                && b[9] == 'E'
                && b[10] == 'B'
                && b[11] == 'P';
    }

    private static String sniffContentType(byte[] b) {
        if (b.length >= 3 && b[0] == (byte) 0xFF && b[1] == (byte) 0xD8 && b[2] == (byte) 0xFF) {
            return MediaType.IMAGE_JPEG_VALUE;
        }
        if (b.length >= 4 && b[0] == (byte) 0x89 && b[1] == 'P' && b[2] == 'N' && b[3] == 'G') {
            return MediaType.IMAGE_PNG_VALUE;
        }
        if (b.length >= 12
                && b[0] == 'R'
                && b[1] == 'I'
                && b[2] == 'F'
                && b[3] == 'F'
                && b[8] == 'W'
                && b[9] == 'E'
                && b[10] == 'B'
                && b[11] == 'P') {
            return "image/webp";
        }
        if (b.length >= 3 && b[0] == 'G' && b[1] == 'I' && b[2] == 'F') {
            return "image/gif";
        }
        return MediaType.IMAGE_JPEG_VALUE;
    }

    private HttpResponse<byte[]> httpGet(String url) throws Exception {
        HttpRequest req = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .timeout(Duration.ofSeconds(120))
                .header(HttpHeaders.USER_AGENT, "Tiempos/1.0 (skill-cover-proxy)")
                .GET()
                .build();
        return httpClient.send(req, HttpResponse.BodyHandlers.ofByteArray());
    }

    private static String sanitizePollinationsUrl(String url) {
        if (!url.contains("pollinations.ai")) {
            return url;
        }
        try {
            URI raw = URI.create(url);
            String q = raw.getQuery();
            if (q == null || q.isBlank()) {
                return url;
            }
            StringBuilder out = new StringBuilder();
            boolean first = true;
            for (String pair : q.split("&")) {
                if (pair.startsWith("nologo=")) {
                    continue;
                }
                if (!first) {
                    out.append("&");
                }
                first = false;
                out.append(pair);
            }
            String newQuery = out.toString();
            if (newQuery.isEmpty()) {
                return new URI(
                        raw.getScheme(),
                        raw.getAuthority(),
                        raw.getPath(),
                        null,
                        raw.getFragment()
                ).toString();
            }
            return new URI(
                    raw.getScheme(),
                    raw.getAuthority(),
                    raw.getPath(),
                    newQuery,
                    raw.getFragment()
            ).toString();
        } catch (Exception e) {
            return url;
        }
    }
}
