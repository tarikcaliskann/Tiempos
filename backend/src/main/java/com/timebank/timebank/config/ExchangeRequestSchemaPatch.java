package com.timebank.timebank.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.DependsOn;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

/**
 * Hibernate tabloyu oluşturduktan sonra çalışır ({@link DependsOn}).
 * Eski PostgreSQL volume'larında eksik sütunları idempotent ALTER ile tamamlar.
 * Üretimde Flyway yeterli — {@code tiempos.schema-patch.enabled=false}.
 */
@Component
@ConditionalOnProperty(name = "tiempos.schema-patch.enabled", havingValue = "true")
@DependsOn("entityManagerFactory")
@Order(Ordered.LOWEST_PRECEDENCE)
public class ExchangeRequestSchemaPatch implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(ExchangeRequestSchemaPatch.class);

    private final JdbcTemplate jdbcTemplate;

    public ExchangeRequestSchemaPatch(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public void run(ApplicationArguments args) {
        patch(
                "ALTER TABLE exchange_requests ADD COLUMN IF NOT EXISTS booked_minutes INTEGER NOT NULL DEFAULT 60",
                "booked_minutes");
        patch(
                "ALTER TABLE exchange_requests ADD COLUMN IF NOT EXISTS scheduled_start_at TIMESTAMPTZ",
                "scheduled_start_at");
        patch(
                "ALTER TABLE exchange_requests ADD COLUMN IF NOT EXISTS reminder_sent BOOLEAN NOT NULL DEFAULT false",
                "reminder_sent");
        patch(
                "ALTER TABLE exchange_requests ADD COLUMN IF NOT EXISTS pending_from_owner BOOLEAN NOT NULL DEFAULT false",
                "pending_from_owner");
        patch(
                "ALTER TABLE exchange_requests ADD COLUMN IF NOT EXISTS session_meeting_url varchar(2000)",
                "session_meeting_url");
        patch(
                "ALTER TABLE exchange_requests ADD COLUMN IF NOT EXISTS requester_attendance_ack_at timestamptz",
                "requester_attendance_ack_at");
        patch(
                "ALTER TABLE exchange_requests ADD COLUMN IF NOT EXISTS pre_session_confirm_sent BOOLEAN NOT NULL DEFAULT false",
                "pre_session_confirm_sent");
        patch(
                "ALTER TABLE exchange_requests ADD COLUMN IF NOT EXISTS requester_pre_session_response VARCHAR(20)",
                "requester_pre_session_response");
        patch(
                "ALTER TABLE exchange_requests ADD COLUMN IF NOT EXISTS owner_pre_session_response VARCHAR(20)",
                "owner_pre_session_response");
        patch(
                "ALTER TABLE exchange_requests ADD COLUMN IF NOT EXISTS pre_session_both_confirmed_at TIMESTAMPTZ",
                "pre_session_both_confirmed_at");
    }

    private void patch(String sql, String label) {
        try {
            jdbcTemplate.execute(sql);
            log.info("exchange_requests.{} verified", label);
        } catch (Exception e) {
            log.warn("Could not patch exchange_requests.{}: {}", label, e.getMessage());
        }
    }
}
