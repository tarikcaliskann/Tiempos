-- İki taraf da seans öncesi "katılacağım" deyince kredi kesinleştirme zamanı
ALTER TABLE exchange_requests
    ADD COLUMN IF NOT EXISTS pre_session_both_confirmed_at TIMESTAMPTZ;
