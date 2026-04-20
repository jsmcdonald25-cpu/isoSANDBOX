-- user_watch_flags: admin-only behavioral flag log for users
-- Legal posture: tags BEHAVIORS (observable facts), not PEOPLE (character judgments).
-- No free-text notes. Enum categories only. Auto-expire. RLS admin-only.

create table if not exists public.user_watch_flags (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references public.profiles(id) on delete cascade,
  username     text not null,                    -- snapshot at flag time
  location     text,                             -- optional city/state snapshot, never address/phone
  category     text not null check (category in (
                  'catalog_error',
                  'price_variance',
                  'duplicate_submission',
                  'provenance_mismatch',
                  'incomplete_info',
                  'pattern_deviation',
                  'manual_review_required'
                )),
  severity     text not null default 'low' check (severity in ('low','medium','high')),
  count        int  not null default 1,          -- incremented on repeat flags of same category
  first_flagged_at timestamptz not null default now(),
  last_flagged_at  timestamptz not null default now(),
  expires_at   timestamptz not null default (now() + interval '90 days'),
  resolved     boolean not null default false,
  resolved_at  timestamptz,
  resolved_by  uuid references public.profiles(id),
  created_by   uuid references public.profiles(id),
  created_at   timestamptz not null default now(),
  unique (user_id, category, resolved)            -- one active row per (user, category)
);

create index if not exists idx_uwf_user on public.user_watch_flags(user_id);
create index if not exists idx_uwf_active on public.user_watch_flags(resolved) where resolved = false;
create index if not exists idx_uwf_expires on public.user_watch_flags(expires_at) where resolved = false;

-- RLS: admin-only, no user can see their own flags
alter table public.user_watch_flags enable row level security;

drop policy if exists uwf_admin_all on public.user_watch_flags;
create policy uwf_admin_all on public.user_watch_flags
  for all
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin = true))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin = true));

-- Auto-resolve expired flags (run daily via cron if desired)
create or replace function public.uwf_expire_stale()
returns void language sql as $$
  update public.user_watch_flags
     set resolved = true, resolved_at = now()
   where resolved = false and expires_at < now();
$$;
