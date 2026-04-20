// ============================================================
// ISOsnipe AI Learn — Pattern analyzer for rejected listings
// netlify/functions/isosnipe-analyze.js
// ============================================================
// Pulls all rejections from Supabase, sends them to Claude Haiku
// 4.5 with structured JSON output, returns:
//   - blocklist_terms: short keyword/phrase suggestions to filter titles
//   - query_refinements: per player+parallel negative keywords (-foo)
//   - insights:        prose pattern observations w/ accept buttons
//   - rejection_breakdown: counts by reason_code
//
// Auth: requires admin JWT in Authorization header. Function verifies
// the token against Supabase auth + checks owner/is_admin on profiles.
//
// Cost: prompt-cached system prompt + ~50-100 rejections per call ≈
// ~$0.003 per analysis run.
// ============================================================

const Anthropic = require('@anthropic-ai/sdk');
const https = require('https');

const SB_URL = process.env.SUPABASE_URL || 'https://jyfaegmnzkarlcximxjo.supabase.co';
const SB_SERVICE = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_KEY;
const ANTHROPIC_KEY = process.env.ANTHROPIC_API_KEY;

const MODEL = 'claude-haiku-4-5';

// ─── HTTP helper ─────────────────────────────────────────
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
        catch (e) { resolve({ status: res.statusCode, json: null, raw: data }); }
      });
    });
    req.on('error', reject);
    if (opts.body) req.write(opts.body);
    req.end();
  });
}

// ─── Verify admin JWT ────────────────────────────────────
async function verifyAdmin(authHeader) {
  if (!authHeader || !authHeader.startsWith('Bearer ')) return null;
  const token = authHeader.slice(7);
  // Verify JWT against Supabase
  const me = await httpJson(`${SB_URL}/auth/v1/user`, {
    headers: { 'apikey': SB_SERVICE, 'Authorization': `Bearer ${token}` },
  });
  if (me.status !== 200 || !me.json?.id) return null;
  // Check owner / is_admin in profiles
  const prof = await httpJson(`${SB_URL}/rest/v1/profiles?id=eq.${me.json.id}&select=role,is_admin&limit=1`, {
    headers: { 'apikey': SB_SERVICE, 'Authorization': `Bearer ${SB_SERVICE}` },
  });
  const p = prof.json?.[0];
  if (!p) return null;
  if (p.role !== 'owner' && p.is_admin !== true) return null;
  return me.json;
}

// ─── Fetch rejections (cap 200 most recent for token budget) ──
async function fetchRejections() {
  const r = await httpJson(
    `${SB_URL}/rest/v1/isosnipe_rejections?select=ebay_item_id,player,parallel,card,title,description,item_specifics,reason_code,reason_notes&order=rejected_at.desc&limit=200`,
    { headers: { 'apikey': SB_SERVICE, 'Authorization': `Bearer ${SB_SERVICE}` } }
  );
  return Array.isArray(r.json) ? r.json : [];
}

// ─── Output schema (Claude returns this exact shape) ─────
const OUTPUT_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  properties: {
    blocklist_terms: {
      type: 'array',
      description: 'Short keyword/phrase suggestions (1-4 words each) that consistently appear in rejected titles or descriptions and would indicate a fake/wrong listing if seen again.',
      items: { type: 'string' },
      maxItems: 20,
    },
    query_refinements: {
      type: 'array',
      description: 'Per player+parallel target, negative keywords to add to future eBay searches (without the leading minus).',
      items: {
        type: 'object',
        additionalProperties: false,
        properties: {
          player:   { type: 'string' },
          parallel: { type: 'string' },
          negatives:{ type: 'array', items: { type: 'string' }, maxItems: 8 },
        },
        required: ['player','parallel','negatives'],
      },
      maxItems: 15,
    },
    insights: {
      type: 'array',
      description: 'Plain-English pattern observations the admin should consider. Each insight is one sentence with a number/percentage if possible.',
      items: { type: 'string' },
      maxItems: 8,
    },
    rejection_breakdown: {
      type: 'object',
      description: 'Count by reason_code across all rejections analyzed. Keys are reason codes, values are counts.',
      additionalProperties: { type: 'integer' },
    },
  },
  required: ['blocklist_terms', 'query_refinements', 'insights', 'rejection_breakdown'],
};

// ─── System prompt (padded for caching) ──────────────────
const SYSTEM_PROMPT = `You are an expert sports trading card listing analyst. You receive a batch of eBay listings that an admin has REJECTED as "not a real snipe" (i.e., not the card the snipe engine was looking for) along with a reason code and free-form notes.

Your job is to find PATTERNS across the rejections and return four things in strict JSON:

1. **blocklist_terms** — short keywords/phrases (1-4 words) that consistently appear in rejected titles or descriptions and would help filter out similar fakes/scams in future scans. Examples: "facsimile", "stamped auto", "1990 chrome reprint", "card image only", "tc card". Be specific enough to catch the bad pattern but generic enough to apply broadly. Don't include obvious junk already in the snipe filter (lot, mystery, repack, etc).

2. **query_refinements** — for each (player, parallel) combo with significant rejection count (≥3), suggest negative keywords to add to that target's eBay query. Example: { player: "Ken Griffey Jr", parallel: "Refractor", negatives: ["reprint", "1990", "custom"] }. Use bare words — the consumer will prepend the minus sign.

3. **insights** — plain-English observations admin should consider. Each insight is ONE sentence. Always include numbers/percentages from the data. Examples:
   - "67% of Griffey Jr Refractor rejections mention '1990' — your target is 1989 Upper Deck, not 1990 Topps Chrome."
   - "23 rejections this batch are facsimile/stamped autos — strongest single fraud pattern."
   - "Seller 'card_reprint_king' accounts for 18 rejected Griffey listings — consider seller-level block."

4. **rejection_breakdown** — count by reason_code. Keys are the reason codes used by the admin, values are integer counts.

# REASON CODES
- wrong_player: different player pictured
- wrong_year: different print year
- wrong_set: flagship vs chrome, etc.
- wrong_parallel: different color/tier
- wrong_card_num: different card # in set
- reprint_or_custom: fan-made, unofficial
- facsimile_signature: printed/stamped sig, not real auto
- graded_mismatch: listed grade/condition wrong
- bad_photos: can't verify
- other: see notes

# RULES
- Be data-driven. If you can't find a pattern, return fewer items rather than padding.
- Prefer multi-word phrases over single common words ("facsimile signature" > "signed").
- Don't repeat blocklist_terms inside query_refinements — those serve different purposes.
- Output STRICT JSON matching the schema. No prose.

# CARD DOMAIN BACKGROUND (for context, do not output)
The snipe engine targets ~13 baseball players (Griffey Jr, Ohtani, Ichiro, Sal Stewart, Daniel Susac, Moises Ballesteros, George Valera, Kevin McGonigle, Chase DeLauter, Munetaka Murakami, JJ Wetherholt, Justin Crawford, Tanner Murray) across 5 parallel categories (Base, Chrome, Refractor, Autograph, Numbered, Insert). It searches BOTH correct spellings AND deliberate misspellings to catch listings priced below market. Common rejection patterns:
- Reprints/customs sold as authentic
- Facsimile (printed) signatures sold as autographs
- Wrong-year flagship cards confused with chrome inserts
- "Card image only" — listing is actually a photo print, not a card
- Multi-card lots disguised as single cards
- TC (trading card) novelty/fan-art cards
- Stickers that look like cards in thumbnails
- Wrong parallel (e.g. "Refractor" listed for non-refractor base cards)
- 1989 vs 1990 Griffey confusion (1989 UD #1 RC is the chase, 1990 chrome reprints are common)
- Ichiro 2001 Topps Traded (T266) vs base Topps (#726) — both rookies, very different value`;

// ─── HANDLER ─────────────────────────────────────────────
exports.handler = async (event) => {
  const cors = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
  };
  if (event.httpMethod === 'OPTIONS') return { statusCode: 204, headers: cors, body: '' };
  if (event.httpMethod !== 'POST')   return { statusCode: 405, headers: cors, body: 'Method not allowed' };

  if (!ANTHROPIC_KEY) return { statusCode: 500, headers: cors, body: JSON.stringify({ error: 'ANTHROPIC_API_KEY not set' }) };
  if (!SB_SERVICE)    return { statusCode: 500, headers: cors, body: JSON.stringify({ error: 'SUPABASE_SERVICE_ROLE_KEY not set' }) };

  // Verify admin
  const admin = await verifyAdmin(event.headers.authorization || event.headers.Authorization);
  if (!admin) return { statusCode: 403, headers: cors, body: JSON.stringify({ error: 'Admin auth required' }) };

  // Pull rejections
  const rejections = await fetchRejections();
  if (rejections.length === 0) {
    return { statusCode: 200, headers: { ...cors, 'Content-Type': 'application/json' }, body: JSON.stringify({
      blocklist_terms: [], query_refinements: [], insights: ['No rejections yet — start clicking ✗ on bad listings to feed the engine.'], rejection_breakdown: {},
    })};
  }

  // Build user message — compact each rejection to keep token usage low
  const compact = rejections.map(r => ({
    item_id: r.ebay_item_id,
    player: r.player,
    parallel: r.parallel,
    card: r.card,
    title: r.title,
    desc: (r.description || '').slice(0, 600),
    specifics: r.item_specifics || {},
    reason: r.reason_code,
    notes: r.reason_notes || '',
  }));

  const client = new Anthropic({ apiKey: ANTHROPIC_KEY });
  let result;
  try {
    const resp = await client.messages.create({
      model: MODEL,
      max_tokens: 2000,
      system: [{ type: 'text', text: SYSTEM_PROMPT, cache_control: { type: 'ephemeral' } }],
      messages: [{
        role: 'user',
        content: `Analyze these ${rejections.length} rejected ISOsnipe listings and return the structured JSON described in the system prompt.\n\nREJECTIONS:\n${JSON.stringify(compact, null, 1)}`,
      }],
    });
    // Extract first text block
    const txt = (resp.content || []).find(c => c.type === 'text')?.text || '';
    // Claude may return JSON wrapped in code fences — strip them
    const cleaned = txt.replace(/^```(?:json)?\s*/i, '').replace(/\s*```\s*$/, '').trim();
    result = JSON.parse(cleaned);
  } catch (e) {
    return { statusCode: 502, headers: { ...cors, 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'AI call failed', detail: e.message }) };
  }

  // Always include rejection count + model meta for the UI
  return {
    statusCode: 200,
    headers: { ...cors, 'Content-Type': 'application/json' },
    body: JSON.stringify({
      ...result,
      _meta: {
        rejections_analyzed: rejections.length,
        model: MODEL,
        analyzed_at: new Date().toISOString(),
      },
    }),
  };
};
