package com.timebank.timebank.review.dto;

import com.timebank.timebank.exchange.ExchangeRequestStatus;

import java.time.Instant;
import java.util.UUID;

/** Sağ dock’ta gösterilecek bekleyen değerlendirme kartı. */
public class PendingReviewDockResponse {

    private UUID exchangeRequestId;
    private String skillTitle;
    private UUID reviewedUserId;
    private String reviewedUserName;
    private ExchangeRequestStatus exchangeStatus;
    private Integer settledMinutes;
    private int bookedMinutes;
    private Instant sessionEndedAt;
    private String outcomeLabel;
    /** QUICK = seans sonu tek tık puan; DETAIL = kısmi / erken bitiş */
    private String uiMode;

    public PendingReviewDockResponse(
            UUID exchangeRequestId,
            String skillTitle,
            UUID reviewedUserId,
            String reviewedUserName,
            ExchangeRequestStatus exchangeStatus,
            Integer settledMinutes,
            int bookedMinutes,
            Instant sessionEndedAt,
            String outcomeLabel,
            String uiMode
    ) {
        this.exchangeRequestId = exchangeRequestId;
        this.skillTitle = skillTitle;
        this.reviewedUserId = reviewedUserId;
        this.reviewedUserName = reviewedUserName;
        this.exchangeStatus = exchangeStatus;
        this.settledMinutes = settledMinutes;
        this.bookedMinutes = bookedMinutes;
        this.sessionEndedAt = sessionEndedAt;
        this.outcomeLabel = outcomeLabel;
        this.uiMode = uiMode;
    }

    public UUID getExchangeRequestId() {
        return exchangeRequestId;
    }

    public String getSkillTitle() {
        return skillTitle;
    }

    public UUID getReviewedUserId() {
        return reviewedUserId;
    }

    public String getReviewedUserName() {
        return reviewedUserName;
    }

    public ExchangeRequestStatus getExchangeStatus() {
        return exchangeStatus;
    }

    public Integer getSettledMinutes() {
        return settledMinutes;
    }

    public int getBookedMinutes() {
        return bookedMinutes;
    }

    public Instant getSessionEndedAt() {
        return sessionEndedAt;
    }

    public String getOutcomeLabel() {
        return outcomeLabel;
    }

    public String getUiMode() {
        return uiMode;
    }
}
