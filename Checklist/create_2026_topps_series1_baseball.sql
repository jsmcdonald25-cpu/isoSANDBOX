-- GrailISO Card Catalog — create table + iv_sets entry
-- Set: 2026 Topps Series 1 Baseball
-- Run this ONCE in Supabase SQL Editor before uploading the CSV

CREATE TABLE IF NOT EXISTS "2026_topps_series1_baseball" (
  id BIGSERIAL PRIMARY KEY,
  card_number TEXT,
  player TEXT,
  team TEXT,
  set_name TEXT DEFAULT '2026 Topps Series 1 Baseball',
  year INT DEFAULT 2026,
  sport TEXT DEFAULT 'baseball',
  category TEXT,
  insert_name TEXT,
  is_rookie BOOLEAN DEFAULT false,
  is_auto BOOLEAN DEFAULT false,
  is_mem BOOLEAN DEFAULT false,
  variations JSONB DEFAULT '[]',
  var_images JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE "2026_topps_series1_baseball" DISABLE ROW LEVEL SECURITY;
GRANT ALL ON "2026_topps_series1_baseball" TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE "2026_topps_series1_baseball_id_seq" TO anon, authenticated;

INSERT INTO iv_sets (table_name, label, sport, year, brand, name, col_schema, sort_order, is_new)
VALUES ('2026_topps_series1_baseball', '2026 Topps Series 1 Baseball', 'baseball', 2026, 'Topps', 'Series 1', 'standard', 2, true)
ON CONFLICT DO NOTHING;

SELECT pg_notify('pgrst', 'reload schema');
