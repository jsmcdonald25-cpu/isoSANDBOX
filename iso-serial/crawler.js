/**
 * ISOSerial Provenance Crawler — shared core
 *
 * Hits eBay for Topps 2026 Series 1 + Heritage /5 listings, pulls full detail via
 * Get Item API, normalizes into review queue records, writes to Supabase.
 *
 * Called from:
 *   bootstrap.js  — one-shot local run to seed initial queue
 *   runner.js     — GitHub Actions cron job (steady-state incremental)
 *
 * Data is written to Supabase only. No local JSON artifacts, no repo commits.
 *
 * Env vars required (.env at repo root):
 *   EBAY_CLIENT_ID, EBAY_CLIENT_SECRET     (reused from ISOsnipe)
 *   SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
 */

require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

const { classifyListing } = require('./ai-classify');

const EBAY_CLIENT_ID        = process.env.EBAY_CLIENT_ID;
const EBAY_CLIENT_SECRET    = process.env.EBAY_CLIENT_SECRET;
const SUPABASE_URL          = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE = process.env.SUPABASE_SERVICE_ROLE_KEY;
const AI_ENABLED            = !!process.env.ANTHROPIC_API_KEY;

if (!EBAY_CLIENT_ID || !EBAY_CLIENT_SECRET) {
  throw new Error('Missing EBAY_CLIENT_ID / EBAY_CLIENT_SECRET in .env');
}
if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE) {
  throw new Error('Missing SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY in .env');
}

// ─── Sets + query variants ──────────────────────────────────
// "/5" is the primary tell. Two queries per set cover how sellers actually title
// listings — "/5" and "#/5". We do NOT bias toward autographs, since many /5
// numbered cards are parallels (Flip Stock, Red Chrome Refractor, Red Border)
// rather than autos.
// Scope rule (Scott, 2026-04-23): /25 or less ONLY. Drop /50/75/77/99 queries.
// Named variations (Flip Stock, 1952 Rookie Variation, Golden Mirror Image) are
// effectively /5-/25 equivalent — no serial # but tracked via parallel_name.
const SETS = [
  {
    label: 'Heritage',
    queries: [
      // Print-run searches — 1/1 + /5 + /10 + /25 only
      '2026 Topps Heritage Superfractor',
      '2026 Topps Heritage 1/1',
      '2026 Topps Heritage /5',
      '2026 Topps Heritage #/5',
      '2026 Topps Heritage /10',
      '2026 Topps Heritage #/10',
      '2026 Topps Heritage /25',
      '2026 Topps Heritage #/25',
      // Parallel-name searches for /25-or-less tiers
      '2026 Topps Heritage Red Bordered Refractor',
      '2026 Topps Heritage Orange Bordered Refractor',
      '2026 Topps Heritage Flip Stock',
      // Inserts with /25-or-less variants (classifier filters out >25)
      '2026 Topps Heritage Real One Auto',
      '2026 Topps Heritage Clubhouse Collection',
      '2026 Topps Heritage Turn Back the Clock',
      '2026 Topps Heritage Flashbacks',
    ],
  },
  {
    label: 'Series 1',
    queries: [
      // 1/1 tier
      '2026 Topps Series 1 Superfractor',
      '2026 Topps Series 1 Foilfractor',
      '2026 Topps Series 1 First Card',
      '2026 Topps Series 1 Printing Plate',
      '2026 Topps Series 1 Rose Gold',
      // Print-run searches — 1/1 + /5 + /10 + /25 only
      '2026 Topps Series 1 1/1',
      '2026 Topps Series 1 /5',
      '2026 Topps Series 1 #/5',
      '2026 Topps Series 1 /10',
      '2026 Topps Series 1 #/10',
      '2026 Topps Series 1 /25',
      '2026 Topps Series 1 #/25',
      // Parallel-family searches for /25-or-less tiers (classifier filters out >25)
      '2026 Topps Series 1 Sandglitter',
      '2026 Topps Series 1 Diamante',
      '2026 Topps Series 1 Holo Foil',
      '2026 Topps Series 1 Rainbow Foil',
      '2026 Topps Series 1 Spring Training',
      '2026 Topps Series 1 Koi Fish',
      '2026 Topps Series 1 Crackle',
      '2026 Topps Series 1 Wood',
      '2026 Topps Series 1 Memorial Day Camo',
      // Unnumbered variations — tracked despite no serial# (rare enough to matter)
      '2026 Topps Series 1 1952 Variation',
      '2026 Topps Series 1 Golden Mirror',
    ],
  },
];

// eBay Sports Trading Cards category (same one ISOsnipe uses)
const EBAY_CATEGORY_ID = '261328';

// Minimum price floor — /5 autos shouldn't go below this. Filters junk.
const PRICE_FLOOR_USD = 5;

// Max listings per query (Browse API cap is 200 per page; we stay lower for speed)
const LISTINGS_PER_QUERY = 100;

// Pause between API calls (ms). eBay's Browse API is pretty generous but we stay polite.
const SLEEP_MS = 350;

// Fraud flag thresholds
const FRAUD_HIGH_PRICE_USD           = 500;   // cards above this get extra scrutiny
const FRAUD_LOW_FEEDBACK_SCORE       = 10;    // seller feedback count
const FRAUD_LOW_FEEDBACK_PERCENT     = 98.0;  // seller feedback %
const FRAUD_VERY_HIGH_PRICE_USD      = 5000;  // always flag above this if any risk signal

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// ─── Blocklist terms (derived from admin skip history) ───────
//
// Phase 3: before querying eBay we pull recent skipped titles, extract terms that
// signal bad listings (not_a_5, multi_card_lot, search_noise), cross-check against
// TAGGED titles so we don't filter legit listings, and append the survivors as
// `-word` negatives on the eBay search query. Applied once per crawler run.
//
// Conservative by design: tight per-reason allowlist, min-length 4, frequency
// threshold 2, max 8 terms per run. We'd rather let the AI classify it than
// accidentally hide a real /5 listing upstream.

const BLOCKLIST_FETCH_LIMIT   = 200;   // rows pulled per side (SKIPPED / TAGGED)
const BLOCKLIST_MAX_TERMS     = 8;     // cap applied to each query
const BLOCKLIST_MIN_FREQ      = 3;     // term must appear in ≥N skipped titles
const BLOCKLIST_MIN_REASONS   = 2;     // term must span ≥N distinct skip_reasons (kills player/team clusters)
const BLOCKLIST_MIN_LEN       = 4;     // skip short tokens (5, of, in, etc.)

// Domain + structural tokens we must NEVER blocklist, even if they cluster in skips
const BLOCKLIST_PROTECTED = new Set([
  // Product/brand
  'topps','series','heritage','bowman','chrome','panini','donruss','prizm','stadium','club',
  'baseball','basketball','football','card','cards','pack','hobby','mega','value','retail',
  // Card attributes
  'auto','autograph','rookie','rc','base','parallel','refractor','insert','relic','patch',
  'red','blue','green','gold','black','orange','pink','silver','purple','rainbow','white',
  'flip','stock','border','sparkle','numbered','print','run','foil','bordered',
  'nmmt','mint','signed','graded','psa','bgs','sgc',
  // Years
  '2026','2025','2024','2023','2022','1991','1977',
  // MLB teams (tokenized city/name words)
  'yankees','redsox','bluejays','rays','orioles','whitesox','tigers','royals','twins',
  'guardians','astros','angels','mariners','rangers','athletics','braves','marlins','mets',
  'phillies','nationals','cubs','reds','brewers','pirates','cardinals','diamondbacks',
  'rockies','dodgers','padres','giants',
  // Cities + split-word team names
  'york','boston','toronto','tampa','baltimore','chicago','detroit','kansas','minnesota',
  'cleveland','houston','seattle','texas','oakland','atlanta','miami','philadelphia',
  'washington','cincinnati','milwaukee','pittsburgh','louis','arizona','colorado',
  'diego','francisco','angeles',
]);
// Only skip reasons that indicate "AI/eBay shouldn't have surfaced this at all"
const BLOCKLIST_SOURCE_REASONS = new Set(['not_a_5','multi_card_lot','search_noise']);

function _tokenize(title){
  return (title || '')
    .toLowerCase()
    .replace(/[^a-z0-9 ]/g, ' ')
    .split(/\s+/)
    .filter(Boolean);
}

async function _fetchQueueTitles(statusFilter, limit){
  const url = `${SUPABASE_URL}/rest/v1/iso_serial_queue`
    + `?status=${statusFilter}`
    + `&title=not.is.null`
    + `&select=title,skip_reason`
    + `&order=tagged_at.desc.nullslast`
    + `&limit=${limit}`;
  try {
    const res = await fetch(url, { headers: sbHeaders });
    if (!res.ok) return [];
    const rows = await res.json();
    return Array.isArray(rows) ? rows : [];
  } catch (_) {
    return [];
  }
}

async function buildBlocklist(){
  const [skipped, tagged] = await Promise.all([
    _fetchQueueTitles('eq.skipped', BLOCKLIST_FETCH_LIMIT),
    _fetchQueueTitles('in.(tagged_new,tagged_existing)', BLOCKLIST_FETCH_LIMIT),
  ]);

  // Token frequency in legit-tagged listings — used as a whitelist guard
  const taggedFreq = new Map();
  for (const r of tagged) {
    for (const tok of new Set(_tokenize(r.title))) {
      taggedFreq.set(tok, (taggedFreq.get(tok) || 0) + 1);
    }
  }

  // Per-token: count of matching skipped titles + set of distinct skip_reasons
  const tokStats = new Map(); // tok → { count, reasons: Set }
  for (const r of skipped) {
    if (!BLOCKLIST_SOURCE_REASONS.has(r.skip_reason)) continue;
    for (const tok of new Set(_tokenize(r.title))) {
      if (tok.length < BLOCKLIST_MIN_LEN) continue;
      if (BLOCKLIST_PROTECTED.has(tok)) continue;
      if (/^\d+$/.test(tok)) continue;          // pure numbers
      if (taggedFreq.get(tok)) continue;         // seen in legit listings — hands off
      const s = tokStats.get(tok) || { count: 0, reasons: new Set() };
      s.count++;
      s.reasons.add(r.skip_reason);
      tokStats.set(tok, s);
    }
  }

  // Term qualifies if: frequency ≥ MIN_FREQ AND spans ≥ MIN_REASONS distinct skip reasons.
  // The reason-spread rule kills player/team name clusters (which tend to bunch under
  // one reason like "multi_card_lot") while keeping true noise like "reprint" or "listia".
  const ranked = Array.from(tokStats.entries())
    .filter(([, s]) => s.count >= BLOCKLIST_MIN_FREQ && s.reasons.size >= BLOCKLIST_MIN_REASONS)
    .sort((a, b) => b[1].count - a[1].count)
    .slice(0, BLOCKLIST_MAX_TERMS)
    .map(([tok]) => tok);

  return ranked;
}

// ─── eBay auth ───────────────────────────────────────────────
async function getEbayToken() {
  const credentials = Buffer.from(`${EBAY_CLIENT_ID}:${EBAY_CLIENT_SECRET}`).toString('base64');
  const res = await fetch('https://api.ebay.com/identity/v1/oauth2/token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': `Basic ${credentials}`,
    },
    body: 'grant_type=client_credentials&scope=https%3A%2F%2Fapi.ebay.com%2Foauth%2Fapi_scope',
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`eBay auth failed (${res.status}): ${body}`);
  }
  return (await res.json()).access_token;
}

// ─── eBay Browse: search ────────────────────────────────────
// sort: null = Best Match (eBay default), '-price' = highest first, 'newlyListed' = newest first.
// Stacking multiple sort passes per query surfaces listings buried under Best
// Match's promoted/top-rated-seller bias. Dedup by ebay_item_id handles overlap.
async function searchEbay(token, query, blocklist = [], sort = null) {
  const filter = [
    `price:[${PRICE_FLOOR_USD}..]`,
    'priceCurrency:USD',
    'deliveryCountry:US',
  ].join(',');

  // eBay Browse supports `-word` negative keywords in the q string.
  const negatives = blocklist.length ? ' ' + blocklist.map(t => `-${t}`).join(' ') : '';
  const paramsObj = {
    q: query + negatives,
    category_ids: EBAY_CATEGORY_ID,
    filter,
    limit: String(LISTINGS_PER_QUERY),
  };
  if (sort) paramsObj.sort = sort;
  const params = new URLSearchParams(paramsObj);

  const res = await fetch(
    `https://api.ebay.com/buy/browse/v1/item_summary/search?${params}`,
    {
      headers: {
        'Authorization': `Bearer ${token}`,
        'X-EBAY-C-MARKETPLACE-ID': 'EBAY_US',
      },
    }
  );

  if (!res.ok) {
    if (res.status === 429) {
      console.warn(`  eBay rate-limited (429) on query "${query}" — backing off`);
      await sleep(5000);
      return { items: [], apiCalls: 1 };
    }
    if (res.status === 204) return { items: [], apiCalls: 1 };
    console.warn(`  eBay search failed (${res.status}) on "${query}"`);
    return { items: [], apiCalls: 1 };
  }

  const body = await res.json();
  return { items: body.itemSummaries || [], apiCalls: 1 };
}

// ─── eBay Browse: get item detail ───────────────────────────
// Returns { item, apiCalls } or { item: null } on failure
async function getEbayItem(token, itemId) {
  const res = await fetch(
    `https://api.ebay.com/buy/browse/v1/item/${encodeURIComponent(itemId)}`,
    {
      headers: {
        'Authorization': `Bearer ${token}`,
        'X-EBAY-C-MARKETPLACE-ID': 'EBAY_US',
      },
    }
  );

  if (!res.ok) {
    if (res.status === 429) {
      await sleep(5000);
    }
    return { item: null, apiCalls: 1 };
  }

  const item = await res.json();
  return { item, apiCalls: 1 };
}

// ─── Parse listing → queue record ───────────────────────────
function parseListingToQueueRecord(searchItem, itemDetail, setLabel) {
  const title = (itemDetail?.title || searchItem?.title || '').trim();
  const description = (itemDetail?.description || '').trim();
  const searchText = `${title}\n${description}`.toLowerCase();

  const price = parseFloat(itemDetail?.price?.value || searchItem?.price?.value || 0);

  // images — primary + gallery
  const images = [];
  if (itemDetail?.image?.imageUrl) images.push(itemDetail.image.imageUrl);
  if (Array.isArray(itemDetail?.additionalImages)) {
    for (const img of itemDetail.additionalImages) {
      if (img?.imageUrl) images.push(img.imageUrl);
    }
  }
  if (images.length === 0 && searchItem?.image?.imageUrl) {
    images.push(searchItem.image.imageUrl);
  }
  if (images.length === 0 && searchItem?.thumbnailImages?.[0]?.imageUrl) {
    images.push(searchItem.thumbnailImages[0].imageUrl);
  }

  // seller
  const seller = itemDetail?.seller || searchItem?.seller || {};
  const sellerUsername = seller.username || null;
  const sellerFeedbackScore = typeof seller.feedbackScore === 'number' ? seller.feedbackScore : null;
  const sellerFeedbackPercent = typeof seller.feedbackPercentage === 'string'
    ? parseFloat(seller.feedbackPercentage)
    : (typeof seller.feedbackPercentage === 'number' ? seller.feedbackPercentage : null);

  // locations — itemLocation (where the item is) + shipping origin
  const itemLoc = itemDetail?.itemLocation || {};
  const shipFrom = itemDetail?.shippingOptions?.[0]?.shipToLocations || {};

  // crawler-inferred guesses
  const setNameGuess = setLabel;

  // Serial edition guess — default is '/5' since that's our query.
  // Look for explicit "N/5" patterns first.
  let serialEditionGuess = '/5';
  const m = searchText.match(/\b(\d+)\s*\/\s*5\b/);
  if (m && parseInt(m[1], 10) >= 1 && parseInt(m[1], 10) <= 5) {
    serialEditionGuess = `${m[1]}/5`;
  }

  // Auto type
  let autoTypeGuess = null;
  if (/\bon[\-\s]?card\b/.test(searchText) && !/sticker/.test(searchText)) autoTypeGuess = 'on-card';
  else if (/sticker\s*(auto|autograph)/.test(searchText)) autoTypeGuess = 'sticker-auto';

  // Inscription — very loose pattern. Admin confirms at review time.
  let inscriptionGuess = null;
  const inscrMatch = searchText.match(
    /\b(inscribed|inscription|hof\s*(\d{4})?|mvp|roy|cy\s*young|[A-Z][a-z]+\s*\d+:\d+)\b/i
  );
  if (inscrMatch) inscriptionGuess = inscrMatch[0];

  // Grade guess
  let gradeGuess = null;
  const gradeMatch = searchText.match(/\b(psa|bgs|beckett|sgc|jsa)\s*(10|9\.5|9|8\.5|8|7|6|5|4|3|2|1)\b/i);
  if (gradeMatch) gradeGuess = `${gradeMatch[1].toUpperCase()} ${gradeMatch[2]}`;

  // Fraud flag computation
  const fraudReasons = [];
  if (price >= FRAUD_HIGH_PRICE_USD && sellerFeedbackScore !== null && sellerFeedbackScore < FRAUD_LOW_FEEDBACK_SCORE) {
    fraudReasons.push('high_price_low_feedback');
  }
  if (price >= FRAUD_VERY_HIGH_PRICE_USD) {
    fraudReasons.push('very_high_price_requires_review');
  }
  if (sellerFeedbackPercent !== null && sellerFeedbackPercent < FRAUD_LOW_FEEDBACK_PERCENT) {
    fraudReasons.push('low_feedback_percent');
  }
  if (sellerFeedbackScore === 0) {
    fraudReasons.push('zero_feedback_seller');
  }
  const fraudFlag = fraudReasons.length > 0;

  return {
    ebay_item_id: searchItem.itemId || itemDetail?.itemId,
    ebay_url: itemDetail?.itemWebUrl || searchItem?.itemWebUrl || null,
    title: title || null,
    description: description || null,
    price_usd: isFinite(price) && price > 0 ? price : null,
    image_urls: images,
    seller_username: sellerUsername,
    seller_feedback_score: sellerFeedbackScore,
    seller_feedback_percent: sellerFeedbackPercent,
    seller_account_age_days: null, // Browse API doesn't expose this
    item_location_city: itemLoc.city || null,
    item_location_state: itemLoc.stateOrProvince || null,
    item_location_country: itemLoc.country || null,
    ship_from_city: shipFrom.city || null,
    ship_from_state: shipFrom.stateOrProvince || null,
    set_name_guess: setNameGuess,
    serial_edition_guess: serialEditionGuess,
    auto_type_guess: autoTypeGuess,
    inscription_guess: inscriptionGuess,
    grade_guess: gradeGuess,
    fraud_flag: fraudFlag,
    fraud_reasons: fraudReasons,
    listing_end_at: itemDetail?.itemEndDate || searchItem?.itemEndDate || null,
    // Preserve the seller's exact parallel wording for admin review. Pull from
    // eBay's item specifics (Parallel/Variety or Features or Insert Set). This
    // keeps ISOsnipe's fat-finger arbitrage opportunity intact at the source
    // level while the classifier can still normalize to canonical names.
    raw_parallel_as_listed: (() => {
      const specs = Array.isArray(itemDetail?.localizedAspects) ? itemDetail.localizedAspects : [];
      const names = ['Parallel/Variety', 'Parallel', 'Card Attributes', 'Features', 'Insert Set'];
      for (const n of names) {
        const found = specs.find(a => (a.name || '').toLowerCase() === n.toLowerCase());
        if (found?.value) return String(found.value).slice(0, 200);
      }
      return null;
    })(),
    raw_browse_response: searchItem || null,
    raw_get_item_response: itemDetail || null,
    status: 'pending',
  };
}

// ─── AI classify pass — fills ai_classification on records ────
//
// Auto-skip rules (in order):
// 1. Named-variation exception — Flip Stock + 1952 Rookie Variation + Golden
//    Mirror Image are tracked despite is_serialized=false because they're
//    rare enough to matter (effective print run /5-/25).
// 2. Not serialized + not a tracked variation → skip.
// 3. Serialized but print_run > 25 → skip (Scott's /25-or-less scope, 4/23).
// 4. Otherwise → pending for admin review.
const TRACKED_VARIATIONS = [
  'flip stock',
  '1952 variation',
  '1952 rookie variation',
  'golden mirror',
  'golden mirror image',
];
function _isTrackedVariation(ai) {
  const hay = [
    (ai?.parallel_name || '').toLowerCase(),
    (ai?.insert_subset_name || '').toLowerCase(),
    (ai?.notes || '').toLowerCase(),
  ].join(' | ');
  return TRACKED_VARIATIONS.some(v => hay.includes(v));
}

async function aiClassifyRecords(records, setLabel) {
  if (!AI_ENABLED || records.length === 0) return 0;
  let classifyCount = 0;
  for (const rec of records) {
    try {
      const ai = await classifyListing({
        title: rec.title,
        description: rec.description,
        setHint: setLabel,
      });
      if (ai) {
        rec.ai_classification = ai;
        classifyCount++;
        const tracked = _isTrackedVariation(ai);
        const pr = ai.print_run;
        if (!ai.is_serialized && !tracked) {
          // Not a real serialized card AND not a tracked variation → skip
          rec.status = 'skipped';
          rec.skip_reason = 'not_a_5';
          rec.admin_notes = `AI auto-skipped: not serialized (confidence=${ai.confidence || 'unknown'})`;
          rec.tagged_at = new Date().toISOString();
        } else if (ai.is_serialized && typeof pr === 'number' && pr > 25) {
          // Serialized but out of /25-or-less scope
          rec.status = 'skipped';
          rec.skip_reason = 'not_a_5';
          rec.admin_notes = `AI auto-skipped: print_run=${pr} exceeds /25 scope`;
          rec.tagged_at = new Date().toISOString();
        }
      }
    } catch (_) {
      // Already logged inside classifyListing — skip silently
    }
  }
  return classifyCount;
}

// ─── Supabase REST helpers ──────────────────────────────────
const sbHeaders = {
  'apikey': SUPABASE_SERVICE_ROLE,
  'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE}`,
  'Content-Type': 'application/json',
};

// Returns Set of ebay_item_ids already present in the queue (dedup map).
async function fetchExistingQueueItemIds(itemIds) {
  if (itemIds.length === 0) return new Set();

  // PostgREST: ?ebay_item_id=in.(id1,id2,...)  — batch in chunks of 100 to avoid URL length issues
  const found = new Set();
  const CHUNK = 100;
  for (let i = 0; i < itemIds.length; i += CHUNK) {
    const chunk = itemIds.slice(i, i + CHUNK);
    const inClause = chunk.map((id) => `"${id}"`).join(',');
    const url = `${SUPABASE_URL}/rest/v1/iso_serial_queue?select=ebay_item_id&ebay_item_id=in.(${inClause})`;
    const res = await fetch(url, { headers: sbHeaders });
    if (!res.ok) {
      console.warn(`  Supabase dedup lookup failed (${res.status}): ${await res.text()}`);
      continue;
    }
    const rows = await res.json();
    for (const r of rows) found.add(r.ebay_item_id);
  }
  return found;
}

async function insertQueueRecords(records) {
  if (records.length === 0) return { inserted: 0, errors: 0 };

  // PostgREST bulk insert (PGRST102) requires every row to have the same
  // keys. Our records vary: ai_classification only set when AI succeeds,
  // skip_reason/admin_notes/tagged_at only set on auto-skip rows, etc.
  // Normalize to a union keyset before sending so every row has every key.
  const OPTIONAL_KEYS = [
    'ai_classification', 'listing_end_at', 'raw_parallel_as_listed',
    'skip_reason', 'admin_notes', 'tagged_at',
  ];
  for (const r of records) {
    for (const k of OPTIONAL_KEYS) if (!(k in r)) r[k] = null;
  }

  // Insert in chunks; Prefer return=minimal keeps the response small
  const CHUNK = 50;
  let inserted = 0;
  let errors = 0;

  for (let i = 0; i < records.length; i += CHUNK) {
    const chunk = records.slice(i, i + CHUNK);
    const res = await fetch(`${SUPABASE_URL}/rest/v1/iso_serial_queue`, {
      method: 'POST',
      headers: { ...sbHeaders, 'Prefer': 'return=minimal,resolution=ignore-duplicates' },
      body: JSON.stringify(chunk),
    });
    if (!res.ok) {
      console.warn(`  Supabase insert chunk failed (${res.status}): ${await res.text()}`);
      errors += chunk.length;
    } else {
      inserted += chunk.length;
    }
  }
  return { inserted, errors };
}

async function logPull({
  setSearched,
  queryString,
  totalResults,
  newListings,
  duplicateListings,
  apiCallsBrowse,
  apiCallsGetItem,
  runtimeSeconds,
  status,
  errorMessage,
  runEnvironment,
}) {
  const row = {
    set_searched: setSearched,
    query_string: queryString,
    total_results: totalResults,
    new_listings: newListings,
    duplicate_listings: duplicateListings,
    api_calls_browse: apiCallsBrowse,
    api_calls_get_item: apiCallsGetItem,
    runtime_seconds: runtimeSeconds,
    status,
    error_message: errorMessage || null,
    run_environment: runEnvironment,
  };
  const res = await fetch(`${SUPABASE_URL}/rest/v1/iso_serial_pulls`, {
    method: 'POST',
    headers: { ...sbHeaders, 'Prefer': 'return=minimal' },
    body: JSON.stringify(row),
  });
  if (!res.ok) {
    console.warn(`  Pull log insert failed (${res.status}): ${await res.text()}`);
  }
}

// ─── Crawl one set (all query variants) ─────────────────────
async function crawlSet({ token, set, runEnvironment, blocklist }) {
  const startTs = Date.now();
  const perSetStats = {
    setLabel: set.label,
    totalResults: 0,
    newListings: 0,
    duplicateListings: 0,
    apiCallsBrowse: 0,
    apiCallsGetItem: 0,
  };

  // 1. Search across all query variants × sort passes, collect unique items.
  // Three sort passes per query surfaces listings Best Match buries (small
  // sellers, new listings, high-priced outliers). Dedup by itemId in the Map
  // means overlap across sorts costs us nothing on the Get Item side.
  const SORT_PASSES = [
    { key: null,          label: 'best'   },
    { key: '-price',      label: 'priceDesc' },
    { key: 'newlyListed', label: 'newest' },
  ];
  const seenItemIds = new Map(); // itemId -> searchItem (keep first occurrence)
  for (const query of set.queries) {
    for (const pass of SORT_PASSES) {
      console.log(`  Search: "${query}" [${pass.label}]${blocklist.length ? ` (−${blocklist.length} neg)` : ''}`);
      const { items, apiCalls } = await searchEbay(token, query, blocklist, pass.key);
      perSetStats.apiCallsBrowse += apiCalls;
      perSetStats.totalResults += items.length;
      for (const it of items) {
        if (it.itemId && !seenItemIds.has(it.itemId)) {
          seenItemIds.set(it.itemId, it);
        }
      }
      console.log(`    ${items.length} results (${seenItemIds.size} unique so far)`);
      await sleep(SLEEP_MS);
    }
  }

  const uniqueItemIds = Array.from(seenItemIds.keys());
  if (uniqueItemIds.length === 0) {
    console.log(`  No listings matched for ${set.label}`);
    const runtimeSec = (Date.now() - startTs) / 1000;
    for (const q of set.queries) {
      await logPull({
        setSearched: set.label, queryString: q,
        totalResults: 0, newListings: 0, duplicateListings: 0,
        apiCallsBrowse: 1, apiCallsGetItem: 0,
        runtimeSeconds: runtimeSec / set.queries.length,
        status: 'success', runEnvironment,
      });
    }
    return perSetStats;
  }

  // 2. Dedupe against existing queue
  console.log(`  Deduping ${uniqueItemIds.length} items against existing queue…`);
  const alreadyQueued = await fetchExistingQueueItemIds(uniqueItemIds);
  perSetStats.duplicateListings = alreadyQueued.size;
  const newItemIds = uniqueItemIds.filter((id) => !alreadyQueued.has(id));
  console.log(`    ${newItemIds.length} new, ${alreadyQueued.size} already in queue`);

  if (newItemIds.length === 0) {
    const runtimeSec = (Date.now() - startTs) / 1000;
    await logPull({
      setSearched: set.label, queryString: set.queries.join(' | '),
      totalResults: perSetStats.totalResults,
      newListings: 0,
      duplicateListings: perSetStats.duplicateListings,
      apiCallsBrowse: perSetStats.apiCallsBrowse,
      apiCallsGetItem: 0,
      runtimeSeconds: runtimeSec,
      status: 'success', runEnvironment,
    });
    return perSetStats;
  }

  // 3. Fetch full detail via Get Item API for each new listing
  const queueRecords = [];
  for (const itemId of newItemIds) {
    const { item: detail, apiCalls } = await getEbayItem(token, itemId);
    perSetStats.apiCallsGetItem += apiCalls;
    if (!detail) {
      console.warn(`    Skipping ${itemId} — Get Item failed`);
      continue;
    }
    const searchItem = seenItemIds.get(itemId);
    try {
      const rec = parseListingToQueueRecord(searchItem, detail, set.label);
      if (rec.ebay_item_id) queueRecords.push(rec);
    } catch (e) {
      console.warn(`    Parse failed for ${itemId}: ${e.message}`);
    }
    await sleep(SLEEP_MS);
  }

  // 4. AI pre-classify each new record (Haiku 4.5)
  if (AI_ENABLED && queueRecords.length > 0) {
    console.log(`  AI classifying ${queueRecords.length} new records…`);
    const classified = await aiClassifyRecords(queueRecords, set.label);
    console.log(`    ${classified} classified, ${queueRecords.length - classified} skipped`);
  }

  // 5. Bulk insert to Supabase
  const { inserted, errors } = await insertQueueRecords(queueRecords);
  perSetStats.newListings = inserted;
  console.log(`  Inserted ${inserted} new queue records (${errors} errors)`);

  // 5. Log pull row
  const runtimeSec = (Date.now() - startTs) / 1000;
  await logPull({
    setSearched: set.label,
    queryString: set.queries.join(' | '),
    totalResults: perSetStats.totalResults,
    newListings: inserted,
    duplicateListings: perSetStats.duplicateListings,
    apiCallsBrowse: perSetStats.apiCallsBrowse,
    apiCallsGetItem: perSetStats.apiCallsGetItem,
    runtimeSeconds: runtimeSec,
    status: errors > 0 ? 'partial' : 'success',
    errorMessage: errors > 0 ? `${errors} insert errors` : null,
    runEnvironment,
  });

  return perSetStats;
}

// ─── Top-level entrypoint ───────────────────────────────────
async function crawl({ runEnvironment }) {
  const globalStart = Date.now();
  console.log(`\n=== ISOSerial Crawler — ${runEnvironment} ===`);
  console.log(`Time: ${new Date().toISOString()}`);

  const token = await getEbayToken();
  console.log('✔ eBay authenticated\n');

  // Derive per-run blocklist from admin skip history (Phase 3)
  const blocklist = await buildBlocklist();
  if (blocklist.length) {
    console.log(`Blocklist (${blocklist.length} terms from skip history): ${blocklist.join(', ')}\n`);
  } else {
    console.log('Blocklist: empty (insufficient skip signal)\n');
  }

  const totals = { totalResults: 0, newListings: 0, duplicateListings: 0, apiCallsBrowse: 0, apiCallsGetItem: 0 };

  for (const set of SETS) {
    console.log(`── ${set.label} ──`);
    try {
      const s = await crawlSet({ token, set, runEnvironment, blocklist });
      totals.totalResults      += s.totalResults;
      totals.newListings       += s.newListings;
      totals.duplicateListings += s.duplicateListings;
      totals.apiCallsBrowse    += s.apiCallsBrowse;
      totals.apiCallsGetItem   += s.apiCallsGetItem;
    } catch (e) {
      console.error(`  ${set.label} crawl failed: ${e.message}`);
      const runtimeSec = (Date.now() - globalStart) / 1000;
      await logPull({
        setSearched: set.label, queryString: set.queries.join(' | '),
        totalResults: 0, newListings: 0, duplicateListings: 0,
        apiCallsBrowse: 0, apiCallsGetItem: 0,
        runtimeSeconds: runtimeSec,
        status: 'error', errorMessage: e.message,
        runEnvironment,
      });
    }
    console.log('');
  }

  const totalRuntime = ((Date.now() - globalStart) / 1000).toFixed(1);
  console.log('=== DONE ===');
  console.log(`Runtime: ${totalRuntime}s`);
  console.log(`Results seen: ${totals.totalResults} | New: ${totals.newListings} | Dupes: ${totals.duplicateListings}`);
  console.log(`API calls — Browse: ${totals.apiCallsBrowse}, Get Item: ${totals.apiCallsGetItem}`);
  console.log('');
}

module.exports = { crawl };
