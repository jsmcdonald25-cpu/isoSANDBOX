-- ============================================================
-- ISOsnipe Targets — Phase 3 (replace hardcoded TARGETS const)
-- ============================================================
-- Each row = one card+parallel combo that the scanner hits every
-- cycle. Admin adds via the "+ Add Target" modal (paste eBay URL).
-- The scanner reads this table at the start of each run.

create table if not exists isosnipe_targets (
  id                 uuid primary key default gen_random_uuid(),
  player             text        not null,
  card               text        not null,
  parallel           text        not null default 'Base',
  market_avg         numeric     not null check (market_avg > 0),
  correct_searches   text[]      not null default '{}',
  misspellings       text[]      not null default '{}',
  source_url         text,
  source_item_id     text,
  is_active          boolean     not null default true,
  created_by         uuid        references auth.users(id) on delete set null,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),
  last_scanned_at    timestamptz
);

create index if not exists isosnipe_targets_active_idx on isosnipe_targets(is_active) where is_active = true;
create index if not exists isosnipe_targets_player_idx on isosnipe_targets(player);

-- RLS off intentionally — admin-only table, accessed via service role.
alter table isosnipe_targets disable row level security;

-- Keep updated_at fresh on every edit.
create or replace function _isosnipe_targets_touch() returns trigger as $$
begin new.updated_at := now(); return new; end;
$$ language plpgsql;

drop trigger if exists isosnipe_targets_touch on isosnipe_targets;
create trigger isosnipe_targets_touch
  before update on isosnipe_targets
  for each row execute function _isosnipe_targets_touch();
