/**
 * ISOsnipe AI analyze — runs inside GitHub Actions after each scan.
 *
 * Reads rejections + confirmations from Supabase, sends them to Claude Haiku,
 * writes the analysis to isosnipe/ai-analysis-latest.json.
 *
 * The admin UI fetches that JSON directly (no Netlify function needed).
 *
 * Env required (set in .github/workflows/isosnipe.yml):
 *   SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, ANTHROPIC_API_KEY
 */

require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });
const fs = require('fs');
const path = require('path');
const https = require('https');

const SB_URL = process.env.SUPABASE_URL || 'https://jyfaegmnzkarlcximxjo.supabase.co';
const SB_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_KEY;
const ANTHROPIC_KEY = process.env.ANTHROPIC_API_KEY;

if (!SB_KEY)         { console.error('No Supabase key'); process.exit(1); }
if (!ANTHROPIC_KEY)  { console.error('No Anthropic key'); process.exit(1); }

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

async function fetchRejections() {
  const r = await httpJson(
    `${SB_URL}/rest/v1/isosnipe_rejections?select=ebay_item_id,player,parallel,card,title,description,item_specifics,reason_code,reason_codes,reason_notes&order=rejected_at.desc&limit=200`,
    { headers: { 'apikey': SB_KEY, 'Authorization': `Bearer ${SB_KEY}` } }
  );
  return Array.isArray(r.json) ? r.json : [];
}

async function fetchConfirmations() {
  const r = await httpJson(
    `${SB_URL}/rest/v1/isosnipe_confirmations?select=ebay_item_id,player,parallel,card,title,description,item_specifics,price,market_avg,delta&order=confirmed_at.desc&limit=100`,
    { headers: { 'apikey': SB_KEY, 'Authorization': `Bearer ${SB_KEY}` } }
  );
  return Array.isArray(r.json) ? r.json : [];
}

const SYSTEM_PROMPT = `You are an expert sports trading card listing analyst. You receive TWO batches from an admin's ISOsnipe queue:

1. REJECTIONS — listings marked "not a real snipe" (negative examples) with reason code(s) + notes
2. CONFIRMATIONS — listings the admin confirmed as real snipes (positive examples)

Your edge: COMPARE. Words/phrases in REJECTIONS but NOT in CONFIRMATIONS are strongest blocklist signals. Words consistent across CONFIRMATIONS describe what a real snipe looks like.

Return strict JSON:
{
  "blocklist_terms": [string] — 1-4 word phrases that indicate REJECTED listings. Max 20.
  "query_refinements": [{player, parallel, negatives:[string]}] — per-target negative keywords. Max 15.
  "insights": [string] — one-sentence observations with counts/%. Max 8.
  "rejection_breakdown": { reason_code: count } — count by reason_code across rejections.
}

Be data-driven. Prefer multi-word phrases ("facsimile signature" > "signed"). Don't repeat blocklist_terms in query_refinements.

Output STRICT JSON, no prose, no code fences.`;

async function callClaude(rejections, confirmations) {
  const compactRej = rejections.map(r => ({
    item_id: r.ebay_item_id,
    player: r.player, parallel: r.parallel, card: r.card,
    title: r.title,
    desc: (r.description || '').slice(0, 600),
    specifics: r.item_specifics || {},
    reason: r.reason_code,
    reasons: r.reason_codes || [],
    notes: r.reason_notes || '',
  }));
  const compactConf = confirmations.map(c => ({
    item_id: c.ebay_item_id,
    player: c.player, parallel: c.parallel, card: c.card,
    title: c.title,
    desc: (c.description || '').slice(0, 600),
    specifics: c.item_specifics || {},
    price: c.price, market_avg: c.market_avg, delta: c.delta,
  }));

  const body = JSON.stringify({
    model: 'claude-haiku-4-5',
    max_tokens: 2000,
    system: [{ type: 'text', text: SYSTEM_PROMPT, cache_control: { type: 'ephemeral' } }],
    messages: [{
      role: 'user',
      content: `Analyze ${rejections.length} REJECTED (bad) and ${confirmations.length} CONFIRMED GOOD listings. Return the structured JSON from the system prompt.\n\nREJECTIONS:\n${JSON.stringify(compactRej, null, 1)}\n\nCONFIRMATIONS:\n${JSON.stringify(compactConf, null, 1)}`,
    }],
  });

  const r = await httpJson('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'x-api-key': ANTHROPIC_KEY,
      'anthropic-version': '2023-06-01',
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(body),
    },
    body,
  });

  if (r.status !== 200) {
    throw new Error(`Claude API ${r.status}: ${r.raw || JSON.stringify(r.json)}`);
  }
  const txt = (r.json.content || []).find(c => c.type === 'text')?.text || '';
  const cleaned = txt.replace(/^```(?:json)?\s*/i, '').replace(/\s*```\s*$/, '').trim();
  return JSON.parse(cleaned);
}

(async () => {
  console.log('ISOsnipe AI analyze — pulling rejections + confirmations…');
  const [rejections, confirmations] = await Promise.all([fetchRejections(), fetchConfirmations()]);
  console.log(`  rejections: ${rejections.length}`);
  console.log(`  confirmations: ${confirmations.length}`);

  let result;
  if (rejections.length === 0 && confirmations.length === 0) {
    console.log('  no feedback yet — writing empty analysis');
    result = {
      blocklist_terms: [], query_refinements: [],
      insights: ['No feedback yet — click ✓ on real snipes and ✗ on bad listings to feed the engine.'],
      rejection_breakdown: {},
    };
  } else {
    console.log('  calling Claude Haiku…');
    try {
      result = await callClaude(rejections, confirmations);
      console.log(`  got ${result.blocklist_terms?.length || 0} blocklist terms, ${result.insights?.length || 0} insights`);
    } catch (e) {
      console.error('  Claude call failed:', e.message);
      process.exit(1);
    }
  }

  const out = {
    ...result,
    _meta: {
      rejections_analyzed:    rejections.length,
      confirmations_analyzed: confirmations.length,
      model: 'claude-haiku-4-5',
      analyzed_at: new Date().toISOString(),
    },
  };

  const outPath = path.join(__dirname, 'ai-analysis-latest.json');
  fs.writeFileSync(outPath, JSON.stringify(out, null, 2));
  console.log(`  saved: ${outPath}`);
})();
