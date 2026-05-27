-- Her katılımcı oturum başına bir yorum bırakabilir (öğrenci ↔ eğitmen)
ALTER TABLE reviews DROP CONSTRAINT IF EXISTS reviews_exchange_request_id_key;
ALTER TABLE reviews DROP CONSTRAINT IF EXISTS uk_reviews_exchange_request_id;

CREATE UNIQUE INDEX IF NOT EXISTS uk_reviews_exchange_reviewer
    ON reviews (exchange_request_id, reviewer_id);
