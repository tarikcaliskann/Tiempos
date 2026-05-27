package com.timebank.timebank.exchange;

import com.timebank.timebank.support.AbstractPostgresIntegrationTest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/** Oturum bitişinde scheduler ile tam kredi aktarımı. */
class SessionSettlementIntegrationTest extends AbstractPostgresIntegrationTest {

    @Autowired
    private ExchangeRequestService exchangeRequestService;

    @Autowired
    private ExchangeRequestRepository exchangeRequestRepository;

    @Test
    void settleDueSessionsAtEnd_transfersFullCredits() throws Exception {
        String skillId = createSkill();
        String exchangeId = createBookingRequest(skillId, scheduledStart, 60);
        accept(exchangeId);
        markPreSessionPromptSent(UUID.fromString(exchangeId));
        submitPreSessionConfirm(exchangeId, requesterToken);
        submitPreSessionConfirm(exchangeId, ownerToken);

        Instant endedStart = Instant.now().minus(90, ChronoUnit.MINUTES);
        setScheduledStart(UUID.fromString(exchangeId), endedStart);

        exchangeRequestService.settleDueSessionsAtEnd();

        ExchangeRequest ex = exchangeRequestRepository.findById(UUID.fromString(exchangeId)).orElseThrow();
        assertThat(ex.getCreditsSettledAt()).isNotNull();
        assertThat(ex.getSettledMinutes()).isEqualTo(60);
        assertThat(ex.getStatus()).isEqualTo(ExchangeRequestStatus.COMPLETED);
    }
}
