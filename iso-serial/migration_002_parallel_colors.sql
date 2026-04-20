-- ISOSerial migration 002 — parallel color + auto ink color + AI classification
-- Run this ONCE in Supabase SQL Editor (after migration_001).

-- 1. Parallel color (separate from parallel name) on registry.
--    e.g. parallel_name='Chrome Bordered', parallel_color='Red'
ALTER TABLE iso_serial_registry
  ADD COLUMN IF NOT EXISTS parallel_color TEXT;

-- 2. Auto ink color — colored-ink autographs (Red Ink, Blue Ink, Gold Ink) carry premium.
ALTER TABLE iso_serial_registry
  ADD COLUMN IF NOT EXISTS auto_ink_color TEXT;

-- 3. AI classification payload from Claude Haiku — stored on the queue row.
--    Includes the model's structured guess (parallel, color, edition, etc.) plus
--    metadata (token usage, model id, timestamp). Used to pre-fill the review modal.
ALTER TABLE iso_serial_queue
  ADD COLUMN IF NOT EXISTS ai_classification JSONB;

SELECT pg_notify('pgrst', 'reload schema');
