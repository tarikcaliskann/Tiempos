package com.timebank.timebank.exchange.dto;

import java.time.Instant;
import java.util.UUID;

public class PendingCancelSurveyDockResponse {

    private UUID exchangeRequestId;
    private String skillTitle;
    private Instant cancelledAt;

    public PendingCancelSurveyDockResponse(UUID exchangeRequestId, String skillTitle, Instant cancelledAt) {
        this.exchangeRequestId = exchangeRequestId;
        this.skillTitle = skillTitle;
        this.cancelledAt = cancelledAt;
    }

    public UUID getExchangeRequestId() {
        return exchangeRequestId;
    }

    public String getSkillTitle() {
        return skillTitle;
    }

    public Instant getCancelledAt() {
        return cancelledAt;
    }
}
