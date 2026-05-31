package com.timebank.timebank.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashSet;
import java.util.List;

@Configuration
public class CorsConfig {

    /**
     * Flutter web varsayılan portu; Render’da {@code APP_CORS_BROWSER_DEV_PATTERNS=false}
     * olsa bile yerel geliştirme bu origin’den prod API’ye istek atabilsin.
     */
    private static final List<String> BUILTIN_FLUTTER_WEB_ORIGINS = List.of(
            "http://localhost:9339",
            "http://127.0.0.1:9339"
    );

    /**
     * Vite / React ve LAN; Spring {@code http://localhost:[*]} desenini properties’te parse
     * etmek riskli olduğu için Java’da. Yalnızca {@code app.cors.browser-dev-patterns=true} iken eklenir.
     */
    private static final List<String> BUILTIN_BROWSER_ORIGIN_PATTERNS = List.of(
            "http://localhost:5173",
            "http://127.0.0.1:5173",
            "http://localhost:3000",
            "http://127.0.0.1:3000",
            "http://localhost:[*]",
            "http://127.0.0.1:[*]",
            "http://192.168.*.*:[*]",
            "http://10.*.*.*:[*]"
    );

    @Value("${app.cors.allowed-origins}")
    private String allowedOriginsCsv;

    @Value("${app.cors.browser-dev-patterns:true}")
    private boolean browserDevPatterns;

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        LinkedHashSet<String> merged = new LinkedHashSet<>(
                Arrays.stream(allowedOriginsCsv.split(","))
                        .map(String::trim)
                        .filter(s -> !s.isEmpty())
                        .toList());

        merged.addAll(BUILTIN_FLUTTER_WEB_ORIGINS);
        if (browserDevPatterns) {
            merged.addAll(BUILTIN_BROWSER_ORIGIN_PATTERNS);
        }

        List<String> origins = new ArrayList<>(merged);

        if (origins.isEmpty()) {
            throw new IllegalStateException(
                    "app.cors.allowed-origins boş; en az bir origin veya desen tanımlayın (ör. https://www.tiempos.site)");
        }

        CorsConfiguration cfg = new CorsConfiguration();
        cfg.setAllowedOriginPatterns(origins);
        cfg.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        cfg.setAllowedHeaders(List.of("*"));
        cfg.setExposedHeaders(List.of("Authorization"));
        cfg.setAllowCredentials(true);
        cfg.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", cfg);
        return source;
    }
}
