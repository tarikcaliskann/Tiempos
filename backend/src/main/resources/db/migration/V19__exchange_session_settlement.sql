-- Oturum sırasında kısmi/tam saat kesinleştirme ve sorun bildirimi
ALTER TABLE exchange_requests
    ADD COLUMN IF NOT EXISTS credits_settled_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS settled_minutes INT,
    ADD COLUMN IF NOT EXISTS session_stopped_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS session_stop_reason VARCHAR(2000),
    ADD COLUMN IF NOT EXISTS session_stopped_by_id UUID REFERENCES users (id);

-- Daha önce seans öncesi çift onayda kesinleşen kayıtlar
UPDATE exchange_requests
SET credits_settled_at = pre_session_both_confirmed_at,
    settled_minutes = booked_minutes
WHERE pre_session_both_confirmed_at IS NOT NULL
  AND credits_settled_at IS NULL;
