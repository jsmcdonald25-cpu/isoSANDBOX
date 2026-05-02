-- Add is_new column to iv_sets if it doesn't exist
ALTER TABLE iv_sets ADD COLUMN IF NOT EXISTS is_new BOOLEAN DEFAULT false;

-- Create the card table
CREATE TABLE IF NOT EXISTS "2025_topps_chrome_football" (
  id BIGSERIAL PRIMARY KEY,
  card_number TEXT,
  player TEXT,
  team TEXT,
  set_name TEXT DEFAULT '2025 Topps Chrome Football',
  year INT DEFAULT 2025,
  sport TEXT DEFAULT 'football',
  category TEXT DEFAULT 'Base',
  insert_name TEXT,
  is_rookie BOOLEAN DEFAULT false,
  variations JSONB DEFAULT '[]',
  var_images JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE "2025_topps_chrome_football" DISABLE ROW LEVEL SECURITY;
GRANT ALL ON "2025_topps_chrome_football" TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE "2025_topps_chrome_football_id_seq" TO anon, authenticated;

-- Add to iv_sets
INSERT INTO iv_sets (table_name, label, sport, year, brand, name, col_schema, sort_order, is_new)
VALUES ('2025_topps_chrome_football', '2025 Topps Chrome Football', 'football', 2025, 'Topps', 'Chrome', 'standard', 2, true);

SELECT pg_notify('pgrst', 'reload schema');
