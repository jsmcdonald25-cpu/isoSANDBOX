-- =============================================================
-- GrailISO — ISOSerial AI Corrections Log
-- iso-serial/corrections-schema.sql
-- =============================================================
-- For every Serial Queue save, capture:
--   1. The AI's pre-classification snapshot (from "Apply to form")
--   2. The admin's final form snapshot (at save time)
--   3. A diff of which fields changed
-- Phase 2 feedback loop reads this table and injects the most common
-- (seller-title → corrected-classification) patterns back into the
-- classifier's system prompt so the next crawler run benefits.
--
-- Run this in Supabase SQL editor (project: jyfaegmnzkarlcximxjo).
-- =============================================================

CREATE TABLE IF NOT EXISTS public.iso_serial_ai_corrections (
  id              bigserial   PRIMARY KEY,
  queue_id        integer     NOT NULL,   -- iso_serial_queue.id
  ebay_item_id    text        NOT NULL,
  listing_title   text,
  set_name_guess  text,
  -- Snapshots
  ai_snapshot     jsonb       NOT NULL,   -- 16-field classifier output + applied form state
  admin_snapshot  jsonb       NOT NULL,   -- what admin actually saved
  diff            jsonb       NOT NULL,   -- { field: {before: X, after: Y}, ... }
  fields_changed  integer     NOT NULL DEFAULT 0,
  perfect_match   boolean     NOT NULL DEFAULT false,  -- fields_changed == 0
  -- Audit
  admin_id        uuid,
  confidence      text,                    -- AI's self-reported confidence at pre-fill
  auto_saved      boolean     NOT NULL DEFAULT false,  -- Phase 3: save skipped manual review
  created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS iso_serial_ai_corrections_queue_idx
  ON public.iso_serial_ai_corrections (queue_id);

CREATE INDEX IF NOT EXISTS iso_serial_ai_corrections_created_idx
  ON public.iso_serial_ai_corrections (created_at DESC);

CREATE INDEX IF NOT EXISTS iso_serial_ai_corrections_perfect_idx
  ON public.iso_serial_ai_corrections (perfect_match, created_at DESC);

ALTER TABLE public.iso_serial_ai_corrections ENABLE ROW LEVEL SECURITY;

-- Provenance admins only
DROP POLICY IF EXISTS iso_serial_ai_corrections_admin_read ON public.iso_serial_ai_corrections;
CREATE POLICY iso_serial_ai_corrections_admin_read
  ON public.iso_serial_ai_corrections
  FOR SELECT
  USING (
    auth.uid() IN (
      SELECT id FROM public.profiles
      WHERE role = 'owner' OR is_admin = true OR is_provenance_admin = true
    )
  );

DROP POLICY IF EXISTS iso_serial_ai_corrections_admin_insert ON public.iso_serial_ai_corrections;
CREATE POLICY iso_serial_ai_corrections_admin_insert
  ON public.iso_serial_ai_corrections
  FOR INSERT
  WITH CHECK (
    auth.uid() IN (
      SELECT id FROM public.profiles
      WHERE role = 'owner' OR is_admin = true OR is_provenance_admin = true
    )
  );

-- =============================================================
-- DONE. Admin.html writes rows here on every Save in Serial Queue.
-- Classifier prompt (Phase 2) will read this table + merge top
-- correction patterns into its "ADMIN CORRECTIONS" example block.
-- =============================================================
