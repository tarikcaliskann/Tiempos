package com.timebank.timebank.notification;

import com.fasterxml.jackson.databind.JsonNode;
import com.timebank.timebank.support.AbstractPostgresIntegrationTest;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/** Rezervasyon / seans öncesi onay sonrası bildirimler. */
class NotificationIntegrationTest extends AbstractPostgresIntegrationTest {

    @Test
    void preSessionPartnerConfirm_createsNotificationForPeer() throws Exception {
        String skillId = createSkill();
        String exchangeId = createBookingRequest(skillId);
        accept(exchangeId);
        markPreSessionPromptSent(UUID.fromString(exchangeId));

        submitPreSessionConfirm(exchangeId, requesterToken);

        var countResult = getJson("/api/notifications/unread-count", ownerToken);
        assertThat(countResult.getResponse().getStatus()).isBetween(200, 299);
        JsonNode countJson = objectMapper.readTree(countResult.getResponse().getContentAsString());
        assertThat(countJson.get("count").asLong()).isGreaterThan(0);

        mockMvc.perform(
                        org.springframework.test.web.servlet.request.MockMvcRequestBuilders
                                .get("/api/notifications")
                                .header("Authorization", "Bearer " + ownerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[?(@.exchangeRequestId == '" + exchangeId + "')]").exists());
    }

    @Test
    void markAllRead_clearsUnreadCount() throws Exception {
        String skillId = createSkill();
        String exchangeId = createBookingRequest(skillId);
        accept(exchangeId);
        markPreSessionPromptSent(UUID.fromString(exchangeId));
        submitPreSessionConfirm(exchangeId, requesterToken);

        mockMvc.perform(
                        org.springframework.test.web.servlet.request.MockMvcRequestBuilders
                                .post("/api/notifications/mark-all-read")
                                .header("Authorization", "Bearer " + ownerToken))
                .andExpect(status().isNoContent());

        var countResult = getJson("/api/notifications/unread-count", ownerToken);
        JsonNode countJson = objectMapper.readTree(countResult.getResponse().getContentAsString());
        assertThat(countJson.get("count").asLong()).isZero();
    }
}
