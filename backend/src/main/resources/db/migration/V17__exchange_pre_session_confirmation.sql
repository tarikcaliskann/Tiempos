-- Oturumdan ~10 dk önce her iki tarafa "katılım onayı" bildirimi ve yanıt alanları
ALTER TABLE exchange_requests
    ADD COLUMN IF NOT EXISTS pre_session_confirm_sent BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE exchange_requests
    ADD COLUMN IF NOT EXISTS requester_pre_session_response VARCHAR(20);
ALTER TABLE exchange_requests
    ADD COLUMN IF NOT EXISTS owner_pre_session_response VARCHAR(20);
