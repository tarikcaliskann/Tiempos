package com.timebank.timebank.exchange;

import com.timebank.timebank.support.AbstractPostgresIntegrationTest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/** Seans öncesi onay dock API: liste, çift onay, çift red. */
class PreSessionDockIntegrationTest extends AbstractPostgresIntegrationTest {

    @Autowired
    private ExchangeRequestRepository exchangeRequestRepository;

    @Test
    void preSessionOpen_andBothConfirm() throws Exception {
        String skillId = createSkill();
        String exchangeId = createBookingRequest(skillId);
        accept(exchangeId);
        markPreSessionPromptSent(UUID.fromString(exchangeId));

        mockMvc.perform(
                        org.springframework.test.web.servlet.request.MockMvcRequestBuilders
                                .get("/api/exchange-requests/pre-session-open")
                                .header("Authorization", "Bearer " + requesterToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].sessionDockPhase").value("PRE_CONFIRM"));

        submitPreSessionConfirm(exchangeId, requesterToken);
        submitPreSessionConfirm(exchangeId, ownerToken);

        ExchangeRequest ex = exchangeRequestRepository.findById(UUID.fromString(exchangeId)).orElseThrow();
        assertThat(ex.getPreSessionBothConfirmedAt()).isNotNull();
        assertThat(ex.getRequesterPreSessionResponse()).isEqualToIgnoringCase("CONFIRMED");
        assertThat(ex.getOwnerPreSessionResponse()).isEqualToIgnoringCase("CONFIRMED");
    }

    @Test
    void preSessionBothDecline_cancelsExchange() throws Exception {
        String skillId = createSkill();
        String exchangeId = createBookingRequest(skillId);
        accept(exchangeId);
        markPreSessionPromptSent(UUID.fromString(exchangeId));

        var body = objectMapper.createObjectNode();
        body.put("decision", "DECLINE");

        mockMvc.perform(
                        org.springframework.test.web.servlet.request.MockMvcRequestBuilders
                                .post("/api/exchange-requests/{id}/pre-session-response", exchangeId)
                                .header("Authorization", "Bearer " + requesterToken)
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isOk());

        mockMvc.perform(
                        org.springframework.test.web.servlet.request.MockMvcRequestBuilders
                                .post("/api/exchange-requests/{id}/pre-session-response", exchangeId)
                                .header("Authorization", "Bearer " + ownerToken)
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("CANCELLED"));
    }
}
