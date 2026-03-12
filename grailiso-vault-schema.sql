-- ============================================================
-- GRAILISO — VAULT SCHEMA
-- Run in: Supabase → SQL Editor
-- Version: 1.0.0 | Build 20260310
-- ============================================================

-- ── USERS (extends Supabase auth.users) ─────────────────────
CREATE TABLE IF NOT EXISTS public.profiles (
  id              UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username        TEXT UNIQUE NOT NULL,
  display_name    TEXT,
  avatar_url      TEXT,
  iso_credits     INT NOT NULL DEFAULT 5,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── CARD MASTER (the catalog) ────────────────────────────────
-- This mirrors your JS CARDS array — source of truth for matching
CREATE TABLE IF NOT EXISTS public.cards (
  id              BIGSERIAL PRIMARY KEY,
  player          TEXT NOT NULL,
  card_number     TEXT NOT NULL,
  set_name        TEXT NOT NULL,
  year            INT NOT NULL,
  sport           TEXT NOT NULL,
  team            TEXT,
  category        TEXT NOT NULL CHECK (category IN ('Base','Auto','Insert','Relic')),
  insert_name     TEXT,
  is_rookie       BOOLEAN NOT NULL DEFAULT false,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Index for fast search
CREATE INDEX IF NOT EXISTS idx_cards_player   ON public.cards (lower(player));
CREATE INDEX IF NOT EXISTS idx_cards_year     ON public.cards (year);
CREATE INDEX IF NOT EXISTS idx_cards_set      ON public.cards (set_name);
CREATE INDEX IF NOT EXISTS idx_cards_sport    ON public.cards (sport);

-- ── VAULT (user collections) ─────────────────────────────────
-- One row per card a user owns (they can have multiples)
CREATE TABLE IF NOT EXISTS public.vault (
  id              BIGSERIAL PRIMARY KEY,
  user_id         UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  card_id         BIGINT NOT NULL REFERENCES public.cards(id) ON DELETE CASCADE,

  -- Card details
  parallel        TEXT NOT NULL DEFAULT 'Base',
  card_number_print TEXT,             -- e.g. "12/50" for numbered cards
  grade           TEXT,               -- PSA 9, BGS 9.5, RAW, etc.
  grade_company   TEXT,               -- PSA, BGS, SGC, CGC, RAW
  grade_cert_num  TEXT,               -- Grading cert number

  -- Provenance
  acquired_date   DATE,
  acquired_price  NUMERIC(10,2),
  acquired_from   TEXT,               -- eBay, COMC, LCS, Trade, Pack, etc.
  notes           TEXT,

  -- Images (Supabase Storage URLs)
  image_front_url TEXT,
  image_back_url  TEXT,

  -- Status flags
  is_for_sale     BOOLEAN NOT NULL DEFAULT false,
  asking_price    NUMERIC(10,2),
  is_hidden       BOOLEAN NOT NULL DEFAULT false,   -- private, won't show in matches

  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_vault_user     ON public.vault (user_id);
CREATE INDEX IF NOT EXISTS idx_vault_card     ON public.vault (card_id);
CREATE INDEX IF NOT EXISTS idx_vault_sale     ON public.vault (is_for_sale) WHERE is_for_sale = true;

-- ── ISO BOARD (active wants) ─────────────────────────────────
CREATE TABLE IF NOT EXISTS public.isos (
  id              BIGSERIAL PRIMARY KEY,
  user_id         UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  card_id         BIGINT NOT NULL REFERENCES public.cards(id) ON DELETE CASCADE,

  parallel        TEXT NOT NULL DEFAULT 'Base',
  max_price       NUMERIC(10,2),
  notes           TEXT,

  status          TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','filled','expired','cancelled')),
  credits_spent   INT NOT NULL DEFAULT 1,
  expires_at      TIMESTAMPTZ NOT NULL DEFAULT (now() + interval '30 days'),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_isos_card      ON public.isos (card_id);
CREATE INDEX IF NOT EXISTS idx_isos_user      ON public.isos (user_id);
CREATE INDEX IF NOT EXISTS idx_isos_active    ON public.isos (status) WHERE status = 'active';

-- ── MATCHES (ISO × Vault cross-reference) ────────────────────
-- Populated by the match engine (trigger or cron)
CREATE TABLE IF NOT EXISTS public.matches (
  id              BIGSERIAL PRIMARY KEY,
  iso_id          BIGINT NOT NULL REFERENCES public.isos(id) ON DELETE CASCADE,
  vault_entry_id  BIGINT NOT NULL REFERENCES public.vault(id) ON DELETE CASCADE,
  buyer_id        UUID NOT NULL REFERENCES public.profiles(id),
  seller_id       UUID NOT NULL REFERENCES public.profiles(id),

  -- Notification state
  seller_notified BOOLEAN NOT NULL DEFAULT false,
  seller_notified_at TIMESTAMPTZ,
  seller_responded   TEXT CHECK (seller_responded IN ('interested','not_selling','ignored')),
  seller_responded_at TIMESTAMPTZ,

  match_score     INT NOT NULL DEFAULT 100,         -- 100 = exact, 80 = parallel diff, etc.
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE (iso_id, vault_entry_id)
);

CREATE INDEX IF NOT EXISTS idx_matches_seller ON public.matches (seller_id);
CREATE INDEX IF NOT EXISTS idx_matches_buyer  ON public.matches (buyer_id);
CREATE INDEX IF NOT EXISTS idx_matches_iso    ON public.matches (iso_id);

-- ── NOTIFICATIONS ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.notifications (
  id              BIGSERIAL PRIMARY KEY,
  user_id         UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  type            TEXT NOT NULL,  -- 'iso_match', 'vault_matched', 'iso_filled', 'credit_earned'
  title           TEXT NOT NULL,
  body            TEXT,
  data            JSONB,          -- { match_id, iso_id, vault_id, card_id, etc. }
  is_read         BOOLEAN NOT NULL DEFAULT false,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_notif_user     ON public.notifications (user_id, is_read);

-- ── CREDIT LEDGER ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.credit_events (
  id              BIGSERIAL PRIMARY KEY,
  user_id         UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  delta           INT NOT NULL,       -- +5 signup, +2 scan upload, -1 ISO post
  reason          TEXT NOT NULL,      -- 'signup_bonus', 'scan_upload', 'iso_post', 'purchase'
  ref_id          TEXT,               -- ISO id, vault id, Stripe payment id
  balance_after   INT NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_credits_user   ON public.credit_events (user_id);

-- ── MATCH ENGINE — TRIGGER ────────────────────────────────────
-- Fires when a vault entry is inserted → find matching ISOs
CREATE OR REPLACE FUNCTION public.find_iso_matches_for_vault()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.matches (iso_id, vault_entry_id, buyer_id, seller_id, match_score)
  SELECT
    i.id,
    NEW.id,
    i.user_id,
    NEW.user_id,
    CASE
      WHEN i.parallel = NEW.parallel THEN 100
      ELSE 80
    END AS match_score
  FROM public.isos i
  WHERE
    i.card_id = NEW.card_id
    AND i.status = 'active'
    AND i.user_id != NEW.user_id
    AND NEW.is_hidden = false
    AND NOT EXISTS (
      SELECT 1 FROM public.matches m
      WHERE m.iso_id = i.id AND m.vault_entry_id = NEW.id
    )
  ON CONFLICT (iso_id, vault_entry_id) DO NOTHING;

  -- Queue notifications for each match found
  INSERT INTO public.notifications (user_id, type, title, body, data)
  SELECT
    NEW.user_id,
    'vault_matched',
    'Someone wants a card in your vault',
    'A buyer has an active ISO matching one of your cards.',
    jsonb_build_object('vault_entry_id', NEW.id, 'card_id', NEW.card_id)
  WHERE EXISTS (
    SELECT 1 FROM public.matches m
    WHERE m.vault_entry_id = NEW.id AND m.seller_notified = false
    LIMIT 1
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_vault_iso_match
  AFTER INSERT ON public.vault
  FOR EACH ROW
  EXECUTE FUNCTION public.find_iso_matches_for_vault();

-- ── REVERSE TRIGGER — fires when ISO is posted ───────────────
CREATE OR REPLACE FUNCTION public.find_vault_matches_for_iso()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.matches (iso_id, vault_entry_id, buyer_id, seller_id, match_score)
  SELECT
    NEW.id,
    v.id,
    NEW.user_id,
    v.user_id,
    CASE
      WHEN v.parallel = NEW.parallel THEN 100
      ELSE 80
    END AS match_score
  FROM public.vault v
  WHERE
    v.card_id = NEW.card_id
    AND v.user_id != NEW.user_id
    AND v.is_hidden = false
  ON CONFLICT (iso_id, vault_entry_id) DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_iso_vault_match
  AFTER INSERT ON public.isos
  FOR EACH ROW
  EXECUTE FUNCTION public.find_vault_matches_for_iso();

-- ── ROW LEVEL SECURITY ────────────────────────────────────────
ALTER TABLE public.profiles     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vault        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.isos         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credit_events ENABLE ROW LEVEL SECURITY;

-- Profiles: visible to all, editable by owner
CREATE POLICY "profiles_read_all"   ON public.profiles FOR SELECT USING (true);
CREATE POLICY "profiles_write_own"  ON public.profiles FOR ALL    USING (auth.uid() = id);

-- Vault: public cards visible (non-hidden), full access to owner
CREATE POLICY "vault_read_public"   ON public.vault FOR SELECT USING (is_hidden = false OR auth.uid() = user_id);
CREATE POLICY "vault_write_own"     ON public.vault FOR ALL    USING (auth.uid() = user_id);

-- ISOs: active ones visible to all
CREATE POLICY "isos_read_active"    ON public.isos FOR SELECT USING (status = 'active' OR auth.uid() = user_id);
CREATE POLICY "isos_write_own"      ON public.isos FOR ALL    USING (auth.uid() = user_id);

-- Matches: only the buyer or seller can see
CREATE POLICY "matches_parties"     ON public.matches FOR SELECT USING (auth.uid() = buyer_id OR auth.uid() = seller_id);

-- Notifications: private
CREATE POLICY "notif_own"           ON public.notifications FOR ALL USING (auth.uid() = user_id);

-- Credits: private
CREATE POLICY "credits_own"         ON public.credit_events FOR ALL USING (auth.uid() = user_id);

-- ── SIGNUP BONUS TRIGGER ─────────────────────────────────────
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, iso_credits)
  VALUES (NEW.id, split_part(NEW.email, '@', 1), 5);

  INSERT INTO public.credit_events (user_id, delta, reason, balance_after)
  VALUES (NEW.id, 5, 'signup_bonus', 5);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- SCHEMA COMPLETE
-- Tables:  profiles · cards · vault · isos · matches
--          notifications · credit_events
-- Triggers: vault→ISO match · ISO→vault match · signup bonus
-- ============================================================
