// ============================================================
// ISOSerial AI Learn — queue skip + tag pattern analyzer
// netlify/functions/iso-serial-analyze.js
// ============================================================
// Pulls skipped + tagged queue entries from iso_serial_queue, feeds
// them to Claude Haiku 4.5, returns pattern suggestions for the
// crawler (what to filter upstream) + breakdown by skip_reason.

const Anthropic = require('@anthropic-ai/sdk');
const https = require('https');

const SB_URL = process.env.SUPABASE_URL || 'https://jyfaegmnzkarlcximxjo.supabase.co';
const SB_SERVICE = process.env.SUPABASE_SERVICE_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY;
const ANTHROPIC_KEY = process.env.ANTHROPIC_API_KEY;
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
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return { user: null, reason: 'no-bearer-header' };
  }
  const token = authHeader.slice(7);
  if (!token) return { user: null, reason: 'empty-token' };

  const me = await httpJson(`${SB_URL}/auth/v1/user`, {
    headers: { 'apikey': SB_SERVICE, 'Authorization': `Bearer ${token}` },
  });
  if (me.status !== 200 || !me.json?.id) {
    return { user: null, reason: `auth-user-${me.status}`, detail: me.json?.msg || me.json?.error_description || me.raw?.slice(0,120) };
  }

  const prof = await httpJson(
    `${SB_URL}/rest/v1/profiles?id=eq.${me.json.id}&select=role,is_admin&limit=1`,
    { headers: { 'apikey': SB_SERVICE, 'Authorization': `Bearer ${SB_SERVICE}` } }
  );
  if (prof.status !== 200) {
    return { user: null, reason: `profile-query-${prof.status}`, detail: prof.raw?.slice(0,120) };
  }
  const p = prof.json?.[0];
  if (!p) return { user: null, reason: 'no-profile-row', detail: `uid=${me.json.id}` };
  if (p.role !== 'owner' && p.is_admin !== true) {
    return { user: null, reason: 'not-admin', detail: `role=${p.role} is_admin=${p.is_admin}` };
  }
  return { user: me.json, reason: 'ok' };
}

async function fetchSkipped() {
  const r = await httpJson(
    `${SB_URL}/rest/v1/iso_serial_queue?status=eq.skipped&select=id,title,description,skip_reason,admin_notes,set_name_guess,price_usd,fraud_flag&order=tagged_at.desc&limit=200`,
    { headers: { 'apikey': SB_SERVICE, 'Authorization': `Bearer ${SB_SERVICE}` } }
  );
  return Array.isArray(r.json) ? r.json : [];
}

async function fetchTagged() {
  const r = await httpJson(
    `${SB_URL}/rest/v1/iso_serial_queue?status=in.(tagged_new,tagged_existing)&select=id,title,description,set_name_guess,price_usd&order=tagged_at.desc&limit=100`,
    { headers: { 'apikey': SB_SERVICE, 'Authorization': `Bearer ${SB_SERVICE}` } }
  );
  return Array.isArray(r.json) ? r.json : [];
}

const SYSTEM_PROMPT = `You are an expert trading card listing classifier for Topps 2026 serialized (/5 and similar low print-run) cards. You receive TWO batches from an admin's ISOSerial crawler queue:

1. SKIPPED — queue entries the admin rejected with a skip_reason (not a real /5, multi-card lot, can't ID, fraud, etc.)
2. TAGGED  — queue entries the admin confirmed and added to the Provenance Registry (positive examples)

Your edge is COMPARING the two: words/phrases in SKIPPED listings that DON'T appear in TAGGED ones are strongest crawler-filter candidates. Words consistent across TAGGED describe what a real serialized /5 listing looks like.

Return strict JSON:

{
  "blocklist_terms": [string] — 1-4 word phrases that indicate a SKIPPED listing. Max 20.
  "insights": [string] — one-sentence observations with counts/percentages from the data. Max 8.
  "skip_breakdown": { reason_code: count } — count by skip_reason across SKIPPED.
}

# SKIP REASON CODES
- not_a_5: not a /5 card (search noise — /10, /25, base, etc.)
- cant_id_copy: is /5 but can't ID which edition
- insert_not_in_checklist: insert subset not yet in our checklist
- multi_card_lot: multi-card lot disguised as single
- suspected_fraud: reprint, facsimile, misleading
- poor_photos: can't verify — revisit later
- other: see admin_notes

# DOMAIN
2026 Topps Series 1 + Heritage. Serialized /5 parallels: Sandglitter, Red Foil, Holo Foil, Red Chrome Bordered, Flip Stock (Heritage SSP). Other rare /77, /99, /150, /25 parallels also in scope. Inserts with codes like 91A-XX, 75YA-XX, ROAC-XX, FS-XX are legitimate. Multi-player dual cards (e.g. Victory Leaders) are tagged normally.`;

exports.handler = async (event) => {
  const cors = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
  };
  if (event.httpMethod === 'OPTIONS') return { statusCode: 204, headers: cors, body: '' };
  if (event.httpMethod !== 'POST')   return { statusCode: 405, headers: cors, body: 'Method not allowed' };
  if (!ANTHROPIC_KEY) return { statusCode: 500, headers: cors, body: JSON.stringify({ error: 'ANTHROPIC_API_KEY not set' }) };
  if (!SB_SERVICE)    return { statusCode: 500, headers: cors, body: JSON.stringify({ error: 'SUPABASE_SERVICE_KEY not set' }) };

  const adminCheck = await verifyAdmin(event.headers.authorization || event.headers.Authorization);
  if (!adminCheck.user) return { statusCode: 403, headers: { ...cors, 'Content-Type': 'application/json' }, body: JSON.stringify({ error: 'Admin auth required', reason: adminCheck.reason, detail: adminCheck.detail }) };

  const [skipped, tagged] = await Promise.all([fetchSkipped(), fetchTagged()]);

  if (skipped.length === 0 && tagged.length === 0) {
    return { statusCode: 200, headers: { ...cors, 'Content-Type': 'application/json' }, body: JSON.stringify({
      blocklist_terms: [], insights: ['No queue data yet — skip or tag some listings first.'], skip_breakdown: {},
    })};
  }

  const compactSkipped = skipped.map(q => ({
    id: q.id,
    set: q.set_name_guess, title: q.title,
    desc: (q.description || '').slice(0, 600),
    skip_reason: q.skip_reason, notes: q.admin_notes || '',
    price: q.price_usd, fraud: q.fraud_flag || false,
  }));
  const compactTagged = tagged.map(q => ({
    id: q.id, set: q.set_name_guess, title: q.title,
    desc: (q.description || '').slice(0, 600),
    price: q.price_usd,
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
        content: `Analyze ${skipped.length} SKIPPED queue entries (bad) and ${tagged.length} TAGGED entries (good) from ISOSerial. Return the structured JSON from the system prompt.\n\nSKIPPED:\n${JSON.stringify(compactSkipped, null, 1)}\n\nTAGGED:\n${JSON.stringify(compactTagged, null, 1)}`,
      }],
    });
    const txt = (resp.content || []).find(c => c.type === 'text')?.text || '';
    const cleaned = txt.replace(/^```(?:json)?\s*/i, '').replace(/\s*```\s*$/, '').trim();
    result = JSON.parse(cleaned);
  } catch (e) {
    return { statusCode: 502, headers: { ...cors, 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'AI call failed', detail: e.message }) };
  }

  return {
    statusCode: 200,
    headers: { ...cors, 'Content-Type': 'application/json' },
    body: JSON.stringify({
      ...result,
      _meta: {
        skipped_analyzed: skipped.length,
        tagged_analyzed:  tagged.length,
        model: MODEL,
        analyzed_at: new Date().toISOString(),
      },
    }),
  };
};
