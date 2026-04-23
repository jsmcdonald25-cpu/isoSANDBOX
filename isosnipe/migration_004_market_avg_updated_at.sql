-- ============================================================
-- ISOsnipe Targets — track when market_avg was last changed
-- ============================================================
-- Used to detect stale wrong_market_price rejections. Admin reviews
-- flagged targets where rejection count (after last market_avg change)
-- exceeds a threshold. Updating market_avg resets the timestamp,
-- which auto-clears the flag.

alter table isosnipe_targets
  add column if not exists market_avg_updated_at timestamptz default now();

-- Backfill existing rows to their created_at so they don't all flag at once.
update isosnipe_targets
  set market_avg_updated_at = coalesce(updated_at, created_at, now())
  where market_avg_updated_at is null;

-- Trigger: update market_avg_updated_at only when market_avg actually changes,
-- not on unrelated edits (is_active toggle, misspellings edit, etc.)
create or replace function _isosnipe_targets_market_avg_touch() returns trigger as $$
begin
  if new.market_avg is distinct from old.market_avg then
    new.market_avg_updated_at := now();
  end if;
  return new;
end;
$$ language plpgsql;

drop trigger if exists isosnipe_targets_market_avg_touch on isosnipe_targets;
create trigger isosnipe_targets_market_avg_touch
  before update on isosnipe_targets
  for each row execute function _isosnipe_targets_market_avg_touch();
