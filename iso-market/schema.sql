-- =============================================================
-- GrailISO — Player Market Meter
-- iso-market/schema.sql
-- =============================================================
-- One row per player per day. Snapshot of eBay active-listings
-- pricing: average of top 10 priciest listings, and the number
-- of cheapest listings needed to sum to $50 (floor index).
--
-- Run this in the Supabase SQL editor (project: jyfaegmnzkarlcximxjo).
-- =============================================================

CREATE TABLE IF NOT EXISTS public.player_market_snapshots (
  id               bigserial   PRIMARY KEY,
  player_id        integer     NOT NULL,      -- matches players.mlb_id
  snapshot_date    date        NOT NULL,
  top10_avg        numeric(10,2) NOT NULL,    -- avg of 10 priciest listings
  floor_50_index   integer     NOT NULL,      -- # of cheapest listings needed to sum $50 (lower = hotter)
  total_listings   integer     NOT NULL,      -- raw count of qualifying listings before filtering
  filtered_out     integer     NOT NULL DEFAULT 0, -- # of multi-player/dropdown listings rejected
  created_at       timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT player_market_snapshots_unique UNIQUE (player_id, snapshot_date)
);

-- Fast lookups by latest date + by player timeline
CREATE INDEX IF NOT EXISTS player_market_snapshots_date_idx
  ON public.player_market_snapshots (snapshot_date DESC);

CREATE INDEX IF NOT EXISTS player_market_snapshots_player_date_idx
  ON public.player_market_snapshots (player_id, snapshot_date DESC);

-- RLS: public read (non-sensitive pricing data), service_role write only
ALTER TABLE public.player_market_snapshots ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS player_market_snapshots_public_read ON public.player_market_snapshots;
CREATE POLICY player_market_snapshots_public_read
  ON public.player_market_snapshots
  FOR SELECT
  USING (true);

-- Service role bypasses RLS by default; no explicit insert/update policy needed.
-- If non-service role ever needs to write (Netlify function w/ anon key), add policy here.

-- Helpful view: latest snapshot per player
CREATE OR REPLACE VIEW public.player_market_latest AS
SELECT DISTINCT ON (player_id)
  player_id,
  snapshot_date,
  top10_avg,
  floor_50_index,
  total_listings,
  filtered_out,
  created_at
FROM public.player_market_snapshots
ORDER BY player_id, snapshot_date DESC, created_at DESC;

-- =============================================================
-- DONE. After running this, the collection script
-- (iso-market/collect.js) will upsert rows daily via GH Actions.
-- =============================================================
