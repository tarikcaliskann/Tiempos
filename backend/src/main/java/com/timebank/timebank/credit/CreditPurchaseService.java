package com.timebank.timebank.credit;

import com.timebank.timebank.credit.dto.CreditCheckoutResponse;
import com.timebank.timebank.credit.dto.CreditPurchaseCompleteResponse;
import com.timebank.timebank.user.User;
import com.timebank.timebank.user.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class CreditPurchaseService {

    private static final long SESSION_TTL_SECONDS = 30 * 60;

    private final UserRepository userRepository;
    private final String paymentMode;
    private final String redirectUrlTemplate;
    private final String frontendBaseUrl;

    private final Map<String, PendingCheckout> pendingBySession = new ConcurrentHashMap<>();

    public CreditPurchaseService(
            UserRepository userRepository,
            @Value("${app.payment.mode:demo}") String paymentMode,
            @Value("${app.payment.redirect-url-template:}") String redirectUrlTemplate,
            @Value("${app.public-base-url:https://tiempos.site}") String frontendBaseUrl
    ) {
        this.userRepository = userRepository;
        this.paymentMode = paymentMode == null ? "demo" : paymentMode.trim().toLowerCase();
        this.redirectUrlTemplate = redirectUrlTemplate == null ? "" : redirectUrlTemplate.trim();
        this.frontendBaseUrl = frontendBaseUrl == null ? "" : frontendBaseUrl.replaceAll("/$", "");
    }

    @Transactional(readOnly = true)
    public CreditCheckoutResponse startCheckout(String userEmail, String packageId) {
        User user = userRepository.findByEmailIgnoreCase(userEmail)
                .orElseThrow(() -> new BadCredentialsException("Kullanıcı bulunamadı"));

        CreditPackageCatalog pkg = CreditPackageCatalog.findById(packageId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Geçersiz paket"));

        String sessionId = UUID.randomUUID().toString();
        PendingCheckout pending = new PendingCheckout(
                sessionId,
                user.getId(),
                user.getEmail(),
                pkg,
                Instant.now().plusSeconds(SESSION_TTL_SECONDS)
        );
        pendingBySession.put(sessionId, pending);

        boolean demoMode = "demo".equals(paymentMode) || redirectUrlTemplate.isEmpty();
        String checkoutUrl = null;
        String provider = "demo";

        if (!demoMode) {
            provider = "redirect";
            checkoutUrl = buildRedirectUrl(pkg, sessionId);
        }

        return new CreditCheckoutResponse(
                sessionId,
                pkg.getId(),
                pkg.getDisplayHours(),
                pkg.getDiscountedPriceTry(),
                pkg.getTotalMinutes(),
                provider,
                demoMode,
                checkoutUrl
        );
    }

    @Transactional
    public CreditPurchaseCompleteResponse completeCheckout(String userEmail, String sessionId) {
        User user = userRepository.findByEmailIgnoreCase(userEmail)
                .orElseThrow(() -> new BadCredentialsException("Kullanıcı bulunamadı"));

        PendingCheckout pending = pendingBySession.remove(sessionId);
        if (pending == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Ödeme oturumu bulunamadı veya süresi doldu");
        }
        if (pending.expiresAt().isBefore(Instant.now())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Ödeme oturumu süresi doldu");
        }
        if (!pending.userId().equals(user.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Bu ödeme oturumu size ait değil");
        }

        CreditPackageCatalog pkg = pending.pkg();
        int minutesToAdd = pkg.getTotalMinutes();
        user.setTimeCreditMinutes(user.getTimeCreditMinutes() + minutesToAdd);
        userRepository.save(user);

        return new CreditPurchaseCompleteResponse(
                user.getTimeCreditMinutes(),
                minutesToAdd,
                pkg.getDisplayHours(),
                pkg.getDiscountedPriceTry()
        );
    }

    private String buildRedirectUrl(CreditPackageCatalog pkg, String sessionId) {
        String returnUrl = frontendBaseUrl + "/payment/return?sessionId=" + sessionId + "&status=success";
        return redirectUrlTemplate
                .replace("{sessionId}", sessionId)
                .replace("{amountTry}", String.valueOf(pkg.getDiscountedPriceTry()))
                .replace("{packageId}", pkg.getId())
                .replace("{returnUrl}", returnUrl);
    }

    private record PendingCheckout(
            String sessionId,
            UUID userId,
            String userEmail,
            CreditPackageCatalog pkg,
            Instant expiresAt
    ) {
    }
}
