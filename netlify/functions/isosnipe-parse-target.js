// ============================================================
// ISOsnipe — Parse eBay listing into a snipe target
// netlify/functions/isosnipe-parse-target.js
// ============================================================
// Admin pastes a URL/item#; we fetch the listing via eBay Browse API
// and ask Claude Haiku to extract {player, card, parallel} + generate
// 5 realistic misspellings. Returns everything the admin needs to
// confirm + save a new isosnipe_targets row.
//
// Auth: admin-only (same pattern as iso-serial-analyze).

const Anthropic = require('@anthropic-ai/sdk');
const https = require('https');

const SB_URL = process.env.SUPABASE_URL || 'https://jyfaegmnzkarlcximxjo.supabase.co';
const SB_SERVICE = process.env.SUPABASE_SERVICE_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY;
const ANTHROPIC_KEY = process.env.ANTHROPIC_API_KEY;
const EBAY_CLIENT_ID = process.env.EBAY_CLIENT_ID;
const EBAY_CLIENT_SECRET = process.env.EBAY_CLIENT_SECRET;

const MODEL = 'claude-haiku-4-5';

function httpJson(url, opts = {}) {
  return new Promise((resolve, reject) => {
    const u = new URL(url);
    const req = https.request({
      hostname: u.hostname,
      path: u.pathname + u.search,
      method: opts.method || 'GET',
      headers: opts.headers || {},
    }, (res) => {
      let data = '';
      res.on('data', c => data += c);
      res.on('end', () => {
        try { resolve({ status: res.statusCode, json: JSON.parse(data) }); }
        catch (_) { resolve({ status: res.statusCode, json: null, raw: data }); }
      });
    });
    req.on('error', reject);
    if (opts.body) req.write(opts.body);
    req.end();
  });
}

async function verifyAdmin(authHeader) {
  if (!authHeader || !authHeader.startsWith('Bearer ')) return { user: null, reason: 'no-bearer' };
  const token = authHeader.slice(7);
  if (!token) return { user: null, reason: 'empty-token' };
  const me = await httpJson(`${SB_URL}/auth/v1/user`, {
    headers: { 'apikey': SB_SERVICE, 'Authorization': `Bearer ${token}` },
  });
  if (me.status !== 200 || !me.json?.id) return { user: null, reason: `auth-user-${me.status}` };
  const prof = await httpJson(
    `${SB_URL}/rest/v1/profiles?id=eq.${me.json.id}&select=role,is_admin&limit=1`,
    { headers: { 'apikey': SB_SERVICE, 'Authorization': `Bearer ${SB_SERVICE}` } }
  );
  const p = prof.json?.[0];
  if (!p) return { user: null, reason: 'no-profile' };
  if (p.role !== 'owner' && p.is_admin !== true) return { user: null, reason: 'not-admin' };
  return { user: me.json, reason: 'ok' };
}

async function getEbayToken() {
  const creds = Buffer.from(`${EBAY_CLIENT_ID}:${EBAY_CLIENT_SECRET}`).toString('base64');
  const r = await httpJson('https://api.ebay.com/identity/v1/oauth2/token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': `Basic ${creds}`,
    },
    body: 'grant_type=client_credentials&scope=https%3A%2F%2Fapi.ebay.com%2Foauth%2Fapi_scope',
  });
  if (r.status !== 200) throw new Error(`eBay auth ${r.status}`);
  return r.json.access_token;
}

async function getEbayItem(token, itemId) {
  const epnId = `v1|${itemId}|0`;
  const r = await httpJson(`https://api.ebay.com/buy/browse/v1/item/${encodeURIComponent(epnId)}`, {
    headers: {
      'Authorization': `Bearer ${token}`,
      'X-EBAY-C-MARKETPLACE-ID': 'EBAY_US',
    },
  });
  if (r.status !== 200) return null;
  return r.json;
}

function cleanItemId(raw) {
  let s = String(raw || '').trim();
  const urlMatch = s.match(/ebay\.com\/itm\/(?:[^\/]*\/)?(\d+)/i);
  if (urlMatch) return urlMatch[1];
  return s.replace(/\D/g, '');
}

const PARSE_PROMPT = `You are a sports card listing analyst. You will receive a raw eBay listing title, optional description, and item specifics. Extract clean fields for a snipe-target row and generate realistic eBay search misspellings.

Return STRICT JSON — no fences, no prose — matching this shape:

{
  "player": "Full canonical name (e.g. 'Ken Griffey Jr.', 'Shohei Ohtani'). Keep Jr./Sr. with a period. Diacritics as-is ('José Ramírez').",
  "card": "Short clean descriptor of the card: '<year> <brand> [set] [#<card-number>] [RC/Rookie if RC]'. Examples: '1989 Upper Deck #1 Rookie', '2001 Topps Chrome Traded #T266', '1st Bowman', '2018 Topps Update RC'.",
  "parallel": "The parallel color/type. 'Base' if it's the plain card. Examples: 'Base', 'Chrome', 'Refractor', 'Gold', 'Red /5', 'Superfractor'.",
  "correct_searches": ["2-3 clean eBay search strings a buyer would actually type to find this card."],
  "misspellings": ["5 REALISTIC fat-finger / auto-correct / non-native-English-speaker variants. Study the examples below carefully."]
}

# MISSPELLING EXAMPLES (study the patterns)

For Ichiro Suzuki 2001 Topps:
  ["2001 topps ichero 726", "Ichiro Suzki 2001 topps", "2001 tops ichiro rookie", "Ichiro Susuki topps 726", "Ichero Suzuki rookie card"]

For Ken Griffey Jr 1989 Upper Deck:
  ["1989 upper deck ken griffy jr", "Griffy Jr 1989 rookie", "Ken Griffee Jr upper deck 1989", "1989 UD Griffey rooky", "Griffey Jr upperdeck rookie"]

For Shohei Ohtani 2018 Chrome:
  ["2018 topps crome ohtani", "Otani 2018 chrome rookie", "Ohtani 2018 tops crome", "Shoehei Ohtani chrome 2018", "2018 topps crome otahni"]

# PATTERN RULES
- Drop one letter ("Griffey" → "Griffy", "Suzuki" → "Suzki")
- Double a letter ("Stewart" → "Stewert", "Crawford" → "Crawfrod")
- Swap e/a ("Stewart" → "Steward", "Weatherholt" → "Wetherhalt")
- "Chrome" → "crome" / "Refractor" → "refactor" or "refracter" / "Bowman" → "bowmen"
- "Topps" → "tops"
- "Upper Deck" → "upperdeck" (no space)
- Common phonetic slips (Ohtani → Otani / Ohtni / Otahni)
- Keep the card/set identifier intact enough that the listing is recognizable — the goal is to catch real people's typos, not generate unreadable gibberish.

Output ONLY the JSON object.`;

exports.handler = async (event) => {
  const cors = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Content-Type': 'application/json',
  };
  if (event.httpMethod === 'OPTIONS') return { statusCode: 204, headers: cors, body: '' };
  if (event.httpMethod !== 'POST') return { statusCode: 405, headers: cors, body: 'Method not allowed' };

  if (!ANTHROPIC_KEY)       return { statusCode: 500, headers: cors, body: JSON.stringify({ error: 'ANTHROPIC_API_KEY not set' }) };
  if (!EBAY_CLIENT_ID)      return { statusCode: 500, headers: cors, body: JSON.stringify({ error: 'EBAY credentials not set' }) };
  if (!SB_SERVICE)          return { statusCode: 500, headers: cors, body: JSON.stringify({ error: 'SUPABASE_SERVICE_KEY not set' }) };

  const adminCheck = await verifyAdmin(event.headers.authorization || event.headers.Authorization);
  if (!adminCheck.user) return { statusCode: 403, headers: cors, body: JSON.stringify({ error: 'Admin auth required', reason: adminCheck.reason }) };

  let body;
  try { body = JSON.parse(event.body || '{}'); }
  catch (_) { return { statusCode: 400, headers: cors, body: JSON.stringify({ error: 'Invalid JSON body' }) }; }

  const { itemInput } = body;
  if (!itemInput) return { statusCode: 400, headers: cors, body: JSON.stringify({ error: 'itemInput (URL or item#) required' }) };

  const itemId = cleanItemId(itemInput);
  if (!itemId || itemId.length < 8) {
    return { statusCode: 400, headers: cors, body: JSON.stringify({ error: 'Invalid eBay URL or item number' }) };
  }

  let ebayItem;
  try {
    const token = await getEbayToken();
    ebayItem = await getEbayItem(token, itemId);
    if (!ebayItem) return { statusCode: 404, headers: cors, body: JSON.stringify({ error: 'eBay item not found or listing is private' }) };
  } catch (e) {
    return { statusCode: 502, headers: cors, body: JSON.stringify({ error: 'eBay fetch failed', detail: e.message }) };
  }

  const title = ebayItem.title || '';
  const desc = (ebayItem.shortDescription || '').slice(0, 500);
  const specifics = (ebayItem.localizedAspects || [])
    .slice(0, 12)
    .map(a => `${a.name}: ${a.value}`)
    .join('\n');

  const userMsg = `TITLE: ${title}\n\nDESCRIPTION: ${desc || '(none)'}\n\nITEM SPECIFICS:\n${specifics || '(none)'}\n\nExtract the fields and generate 5 realistic misspellings. Return ONLY the JSON object.`;

  let parsed;
  try {
    const client = new Anthropic({ apiKey: ANTHROPIC_KEY });
    const resp = await client.messages.create({
      model: MODEL,
      max_tokens: 800,
      system: [{ type: 'text', text: PARSE_PROMPT, cache_control: { type: 'ephemeral' } }],
      messages: [{ role: 'user', content: userMsg }],
    });
    const txt = (resp.content || []).find(c => c.type === 'text')?.text || '';
    let cleaned = txt.replace(/^```(?:json)?\s*/i, '').replace(/\s*```\s*$/, '').trim();
    const first = cleaned.indexOf('{'), last = cleaned.lastIndexOf('}');
    if (first !== -1 && last > first) cleaned = cleaned.slice(first, last + 1);
    parsed = JSON.parse(cleaned);
  } catch (e) {
    return { statusCode: 502, headers: cors, body: JSON.stringify({ error: 'AI parse failed', detail: e.message }) };
  }

  // Sanitize + guarantee arrays
  const safeArr = v => Array.isArray(v) ? v.map(s => String(s || '').trim()).filter(Boolean).slice(0, 10) : [];

  return {
    statusCode: 200,
    headers: cors,
    body: JSON.stringify({
      listing: {
        title,
        price:     ebayItem.price?.value || null,
        imageUrl:  ebayItem.image?.imageUrl || null,
        url:       ebayItem.itemWebUrl || null,
        itemId,
        condition: ebayItem.condition || null,
      },
      parsed: {
        player:           parsed.player || '',
        card:             parsed.card || '',
        parallel:         parsed.parallel || 'Base',
        correct_searches: safeArr(parsed.correct_searches),
        misspellings:     safeArr(parsed.misspellings),
      },
    }),
  };
};
