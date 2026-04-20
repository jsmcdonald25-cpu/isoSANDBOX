-- ISOsnipe Rejections — admin marks "not a real snipe" with reason.
-- Each ebay item# is permanently excluded from future scans.
-- AI uses title + description + item specifics to learn pattern blocklist.

CREATE TABLE IF NOT EXISTS public.isosnipe_rejections (
  id              BIGSERIAL PRIMARY KEY,
  ebay_item_id    TEXT NOT NULL UNIQUE,
  player          TEXT,
  parallel        TEXT,
  card            TEXT,
  title           TEXT,
  description     TEXT,
  item_specifics  JSONB,
  reason_code     TEXT NOT NULL,
  reason_notes    TEXT,
  rejected_by     UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  rejected_by_name TEXT,
  rejected_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS isosnipe_rejections_item_idx
  ON public.isosnipe_rejections (ebay_item_id);

CREATE INDEX IF NOT EXISTS isosnipe_rejections_reason_idx
  ON public.isosnipe_rejections (reason_code);

CREATE INDEX IF NOT EXISTS isosnipe_rejections_player_idx
  ON public.isosnipe_rejections (player, parallel);

CREATE INDEX IF NOT EXISTS isosnipe_rejections_recent_idx
  ON public.isosnipe_rejections (rejected_at DESC);

-- RLS off intentionally — admin-only table, same pattern as per-set catalog tables.
ALTER TABLE public.isosnipe_rejections DISABLE ROW LEVEL SECURITY;

-- Reason code reference (informational, not enforced):
--   wrong_player          — different player pictured
--   wrong_year            — different print year
--   wrong_set             — flagship vs chrome etc.
--   wrong_parallel        — different color / tier
--   wrong_card_num        — different card # in set
--   reprint_or_custom     — fan-made, unofficial, custom
--   facsimile_signature   — printed/stamped sig, not real auto
--   graded_mismatch       — listed grade/condition wrong
--   bad_photos            — can't verify, revisit later
--   other                 — see notes
