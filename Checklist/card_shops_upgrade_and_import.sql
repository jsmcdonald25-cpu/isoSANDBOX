-- ═══════════════════════════════════════════════════════════════
-- CARD SHOPS — Add new columns + prepare for master CSV import
-- Run in Supabase SQL Editor
-- ═══════════════════════════════════════════════════════════════

-- ── STEP 1: Add new columns to card_shops ──
ALTER TABLE card_shops ADD COLUMN IF NOT EXISTS email          TEXT;
ALTER TABLE card_shops ADD COLUMN IF NOT EXISTS facebook_url   TEXT;
ALTER TABLE card_shops ADD COLUMN IF NOT EXISTS instagram_url  TEXT;
ALTER TABLE card_shops ADD COLUMN IF NOT EXISTS x_url          TEXT;
ALTER TABLE card_shops ADD COLUMN IF NOT EXISTS discord        TEXT;
ALTER TABLE card_shops ADD COLUMN IF NOT EXISTS ebay_url       TEXT;
ALTER TABLE card_shops ADD COLUMN IF NOT EXISTS tcgplayer_url  TEXT;

-- ── STEP 2: Wipe existing rows before fresh import ──
-- The master CSV is the new source of truth (1,265 cleaned shops).
-- If you want to keep existing rows and merge instead, SKIP this step.
TRUNCATE card_shops CASCADE;

-- ── STEP 3: Import via Supabase CSV Import ──
-- Go to Table Editor → card_shops → Insert → Import from CSV
-- Select: Checklist/card_shops_master_clean.csv
--
-- Column mapping (CSV column → DB column):
--   name           → name
--   address        → address
--   city           → city
--   state          → state
--   country        → country
--   postal_code    → zip            ← NOTE: CSV says postal_code, DB says zip
--   phone          → phone
--   email          → email
--   facebook_url   → facebook_url
--   instagram_url  → instagram_url
--   website        → website
--   x_url          → x_url
--   discord        → discord
--   ebay_url       → ebay_url
--   tcgplayer_url  → tcgplayer_url
--   types          → types          ← SEE NOTE BELOW
--   hours          → hours
--   lat            → lat
--   lng            → lng
--   source         → source
--   notes          → notes
--
-- IMPORTANT: The `types` column in the DB is TEXT[] (array).
-- The CSV has types as comma-separated text like "Sports,Pokemon,MTG".
-- Supabase CSV import may not auto-cast this to TEXT[].
--
-- If types doesn't import cleanly, run this after import to fix:

/*
UPDATE card_shops
SET types = string_to_array(
  regexp_replace(types::text, '^\{|\}$', '', 'g'),
  ','
)
WHERE types IS NOT NULL;
*/

-- ── STEP 4: Set defaults for columns not in CSV ──
UPDATE card_shops SET verified = false WHERE verified IS NULL;
UPDATE card_shops SET active = true WHERE active IS NULL;
UPDATE card_shops SET region = NULL WHERE region = '';
UPDATE card_shops SET lat = NULL WHERE lat = 0 OR lat::text = '';
UPDATE card_shops SET lng = NULL WHERE lng = 0 OR lng::text = '';

-- ── STEP 5: Verify ──
SELECT count(*) AS total_shops FROM card_shops;
SELECT state, count(*) AS cnt FROM card_shops GROUP BY state ORDER BY cnt DESC LIMIT 20;
SELECT source, count(*) AS cnt FROM card_shops GROUP BY source ORDER BY cnt DESC;
