// Debug endpoint — given a query string, run the exact same eBay Browse
// search the Power Rankings refresh uses and return the raw results +
// the post-filter prices. Lets us see WHY a player is coming back null.
//
// Hit it with: ?q=2026+Bowman+Owen+Caissie

const https = require('https');

const EBAY_AUTH_URL = 'https://api.ebay.com/identity/v1/oauth2/token';
const EBAY_BROWSE_URL = 'https://api.ebay.com/buy/browse/v1/item_summary/search';

const JUNK_TERMS = [
  'custom', 'reprint', 'facsimile', 'novelty', 'fantasy card',
  'art card', 'aceo', 'tc card', 'unofficial', 'not real',
  'fan made', 'fanmade', 'homemade', 'home made', 'gag gift',
  'limited edit', 'replica', 'counterfeit', 'bootleg',
  'custom blast', 'art print', 'fan art', 'proxy',
];
function isJunkListing(title) {
  if (!title) return false;
  const t = title.toLowerCase();
  return JUNK_TERMS.some(term => t.includes(term));
}

function httpsRequest(url, options, body) {
  return new Promise((resolve, reject) => {
    const u = typeof url === 'string' ? new URL(url) : url;
    const req = https.request(u, options, (res) => {
      let data = '';
      res.on('data', (c) => (data += c));
      res.on('end', () => resolve({ statusCode: res.statusCode, body: data }));
    });
    req.on('error', reject);
    if (body) req.write(body);
    req.end();
  });
}

async function getEbayToken() {
  const clientId = process.env.EBAY_CLIENT_ID;
  const clientSecret = process.env.EBAY_CLIENT_SECRET;
  if (!clientId || !clientSecret) return null;
  const creds = Buffer.from(`${clientId}:${clientSecret}`).toString('base64');
  const postBody = 'grant_type=client_credentials&scope=https%3A%2F%2Fapi.ebay.com%2Foauth%2Fapi_scope';
  const url = new URL(EBAY_AUTH_URL);
  const res = await httpsRequest(url, {
    method: 'POST', hostname: url.hostname, path: url.pathname,
    headers: { 'Content-Type': 'application/x-www-form-urlencoded', Authorization: `Basic ${creds}`, 'Content-Length': Buffer.byteLength(postBody) },
  }, postBody);
  if (res.statusCode !== 200) return null;
  return JSON.parse(res.body).access_token;
}

async function ebaySearch(token, query) {
  const url = new URL(`${EBAY_BROWSE_URL}?q=${encodeURIComponent(query)}&filter=buyingOptions:{FIXED_PRICE|AUCTION}&limit=40`);
  const res = await httpsRequest(url, {
    method: 'GET', hostname: url.hostname, path: `${url.pathname}${url.search}`,
    headers: { Authorization: `Bearer ${token}`, 'X-EBAY-C-MARKETPLACE-ID': 'EBAY_US', 'Content-Type': 'application/json' },
  });
  return res;
}

exports.handler = async (event) => {
  const headers = { 'Access-Control-Allow-Origin': '*', 'Content-Type': 'application/json' };
  const q = (event.queryStringParameters || {}).q;
  if (!q) return { statusCode: 400, headers, body: JSON.stringify({ error: 'pass ?q=...' }) };

  const token = await getEbayToken();
  if (!token) return { statusCode: 500, headers, body: JSON.stringify({ error: 'no eBay token' }) };

  const res = await ebaySearch(token, q);
  let data;
  try { data = JSON.parse(res.body); } catch (e) { data = { parseError: e.message, raw: res.body.slice(0, 500) }; }

  const items = (data.itemSummaries || []).map(i => ({
    title: i.title,
    price: i.price && i.price.value,
    isJunk: isJunkListing(i.title),
  }));

  const validPrices = items
    .filter(i => i.price && !i.isJunk)
    .map(i => parseFloat(i.price))
    .filter(p => p >= 0.99)
    .sort((a, b) => a - b);

  const trimmed = validPrices.length >= 5 ? validPrices.slice(0, -2) : validPrices;
  const avg = trimmed.length ? Math.round((trimmed.reduce((a, b) => a + b, 0) / trimmed.length) * 100) / 100 : null;

  return {
    statusCode: 200, headers,
    body: JSON.stringify({
      query: q,
      ebayHttpStatus: res.statusCode,
      totalReturned: items.length,
      totalAfterJunkFilter: items.filter(i => !i.isJunk).length,
      validPriceCount: validPrices.length,
      validPrices,
      trimmedAvg: avg,
      first10Items: items.slice(0, 10),
      junkRejected: items.filter(i => i.isJunk).slice(0, 5).map(i => i.title),
      ebayWarnings: data.warnings || null,
      ebayErrors: data.errors || null,
    }, null, 2),
  };
};
