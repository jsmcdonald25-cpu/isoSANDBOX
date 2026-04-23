-- ============================================================
-- Backfill: auto-skip pending rows the AI classified as not serialized
-- ============================================================
-- Uses the existing soft-skip mechanism (status='skipped', skip_reason='not_a_5')
-- so rows are still in the DB for audit but disappear from the pending view.
-- Safe to re-run — only touches status='pending' rows.

update iso_serial_queue
set
  status       = 'skipped',
  skip_reason  = 'not_a_5',
  admin_notes  = concat('AI auto-skipped: not serialized (confidence=',
                        coalesce(ai_classification->>'confidence', 'unknown'),
                        ')'),
  tagged_at    = now()
where
  status = 'pending'
  and ai_classification is not null
  and (ai_classification->>'is_serialized')::boolean = false;
