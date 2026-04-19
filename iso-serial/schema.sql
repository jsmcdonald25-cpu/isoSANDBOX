-- ISOSerial Provenance Tracker — Schema
-- Run this ONCE in Supabase SQL Editor AFTER the 2026 Series 1 + Heritage checklist tables are loaded.
--
-- Three tables:
--   iso_serial_queue    — untagged eBay hits from the crawler, awaiting admin review
--   iso_serial_registry — permanent tracked physical cards (post-review), the provenance database
--   iso_serial_pulls    — crawler audit log (one row per cron/bootstrap run)
--
-- All three tables run RLS ON with service_role-only write.
-- Admin read/update access gated via profiles.is_provenance_admin = true.

-- ============================================================
-- 1. Admin flag on profiles
-- ============================================================
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS is_provenance_admin BOOLEAN DEFAULT FALSE;


-- ============================================================
-- 2. iso_serial_queue — raw crawler output, pre-review
-- ============================================================
CREATE TABLE IF NOT EXISTS iso_serial_queue (
  id BIGSERIAL PRIMARY KEY,

  -- eBay identity
  ebay_item_id TEXT UNIQUE NOT NULL,
  ebay_url TEXT,
  title TEXT,
  description TEXT,

  -- Price
  price_usd NUMERIC(10,2),

  -- Images (primary + gallery from Get Item API)
  image_urls JSONB DEFAULT '[]',

  -- Seller
  seller_username TEXT,
  seller_feedback_score INT,
  seller_feedback_percent NUMERIC(5,2),
  seller_account_age_days INT,

  -- Location (from Get Item API itemLocation + shippingOptions)
  item_location_city TEXT,
  item_location_state TEXT,
  item_location_country TEXT,
  ship_from_city TEXT,
  ship_from_state TEXT,

  -- Crawler-inferred guesses (admin confirms/corrects at review time)
  set_name_guess TEXT,            -- 'Series 1' | 'Heritage'
  serial_edition_guess TEXT,      -- '/5' if unspecified, or e.g. '3/5' if visible in title
  auto_type_guess TEXT,           -- 'on-card' | 'sticker-auto' | NULL
  inscription_guess TEXT,
  grade_guess TEXT,               -- 'PSA 9', 'BGS 9.5', etc.

  -- Fraud signal
  fraud_flag BOOLEAN DEFAULT FALSE,
  fraud_reasons JSONB DEFAULT '[]',

  -- Raw API payloads (for debugging + re-parsing later if rules change)
  raw_browse_response JSONB,
  raw_get_item_response JSONB,

  -- Lifecycle
  crawled_at TIMESTAMPTZ DEFAULT now(),
  status TEXT DEFAULT 'pending'
    CHECK (status IN ('pending','tagged_new','tagged_existing','skipped','error')),
  tagged_by UUID REFERENCES auth.users(id),
  tagged_at TIMESTAMPTZ,
  linked_registry_id BIGINT,      -- FK filled after tagging (points at iso_serial_registry.id)
  admin_notes TEXT
);

CREATE INDEX IF NOT EXISTS idx_iso_serial_queue_status       ON iso_serial_queue(status);
CREATE INDEX IF NOT EXISTS idx_iso_serial_queue_crawled_at   ON iso_serial_queue(crawled_at DESC);
CREATE INDEX IF NOT EXISTS idx_iso_serial_queue_fraud        ON iso_serial_queue(fraud_flag) WHERE fraud_flag = TRUE;
CREATE INDEX IF NOT EXISTS idx_iso_serial_queue_set_guess    ON iso_serial_queue(set_name_guess);


-- ============================================================
-- 3. iso_serial_registry — permanent provenance registry
-- One row per unique physical card (e.g. "Ohtani S1 card #1, copy 3 of 5")
-- ============================================================
CREATE TABLE IF NOT EXISTS iso_serial_registry (
  id BIGSERIAL PRIMARY KEY,

  -- Link to checklist (logical FK — per-set tables are dynamic so no real FK constraint)
  checklist_set_table TEXT NOT NULL,   -- e.g. '2026_topps_series1_baseball'
  checklist_card_id BIGINT NOT NULL,   -- row id in the per-set table

  -- Denormalized for fast display / search
  player TEXT NOT NULL,
  card_number TEXT,
  set_name TEXT,                       -- '2026 Topps Series 1 Baseball'

  -- Serial + variant identity
  serial_edition TEXT NOT NULL,        -- '1/5', '2/5', '3/5', '4/5', '5/5'
  parallel_name TEXT,                  -- base variant if null, else e.g. 'Chrome Gold'
  auto_type TEXT CHECK (auto_type IN ('on-card','sticker-auto')),
  is_inscribed BOOLEAN DEFAULT FALSE,
  inscription_text TEXT,

  -- Current grading state (updates if card gets re-graded)
  currently_graded BOOLEAN DEFAULT FALSE,
  current_grading_company TEXT CHECK (current_grading_company IN ('PSA','BGS','SGC','JSA',NULL)),
  current_grading_cert TEXT,
  current_grade NUMERIC(3,1),

  -- Pricing
  first_found_price NUMERIC(10,2),
  current_price NUMERIC(10,2),
  price_history JSONB DEFAULT '[]',
    -- [{price, date, grade, condition, ebay_item_id}]

  -- Provenance chain — every owner we've observed
  ownership_chain JSONB DEFAULT '[]',
    -- [{seller_username, location_city, location_state, date_observed, price,
    --   grade, ebay_item_id, ebay_url, queue_id}]

  -- Current owner
  current_owner_seller TEXT,
  current_owner_location_city TEXT,
  current_owner_location_state TEXT,

  -- Status
  status TEXT DEFAULT 'tracking'
    CHECK (status IN ('tracking','sold','delisted','on_grailiso','archived')),

  -- Timestamps
  first_found_at TIMESTAMPTZ DEFAULT now(),
  last_seen_at TIMESTAMPTZ DEFAULT now(),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),

  -- Only one row per checklist card + edition number
  UNIQUE (checklist_set_table, checklist_card_id, serial_edition, parallel_name)
);

CREATE INDEX IF NOT EXISTS idx_iso_serial_registry_player       ON iso_serial_registry(player);
CREATE INDEX IF NOT EXISTS idx_iso_serial_registry_checklist    ON iso_serial_registry(checklist_set_table, checklist_card_id);
CREATE INDEX IF NOT EXISTS idx_iso_serial_registry_status       ON iso_serial_registry(status);
CREATE INDEX IF NOT EXISTS idx_iso_serial_registry_last_seen    ON iso_serial_registry(last_seen_at DESC);


-- Back-fill FK from queue to registry (couldn't create in queue table above because registry didn't exist yet)
ALTER TABLE iso_serial_queue
  ADD CONSTRAINT fk_iso_serial_queue_registry
  FOREIGN KEY (linked_registry_id) REFERENCES iso_serial_registry(id) ON DELETE SET NULL;


-- ============================================================
-- 4. iso_serial_pulls — crawler audit log
-- ============================================================
CREATE TABLE IF NOT EXISTS iso_serial_pulls (
  id BIGSERIAL PRIMARY KEY,
  pull_timestamp TIMESTAMPTZ DEFAULT now(),
  set_searched TEXT NOT NULL,          -- 'Series 1' | 'Heritage'
  query_string TEXT,
  total_results INT,
  new_listings INT DEFAULT 0,
  duplicate_listings INT DEFAULT 0,
  api_calls_browse INT DEFAULT 0,
  api_calls_get_item INT DEFAULT 0,
  runtime_seconds NUMERIC(8,2),
  status TEXT DEFAULT 'success' CHECK (status IN ('success','partial','error')),
  error_message TEXT,
  run_environment TEXT CHECK (run_environment IN ('local_bootstrap','github_actions','manual'))
);

CREATE INDEX IF NOT EXISTS idx_iso_serial_pulls_timestamp ON iso_serial_pulls(pull_timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_iso_serial_pulls_set      ON iso_serial_pulls(set_searched);


-- ============================================================
-- 5. updated_at trigger for registry
-- ============================================================
CREATE OR REPLACE FUNCTION iso_serial_registry_touch_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_iso_serial_registry_updated_at ON iso_serial_registry;
CREATE TRIGGER trg_iso_serial_registry_updated_at
  BEFORE UPDATE ON iso_serial_registry
  FOR EACH ROW EXECUTE FUNCTION iso_serial_registry_touch_updated_at();


-- ============================================================
-- 6. RLS — enabled, provenance admins only
-- service_role bypasses RLS automatically (used by the crawler).
-- ============================================================
ALTER TABLE iso_serial_queue    ENABLE ROW LEVEL SECURITY;
ALTER TABLE iso_serial_registry ENABLE ROW LEVEL SECURITY;
ALTER TABLE iso_serial_pulls    ENABLE ROW LEVEL SECURITY;

-- Queue: provenance admins can read + update (tag), nobody else sees it
DROP POLICY IF EXISTS iso_serial_queue_admin_read   ON iso_serial_queue;
DROP POLICY IF EXISTS iso_serial_queue_admin_update ON iso_serial_queue;

CREATE POLICY iso_serial_queue_admin_read
  ON iso_serial_queue
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
        AND profiles.is_provenance_admin = TRUE
    )
  );

CREATE POLICY iso_serial_queue_admin_update
  ON iso_serial_queue
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
        AND profiles.is_provenance_admin = TRUE
    )
  );

-- Registry: same rules
DROP POLICY IF EXISTS iso_serial_registry_admin_read   ON iso_serial_registry;
DROP POLICY IF EXISTS iso_serial_registry_admin_update ON iso_serial_registry;
DROP POLICY IF EXISTS iso_serial_registry_admin_insert ON iso_serial_registry;

CREATE POLICY iso_serial_registry_admin_read
  ON iso_serial_registry
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
        AND profiles.is_provenance_admin = TRUE
    )
  );

CREATE POLICY iso_serial_registry_admin_update
  ON iso_serial_registry
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
        AND profiles.is_provenance_admin = TRUE
    )
  );

CREATE POLICY iso_serial_registry_admin_insert
  ON iso_serial_registry
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
        AND profiles.is_provenance_admin = TRUE
    )
  );

-- Pulls: admins read-only (crawler writes via service_role)
DROP POLICY IF EXISTS iso_serial_pulls_admin_read ON iso_serial_pulls;

CREATE POLICY iso_serial_pulls_admin_read
  ON iso_serial_pulls
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
        AND profiles.is_provenance_admin = TRUE
    )
  );


-- ============================================================
-- 7. Schema reload notify
-- ============================================================
SELECT pg_notify('pgrst', 'reload schema');


-- ============================================================
-- POST-RUN: manually flip your two admin accounts
-- ============================================================
-- UPDATE profiles SET is_provenance_admin = TRUE WHERE email IN (
--   'your-email-1@example.com',
--   'your-email-2@example.com'
-- );
