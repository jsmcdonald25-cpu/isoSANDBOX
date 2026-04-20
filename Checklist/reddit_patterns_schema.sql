-- reddit_patterns: admin-only scam/fraud pattern library scraped from Reddit
-- Usernames are stripped before storage. Zero PII. Content + Reddit permalink only.
-- Purpose: pattern library for AI to recognize scam techniques, NOT a name database.

create table if not exists public.reddit_patterns (
  id               uuid primary key default gen_random_uuid(),
  subreddit        text not null,
  post_id          text not null unique,             -- Reddit t3_/t1_ id for dedup
  post_type        text not null check (post_type in ('submission','comment')),
  title            text,                              -- submission title (null for comments)
  content          text not null,                     -- body text, usernames stripped → [user]
  permalink        text not null,                     -- https://reddit.com/r/.../comments/...
  matched_keywords text[] not null default '{}',
  score            int not null default 0,
  num_comments     int not null default 0,
  created_utc      timestamptz not null,
  scraped_at       timestamptz not null default now(),
  reviewed         boolean not null default false,
  useful           boolean,                           -- null = unreviewed, true/false = admin judgment
  dismissed        boolean not null default false,
  admin_notes      text
);

create index if not exists idx_rp_sub on public.reddit_patterns(subreddit);
create index if not exists idx_rp_created on public.reddit_patterns(created_utc desc);
create index if not exists idx_rp_unreviewed on public.reddit_patterns(reviewed) where reviewed = false;
create index if not exists idx_rp_useful on public.reddit_patterns(useful) where useful = true;

-- RLS: admin-only, fully private
alter table public.reddit_patterns enable row level security;

drop policy if exists rp_admin_all on public.reddit_patterns;
create policy rp_admin_all on public.reddit_patterns
  for all
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin = true))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin = true));
