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

-- ── PENDING CARDS (missing-card submissions awaiting admin approval) ──
CREATE TABLE IF NOT EXISTS public.pending_cards (
  id              BIGSERIAL PRIMARY KEY,
  user_id         UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,

  -- Card identity (user-supplied)
  player          TEXT NOT NULL,
  year            INT,
  brand           TEXT,
  set_name        TEXT,
  card_number     TEXT,
  team            TEXT,
  variation       TEXT NOT NULL,          -- the missing parallel / variation name

  -- Images (user-uploaded via Supabase Storage)
  front_image_url TEXT,
  back_image_url  TEXT,

  -- Acquisition details (same fields as vault modal)
  acquisition_type  TEXT,                 -- bought_single, pulled, trade, other
  purchase_source   TEXT,                 -- ebay, lcs, facebook, other_source
  pack_type         TEXT,                 -- hobby_box, blaster, etc.
  price_paid        NUMERIC(10,2),
  date_acquired     DATE,
  serial_number     INT,
  serial_total      INT,

  -- Admin workflow
  status          TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','approved','rejected')),
  admin_note      TEXT,
  reviewed_by     UUID REFERENCES public.profiles(id),
  reviewed_at     TIMESTAMPTZ,

  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_pending_user   ON public.pending_cards (user_id);
CREATE INDEX IF NOT EXISTS idx_pending_status ON public.pending_cards (status);

ALTER TABLE public.pending_cards ENABLE ROW LEVEL SECURITY;

-- Anyone can insert (submit), users can read their own, admins read all via service key
CREATE POLICY "pending_cards_insert" ON public.pending_cards FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "pending_cards_read_own" ON public.pending_cards FOR SELECT USING (auth.uid() = user_id);

-- ── ALPHA SIGNUPS (waitlist for alpha testers) ───────────────
CREATE TABLE IF NOT EXISTS public.alpha_signups (
  id              BIGSERIAL PRIMARY KEY,
  email           TEXT NOT NULL UNIQUE,
  first_name      TEXT,
  last_name       TEXT,
  note            TEXT,                   -- optional message from applicant
  favorite_sport  TEXT,                   -- what they collect

  -- Admin workflow
  status          TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','approved','rejected','invited')),
  invite_sent_at  TIMESTAMPTZ,           -- when magic link was emailed
  admin_note      TEXT,
  reviewed_by     UUID REFERENCES public.profiles(id),
  reviewed_at     TIMESTAMPTZ,

  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_alpha_email  ON public.alpha_signups (email);
CREATE INDEX IF NOT EXISTS idx_alpha_status ON public.alpha_signups (status);

ALTER TABLE public.alpha_signups ENABLE ROW LEVEL SECURITY;

-- Public insert (no auth needed — this is a pre-signup form)
CREATE POLICY "alpha_signups_insert" ON public.alpha_signups FOR INSERT WITH CHECK (true);
-- Only service role (admin) can read/update
CREATE POLICY "alpha_signups_service" ON public.alpha_signups FOR ALL USING (auth.role() = 'service_role');

-- ══════════════════════════════════════════════════════════════
-- TRANSACTION ARCHITECTURE — Full ISO → Match → Offer → Pay →
-- Grade/Verify → Ship → Complete flow
-- ══════════════════════════════════════════════════════════════

-- ── SELLER PREFERENCES ──────────────────────────────────────
-- Users opt in as sellers + configure what they're willing to sell
CREATE TABLE IF NOT EXISTS public.seller_preferences (
  id              BIGSERIAL PRIMARY KEY,
  user_id         UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,

  is_seller       BOOLEAN NOT NULL DEFAULT false,
  sports          TEXT[] DEFAULT '{}',            -- e.g. {'baseball','basketball'}
  card_types      TEXT[] DEFAULT '{}',            -- e.g. {'rc','auto','base'}
  min_price       NUMERIC(10,2) DEFAULT 0,        -- don't notify below this
  notify_email    BOOLEAN NOT NULL DEFAULT true,
  notify_push     BOOLEAN NOT NULL DEFAULT true,
  auto_respond    BOOLEAN NOT NULL DEFAULT false,  -- future: auto-accept if price >= asking

  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_seller_user ON public.seller_preferences (user_id);
ALTER TABLE public.seller_preferences ENABLE ROW LEVEL SECURITY;
CREATE POLICY "seller_prefs_own" ON public.seller_preferences FOR ALL USING (auth.uid() = user_id);

-- ── OFFERS ──────────────────────────────────────────────────
-- Seller responds to a match with their price/grade/cert
CREATE TABLE IF NOT EXISTS public.offers (
  id              BIGSERIAL PRIMARY KEY,
  match_id        BIGINT NOT NULL REFERENCES public.matches(id) ON DELETE CASCADE,
  iso_id          BIGINT NOT NULL REFERENCES public.isos(id),
  seller_id       UUID NOT NULL REFERENCES public.profiles(id),
  buyer_id        UUID NOT NULL REFERENCES public.profiles(id),

  -- Seller's card details
  grade_company   TEXT,                           -- PSA, BGS, SGC, CGC, RAW
  grade_number    TEXT,                           -- 10, 9.5, 9, etc.
  cert_number     TEXT,                           -- grading cert number
  condition_notes TEXT,                           -- seller's description
  asking_price    NUMERIC(10,2) NOT NULL,

  -- Photos (seller can add/update at offer time)
  front_image_url TEXT,
  back_image_url  TEXT,

  -- Status
  status          TEXT NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending','accepted','declined','countered','expired','withdrawn')),

  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_offer_match  ON public.offers (match_id);
CREATE INDEX IF NOT EXISTS idx_offer_buyer  ON public.offers (buyer_id);
CREATE INDEX IF NOT EXISTS idx_offer_seller ON public.offers (seller_id);
CREATE INDEX IF NOT EXISTS idx_offer_status ON public.offers (status);
ALTER TABLE public.offers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "offers_parties" ON public.offers FOR ALL
  USING (auth.uid() = buyer_id OR auth.uid() = seller_id);

-- ── COUNTER OFFERS ──────────────────────────────────────────
-- Back-and-forth negotiation (max 3 rounds enforced in app)
CREATE TABLE IF NOT EXISTS public.counter_offers (
  id              BIGSERIAL PRIMARY KEY,
  offer_id        BIGINT NOT NULL REFERENCES public.offers(id) ON DELETE CASCADE,
  from_user_id    UUID NOT NULL REFERENCES public.profiles(id),
  to_user_id      UUID NOT NULL REFERENCES public.profiles(id),

  price           NUMERIC(10,2) NOT NULL,
  message         TEXT,
  round_number    INT NOT NULL DEFAULT 1,         -- 1, 2, or 3

  status          TEXT NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending','accepted','declined','expired')),

  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_counter_offer ON public.counter_offers (offer_id);
ALTER TABLE public.counter_offers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "counter_parties" ON public.counter_offers FOR ALL
  USING (auth.uid() = from_user_id OR auth.uid() = to_user_id);

-- ── TRANSACTIONS ────────────────────────────────────────────
-- Master record linking everything together
CREATE TABLE IF NOT EXISTS public.transactions (
  id              BIGSERIAL PRIMARY KEY,
  iso_id          BIGINT REFERENCES public.isos(id),
  match_id        BIGINT REFERENCES public.matches(id),
  offer_id        BIGINT REFERENCES public.offers(id),
  buyer_id        UUID NOT NULL REFERENCES public.profiles(id),
  seller_id       UUID NOT NULL REFERENCES public.profiles(id),

  -- Agreed terms
  agreed_price    NUMERIC(10,2) NOT NULL,
  platform_fee    NUMERIC(10,2) NOT NULL DEFAULT 0,
  grading_fee     NUMERIC(10,2) DEFAULT 0,
  shipping_fee    NUMERIC(10,2) DEFAULT 0,
  total_amount    NUMERIC(10,2) NOT NULL,          -- agreed + fees

  -- Status workflow
  status          TEXT NOT NULL DEFAULT 'payment_pending'
                  CHECK (status IN (
                    'payment_pending',              -- waiting for buyer to pay
                    'payment_held',                 -- Stripe hold active
                    'service_selected',             -- buyer chose grading/verification
                    'awaiting_shipment',            -- seller needs to ship to hub
                    'shipped_to_hub',               -- seller shipped, in transit
                    'received_at_hub',              -- hub received card
                    'verification_in_progress',     -- hub inspecting
                    'verification_failed',          -- authenticity/grade failed
                    'submitted_for_grading',        -- sent to PSA/BGS/etc
                    'grading_complete',             -- grade returned
                    'shipping_to_buyer',            -- card on way to buyer
                    'delivered',                    -- carrier confirmed delivery
                    'completed',                    -- buyer confirmed, payment captured
                    'cancelled',                    -- cancelled before completion
                    'disputed',                     -- dispute opened
                    'refunded'                      -- refunded to buyer
                  )),

  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_txn_buyer    ON public.transactions (buyer_id);
CREATE INDEX IF NOT EXISTS idx_txn_seller   ON public.transactions (seller_id);
CREATE INDEX IF NOT EXISTS idx_txn_status   ON public.transactions (status);
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "txn_parties" ON public.transactions FOR ALL
  USING (auth.uid() = buyer_id OR auth.uid() = seller_id);

-- ── PAYMENTS ────────────────────────────────────────────────
-- Stripe payment intents and capture tracking
CREATE TABLE IF NOT EXISTS public.payments (
  id                  BIGSERIAL PRIMARY KEY,
  transaction_id      BIGINT NOT NULL REFERENCES public.transactions(id),
  stripe_payment_intent_id TEXT UNIQUE,
  stripe_customer_id  TEXT,

  amount_held         NUMERIC(10,2),              -- initial hold amount
  amount_captured     NUMERIC(10,2),              -- final captured amount (may differ)
  currency            TEXT NOT NULL DEFAULT 'usd',

  status              TEXT NOT NULL DEFAULT 'pending'
                      CHECK (status IN ('pending','held','captured','cancelled','refunded','failed')),

  held_at             TIMESTAMPTZ,
  captured_at         TIMESTAMPTZ,
  refunded_at         TIMESTAMPTZ,

  created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_pay_txn    ON public.payments (transaction_id);
CREATE INDEX IF NOT EXISTS idx_pay_stripe ON public.payments (stripe_payment_intent_id);
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "pay_service" ON public.payments FOR ALL USING (auth.role() = 'service_role');

-- ── GRADING ORDERS ──────────────────────────────────────────
-- When buyer selects grading service after payment hold
CREATE TABLE IF NOT EXISTS public.grading_orders (
  id              BIGSERIAL PRIMARY KEY,
  transaction_id  BIGINT NOT NULL REFERENCES public.transactions(id),

  -- Service selection
  service_type    TEXT NOT NULL DEFAULT 'verification_only'
                  CHECK (service_type IN ('verification_only','grading','already_graded')),
  grading_company TEXT,                           -- PSA, BGS, SGC, CGC (null if verification_only)
  grading_tier    TEXT,                           -- standard, express, premium
  fee             NUMERIC(10,2) NOT NULL DEFAULT 0,
  estimated_turnaround_days INT,

  -- Results (filled by admin after grading returns)
  grade_received  TEXT,                           -- e.g. "PSA 10", "BGS 9.5"
  cert_number     TEXT,
  grade_notes     TEXT,

  status          TEXT NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending','submitted','in_progress','completed','failed')),

  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_grade_txn ON public.grading_orders (transaction_id);
ALTER TABLE public.grading_orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "grade_service" ON public.grading_orders FOR ALL USING (auth.role() = 'service_role');

-- ── SHIPPING ────────────────────────────────────────────────
-- Tracks both seller→hub and hub→buyer shipments
CREATE TABLE IF NOT EXISTS public.shipping (
  id              BIGSERIAL PRIMARY KEY,
  transaction_id  BIGINT NOT NULL REFERENCES public.transactions(id),

  leg             TEXT NOT NULL CHECK (leg IN ('seller_to_hub','hub_to_buyer')),
  carrier         TEXT,                           -- USPS, UPS, FedEx, etc.
  tracking_number TEXT,
  label_url       TEXT,                           -- prepaid label download URL

  -- Addresses
  from_name       TEXT,
  from_address    TEXT,
  to_name         TEXT,
  to_address      TEXT,

  status          TEXT NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending','label_created','shipped','in_transit','delivered','returned')),

  shipped_at      TIMESTAMPTZ,
  delivered_at    TIMESTAMPTZ,

  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_ship_txn ON public.shipping (transaction_id);
ALTER TABLE public.shipping ENABLE ROW LEVEL SECURITY;
CREATE POLICY "ship_parties" ON public.shipping FOR ALL
  USING (auth.role() = 'service_role');  -- only admin manages shipping

-- ── HUB INSPECTIONS ─────────────────────────────────────────
-- Admin verification results when card arrives at hub
CREATE TABLE IF NOT EXISTS public.hub_inspections (
  id              BIGSERIAL PRIMARY KEY,
  transaction_id  BIGINT NOT NULL REFERENCES public.transactions(id),
  inspector_id    UUID REFERENCES public.profiles(id),

  -- Verification
  authenticity    TEXT CHECK (authenticity IN ('pass','fail','inconclusive')),
  grade_confirmed BOOLEAN,                        -- does grade match seller's claim?
  condition_notes TEXT,
  inspection_photos TEXT[],                       -- array of Storage URLs

  -- Overall result
  result          TEXT NOT NULL DEFAULT 'pending'
                  CHECK (result IN ('pending','passed','failed')),
  failure_reason  TEXT,                           -- if failed

  inspected_at    TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_hub_txn ON public.hub_inspections (transaction_id);
ALTER TABLE public.hub_inspections ENABLE ROW LEVEL SECURITY;
CREATE POLICY "hub_service" ON public.hub_inspections FOR ALL USING (auth.role() = 'service_role');

-- ── DISPUTES ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.disputes (
  id              BIGSERIAL PRIMARY KEY,
  transaction_id  BIGINT NOT NULL REFERENCES public.transactions(id),
  opened_by       UUID NOT NULL REFERENCES public.profiles(id),

  reason          TEXT NOT NULL,
  description     TEXT,
  evidence_urls   TEXT[],                         -- photos, screenshots

  status          TEXT NOT NULL DEFAULT 'open'
                  CHECK (status IN ('open','under_review','resolved_buyer','resolved_seller','closed')),
  resolution_note TEXT,
  resolved_by     UUID REFERENCES public.profiles(id),
  resolved_at     TIMESTAMPTZ,

  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_dispute_txn ON public.disputes (transaction_id);
ALTER TABLE public.disputes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "dispute_parties" ON public.disputes FOR ALL
  USING (auth.uid() = opened_by OR auth.role() = 'service_role');

-- ── REVIEWS ─────────────────────────────────────────────────
-- Post-transaction ratings from both parties
CREATE TABLE IF NOT EXISTS public.reviews (
  id              BIGSERIAL PRIMARY KEY,
  transaction_id  BIGINT NOT NULL REFERENCES public.transactions(id),
  reviewer_id     UUID NOT NULL REFERENCES public.profiles(id),
  reviewee_id     UUID NOT NULL REFERENCES public.profiles(id),

  rating          INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment         TEXT,
  role            TEXT NOT NULL CHECK (role IN ('buyer','seller')),

  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (transaction_id, reviewer_id)
);

CREATE INDEX IF NOT EXISTS idx_review_txn      ON public.reviews (transaction_id);
CREATE INDEX IF NOT EXISTS idx_review_reviewee ON public.reviews (reviewee_id);
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
CREATE POLICY "review_own" ON public.reviews FOR INSERT WITH CHECK (auth.uid() = reviewer_id);
CREATE POLICY "review_read" ON public.reviews FOR SELECT USING (true);

-- ── UPLOAD CREDIT EVENTS (milestone tracking) ───────────────
-- Track upload milestone awards separately for clean accounting
CREATE TABLE IF NOT EXISTS public.upload_milestones (
  id              BIGSERIAL PRIMARY KEY,
  user_id         UUID NOT NULL REFERENCES public.profiles(id),
  threshold       INT NOT NULL,                   -- 10, 25, 50, 100
  bonus_credits   INT NOT NULL,
  awarded_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  awarded_by      UUID REFERENCES public.profiles(id),
  UNIQUE (user_id, threshold)
);

CREATE INDEX IF NOT EXISTS idx_ulmile_user ON public.upload_milestones (user_id);
ALTER TABLE public.upload_milestones ENABLE ROW LEVEL SECURITY;
CREATE POLICY "ulmile_read_own" ON public.upload_milestones FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "ulmile_service" ON public.upload_milestones FOR INSERT USING (auth.role() = 'service_role');

-- ── ADMIN ACTIONS (audit log) ─────────────────────────────────
-- Every card add, edit, delete, approval, rejection by any admin
CREATE TABLE IF NOT EXISTS public.admin_actions (
  id              BIGSERIAL PRIMARY KEY,
  admin_id        UUID REFERENCES public.profiles(id),
  admin_name      TEXT,
  action_type     TEXT NOT NULL CHECK (action_type IN (
                    'card_added','card_edited','card_deleted',
                    'card_approved','card_rejected','image_uploaded'
                  )),
  table_name      TEXT,                              -- which set table was affected
  card_number     TEXT,
  player          TEXT,
  before_data     JSONB,                             -- snapshot before change
  after_data      JSONB,                             -- snapshot after change
  note            TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_admin_actions_admin ON public.admin_actions (admin_id);
CREATE INDEX IF NOT EXISTS idx_admin_actions_type  ON public.admin_actions (action_type);
CREATE INDEX IF NOT EXISTS idx_admin_actions_date  ON public.admin_actions (created_at DESC);
ALTER TABLE public.admin_actions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "admin_actions_read" ON public.admin_actions FOR SELECT USING (true);
CREATE POLICY "admin_actions_insert" ON public.admin_actions FOR INSERT WITH CHECK (true);

-- ============================================================
-- SCHEMA COMPLETE
-- Tables:  profiles · cards · vault · isos · matches
--          notifications · credit_events · pending_cards
--          alpha_signups · seller_preferences · offers
--          counter_offers · transactions · payments
--          grading_orders · shipping · hub_inspections
--          disputes · reviews · upload_milestones
--          admin_actions
-- Triggers: vault→ISO match · ISO→vault match · signup bonus
-- ============================================================
