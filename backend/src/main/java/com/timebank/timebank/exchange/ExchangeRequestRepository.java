package com.timebank.timebank.exchange;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ExchangeRequestRepository extends JpaRepository<ExchangeRequest, UUID> {

    @EntityGraph(attributePaths = {"skill", "skill.owner", "requester"})
    List<ExchangeRequest> findByRequesterEmailOrderByCreatedAtDesc(String requesterEmail);

    @EntityGraph(attributePaths = {"skill", "skill.owner", "requester"})
    List<ExchangeRequest> findBySkillOwnerEmailOrderByCreatedAtDesc(String ownerEmail);

    @Override
    @EntityGraph(attributePaths = {"skill", "skill.owner", "requester"})
    Optional<ExchangeRequest> findById(UUID id);

    long countByRequesterEmail(String requesterEmail);

    long countBySkillOwnerEmail(String ownerEmail);

    @EntityGraph(attributePaths = {"skill", "skill.owner", "requester"})
    List<ExchangeRequest> findByStatusAndReminderSentFalseAndScheduledStartAtBetween(
            ExchangeRequestStatus status,
            Instant start,
            Instant end
    );

    @EntityGraph(attributePaths = {"skill", "skill.owner", "requester"})
    List<ExchangeRequest> findByStatusAndStartedPromptSentFalseAndScheduledStartAtBetween(
            ExchangeRequestStatus status,
            Instant start,
            Instant end
    );

    @EntityGraph(attributePaths = {"skill", "skill.owner", "requester"})
    List<ExchangeRequest> findByStatusAndPreSessionConfirmSentFalseAndScheduledStartAtBetween(
            ExchangeRequestStatus status,
            Instant start,
            Instant end
    );

    @EntityGraph(attributePaths = {"skill", "skill.owner", "requester"})
    @Query("SELECT DISTINCT e FROM ExchangeRequest e JOIN e.skill s "
            + "WHERE e.status = :st AND e.inquiryOnly = false "
            + "AND e.scheduledStartAt IS NOT NULL "
            + "AND e.creditsSettledAt IS NULL "
            + "AND (LOWER(e.requester.email) = LOWER(:email) OR LOWER(s.owner.email) = LOWER(:email))")
    List<ExchangeRequest> findOpenPreSessionConfirmationsForParticipant(
            @Param("st") ExchangeRequestStatus st,
            @Param("email") String email
    );

    @EntityGraph(attributePaths = {"skill", "skill.owner", "requester"})
    @Query("SELECT e FROM ExchangeRequest e WHERE e.status = :st "
            + "AND e.inquiryOnly = false "
            + "AND e.preSessionBothConfirmedAt IS NOT NULL "
            + "AND e.creditsSettledAt IS NULL")
    List<ExchangeRequest> findPendingSessionCreditSettlement(
            @Param("st") ExchangeRequestStatus st
    );
    @EntityGraph(attributePaths = {"skill", "skill.owner", "requester"})
    @Query("SELECT e FROM ExchangeRequest e JOIN e.skill s " +
            "WHERE e.status = :st " +
            "AND e.scheduledStartAt IS NOT NULL " +
            "AND (e.requester.id = :uid OR s.owner.id = :uid)")
    List<ExchangeRequest> findAcceptedByUserInvolvement(
            @Param("st") ExchangeRequestStatus st,
            @Param("uid") UUID userId
    );

    @Query("SELECT COALESCE(SUM(e.bookedMinutes), 0) FROM ExchangeRequest e WHERE e.status = :status")
    long sumBookedMinutesByStatus(@Param("status") ExchangeRequestStatus status);
}