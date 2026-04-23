// ============================================================
// ISOSerial — Manual Queue Add
// netlify/functions/iso-serial-add-manual.js
// ============================================================
// Admin pastes an eBay URL/item#; we fetch the listing, AI-classify,
// and insert a row into iso_serial_queue with status='pending'.
// Never auto-skips — manual adds always go to pending for review.
//
// Auth: admin-only (is_provenance_admin or owner/is_admin).

const Anthropic = require('@anthropic-ai/sdk');
const https = require('https');

const SB_URL     = process.env.SUPABASE_URL || 'https://jyfaegmnzkarlcximxjo.supabase.co';
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
    `${SB_URL}/rest/v1/profiles?id=eq.${me.json.id}&select=role,is_admin,is_provenance_admin&limit=1`,
    { headers: { 'apikey': SB_SERVICE, 'Authorization': `Bearer ${SB_SERVICE}` } }
  );
  const p = prof.json?.[0];
  if (!p) return { user: null, reason: 'no-profile' };
  if (p.role !== 'owner' && p.is_admin !== true && p.is_provenance_admin !== true) {
    return { user: null, reason: 'not-admin' };
  }
  return { user: me.json, reason: 'ok' };
}

function cleanItemId(raw) {
  let s = String(raw || '').trim();
  const urlMatch = s.match(/ebay\.com\/itm\/(?:[^\/]*\/)?(\d+)/i);
  if (urlMatch) return urlMatch[1];
  return s.replace(/\D/g, '');
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

// Mirror of iso-serial/ai-classify.js — simplified, single call.
// Uses same OUTPUT_SCHEMA shape so the review modal's "Apply to form" works.
const AI_PROMPT = `You are a sports trading card classifier. Extract structured fields from this eBay listing and return STRICT JSON — no fences, no prose. Shape:

{
  "is_serialized": boolean,
  "print_run": integer or null,
  "edition_num": integer or null,
  "set_name": "Series 1" | "Heritage" | "other" | "unknown",
  "player_name": string or null,
  "card_number": string or null,
  "parallel_name": string or null,
  "auto_type": "on-card" | "sticker-auto" | "none",
  "is_inscribed": boolean,
  "inscription_text": string or null,
  "is_multi_card_lot": boolean,
  "is_insert_subset": boolean,
  "insert_subset_name": string or null,
  "reject_reason": "none" | "not_serialized" | "wrong_set" | "multi_card_lot" | "search_noise" | "insert_subset_no_checklist",
  "confidence": "high" | "medium" | "low",
  "notes": string or null
}

Heritage canonical parallel ladder (collapse seller mislabels to these):
- 1/1 → "Superfractor"
- /5  → "Chrome Red Border"
- /25 → "Orange Border Chrome"
- /50 Gold, /77 Black, /99 Green, /150 Blue

Return ONLY the JSON.`;

async function classifyWithClaude(title, description, specifics) {
  const client = new Anthropic({ apiKey: ANTHROPIC_KEY });
  const userMsg = `TITLE: ${title}\n\nDESCRIPTION: ${(description || '').slice(0, 1500)}\n\nITEM SPECIFICS:\n${specifics}`;
  const resp = await client.messages.create({
    model: MODEL,
    max_tokens: 800,
    system: [{ type: 'text', text: AI_PROMPT, cache_control: { type: 'ephemeral' } }],
    messages: [{ role: 'user', content: userMsg }],
  });
  const txt = (resp.content || []).find(c => c.type === 'text')?.text || '';
  let cleaned = txt.replace(/^```(?:json)?\s*/i, '').replace(/\s*```\s*$/, '').trim();
  const first = cleaned.indexOf('{'), last = cleaned.lastIndexOf('}');
  if (first !== -1 && last > first) cleaned = cleaned.slice(first, last + 1);
  return JSON.parse(cleaned);
}

exports.handler = async (event) => {
  const cors = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Content-Type': 'application/json',
  };
  if (event.httpMethod === 'OPTIONS') return { statusCode: 204, headers: cors, body: '' };
  if (event.httpMethod !== 'POST') return { statusCode: 405, headers: cors, body: 'Method not allowed' };

  if (!SB_SERVICE)       return { statusCode: 500, headers: cors, body: JSON.stringify({ error: 'SUPABASE_SERVICE_KEY not set' }) };
  if (!EBAY_CLIENT_ID)   return { statusCode: 500, headers: cors, body: JSON.stringify({ error: 'eBay credentials not set' }) };

  const adminCheck = await verifyAdmin(event.headers.authorization || event.headers.Authorization);
  if (!adminCheck.user) return { statusCode: 403, headers: cors, body: JSON.stringify({ error: 'Admin auth required', reason: adminCheck.reason }) };

  let body;
  try { body = JSON.parse(event.body || '{}'); }
  catch (_) { return { statusCode: 400, headers: cors, body: JSON.stringify({ error: 'Invalid JSON body' }) }; }

  const itemInput = body.itemInput;
  if (!itemInput) return { statusCode: 400, headers: cors, body: JSON.stringify({ error: 'itemInput (URL or item#) required' }) };
  const itemId = cleanItemId(itemInput);
  if (!itemId || itemId.length < 8) {
    return { statusCode: 400, headers: cors, body: JSON.stringify({ error: 'Invalid eBay URL or item number' }) };
  }

  // Dedup — don't double-insert an item that's already in the queue
  const existing = await httpJson(
    `${SB_URL}/rest/v1/iso_serial_queue?ebay_item_id=eq.v1|${itemId}|0&select=id,status&limit=1`,
    { headers: { 'apikey': SB_SERVICE, 'Authorization': `Bearer ${SB_SERVICE}` } }
  );
  if (existing.status === 200 && Array.isArray(existing.json) && existing.json.length > 0) {
    const row = existing.json[0];
    return { statusCode: 409, headers: cors, body: JSON.stringify({
      error: 'Already in queue',
      queue_id: row.id,
      status: row.status,
    }) };
  }

  // Pull from eBay
  let item;
  try {
    const token = await getEbayToken();
    item = await getEbayItem(token, itemId);
    if (!item) return { statusCode: 404, headers: cors, body: JSON.stringify({ error: 'eBay item not found or listing is private' }) };
  } catch (e) {
    return { statusCode: 502, headers: cors, body: JSON.stringify({ error: 'eBay fetch failed', detail: e.message }) };
  }

  // Normalize fields (mirror of crawler.js parseListingToQueueRecord, simplified)
  const title = (item.title || '').trim();
  const description = (item.description || '').trim();
  const price = parseFloat(item.price?.value || 0);
  const images = [];
  if (item.image?.imageUrl) images.push(item.image.imageUrl);
  if (Array.isArray(item.additionalImages)) {
    for (const img of item.additionalImages) {
      if (img?.imageUrl) images.push(img.imageUrl);
    }
  }
  const seller = item.seller || {};
  const itemLoc = item.itemLocation || {};
  const shipFrom = item.shippingOptions?.[0]?.shipToLocations || {};

  // AI classify (try; non-fatal if it fails)
  let ai = null;
  if (ANTHROPIC_KEY) {
    try {
      const specs = (item.localizedAspects || []).map(a => `${a.name}: ${a.value}`).join('\n');
      ai = await classifyWithClaude(title, description, specs);
    } catch (e) {
      console.warn('AI classify failed:', e.message);
    }
  }

  // Build row — always status='pending' for manual adds (skip auto-skip path)
  const row = {
    ebay_item_id: item.itemId,
    ebay_url: item.itemWebUrl || null,
    title: title || null,
    description: description || null,
    price_usd: isFinite(price) && price > 0 ? price : null,
    image_urls: images,
    seller_username: seller.username || null,
    seller_feedback_score: seller.feedbackScore ?? null,
    seller_feedback_percent: seller.feedbackPercentage ? parseFloat(seller.feedbackPercentage) : null,
    item_location_city: itemLoc.city || null,
    item_location_state: itemLoc.stateOrProvince || null,
    item_location_country: itemLoc.country || null,
    ship_from_city: null,
    ship_from_state: null,
    set_name_guess: ai?.set_name || null,
    listing_end_at: item.itemEndDate || null,
    raw_browse_response: null,
    raw_get_item_response: item,
    status: 'pending',
    ai_classification: ai,
  };

  const ins = await httpJson(`${SB_URL}/rest/v1/iso_serial_queue`, {
    method: 'POST',
    headers: {
      'apikey': SB_SERVICE,
      'Authorization': `Bearer ${SB_SERVICE}`,
      'Content-Type': 'application/json',
      'Prefer': 'return=representation',
    },
    body: JSON.stringify(row),
  });
  if (ins.status >= 300) {
    return { statusCode: 502, headers: cors, body: JSON.stringify({ error: 'Insert failed', detail: ins.json || ins.raw?.slice(0, 300) }) };
  }
  const inserted = Array.isArray(ins.json) ? ins.json[0] : ins.json;

  return {
    statusCode: 200,
    headers: cors,
    body: JSON.stringify({
      ok: true,
      queue_id: inserted?.id,
      title,
      ai_serialized: ai?.is_serialized ?? null,
      ai_confidence: ai?.confidence ?? null,
    }),
  };
};
