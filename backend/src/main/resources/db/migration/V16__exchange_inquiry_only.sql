-- Mesaj / tanışma talebi: oluştururken kredi askıya alınmaz; kabul anında kontrol edilir.
DO $migration$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = current_schema() AND table_name = 'exchange_requests'
  ) THEN
    ALTER TABLE exchange_requests
      ADD COLUMN IF NOT EXISTS inquiry_only BOOLEAN NOT NULL DEFAULT FALSE;
  END IF;
END
$migration$;
