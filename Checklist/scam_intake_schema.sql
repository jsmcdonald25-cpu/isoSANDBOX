-- scam_intake: admin-only manual capture of off-platform scam evidence
-- (Facebook/IG DMs, eBay messages, emails, texts, etc.)
-- Auto-strips usernames/emails from pasted text.
-- Screenshots land in a PRIVATE Supabase Storage bucket (signed URLs only).

create table if not exists public.scam_intake (
  id             uuid primary key default gen_random_uuid(),
  source         text not null check (source in (
                   'dm_messenger','dm_instagram','dm_discord',
                   'ebay_msg','email','text_message','other'
                 )),
  scam_category  text check (scam_category in (
                   'catalog_error','price_variance','duplicate_submission',
                   'provenance_mismatch','incomplete_info','pattern_deviation',
                   'manual_review_required','fake_card','never_shipped',
                   'bait_switch','chargeback_abuse','other'
                 )),
  date_occurred  date,
  content        text not null,                       -- pasted conversation / email body, usernames stripped
  screenshots    text[] not null default '{}',        -- storage paths within the bucket
  admin_notes    text,
  reviewed       boolean not null default false,
  useful         boolean,
  dismissed      boolean not null default false,
  submitted_by   uuid references public.profiles(id),
  created_at     timestamptz not null default now()
);

create index if not exists idx_si_source on public.scam_intake(source);
create index if not exists idx_si_created on public.scam_intake(created_at desc);
create index if not exists idx_si_unreviewed on public.scam_intake(reviewed) where reviewed = false;

alter table public.scam_intake enable row level security;

drop policy if exists si_admin_all on public.scam_intake;
create policy si_admin_all on public.scam_intake
  for all
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin = true))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin = true));

-- ─── Private Storage bucket for screenshots ───
insert into storage.buckets (id, name, public)
  values ('scam-intake', 'scam-intake', false)
  on conflict (id) do nothing;

-- Admin-only access to the bucket (read, write, delete)
drop policy if exists "scam-intake admin read"   on storage.objects;
drop policy if exists "scam-intake admin write"  on storage.objects;
drop policy if exists "scam-intake admin update" on storage.objects;
drop policy if exists "scam-intake admin delete" on storage.objects;

create policy "scam-intake admin read" on storage.objects
  for select
  using (bucket_id = 'scam-intake'
         and exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin = true));

create policy "scam-intake admin write" on storage.objects
  for insert
  with check (bucket_id = 'scam-intake'
              and exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin = true));

create policy "scam-intake admin update" on storage.objects
  for update
  using (bucket_id = 'scam-intake'
         and exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin = true));

create policy "scam-intake admin delete" on storage.objects
  for delete
  using (bucket_id = 'scam-intake'
         and exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin = true));
