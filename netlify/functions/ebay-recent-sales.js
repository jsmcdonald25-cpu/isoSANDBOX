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

  if (res.statusCode !== 200) {
    throw new Error(`eBay search failed (${res.statusCode}): ${res.body}`);
  }
  return JSON.parse(res.body);
}

// ── Summarize pricing from results ──────────────────────────
function summarizePricing(results) {
  const items = (results.itemSummaries || [])
    .filter((i) => i.price && i.price.value)
    .map((i) => ({
      title: i.title,
      price: parseFloat(i.price.value),
      currency: i.price.currency || 'USD',
      date: i.itemEndDate || null,
      condition: i.condition || null,
      imageUrl: (i.image && i.image.imageUrl) || null,
      itemUrl: i.itemWebUrl || null,
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

    const envKey = (process.env.EBAY_ENVIRONMENT || 'production').toLowerCase();
    const env = EBAY_ENV[envKey] || EBAY_ENV.production;

    // 1. Get OAuth token
    const token = await getEbayToken(clientId, clientSecret, env);

    // 2. Build query and search
    const query = buildSearchQuery({ player, year, brand, set_name, card_number, variation, grade });
    const results = await searchSoldListings(token, query, env);

    // 3. Summarize pricing
    const summary = summarizePricing(results);
    summary.query = query; // Include for debugging/transparency

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify(summary),
    };
  } catch (err) {
    console.error('ebay-recent-sales error:', err);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: 'Failed to fetch recent sales', detail: err.message }),
    };
  }
};
