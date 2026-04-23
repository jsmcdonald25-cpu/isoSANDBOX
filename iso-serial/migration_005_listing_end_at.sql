-- ============================================================
-- iso_serial_queue — add listing_end_at (eBay itemEndDate)
-- ============================================================
-- Used by Serial Queue admin table to sort "ending soonest" so
-- Scott can capture provenance right before an auction closes.
-- Populated by crawler from itemDetail.itemEndDate going forward;
-- backfilled from raw_get_item_response for existing rows.

alter table iso_serial_queue
  add column if not exists listing_end_at timestamptz;

-- Backfill existing rows from the raw eBay response JSON.
update iso_serial_queue
set    listing_end_at = (raw_get_item_response->>'itemEndDate')::timestamptz
where  listing_end_at is null
  and  raw_get_item_response ? 'itemEndDate';

-- Index for the default "ending soonest" sort.
create index if not exists iso_serial_queue_listing_end_at_idx
  on iso_serial_queue (listing_end_at);
