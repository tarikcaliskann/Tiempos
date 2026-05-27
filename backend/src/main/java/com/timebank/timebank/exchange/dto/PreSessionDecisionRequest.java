package com.timebank.timebank.exchange.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

/**
 * Oturum öncesi katılım onayı: CONFIRM veya iptal (DECLINE → rezervasyon iptali).
 */
public class PreSessionDecisionRequest {

    @NotBlank
    @Pattern(regexp = "(?i)^(CONFIRM|DECLINE)$", message = "decision CONFIRM veya DECLINE olmalıdır")
    private String decision;

    public String getDecision() {
        return decision;
    }

    public void setDecision(String decision) {
        this.decision = decision;
    }
}
