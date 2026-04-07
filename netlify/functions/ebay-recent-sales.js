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
function buildSearchQuery({ player, year, set_name, card_number, grade }) {
  const parts = [];
  if (player) parts.push(player);
  if (year) parts.push(String(year));
  if (set_name) parts.push(set_name);
  if (card_number) parts.push(`#${card_number}`);
  if (grade && !['Raw','raw','Base','base',''].includes(grade)) parts.push(grade);
  return parts.join(' ');
}

// ── Search eBay sold listings ───────────────────────────────
async function searchSoldListings(token, query, env) {
  const params = new URLSearchParams({
    q: query,
    filter: 'buyingOptions:{FIXED_PRICE|AUCTION},conditionIds:{2750|3000}',
    sort: '-price',
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
    return { count: 0, lastSold: null, average: null, low: null, high: null, items: [] };
  }

  const prices = items.map((i) => i.price);
  const sum = prices.reduce((a, b) => a + b, 0);

  return {
    count: items.length,
    lastSold: items[0].price,
    average: Math.round((sum / prices.length) * 100) / 100,
    low: Math.min(...prices),
    high: Math.max(...prices),
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
    const { player, year, set_name, card_number, grade } = JSON.parse(event.body || '{}');

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
    const query = buildSearchQuery({ player, year, set_name, card_number, grade });
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
