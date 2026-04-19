#!/usr/bin/env node
/**
 * ISOSerial Bootstrap — one-shot local run to seed the review queue.
 *
 * Usage (from repo root):
 *   node iso-serial/bootstrap.js
 *
 * What it does:
 *   - Reads eBay + Supabase creds from .env
 *   - Queries eBay for Topps 2026 Series 1 + Heritage /5 listings
 *   - For each NEW listing (not yet in iso_serial_queue):
 *       - Fetches full detail via Get Item API (photos, seller, location)
 *       - Computes fraud flag
 *       - Inserts into iso_serial_queue (status = 'pending')
 *   - Logs each set's pull to iso_serial_pulls (run_environment = 'local_bootstrap')
 *
 * Safe to re-run. Dedupes by ebay_item_id, so killed mid-run → just re-run it.
 */

const { crawl } = require('./crawler');

crawl({ runEnvironment: 'local_bootstrap' })
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('\nFATAL:', err);
    process.exit(1);
  });
