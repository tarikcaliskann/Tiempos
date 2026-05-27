package com.timebank.timebank.exchange.dto;

import com.timebank.timebank.exchange.ExchangeRequestStatus;

import java.time.Instant;
import java.util.UUID;

public class ExchangeRequestResponse {

    private UUID id;
    private UUID skillId;
    private String skillTitle;
    private UUID requesterId;
    private String requesterName;
    private String requesterEmail;
    private UUID ownerId;
    private String ownerName;
    private String ownerEmail;
    private String message;
    private int bookedMinutes;
    private Instant scheduledStartAt;
    private boolean pendingFromOwner;
    private ExchangeRequestStatus status;
    private Instant createdAt;
    private String sessionMeetingUrl;
    private Instant requesterAttendanceAckAt;
    private Instant ownerAttendanceAckAt;
    private boolean inquiryOnly;
    private boolean preSessionConfirmSent;
    private String requesterPreSessionResponse;
    private String ownerPreSessionResponse;
    private Instant preSessionBothConfirmedAt;
  /** PRE_CONFIRM | WAITING_START | LIVE | DONE */
    private String sessionDockPhase;
    private Instant scheduledEndAt;
    private Instant creditsSettledAt;
    private Integer settledMinutes;
    private Instant sessionStoppedAt;
    private String sessionStopReason;

    public ExchangeRequestResponse(
            UUID id,
            UUID skillId,
            String skillTitle,
            UUID requesterId,
            String requesterName,
            String requesterEmail,
            UUID ownerId,
            String ownerName,
            String ownerEmail,
            String message,
            int bookedMinutes,
            Instant scheduledStartAt,
            boolean pendingFromOwner,
            ExchangeRequestStatus status,
            Instant createdAt,
            String sessionMeetingUrl,
            Instant requesterAttendanceAckAt,
            Instant ownerAttendanceAckAt,
            boolean inquiryOnly,
            boolean preSessionConfirmSent,
            String requesterPreSessionResponse,
            String ownerPreSessionResponse,
            Instant preSessionBothConfirmedAt,
            String sessionDockPhase,
            Instant scheduledEndAt,
            Instant creditsSettledAt,
            Integer settledMinutes,
            Instant sessionStoppedAt,
            String sessionStopReason
    ) {
        this.id = id;
        this.skillId = skillId;
        this.skillTitle = skillTitle;
        this.requesterId = requesterId;
        this.requesterName = requesterName;
        this.requesterEmail = requesterEmail;
        this.ownerId = ownerId;
        this.ownerName = ownerName;
        this.ownerEmail = ownerEmail;
        this.message = message;
        this.bookedMinutes = bookedMinutes;
        this.scheduledStartAt = scheduledStartAt;
        this.pendingFromOwner = pendingFromOwner;
        this.status = status;
        this.createdAt = createdAt;
        this.sessionMeetingUrl = sessionMeetingUrl;
        this.requesterAttendanceAckAt = requesterAttendanceAckAt;
        this.ownerAttendanceAckAt = ownerAttendanceAckAt;
        this.inquiryOnly = inquiryOnly;
        this.preSessionConfirmSent = preSessionConfirmSent;
        this.requesterPreSessionResponse = requesterPreSessionResponse;
        this.ownerPreSessionResponse = ownerPreSessionResponse;
        this.preSessionBothConfirmedAt = preSessionBothConfirmedAt;
        this.sessionDockPhase = sessionDockPhase;
        this.scheduledEndAt = scheduledEndAt;
        this.creditsSettledAt = creditsSettledAt;
        this.settledMinutes = settledMinutes;
        this.sessionStoppedAt = sessionStoppedAt;
        this.sessionStopReason = sessionStopReason;
    }

    public UUID getId() {
        return id;
    }

    public UUID getSkillId() {
        return skillId;
    }

    public String getSkillTitle() {
        return skillTitle;
    }

    public UUID getRequesterId() {
        return requesterId;
    }

    public String getRequesterName() {
        return requesterName;
    }

    public String getRequesterEmail() {
        return requesterEmail;
    }

    public UUID getOwnerId() {
        return ownerId;
    }

    public String getOwnerName() {
        return ownerName;
    }

    public String getOwnerEmail() {
        return ownerEmail;
    }

    public String getMessage() {
        return message;
    }

    public int getBookedMinutes() {
        return bookedMinutes;
    }

    public Instant getScheduledStartAt() {
        return scheduledStartAt;
    }

    public ExchangeRequestStatus getStatus() {
        return status;
    }

    public boolean isPendingFromOwner() {
        return pendingFromOwner;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public String getSessionMeetingUrl() {
        return sessionMeetingUrl;
    }

    public Instant getRequesterAttendanceAckAt() {
        return requesterAttendanceAckAt;
    }

    public Instant getOwnerAttendanceAckAt() {
        return ownerAttendanceAckAt;
    }

    public boolean isInquiryOnly() {
        return inquiryOnly;
    }

    public boolean isPreSessionConfirmSent() {
        return preSessionConfirmSent;
    }

    public String getRequesterPreSessionResponse() {
        return requesterPreSessionResponse;
    }

    public String getOwnerPreSessionResponse() {
        return ownerPreSessionResponse;
    }

    public Instant getPreSessionBothConfirmedAt() {
        return preSessionBothConfirmedAt;
    }

    public String getSessionDockPhase() {
        return sessionDockPhase;
    }

    public Instant getScheduledEndAt() {
        return scheduledEndAt;
    }

    public Instant getCreditsSettledAt() {
        return creditsSettledAt;
    }

    public Integer getSettledMinutes() {
        return settledMinutes;
    }

    public Instant getSessionStoppedAt() {
        return sessionStoppedAt;
    }

    public String getSessionStopReason() {
        return sessionStopReason;
    }
}