-- Patch the auto-created 2025_topps_chrome_football table that came from CSV import.
-- CSV import only created 6 columns; eBay query needs set_name/year/sport.

ALTER TABLE "2025_topps_chrome_football"
  ADD COLUMN IF NOT EXISTS id BIGSERIAL,
  ADD COLUMN IF NOT EXISTS set_name    TEXT          DEFAULT '2025 Topps Chrome Football',
  ADD COLUMN IF NOT EXISTS year        INT           DEFAULT 2025,
  ADD COLUMN IF NOT EXISTS sport       TEXT          DEFAULT 'football',
  ADD COLUMN IF NOT EXISTS variations  JSONB         DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS var_images  JSONB         DEFAULT '{}'::jsonb,
  ADD COLUMN IF NOT EXISTS created_at  TIMESTAMPTZ   DEFAULT now();

-- Backfill existing rows (defaults only apply to NEW rows, not retroactively)
UPDATE "2025_topps_chrome_football"
SET set_name   = COALESCE(set_name,   '2025 Topps Chrome Football'),
    year       = COALESCE(year,       2025),
    sport      = COALESCE(sport,      'football'),
    variations = COALESCE(variations, '[]'::jsonb),
    var_images = COALESCE(var_images, '{}'::jsonb);

-- Add primary key on id if missing
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = '"2025_topps_chrome_football"'::regclass
      AND contype = 'p'
  ) THEN
    ALTER TABLE "2025_topps_chrome_football" ADD PRIMARY KEY (id);
  END IF;
END $$;

-- Belt-and-suspenders on RLS + grants + iv_sets registration
ALTER TABLE "2025_topps_chrome_football" DISABLE ROW LEVEL SECURITY;
GRANT ALL ON "2025_topps_chrome_football" TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE "2025_topps_chrome_football_id_seq" TO anon, authenticated;

INSERT INTO iv_sets (table_name, label, sport, year, brand, name, col_schema, sort_order, is_new)
VALUES ('2025_topps_chrome_football', '2025 Topps Chrome Football', 'football', 2025, 'Topps', 'Chrome', 'standard', 2, true)
ON CONFLICT DO NOTHING;

SELECT pg_notify('pgrst', 'reload schema');
