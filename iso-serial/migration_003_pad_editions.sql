-- ISOSerial migration 003 — zero-pad serial_edition numerators
-- Run ONCE in Supabase SQL Editor.
--
-- Normalizes serial_edition to collector convention:
--   /5   → 1/5, 2/5, ... 5/5 (single digit, no pad)
--   /10  → 01/10, 02/10, ... 10/10
--   /99  → 01/99 ... 99/99
--   /150 → 001/150 ... 150/150
--   /1000→ 0001/1000 ... 1000/1000
-- Leaves Flip Stock placeholders (N/A/5) untouched.

UPDATE iso_serial_registry
SET serial_edition = CASE
  WHEN serial_edition LIKE 'N/A/%' THEN serial_edition
  WHEN serial_edition ~ '^\d+/\d+$' THEN
    lpad(split_part(serial_edition, '/', 1),
         length(split_part(serial_edition, '/', 2)),
         '0')
    || '/' || split_part(serial_edition, '/', 2)
  ELSE serial_edition
END
WHERE serial_edition IS NOT NULL;

SELECT pg_notify('pgrst', 'reload schema');
