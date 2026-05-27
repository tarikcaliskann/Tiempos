package com.timebank.timebank.exchange;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface ExchangeCancelSurveyRepository extends JpaRepository<ExchangeCancelSurvey, UUID> {

    boolean existsByExchangeRequest_IdAndRespondent_Id(UUID exchangeRequestId, UUID respondentId);
}
