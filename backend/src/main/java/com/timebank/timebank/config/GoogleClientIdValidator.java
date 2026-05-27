package com.timebank.timebank.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

@Component
public class GoogleClientIdValidator {

    private static final Logger log = LoggerFactory.getLogger(GoogleClientIdValidator.class);

    @Value("${app.google.client-id:}")
    private String googleClientId;

    @Value("${app.google.require-client-id:false}")
    private boolean requireClientId;

    @EventListener(ApplicationReadyEvent.class)
    public void validateOnStartup() {
        if (!requireClientId) {
            return;
        }
        if (googleClientId == null || googleClientId.isBlank()) {
            throw new IllegalStateException(
                    "GOOGLE_CLIENT_ID zorunlu (app.google.require-client-id=true) ancak tanımlı değil.");
        }
        log.info("Google OAuth client-id yapılandırıldı (aud doğrulaması aktif).");
    }
}
