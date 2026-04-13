-- ═══════════════════════════════════════════════════════════════
-- CARD SHOPS FEATURE — Schema + RLS
-- Run in Supabase SQL Editor (one-time)
-- ═══════════════════════════════════════════════════════════════

-- ── 1. card_shops — master directory of shops ──
CREATE TABLE IF NOT EXISTS card_shops (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name          TEXT NOT NULL,
  address       TEXT,
  city          TEXT,
  state         TEXT,            -- US state or CA province code (e.g. TN, NC, ON)
  country       TEXT DEFAULT 'US',
  zip           TEXT,
  phone         TEXT,
  lat           DOUBLE PRECISION,
  lng           DOUBLE PRECISION,
  region        TEXT,            -- metro grouping key (e.g. 'chattanooga', 'charlotte')
  types         TEXT[],          -- e.g. {'Sports','Pokemon','MTG'}
  hours         TEXT,
  website       TEXT,
  notes         TEXT,
  google_place_id TEXT,          -- dedup key for scraper
  source        TEXT DEFAULT 'manual',  -- 'manual','google','yelp','scraper'
  verified      BOOLEAN DEFAULT false,
  active        BOOLEAN DEFAULT true,
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_card_shops_state   ON card_shops(state);
CREATE INDEX IF NOT EXISTS idx_card_shops_region  ON card_shops(region);
CREATE UNIQUE INDEX IF NOT EXISTS idx_card_shops_place_id ON card_shops(google_place_id) WHERE google_place_id IS NOT NULL;

-- card_shops is public read, admin write — RLS off for now (same pattern as per-set catalog tables)
-- Will enable RLS when more admins are added


-- ── 2. shop_reviews — user ratings + freeform ──
CREATE TABLE IF NOT EXISTS shop_reviews (
  id             UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  shop_id        UUID REFERENCES card_shops(id) ON DELETE CASCADE NOT NULL,
  user_id        UUID REFERENCES auth.users(id) NOT NULL,
  -- Quick-input boolean tags
  good_pulls     BOOLEAN DEFAULT false,
  liked_shop     BOOLEAN DEFAULT false,
  nice_people    BOOLEAN DEFAULT false,
  good_prices    BOOLEAN DEFAULT false,
  nice_inventory BOOLEAN DEFAULT false,
  -- Freeform review (min 100 chars enforced in UI + DB)
  review_text    TEXT NOT NULL CHECK (char_length(review_text) >= 100),
  -- Admin moderation
  status         TEXT DEFAULT 'pending' CHECK (status IN ('pending','approved','rejected','flagged')),
  admin_notes    TEXT,
  reviewed_by    UUID,
  reviewed_at    TIMESTAMPTZ,
  created_at     TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_shop_reviews_shop   ON shop_reviews(shop_id);
CREATE INDEX IF NOT EXISTS idx_shop_reviews_status ON shop_reviews(status);
CREATE INDEX IF NOT EXISTS idx_shop_reviews_user   ON shop_reviews(user_id);

ALTER TABLE shop_reviews ENABLE ROW LEVEL SECURITY;

-- Users can insert their own review
CREATE POLICY "Users can insert own reviews"
  ON shop_reviews FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can see approved reviews + their own (any status)
CREATE POLICY "Users can read approved or own reviews"
  ON shop_reviews FOR SELECT
  USING (status = 'approved' OR auth.uid() = user_id);

-- Admins can read all reviews
CREATE POLICY "Admins can read all reviews"
  ON shop_reviews FOR SELECT
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin = true));

-- Admins can update any review (approve/reject/flag/edit)
CREATE POLICY "Admins can update reviews"
  ON shop_reviews FOR UPDATE
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin = true));


-- ── 3. shop_favorites — user bookmarks ──
CREATE TABLE IF NOT EXISTS shop_favorites (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id     UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  shop_id     UUID REFERENCES card_shops(id) ON DELETE CASCADE NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, shop_id)
);

CREATE INDEX IF NOT EXISTS idx_shop_favorites_user ON shop_favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_shop_favorites_shop ON shop_favorites(shop_id);

ALTER TABLE shop_favorites ENABLE ROW LEVEL SECURITY;

-- Users can manage (select, insert, delete) their own favorites
CREATE POLICY "Users manage own favorites"
  ON shop_favorites FOR ALL
  USING (auth.uid() = user_id);

-- Anyone can read favorite counts (aggregated) — allow public select
CREATE POLICY "Public can read favorites for counts"
  ON shop_favorites FOR SELECT
  USING (true);
