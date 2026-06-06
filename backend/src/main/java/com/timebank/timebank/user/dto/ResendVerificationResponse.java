package com.timebank.timebank.user.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

/**
 * POST /api/auth/resend-verification yanıtı.
 * {@code verificationCode} yalnızca yerel geliştirmede (SMTP kapalı + bayrak açık) dolu olur.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public record ResendVerificationResponse(boolean ok, boolean mailSent, String verificationCode) {

    public static ResendVerificationResponse of(boolean mailSent, String verificationCode) {
        return new ResendVerificationResponse(true, mailSent, verificationCode);
    }
}
