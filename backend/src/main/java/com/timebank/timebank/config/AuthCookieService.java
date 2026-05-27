package com.timebank.timebank.config;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.Optional;

/**
 * HttpOnly oturum çerezi — XSS ile localStorage'dan daha güvenli.
 * Bearer header hâlâ desteklenir (geriye dönük uyumluluk).
 */
@Service
public class AuthCookieService {

    public static final String COOKIE_NAME = "tiempos_access";

    private final long expirationMinutes;
    private final boolean secureCookie;
    private final String sameSite;

    public AuthCookieService(
            @Value("${app.jwt.expiration-minutes:120}") long expirationMinutes,
            @Value("${app.auth.cookie.secure:${APP_AUTH_COOKIE_SECURE:false}}") boolean secureCookie,
            @Value("${app.auth.cookie.same-site:${APP_AUTH_COOKIE_SAME_SITE:Lax}}") String sameSite
    ) {
        this.expirationMinutes = expirationMinutes;
        this.secureCookie = secureCookie;
        this.sameSite = sameSite == null || sameSite.isBlank() ? "Lax" : sameSite.trim();
    }

    public void setAccessTokenCookie(HttpServletResponse response, String jwt) {
        ResponseCookie cookie = ResponseCookie.from(COOKIE_NAME, jwt)
                .httpOnly(true)
                .secure(secureCookie)
                .sameSite(sameSite)
                .path("/")
                .maxAge(Duration.ofMinutes(expirationMinutes))
                .build();
        response.addHeader(HttpHeaders.SET_COOKIE, cookie.toString());
    }

    public void clearAccessTokenCookie(HttpServletResponse response) {
        ResponseCookie cookie = ResponseCookie.from(COOKIE_NAME, "")
                .httpOnly(true)
                .secure(secureCookie)
                .sameSite(sameSite)
                .path("/")
                .maxAge(0)
                .build();
        response.addHeader(HttpHeaders.SET_COOKIE, cookie.toString());
    }

    public Optional<String> readAccessToken(HttpServletRequest request) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null) {
            return Optional.empty();
        }
        for (Cookie c : cookies) {
            if (COOKIE_NAME.equals(c.getName()) && c.getValue() != null && !c.getValue().isBlank()) {
                return Optional.of(c.getValue().trim());
            }
        }
        return Optional.empty();
    }
}
