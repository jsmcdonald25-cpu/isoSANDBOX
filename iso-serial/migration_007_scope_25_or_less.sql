-- ============================================================
-- iso_serial_queue — scope narrow to /25 or less (2026-04-23)
-- ============================================================
-- Scott's scope rule: only 1/1 + /5 + /10 + /25 serialized cards,
-- plus tracked unnumbered variations (Flip Stock, 1952 Rookie
-- Variation, Golden Mirror Image). Skip everything else from the
-- pending view to keep the queue actionable.
--
-- Soft-skip (status='skipped') — never hard delete. Audit preserved.

-- 1. Add raw_parallel_as_listed column (preserves seller's exact wording;
--    canonical parallel_name lives in ai_classification as today).
alter table iso_serial_queue
  add column if not exists raw_parallel_as_listed text;

-- 2. Backfill: auto-skip any pending row where AI classified print_run > 25.
update iso_serial_queue
set
  status      = 'skipped',
  skip_reason = 'not_a_5',
  admin_notes = concat(
    'AI auto-skipped: print_run=',
    ai_classification->>'print_run',
    ' exceeds /25 scope (backfill 2026-04-23)'
  ),
  tagged_at   = now()
where
  status = 'pending'
  and ai_classification is not null
  and (ai_classification->>'print_run') ~ '^[0-9]+$'
  and (ai_classification->>'print_run')::int > 25;

-- 3. Diagnostic — count of rows in each bucket after the cleanup
select
  status,
  count(*) as n,
  count(*) filter (
    where ai_classification is not null
      and (ai_classification->>'print_run') ~ '^[0-9]+$'
  ) as with_print_run
from iso_serial_queue
group by status
order by status;
