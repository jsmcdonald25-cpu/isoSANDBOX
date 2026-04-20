-- ISOsnipe Confirmations — admin marks "this IS a real snipe (good)".
-- Feeds positive examples to the AI Learn analyzer alongside rejections.

CREATE TABLE IF NOT EXISTS public.isosnipe_confirmations (
  id              BIGSERIAL PRIMARY KEY,
  ebay_item_id    TEXT NOT NULL UNIQUE,
  player          TEXT,
  parallel        TEXT,
  card            TEXT,
  title           TEXT,
  description     TEXT,
  item_specifics  JSONB,
  price           NUMERIC,
  market_avg      NUMERIC,
  delta           NUMERIC,
  confirmed_by    UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  confirmed_by_name TEXT,
  confirmed_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS isosnipe_confirmations_item_idx
  ON public.isosnipe_confirmations (ebay_item_id);

CREATE INDEX IF NOT EXISTS isosnipe_confirmations_player_idx
  ON public.isosnipe_confirmations (player, parallel);

CREATE INDEX IF NOT EXISTS isosnipe_confirmations_recent_idx
  ON public.isosnipe_confirmations (confirmed_at DESC);

ALTER TABLE public.isosnipe_confirmations DISABLE ROW LEVEL SECURITY;
