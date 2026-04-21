#!/usr/bin/env node
/**
 * GrailISO — Player Market Meter Collector
 *
 * For every player in the `players` table, hits the eBay Browse API,
 * filters out multi-player "pick your card" listings, and computes:
 *   - top10_avg:       mean of the 10 priciest qualifying listings
 *   - floor_50_index:  # of cheapest listings needed to sum ≥ $50
 *                      (lower = hotter player, higher price floor)
 *
 * Upserts one row per (player_id, snapshot_date) to player_market_snapshots.
 *
 * Invoked daily by .github/workflows/market-meter.yml at 06:00 UTC.
 *
 * Env vars:
 *   EBAY_CLIENT_ID, EBAY_CLIENT_SECRET
 *   SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
 */

require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

const EBAY_CLIENT_ID        = process.env.EBAY_CLIENT_ID;
const EBAY_CLIENT_SECRET    = process.env.EBAY_CLIENT_SECRET;
const SUPABASE_URL          = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!EBAY_CLIENT_ID || !EBAY_CLIENT_SECRET) throw new Error('Missing EBAY_CLIENT_ID / EBAY_CLIENT_SECRET');
if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE) throw new Error('Missing SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY');

const EBAY_CATEGORY_ID = '261328';   // Sports Trading Cards
const LISTINGS_LIMIT   = 200;        // eBay Browse max per query
const PRICE_FLOOR_USD  = 0.50;       // skip sub-fifty-cent junk
const FLOOR_TARGET_USD = 50;         // $50 Floor Index target
const TOP_N_FOR_AVG    = 10;
const SLEEP_MS         = 250;

const sbHeaders = {
  'apikey': SUPABASE_SERVICE_ROLE,
  'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE}`,
  'Content-Type': 'application/json',
};

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// ─── Multi-player / pick-your-card filter ──────────────────
// Keywords that strongly indicate the listing covers multiple cards
// or players. The user can't know exactly what they're getting, so
// the asking price is a weighted average of many cards, not this
// player's — useless for our metric.
const DROPDOWN_PATTERNS = [
  /\b(u\s*pick|you\s*pick|pick\s*your|your\s*choice|pyc)\b/i,
  /\bpick\s*(a|from|the|card|player)\b/i,
  /\bchoose\s*(from|your|a|the)\b/i,
  /\b(lot\s*of|multi[-\s]?card)\b/i,
  /\b(complete|partial|team)\s*set\b/i,
  /\bteam\s*break\b/i,
  /\bvariations?\s*(available|list|dropdown)\b/i,
  /\b\d+\s*(card|pack)s?\b/i,      // "25 cards", "100 card lot"
  /\b(1st|second|third|50)\s*half\b/i, // "first half listings"
];

function isDropdownListing(title){
  const t = (title || '').toLowerCase();
  return DROPDOWN_PATTERNS.some(re => re.test(t));
}

// ─── eBay auth ──────────────────────────────────────────────
async function getEbayToken(){
  const credentials = Buffer.from(`${EBAY_CLIENT_ID}:${EBAY_CLIENT_SECRET}`).toString('base64');
  const res = await fetch('https://api.ebay.com/identity/v1/oauth2/token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': `Basic ${credentials}`,
    },
    body: 'grant_type=client_credentials&scope=https%3A%2F%2Fapi.ebay.com%2Foauth%2Fapi_scope',
  });
  if (!res.ok) throw new Error(`eBay auth failed (${res.status}): ${await res.text()}`);
  return (await res.json()).access_token;
}

// ─── eBay Browse search ─────────────────────────────────────
async function searchPlayer(token, playerName){
  const filter = [
    `price:[${PRICE_FLOOR_USD}..]`,
    'priceCurrency:USD',
    'deliveryCountry:US',
    'buyingOptions:{FIXED_PRICE|AUCTION}',
  ].join(',');

  const q = `"${playerName}" baseball card`;
  const params = new URLSearchParams({
    q,
    category_ids: EBAY_CATEGORY_ID,
    filter,
    limit: String(LISTINGS_LIMIT),
    sort: '-price', // highest price first (saves pagination for top10 calc)
  });

  const res = await fetch(
    `https://api.ebay.com/buy/browse/v1/item_summary/search?${params}`,
    { headers: { 'Authorization': `Bearer ${token}`, 'X-EBAY-C-MARKETPLACE-ID': 'EBAY_US' } }
  );

  if (!res.ok) {
    if (res.status === 429) { await sleep(5000); return []; }
    if (res.status === 204) return [];
    console.warn(`  [${playerName}] eBay search ${res.status}`);
    return [];
  }

  const body = await res.json();
  return body.itemSummaries || [];
}

// ─── Metric computation ─────────────────────────────────────
function computeMetrics(items){
  const total_raw = items.length;
  // Extract price + title + drop filtered rows
  const clean = [];
  let filtered_out = 0;
  for (const it of items){
    if (!it || !it.title) { filtered_out++; continue; }
    if (isDropdownListing(it.title)) { filtered_out++; continue; }
    const p = parseFloat(it?.price?.value);
    if (!isFinite(p) || p < PRICE_FLOOR_USD) { filtered_out++; continue; }
    clean.push({ price: p, title: it.title });
  }

  if (clean.length === 0) return null;

  // top10_avg — sort desc, take up to 10, mean
  clean.sort((a,b) => b.price - a.price);
  const topSlice = clean.slice(0, TOP_N_FOR_AVG);
  const top10_avg = topSlice.reduce((s,r) => s + r.price, 0) / topSlice.length;

  // floor_50_index — sort asc, accumulate until sum ≥ $50
  const asc = [...clean].sort((a,b) => a.price - b.price);
  let running = 0, idx = 0;
  for (const r of asc){
    idx++;
    running += r.price;
    if (running >= FLOOR_TARGET_USD) break;
  }
  // If we ran out before hitting $50, idx = total clean listings (conservative)
  const floor_50_index = running >= FLOOR_TARGET_USD ? idx : clean.length;

  return {
    top10_avg: Number(top10_avg.toFixed(2)),
    floor_50_index,
    total_listings: clean.length,
    filtered_out,
    total_raw,
  };
}

// ─── Supabase: fetch player list ────────────────────────────
async function fetchPlayers(){
  const url = `${SUPABASE_URL}/rest/v1/players?select=mlb_id,full_name&order=full_name.asc&limit=2000`;
  const res = await fetch(url, { headers: sbHeaders });
  if (!res.ok) throw new Error(`Fetch players failed ${res.status}: ${await res.text()}`);
  return await res.json();
}

// ─── Supabase: upsert snapshot ──────────────────────────────
async function upsertSnapshots(rows){
  if (rows.length === 0) return { ok: 0, err: 0 };
  let ok = 0, err = 0;
  const CHUNK = 50;
  for (let i = 0; i < rows.length; i += CHUNK){
    const chunk = rows.slice(i, i + CHUNK);
    const res = await fetch(
      `${SUPABASE_URL}/rest/v1/player_market_snapshots?on_conflict=player_id,snapshot_date`,
      {
        method: 'POST',
        headers: { ...sbHeaders, 'Prefer': 'return=minimal,resolution=merge-duplicates' },
        body: JSON.stringify(chunk),
      }
    );
    if (!res.ok) {
      console.warn(`  Upsert chunk ${i} failed (${res.status}): ${(await res.text()).slice(0,200)}`);
      err += chunk.length;
    } else {
      ok += chunk.length;
    }
  }
  return { ok, err };
}

// ─── Main ───────────────────────────────────────────────────
async function main(){
  const startTs = Date.now();
  console.log(`\n=== Market Meter Collector — ${new Date().toISOString()} ===`);

  const token = await getEbayToken();
  console.log('✔ eBay authenticated');

  const players = await fetchPlayers();
  console.log(`✔ Loaded ${players.length} players from Supabase\n`);

  const today = new Date().toISOString().slice(0,10); // YYYY-MM-DD
  const rows = [];
  let processed = 0, no_data = 0;

  for (const p of players){
    const items = await searchPlayer(token, p.full_name);
    const m = computeMetrics(items);
    processed++;

    if (!m){
      no_data++;
      console.log(`  [${processed}/${players.length}] ${p.full_name} — no usable listings`);
    } else {
      rows.push({
        player_id:      p.mlb_id,
        snapshot_date:  today,
        top10_avg:      m.top10_avg,
        floor_50_index: m.floor_50_index,
        total_listings: m.total_listings,
        filtered_out:   m.filtered_out,
      });
      console.log(`  [${processed}/${players.length}] ${p.full_name} — $${m.top10_avg} · floor ${m.floor_50_index} · ${m.total_listings} listings (${m.filtered_out} filtered)`);
    }
    await sleep(SLEEP_MS);
  }

  console.log(`\nWriting ${rows.length} snapshot rows to Supabase...`);
  const { ok, err } = await upsertSnapshots(rows);

  const runtime = ((Date.now() - startTs) / 1000).toFixed(1);
  console.log(`\n=== DONE in ${runtime}s ===`);
  console.log(`Processed: ${processed} | No data: ${no_data} | Upserted: ${ok} | Errors: ${err}`);
}

main().then(() => process.exit(0)).catch((e) => {
  console.error('FATAL:', e);
  process.exit(1);
});
