-- =============================================================
-- GrailISO — ISOSerial AI Learning Stats
-- iso-serial/stats-schema.sql
-- =============================================================
-- Daily snapshot of how the AI classifier is performing vs.
-- admin's actual tagging/skipping decisions. Makes "is the AI
-- learning?" an observable metric, not a guess.
--
-- Run this in the Supabase SQL editor (project: jyfaegmnzkarlcximxjo).
-- =============================================================

CREATE TABLE IF NOT EXISTS public.iso_serial_ai_stats (
  snapshot_date        date        PRIMARY KEY,
  -- Raw counts
  classifier_calls     integer     NOT NULL DEFAULT 0,   -- queue rows that got AI pre-fill that day
  tagged_count         integer     NOT NULL DEFAULT 0,   -- admin approved + tagged (new or existing)
  skipped_count        integer     NOT NULL DEFAULT 0,   -- admin skipped
  pending_count        integer     NOT NULL DEFAULT 0,   -- still sitting in queue awaiting review
  -- Agreement: did AI's pre-classification match what admin did?
  agreement_count      integer     NOT NULL DEFAULT 0,   -- AI said reject AND admin skipped, OR AI said "none" AND admin tagged
  disagreement_count   integer     NOT NULL DEFAULT 0,   -- the inverse
  agreement_pct        numeric(5,2) NOT NULL DEFAULT 0,  -- agreement / (agreement + disagreement)
  -- AI confidence breakdown
  confidence_high      integer     NOT NULL DEFAULT 0,
  confidence_medium    integer     NOT NULL DEFAULT 0,
  confidence_low       integer     NOT NULL DEFAULT 0,
  -- Crawler blocklist size at end of day (0 if thin skip history)
  blocklist_terms      integer     NOT NULL DEFAULT 0,
  created_at           timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS iso_serial_ai_stats_date_idx
  ON public.iso_serial_ai_stats (snapshot_date DESC);

ALTER TABLE public.iso_serial_ai_stats ENABLE ROW LEVEL SECURITY;

-- Admin-only read (provenance admins see the stats)
DROP POLICY IF EXISTS iso_serial_ai_stats_admin_read ON public.iso_serial_ai_stats;
CREATE POLICY iso_serial_ai_stats_admin_read
  ON public.iso_serial_ai_stats
  FOR SELECT
  USING (
    auth.uid() IN (
      SELECT id FROM public.profiles
      WHERE role = 'owner' OR is_admin = true OR is_provenance_admin = true
    )
  );

-- Service role writes (compute-stats.js cron)
-- Service role bypasses RLS by default; no explicit write policy needed.

-- =============================================================
-- DONE. After running this, compute-stats.js will upsert daily.
-- =============================================================
