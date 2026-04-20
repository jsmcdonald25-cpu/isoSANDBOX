-- Dedupe iso_serial_registry
--
-- A "physical card" is uniquely identified by:
--   (checklist_set_table, player, card_number, serial_edition)
--
-- Duplicates happen when admin clicks "Save as NEW registry" multiple times
-- on the same queue entry or on separate queue entries for the same physical card.
--
-- This merges duplicate groups by:
--   1. Keeping the row with the earliest first_found_at as canonical.
--   2. Appending all distinct ownership_chain + price_history entries from dupes.
--   3. Deleting the non-canonical rows.
--   4. Repointing iso_serial_queue.linked_registry_id to the canonical row.
--   5. Adding a UNIQUE constraint so this can't happen again.

BEGIN;

-- Step 1: pick canonical row per dup group (oldest first_found_at wins).
WITH groups AS (
  SELECT
    id,
    checklist_set_table,
    player,
    card_number,
    serial_edition,
    first_found_at,
    ROW_NUMBER() OVER (
      PARTITION BY checklist_set_table, player, card_number, serial_edition
      ORDER BY first_found_at ASC, id ASC
    ) AS rn
  FROM public.iso_serial_registry
  WHERE checklist_set_table IS NOT NULL
    AND player IS NOT NULL
    AND card_number IS NOT NULL
    AND serial_edition IS NOT NULL
),
canonicals AS (
  SELECT id AS canonical_id, checklist_set_table, player, card_number, serial_edition
  FROM groups WHERE rn = 1
),
dupes AS (
  SELECT g.id AS dup_id, c.canonical_id
  FROM groups g
  JOIN canonicals c USING (checklist_set_table, player, card_number, serial_edition)
  WHERE g.rn > 1
)

-- Step 2: merge ownership_chain + price_history from dupes into canonical.
UPDATE public.iso_serial_registry AS canon
SET
  ownership_chain = COALESCE(canon.ownership_chain, '[]'::jsonb)
    || COALESCE((SELECT jsonb_agg(elem)
                 FROM dupes d
                 JOIN public.iso_serial_registry r ON r.id = d.dup_id
                 CROSS JOIN LATERAL jsonb_array_elements(COALESCE(r.ownership_chain, '[]'::jsonb)) AS elem
                 WHERE d.canonical_id = canon.id), '[]'::jsonb),
  price_history = COALESCE(canon.price_history, '[]'::jsonb)
    || COALESCE((SELECT jsonb_agg(elem)
                 FROM dupes d
                 JOIN public.iso_serial_registry r ON r.id = d.dup_id
                 CROSS JOIN LATERAL jsonb_array_elements(COALESCE(r.price_history, '[]'::jsonb)) AS elem
                 WHERE d.canonical_id = canon.id), '[]'::jsonb),
  last_seen_at = GREATEST(
    canon.last_seen_at,
    COALESCE((SELECT MAX(r.last_seen_at) FROM dupes d JOIN public.iso_serial_registry r ON r.id = d.dup_id WHERE d.canonical_id = canon.id), canon.last_seen_at)
  )
FROM dupes
WHERE canon.id = dupes.canonical_id;

-- Step 3: repoint queue.linked_registry_id from dupes → canonical.
UPDATE public.iso_serial_queue q
SET linked_registry_id = c.canonical_id
FROM (
  WITH groups AS (
    SELECT id, checklist_set_table, player, card_number, serial_edition,
           ROW_NUMBER() OVER (PARTITION BY checklist_set_table, player, card_number, serial_edition
                              ORDER BY first_found_at ASC, id ASC) rn
    FROM public.iso_serial_registry
    WHERE checklist_set_table IS NOT NULL AND player IS NOT NULL
      AND card_number IS NOT NULL AND serial_edition IS NOT NULL
  )
  SELECT g.id AS dup_id,
         (SELECT id FROM groups g2
            WHERE g2.checklist_set_table = g.checklist_set_table
              AND g2.player = g.player
              AND g2.card_number = g.card_number
              AND g2.serial_edition = g.serial_edition
              AND g2.rn = 1) AS canonical_id
  FROM groups g WHERE g.rn > 1
) c
WHERE q.linked_registry_id = c.dup_id;

-- Step 4: delete dup rows (ownership chain + history already merged into canonical).
DELETE FROM public.iso_serial_registry
WHERE id IN (
  SELECT id FROM (
    SELECT id,
           ROW_NUMBER() OVER (PARTITION BY checklist_set_table, player, card_number, serial_edition
                              ORDER BY first_found_at ASC, id ASC) rn
    FROM public.iso_serial_registry
    WHERE checklist_set_table IS NOT NULL AND player IS NOT NULL
      AND card_number IS NOT NULL AND serial_edition IS NOT NULL
  ) t WHERE rn > 1
);

-- Step 5: prevent it from happening again.
ALTER TABLE public.iso_serial_registry
  ADD CONSTRAINT iso_serial_registry_physical_card_uniq
  UNIQUE (checklist_set_table, player, card_number, serial_edition);

COMMIT;
