// ============================================================
// GrailISO — eBay Set Prices (Batch)
// netlify/functions/ebay-set-prices.js
// ============================================================
// Accepts a batch of cards (up to 25), queries eBay Browse API
// for current listing prices, writes results to ebay_price_cache
// in Supabase, and returns the prices.
//
// Called by ISOVault checklist to populate MKT AVG column.
// Cache TTL: 24 hours — won't re-query eBay for cached cards.
// ============================================================

const https = require('https');

// ── Fake/junk card filter ────────────────────────────────────
const JUNK_TERMS = [
  'custom', 'reprint', 'facsimile', 'novelty', 'fantasy card',
  'art card', 'aceo', 'tc card', 'unofficial', 'not real',
  'fan made', 'fanmade', 'homemade', 'home made', 'gag gift',
  'limited edit', 'replica', 'counterfeit', 'bootleg',
  'custom blast', 'art print', 'fan art', 'proxy',
];
let _blocklistCache = null;
let _blocklistTs = 0;
async function getBlocklist() {
  if (_blocklistCache && (Date.now() - _blocklistTs) < 300000) return _blocklistCache;
  try {
    const SB = 'https://jyfaegmnzkarlcximxjo.supabase.co';
    const KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp5ZmFlZ21uemthcmxjeGlteGpvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMyNzU3MDMsImV4cCI6MjA4ODg1MTcwM30.e6U1TZECRlEV9LkTm9NY6ljIJVRKhajE6VvRaBLlaCA';
    const res = await new Promise((resolve, reject) => {
      https.get(`${SB}/rest/v1/ebay_blocklist?select=term&limit=500`, { headers: { 'apikey': KEY, 'Authorization': 'Bearer ' + KEY } }, (r) => {
        let d = ''; r.on('data', c => d += c); r.on('end', () => resolve(d));
      }).on('error', reject);
    });
    _blocklistCache = (JSON.parse(res) || []).map(r => r.term.toLowerCase());
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
  if (res.statusCode !== 200) throw new Error(`eBay auth failed (${res.statusCode})`);
  return JSON.parse(res.body).access_token;
}

// ── Build search query (same logic as ebay-recent-sales.js) ─
function buildQuery({ player, year, brand, set_name, card_number }) {
  const yearStr = year ? String(year).trim() : '';
  const brandStr = (brand || '').trim();
  let setOnly = (set_name || '')
    .replace(/\s+(Baseball|Football|Basketball|Hockey|Soccer)\s*$/i, '')
    .trim();
  if (yearStr && setOnly.startsWith(yearStr)) setOnly = setOnly.slice(yearStr.length).trim();
  if (brandStr && setOnly.toLowerCase().startsWith(brandStr.toLowerCase())) setOnly = setOnly.slice(brandStr.length).trim();

  const parts = [];
  if (yearStr) parts.push(yearStr);
  if (brandStr) parts.push(brandStr);
  if (setOnly) parts.push(setOnly);
  if (player) parts.push(player);
  if (card_number) parts.push(`#${card_number}`);
  return parts.join(' ');
}

// ── Search eBay for a single card ───────────────────────────
async function searchCard(token, query, env, adminTerms) {
  const params = new URLSearchParams({
    q: query,
    filter: 'buyingOptions:{FIXED_PRICE|AUCTION}',
    limit: '20',
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
  if (res.statusCode !== 200) return null;
  const data = JSON.parse(res.body);
  const items = (data.itemSummaries || [])
    .filter(i => i.price && i.price.value && !isJunkListing(i.title, adminTerms))
    .map(i => parseFloat(i.price.value))
    .filter(p => p > 0);
  if (!items.length) return { avg: null, low: null, high: null, count: 0 };
  items.sort((a, b) => a - b);
  // Trim outliers (10% top/bottom) when 10+ items
  let statsPrices = items;
  if (items.length >= 10) {
    const trim = Math.floor(items.length * 0.1);
    statsPrices = items.slice(trim, items.length - trim);
  }
  const sum = statsPrices.reduce((a, b) => a + b, 0);
  return {
    avg: Math.round((sum / statsPrices.length) * 100) / 100,
    low: statsPrices[0],
    high: statsPrices[statsPrices.length - 1],
    count: items.length,
  };
}

// ── Write results to Supabase cache ─────────────────────────
async function writeCache(rows) {
  if (!rows.length) return;
  const SB_URL = 'https://jyfaegmnzkarlcximxjo.supabase.co';
  const SB_KEY = process.env.SUPABASE_SERVICE_KEY || process.env.SUPABASE_ANON_KEY
    || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp5ZmFlZ21uemthcmxjeGlteGpvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMyNzU3MDMsImV4cCI6MjA4ODg1MTcwM30.e6U1TZECRlEV9LkTm9NY6ljIJVRKhajE6VvRaBLlaCA';

  const body = JSON.stringify(rows);
  const url = new URL(`${SB_URL}/rest/v1/ebay_price_cache`);
  // Upsert on (set_table, card_number)
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
}

// ── Netlify Handler ─────────────────────────────────────────
exports.handler = async (event) => {
  const headers = {
    'Access-Control-Allow-Origin': 'https://isosandbox.com',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Content-Type': 'application/json',
  };

  if (event.httpMethod === 'OPTIONS') return { statusCode: 200, headers, body: '' };
  if (event.httpMethod !== 'POST') return { statusCode: 405, headers, body: JSON.stringify({ error: 'Method not allowed' }) };

  const clientId = process.env.EBAY_CLIENT_ID;
  const clientSecret = process.env.EBAY_CLIENT_SECRET;
  if (!clientId || !clientSecret) return { statusCode: 503, headers, body: JSON.stringify({ error: 'eBay API not configured' }) };

  try {
    const { cards, set_table, year, brand, set_name } = JSON.parse(event.body || '{}');
    if (!cards || !cards.length) return { statusCode: 400, headers, body: JSON.stringify({ error: 'cards array required' }) };

    // Cap at 25 cards per request to stay within Netlify timeout
    const batch = cards.slice(0, 25);

    const envKey = (process.env.EBAY_ENVIRONMENT || 'production').toLowerCase();
    const env = EBAY_ENV[envKey] || EBAY_ENV.production;
    const [token, adminTerms] = await Promise.all([
      getEbayToken(clientId, clientSecret, env),
      getBlocklist(),
    ]);

    const results = [];
    const cacheRows = [];

    // Process cards sequentially to avoid eBay rate limits
    for (const card of batch) {
      const query = buildQuery({
        player: card.player,
        year: year || card.year,
        brand: brand || card.brand,
        set_name: set_name || card.set_name,
        card_number: card.card_number,
      });

      const pricing = await searchCard(token, query, env, adminTerms);

      const entry = {
        card_number: String(card.card_number),
        player: card.player || null,
        avg_price: pricing ? pricing.avg : null,
        low_price: pricing ? pricing.low : null,
        high_price: pricing ? pricing.high : null,
        listing_count: pricing ? pricing.count : 0,
      };
      results.push(entry);

      // Build cache row for Supabase upsert
      if (set_table) {
        cacheRows.push({
          set_table: set_table,
          card_number: entry.card_number,
          player: entry.player,
          avg_price: entry.avg_price,
          low_price: entry.low_price,
          high_price: entry.high_price,
          listing_count: entry.listing_count,
          last_fetched: new Date().toISOString(),
        });
      }
    }

    // Write cache to Supabase (non-blocking — don't fail the response if cache write fails)
    if (cacheRows.length) {
      try { await writeCache(cacheRows); } catch (e) { console.warn('Cache write failed:', e.message); }
    }

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({ results, cached: cacheRows.length }),
    };
  } catch (err) {
    console.error('ebay-set-prices error:', err);
    return { statusCode: 500, headers, body: JSON.stringify({ error: 'Failed to fetch prices', detail: err.message }) };
  }
};
