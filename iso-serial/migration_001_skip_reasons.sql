-- ISOSerial migration 001 — skip reasons + non-auto parallel support
-- Run this ONCE in Supabase SQL Editor (after schema.sql).
-- Safe to re-run (uses IF NOT EXISTS).

-- 1. Skip reason column on the queue.
--    Stored as TEXT, validated client-side. NULL = not skipped (or skipped before we tracked the reason).
ALTER TABLE iso_serial_queue
  ADD COLUMN IF NOT EXISTS skip_reason TEXT;

-- 2. Drop the old auto_type CHECK constraint that forbade NULL implicitly via the IN list.
--    NULL is now a valid value (means "non-auto parallel" — Flip Stock, Red Chrome, etc.).
--    The existing IN-list CHECK already allows NULL via SQL three-valued logic, so this is a no-op
--    unless a stricter constraint was added later. Left here for clarity.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'iso_serial_registry'::regclass
      AND conname LIKE '%auto_type%'
  ) THEN
    -- no-op; existing constraint already permits NULL
    NULL;
  END IF;
END $$;

SELECT pg_notify('pgrst', 'reload schema');
