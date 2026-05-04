// ============================================================
// GrailISO — eBay Recent Sales Lookup
// netlify/functions/ebay-recent-sales.js
// ============================================================
// Queries eBay's Browse API for recently sold listings matching
// a card's details (player, year, set, card number, grade).
// Returns pricing summary: last sold, average, low, high, count.
//
// SETUP: Set EBAY_CLIENT_ID + EBAY_CLIENT_SECRET in Netlify env vars
// Optionally set EBAY_ENVIRONMENT to 'production' (default: 'production')
// ============================================================

const https = require('https');

// ── eBay API endpoints ──────────────────────────────────────
const EBAY_ENV = {
  production: {
    authUrl: 'https://api.ebay.com/identity/v1/oauth2/token',
    browseUrl: 'https://api.ebay.com/buy/browse/v1/item_summary/search',
  },
  sandbox: {
    authUrl: 'https://api.sandbox.ebay.com/identity/v1/oauth2/token',
    browseUrl: 'https://api.sandbox.ebay.com/buy/browse/v1/item_summary/search',
  },
};

// ── Helpers ─────────────────────────────────────────────────
function httpsRequest(url, options, body) {
  return new Promise((resolve, reject) => {
    const req = https.request(url, options, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => resolve({ statusCode: res.statusCode, body: data }));
    });
    req.on('error', reject);
    if (body) req.write(body);
    req.end();
  });
}

// ── Get eBay OAuth token (Client Credentials) ──────────────
async function getEbayToken(clientId, clientSecret, env) {
  const credentials = Buffer.from(`${clientId}:${clientSecret}`).toString('base64');
  const postBody = 'grant_type=client_credentials&scope=https%3A%2F%2Fapi.ebay.com%2Foauth%2Fapi_scope';
  const url = new URL(env.authUrl);

  const res = await httpsRequest(url, {
    method: 'POST',
    hostname: url.hostname,
    path: url.pathname,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      Authorization: `Basic ${credentials}`,
      'Content-Length': Buffer.byteLength(postBody),
    },
  }, postBody);

  if (res.statusCode !== 200) {
    throw new Error(`eBay auth failed (${res.statusCode}): ${res.body}`);
  }
  return JSON.parse(res.body).access_token;
}

// ── Build search query from card details ────────────────────
// Assembles: year → brand → set → player → card# → variation → grade
// The set_name may already contain year/brand, so we strip duplicates.
function buildSearchQuery({ player, year, brand, set_name, card_number, variation, grade }) {
  const yearStr  = year ? String(year).trim() : '';
  const brandStr = (brand || '').trim();

  // Strip sport suffix, year, and brand from set_name to get the pure set name
  let setOnly = (set_name || '')
    .replace(/\s+(Baseball|Football|Basketball|Hockey|Soccer)\s*$/i, '')
    .trim();
  // Remove leading year if set_name starts with it (e.g. "2025 Topps Stadium Club" → "Topps Stadium Club")
  if (yearStr && setOnly.startsWith(yearStr)) setOnly = setOnly.slice(yearStr.length).trim();
  // Remove brand if set_name starts with it after year removal (e.g. "Topps Stadium Club" → "Stadium Club")
  if (brandStr && setOnly.toLowerCase().startsWith(brandStr.toLowerCase())) setOnly = setOnly.slice(brandStr.length).trim();

  // Build query in the order sellers list cards:
  // year → brand → set → player → card# → variation → grade
  const parts = [];
  if (yearStr)  parts.push(yearStr);
  if (brandStr) parts.push(brandStr);
  if (setOnly)  parts.push(setOnly);
  if (player)   parts.push(player);
  if (card_number) parts.push(`#${card_number}`);

  // Variation: include if not base
  const v = String(variation || '').trim();
  const isBase = !v || ['base','raw','base cards'].includes(v.toLowerCase());
  if (!isBase) {
    // Insert/subset variations (e.g. "1986 Topps Baseball Chrome — Insert")
    // contain the real subset identity. Strip the " — Insert/Parallel/…" suffix
    // and use the subset name INSTEAD of the parent set to avoid bloated queries.
    const dashSplit = v.split(/\s*[—–-]\s*/);
    const suffix = (dashSplit[1] || '').toLowerCase();
    const isInsertLabel = ['insert', 'parallel', 'short print', 'base cards'].includes(suffix)
      || dashSplit.length > 1;
    if (isInsertLabel && dashSplit[0].length > 3) {
      // Replace the parent set in parts with the subset name
      const subsetName = dashSplit[0].trim();
      const setIdx = parts.indexOf(setOnly);
      if (setIdx !== -1) {
        // Clean subset: strip year/brand that may be embedded
        let cleanSub = subsetName;
        if (yearStr && cleanSub.startsWith(yearStr)) cleanSub = cleanSub.slice(yearStr.length).trim();
        if (brandStr && cleanSub.toLowerCase().startsWith(brandStr.toLowerCase())) cleanSub = cleanSub.slice(brandStr.length).trim();
        parts[setIdx] = cleanSub;
      } else {
        parts.push(subsetName);
      }
    } else {
      parts.push(v);
    }
  }

  // Grade (PSA 10, BGS 9.5, etc.)
  if (grade && !['Raw','raw','Base','base',''].includes(grade)) parts.push(grade);

  return parts.join(' ');
}

// ── Search eBay sold listings ───────────────────────────────
async function searchSoldListings(token, query, env) {
  // No `sort` param → eBay's default best-match relevance ranking.
  // Previously we used `-price` which always surfaced the rarest parallel
  // first regardless of whether it was the user's actual card.
  const params = new URLSearchParams({
    q: query,
    filter: 'buyingOptions:{FIXED_PRICE|AUCTION}',
    limit: '50',
  });

  const url = new URL(`${env.browseUrl}?${params.toString()}`);

  const res = await httpsRequest(url, {
    method: 'GET',
    hostname: url.hostname,
    path: `${url.pathname}${url.search}`,
    headers: {
      Authorization: `Bearer ${token}`,
      'X-EBAY-C-MARKETPLACE-ID': 'EBAY_US',
      'Content-Type': 'application/json',
    },
  });

  if (res.statusCode === 429) {
    // eBay daily call cap — return marker instead of throwing so caller can
    // skip cache poisoning. Dashboard treats rate_limited as "retry next load".
    const err = new Error('rate_limited');
    err.rateLimited = true;
    throw err;
  }
  if (res.statusCode !== 200) {
    throw new Error(`eBay search failed (${res.statusCode}): ${res.body}`);
  }
  return JSON.parse(res.body);
}

// ── Fake/junk card filter ────────────────────────────────────
// Hardcoded floor — always blocked. Admin can add more via ebay_blocklist table.
const JUNK_TERMS = [
  'custom', 'reprint', 'facsimile', 'novelty', 'fantasy card',
  'art card', 'aceo', 'tc card', 'unofficial', 'not real',
  'fan made', 'fanmade', 'homemade', 'home made', 'gag gift',
  'limited edit', 'replica', 'counterfeit', 'bootleg',
  'custom blast', 'art print', 'fan art', 'proxy',
];

// Cache admin blocklist (refreshed once per cold start)
let _blocklistCache = null;
let _blocklistTs = 0;
const BLOCKLIST_TTL = 5 * 60 * 1000; // 5 min cache

async function getBlocklist() {
  if (_blocklistCache && (Date.now() - _blocklistTs) < BLOCKLIST_TTL) return _blocklistCache;
  try {
    const SB = 'https://jyfaegmnzkarlcximxjo.supabase.co';
    const KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp5ZmFlZ21uemthcmxjeGlteGpvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMyNzU3MDMsImV4cCI6MjA4ODg1MTcwM30.e6U1TZECRlEV9LkTm9NY6ljIJVRKhajE6VvRaBLlaCA';
    const url = `${SB}/rest/v1/ebay_blocklist?select=term&limit=500`;
    const res = await new Promise((resolve, reject) => {
      https.get(url, { headers: { 'apikey': KEY, 'Authorization': 'Bearer ' + KEY } }, (r) => {
        let d = ''; r.on('data', c => d += c); r.on('end', () => resolve(d));
      }).on('error', reject);
    });
    const rows = JSON.parse(res);
    _blocklistCache = (rows || []).map(r => r.term.toLowerCase());
    _blocklistTs = Date.now();
  } catch (e) { _blocklistCache = []; _blocklistTs = Date.now(); }
  return _blocklistCache;
}

function isJunkListing(title, adminTerms) {
  if (!title) return false;
  const t = title.toLowerCase();
  if (JUNK_TERMS.some(term => t.includes(term))) return true;
  if (adminTerms && adminTerms.some(term => t.includes(term))) return true;
  return false;
}

// ── Summarize pricing from results ──────────────────────────
function summarizePricing(results, adminTerms) {
  const items = (results.itemSummaries || [])
    .filter((i) => i.price && i.price.value && !isJunkListing(i.title, adminTerms))
    .map((i) => ({
      title: i.title,
      price: parseFloat(i.price.value),
      currency: i.price.currency || 'USD',
      date: i.itemEndDate || null,
      condition: i.condition || null,
      imageUrl: (i.image && i.image.imageUrl) || null,
      itemUrl: i.itemWebUrl || null,
      itemId: i.itemId || null,
    }))
    .filter((i) => i.price > 0);

  if (!items.length) {
    return { count: 0, average: null, low: null, high: null, items: [] };
  }

  // Trim outliers before computing low/avg/high so a single rogue parallel
  // that slipped past the exclusion list can't blow up the stats.
  // Drop top 10% and bottom 10% when we have at least 10 items.
  const sortedAsc = items.map((i) => i.price).sort((a, b) => a - b);
  let statsPrices = sortedAsc;
  if (sortedAsc.length >= 10) {
    const trim = Math.floor(sortedAsc.length * 0.1);
    statsPrices = sortedAsc.slice(trim, sortedAsc.length - trim);
  }
  const sum = statsPrices.reduce((a, b) => a + b, 0);

  return {
    count: items.length,
    average: Math.round((sum / statsPrices.length) * 100) / 100,
    low: statsPrices[0],
    high: statsPrices[statsPrices.length - 1],
    items: items.slice(0, 10), // Return top 10 for detail display
  };
}

// ── Shared Supabase cache layer ─────────────────────────────
// Drops eBay calls 90%+ in dashboard usage by caching responses keyed on the
// normalized lookup parameters. First user pays the eBay call; everyone else
// reads from Supabase for `CACHE_TTL_MS`. Eliminates the 5K/day cap as a
// user-facing failure mode and keeps eBay reviewers happy when applying for
// Marketplace Insights API access.
const SB_URL = 'https://jyfaegmnzkarlcximxjo.supabase.co';
const SB_KEY = process.env.SUPABASE_SERVICE_KEY || process.env.SUPABASE_ANON_KEY
  || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp5ZmFlZ21uemthcmxjeGlteGpvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMyNzU3MDMsImV4cCI6MjA4ODg1MTcwM30.e6U1TZECRlEV9LkTm9NY6ljIJVRKhajE6VvRaBLlaCA';
const CACHE_TTL_MS = 24 * 60 * 60 * 1000;

function _norm(s) {
  return String(s || '').trim().toLowerCase().replace(/\s+/g, ' ');
}
function buildCacheKey({ player, year, brand, set_name, card_number, variation, grade }) {
  return [
    _norm(player), _norm(year), _norm(brand), _norm(set_name),
    _norm(card_number), _norm(variation), _norm(grade),
  ].join('|');
}
async function readCache(key) {
  try {
    const url = `${SB_URL}/rest/v1/ebay_lookup_cache?lookup_key=eq.${encodeURIComponent(key)}&select=response,last_fetched&limit=1`;
    const res = await new Promise((resolve, reject) => {
      https.get(url, { headers: { 'apikey': SB_KEY, 'Authorization': 'Bearer ' + SB_KEY } }, (r) => {
        let d = ''; r.on('data', c => d += c); r.on('end', () => resolve({ statusCode: r.statusCode, body: d }));
      }).on('error', reject);
    });
    if (res.statusCode !== 200) return null;
    const rows = JSON.parse(res.body || '[]');
    if (!rows.length) return null;
    const age = Date.now() - new Date(rows[0].last_fetched).getTime();
    if (age >= CACHE_TTL_MS) return null;
    return rows[0].response;
  } catch (_) {
    return null;
  }
}
// Returns the cache row regardless of TTL — used as a fallback when eBay
// returns 0 listings, so we can preserve the most recent confirmed price.
async function readCacheAnyAge(key) {
  try {
    const url = `${SB_URL}/rest/v1/ebay_lookup_cache?lookup_key=eq.${encodeURIComponent(key)}&select=response,last_fetched&limit=1`;
    const res = await new Promise((resolve, reject) => {
      https.get(url, { headers: { 'apikey': SB_KEY, 'Authorization': 'Bearer ' + SB_KEY } }, (r) => {
        let d = ''; r.on('data', c => d += c); r.on('end', () => resolve({ statusCode: r.statusCode, body: d }));
      }).on('error', reject);
    });
    if (res.statusCode !== 200) return null;
    const rows = JSON.parse(res.body || '[]');
    if (!rows.length) return null;
    return { response: rows[0].response, last_fetched: rows[0].last_fetched };
  } catch (_) {
    return null;
  }
}
async function writeCache(key, response) {
  try {
    const body = JSON.stringify({ lookup_key: key, response, last_fetched: new Date().toISOString() });
    const url = new URL(`${SB_URL}/rest/v1/ebay_lookup_cache`);
    await httpsRequest(url, {
      method: 'POST',
      hostname: url.hostname,
      path: url.pathname,
      headers: {
        'Content-Type': 'application/json',
        'apikey': SB_KEY,
        'Authorization': `Bearer ${SB_KEY}`,
        'Prefer': 'resolution=merge-duplicates',
        'Content-Length': Buffer.byteLength(body),
      },
    }, body);
  } catch (_) { /* non-fatal */ }
}

// ── Netlify Handler ─────────────────────────────────────────
exports.handler = async (event) => {
  const headers = {
    'Access-Control-Allow-Origin': 'https://isosandbox.com',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Content-Type': 'application/json',
  };

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers, body: '' };
  }

  if (event.httpMethod !== 'POST') {
    return { statusCode: 405, headers, body: JSON.stringify({ error: 'Method not allowed' }) };
  }

  const clientId = process.env.EBAY_CLIENT_ID;
  const clientSecret = process.env.EBAY_CLIENT_SECRET;

  if (!clientId || !clientSecret) {
    return {
      statusCode: 503,
      headers,
      body: JSON.stringify({ error: 'eBay API not configured' }),
    };
  }

  try {
    const { player, year, brand, set_name, card_number, variation, grade } = JSON.parse(event.body || '{}');

    // Need at least a player/card name to search
    if (!player) {
      return {
        statusCode: 400,
        headers,
        body: JSON.stringify({ error: 'player is required' }),
      };
    }

    // 1. Cache check — return immediately on fresh hit, skip eBay entirely
    const cacheKey = buildCacheKey({ player, year, brand, set_name, card_number, variation, grade });
    const cached = await readCache(cacheKey);
    if (cached) {
      return {
        statusCode: 200,
        headers,
        body: JSON.stringify({ ...cached, cached: true }),
      };
    }

    const envKey = (process.env.EBAY_ENVIRONMENT || 'production').toLowerCase();
    const env = EBAY_ENV[envKey] || EBAY_ENV.production;

    // 2. Get OAuth token + blocklist in parallel
    const [token, adminTerms] = await Promise.all([
      getEbayToken(clientId, clientSecret, env),
      getBlocklist(),
    ]);

    // 3. Build query and search
    const query = buildSearchQuery({ player, year, brand, set_name, card_number, variation, grade });
    const results = await searchSoldListings(token, query, env);

    // 4. Summarize pricing (filters junk via hardcoded + admin blocklist)
    const summary = summarizePricing(results, adminTerms);
    summary.query = query; // Include for debugging/transparency

    // 5a. eBay returned 0 listings — preserve the most recent confirmed price.
    //     Fall back to the cached row regardless of age. Skip the cache write so
    //     the prior good entry survives. UI surfaces this via stale:true flag.
    if (summary.count === 0) {
      const prior = await readCacheAnyAge(cacheKey);
      if (prior && prior.response && prior.response.count > 0) {
        return {
          statusCode: 200,
          headers,
          body: JSON.stringify({
            ...prior.response,
            stale: true,
            last_fresh: prior.last_fetched,
            cached: true,
          }),
        };
      }
    }

    // 5b. Normal path: write fresh result to cache (non-blocking)
    writeCache(cacheKey, summary);

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify(summary),
    };
  } catch (err) {
    console.error('ebay-recent-sales error:', err);
    if (err && err.rateLimited) {
      // Return 200 with rate_limited flag so dashboard skips cache poisoning.
      return {
        statusCode: 200,
        headers,
        body: JSON.stringify({ rate_limited: true, count: 0, average: 0, lastSold: 0, low: 0, high: 0, results: [] }),
      };
    }
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: 'Failed to fetch recent sales', detail: err.message }),
    };
  }
};
