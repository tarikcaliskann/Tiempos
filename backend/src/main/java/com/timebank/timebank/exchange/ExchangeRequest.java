package com.timebank.timebank.exchange;

import com.timebank.timebank.skill.Skill;
import com.timebank.timebank.user.User;
import jakarta.persistence.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "exchange_requests")
public class ExchangeRequest {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name = "skill_id", nullable = false)
    private Skill skill;

    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name = "requester_id", nullable = false)
    private User requester;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ExchangeRequestStatus status;

    @Column(nullable = false, length = 1000)
    private String message;

    /** Talep oluşturulurken seçilen süre (dakika). Tamamlanınca bu süre kadar bakiyeden düşülür (1 saat = 60 dk). */
    @Column(name = "booked_minutes", nullable = false)
    private int bookedMinutes;

    /** Kullanıcının seçtiği oturum başlangıç zamanı (UTC). */
    @Column(name = "scheduled_start_at")
    private Instant scheduledStartAt;

    /** Oturumdan ~1 saat önce hatırlatıcı bildirimi gönderildi mi */
    @Column(name = "reminder_sent", nullable = false)
    private boolean reminderSent;

    /** Bekleyen isteğin son teklifini eğitmen tarafı mı başlattı? */
    @Column(name = "pending_from_owner", nullable = false)
    private boolean pendingFromOwner;

    @Column(nullable = false, updatable = false)
    private Instant createdAt;

    /** Eğitmen/organizatör: Zoom, Meet vb. (kabulden sonra) */
    @Column(name = "session_meeting_url", length = 2000)
    private String sessionMeetingUrl;

    /** İsteğe bağlı: öğrenci (talep sahibi) oturuma katıldığını işaretledi */
    @Column(name = "requester_attendance_ack_at")
    private Instant requesterAttendanceAckAt;

    /** İsteğe bağlı: eğitmen (beceri sahibi) oturumun başladığını işaretledi */
    @Column(name = "owner_attendance_ack_at")
    private Instant ownerAttendanceAckAt;

    /** Talep oluşturulurken öğrenciden düşülen ve askıda tutulan kredi */
    @Column(name = "requester_credit_held", nullable = false)
    private boolean requesterCreditHeld;

    /**
     * Eğitmene ilk mesaj / tanışma: önerilen slot ve süre kayıtlı kalır ama kredi kabul anına ertelenir.
     */
    @Column(name = "inquiry_only", nullable = false)
    private boolean inquiryOnly;

    /** Oturumdan ~10 dk önce "katılıyor musunuz?" bildirimi gönderildi mi */
    @Column(name = "pre_session_confirm_sent", nullable = false)
    private boolean preSessionConfirmSent;

    /** Öğrenci: CONFIRMED veya null (bekliyor) */
    @Column(name = "requester_pre_session_response", length = 20)
    private String requesterPreSessionResponse;

    /** Eğitmen: CONFIRMED veya null (bekliyor) */
    @Column(name = "owner_pre_session_response", length = 20)
    private String ownerPreSessionResponse;

    /** İki taraf da seans öncesi katılımı onayladığında kredi kesinleştirme anı */
    @Column(name = "pre_session_both_confirmed_at")
    private Instant preSessionBothConfirmedAt;

    /** Oturum başlangıcında "başladı mı?" bildirimi gönderildi mi */
    @Column(name = "started_prompt_sent", nullable = false)
    private boolean startedPromptSent;

    /** Askıdaki / aktarılan dakikaların kesinleştiği an */
    @Column(name = "credits_settled_at")
    private Instant creditsSettledAt;

    /** Eğitmene aktarılan dakika (kısmi veya tam) */
    @Column(name = "settled_minutes")
    private Integer settledMinutes;

    /** Sorun bildirimi veya erken bitiş anı */
    @Column(name = "session_stopped_at")
    private Instant sessionStoppedAt;

    @Column(name = "session_stop_reason", length = 2000)
    private String sessionStopReason;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "session_stopped_by_id")
    private User sessionStoppedBy;

    @Column(name = "cancelled_at")
    private Instant cancelledAt;

    @PrePersist
    public void prePersist() {
        if (createdAt == null) {
            createdAt = Instant.now();
        }
        if (status == null) {
            status = ExchangeRequestStatus.PENDING;
        }
    }

    public UUID getId() {
        return id;
    }

    public Skill getSkill() {
        return skill;
    }

    public User getRequester() {
        return requester;
    }

    public ExchangeRequestStatus getStatus() {
        return status;
    }

    public String getMessage() {
        return message;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public void setSkill(Skill skill) {
        this.skill = skill;
    }

    public void setRequester(User requester) {
        this.requester = requester;
    }

    public void setStatus(ExchangeRequestStatus status) {
        this.status = status;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public int getBookedMinutes() {
        return bookedMinutes;
    }

    public void setBookedMinutes(int bookedMinutes) {
        this.bookedMinutes = bookedMinutes;
    }

    public Instant getScheduledStartAt() {
        return scheduledStartAt;
    }

    public void setScheduledStartAt(Instant scheduledStartAt) {
        this.scheduledStartAt = scheduledStartAt;
    }

    public boolean isReminderSent() {
        return reminderSent;
    }

    public void setReminderSent(boolean reminderSent) {
        this.reminderSent = reminderSent;
    }

    public boolean isPendingFromOwner() {
        return pendingFromOwner;
    }

    public void setPendingFromOwner(boolean pendingFromOwner) {
        this.pendingFromOwner = pendingFromOwner;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public String getSessionMeetingUrl() {
        return sessionMeetingUrl;
    }

    public void setSessionMeetingUrl(String sessionMeetingUrl) {
        this.sessionMeetingUrl = sessionMeetingUrl;
    }

    public Instant getRequesterAttendanceAckAt() {
        return requesterAttendanceAckAt;
    }

    public void setRequesterAttendanceAckAt(Instant requesterAttendanceAckAt) {
        this.requesterAttendanceAckAt = requesterAttendanceAckAt;
    }

    public Instant getOwnerAttendanceAckAt() {
        return ownerAttendanceAckAt;
    }

    public void setOwnerAttendanceAckAt(Instant ownerAttendanceAckAt) {
        this.ownerAttendanceAckAt = ownerAttendanceAckAt;
    }

    public boolean isRequesterCreditHeld() {
        return requesterCreditHeld;
    }

    public void setRequesterCreditHeld(boolean requesterCreditHeld) {
        this.requesterCreditHeld = requesterCreditHeld;
    }

    public boolean isInquiryOnly() {
        return inquiryOnly;
    }

    public void setInquiryOnly(boolean inquiryOnly) {
        this.inquiryOnly = inquiryOnly;
    }

    public boolean isStartedPromptSent() {
        return startedPromptSent;
    }

    public void setStartedPromptSent(boolean startedPromptSent) {
        this.startedPromptSent = startedPromptSent;
    }

    public boolean isPreSessionConfirmSent() {
        return preSessionConfirmSent;
    }

    public void setPreSessionConfirmSent(boolean preSessionConfirmSent) {
        this.preSessionConfirmSent = preSessionConfirmSent;
    }

    public String getRequesterPreSessionResponse() {
        return requesterPreSessionResponse;
    }

    public void setRequesterPreSessionResponse(String requesterPreSessionResponse) {
        this.requesterPreSessionResponse = requesterPreSessionResponse;
    }

    public String getOwnerPreSessionResponse() {
        return ownerPreSessionResponse;
    }

    public void setOwnerPreSessionResponse(String ownerPreSessionResponse) {
        this.ownerPreSessionResponse = ownerPreSessionResponse;
    }

    public Instant getPreSessionBothConfirmedAt() {
        return preSessionBothConfirmedAt;
    }

    public void setPreSessionBothConfirmedAt(Instant preSessionBothConfirmedAt) {
        this.preSessionBothConfirmedAt = preSessionBothConfirmedAt;
    }

    public Instant getCreditsSettledAt() {
        return creditsSettledAt;
    }

    public void setCreditsSettledAt(Instant creditsSettledAt) {
        this.creditsSettledAt = creditsSettledAt;
    }

    public Integer getSettledMinutes() {
        return settledMinutes;
    }

    public void setSettledMinutes(Integer settledMinutes) {
        this.settledMinutes = settledMinutes;
    }

    public Instant getSessionStoppedAt() {
        return sessionStoppedAt;
    }

    public void setSessionStoppedAt(Instant sessionStoppedAt) {
        this.sessionStoppedAt = sessionStoppedAt;
    }

    public String getSessionStopReason() {
        return sessionStopReason;
    }

    public void setSessionStopReason(String sessionStopReason) {
        this.sessionStopReason = sessionStopReason;
    }

    public User getSessionStoppedBy() {
        return sessionStoppedBy;
    }

    public void setSessionStoppedBy(User sessionStoppedBy) {
        this.sessionStoppedBy = sessionStoppedBy;
    }

    public Instant getCancelledAt() {
        return cancelledAt;
    }

    public void setCancelledAt(Instant cancelledAt) {
        this.cancelledAt = cancelledAt;
    }
}