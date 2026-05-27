ALTER TABLE exchange_requests
    ADD COLUMN IF NOT EXISTS cancelled_at TIMESTAMPTZ;

UPDATE exchange_requests
SET cancelled_at = created_at
WHERE status = 'CANCELLED' AND cancelled_at IS NULL;

CREATE TABLE IF NOT EXISTS exchange_cancel_surveys (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exchange_request_id UUID NOT NULL REFERENCES exchange_requests (id) ON DELETE CASCADE,
    respondent_id UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    reason_code VARCHAR(40) NOT NULL,
    note VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uk_exchange_cancel_survey UNIQUE (exchange_request_id, respondent_id)
);

CREATE INDEX IF NOT EXISTS idx_exchange_cancel_surveys_respondent
    ON exchange_cancel_surveys (respondent_id);
