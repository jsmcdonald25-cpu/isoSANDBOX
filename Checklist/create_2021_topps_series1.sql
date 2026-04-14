-- GrailISO Card Catalog — create table + iv_sets entry
-- Set: 2021 Topps Series 1
-- Run this ONCE in Supabase SQL Editor before uploading the CSV

CREATE TABLE IF NOT EXISTS "2021_topps_series1" (
  id BIGSERIAL PRIMARY KEY,
  card_number TEXT,
  player TEXT,
  team TEXT,
  set_name TEXT DEFAULT '2021 Topps Series 1',
  year INT DEFAULT 2021,
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

ALTER TABLE "2021_topps_series1" DISABLE ROW LEVEL SECURITY;
GRANT ALL ON "2021_topps_series1" TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE "2021_topps_series1_id_seq" TO anon, authenticated;

INSERT INTO iv_sets (table_name, label, sport, year, brand, name, col_schema, sort_order, is_new)
VALUES ('2021_topps_series1', '2021 Topps Series 1', 'baseball', 2021, 'Topps', 'Series 1', 'standard', 2, true)
ON CONFLICT DO NOTHING;

SELECT pg_notify('pgrst', 'reload schema');
