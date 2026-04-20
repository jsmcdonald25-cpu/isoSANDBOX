/**
 * ISOSerial queue AI analyze — runs in GitHub Actions iso-serial workflow.
 *
 * Reads skipped + tagged queue entries from iso_serial_queue, calls Claude Haiku,
 * writes analysis to isosnipe/queue-ai-analysis-latest.json (reused location).
 *
 * Admin UI fetches the JSON directly — no Netlify function needed.
 */

require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });
const fs = require('fs');
const path = require('path');
const https = require('https');

const SB_URL = process.env.SUPABASE_URL || 'https://jyfaegmnzkarlcximxjo.supabase.co';
const SB_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_KEY;
const ANTHROPIC_KEY = process.env.ANTHROPIC_API_KEY;

if (!SB_KEY)        { console.error('No Supabase key'); process.exit(1); }
if (!ANTHROPIC_KEY) { console.error('No Anthropic key'); process.exit(1); }

function httpJson(url, opts = {}) {
  return new Promise((resolve, reject) => {
    const u = new URL(url);
    const req = https.request({
      hostname: u.hostname, path: u.pathname + u.search,
      method: opts.method || 'GET', headers: opts.headers || {},
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

async function fetchSkipped() {
  const r = await httpJson(
    `${SB_URL}/rest/v1/iso_serial_queue?status=eq.skipped&select=id,title,description,skip_reason,admin_notes,set_name_guess,price_usd,fraud_flag&order=tagged_at.desc&limit=200`,
    { headers: { 'apikey': SB_KEY, 'Authorization': `Bearer ${SB_KEY}` } }
  );
  return Array.isArray(r.json) ? r.json : [];
}

async function fetchTagged() {
  const r = await httpJson(
    `${SB_URL}/rest/v1/iso_serial_queue?status=in.(tagged_new,tagged_existing)&select=id,title,description,set_name_guess,price_usd&order=tagged_at.desc&limit=100`,
    { headers: { 'apikey': SB_KEY, 'Authorization': `Bearer ${SB_KEY}` } }
  );
  return Array.isArray(r.json) ? r.json : [];
}

const SYSTEM_PROMPT = `You analyze ISOSerial crawler queue entries (2026 Topps /5 cards):
1. SKIPPED — admin rejected with skip_reason (not_a_5, cant_id_copy, insert_not_in_checklist, multi_card_lot, suspected_fraud, poor_photos, other)
2. TAGGED — admin added to Provenance Registry (positive examples)

Return strict JSON:
{
  "blocklist_terms": [string] — 1-4 word phrases that mark SKIPPED listings. Max 20.
  "insights": [string] — sentences with counts/%. Max 8.
  "skip_breakdown": { skip_reason: count }
}

Output STRICT JSON, no prose, no code fences.`;

async function callClaude(skipped, tagged) {
  const compactS = skipped.map(q => ({
    id: q.id, set: q.set_name_guess, title: q.title,
    desc: (q.description || '').slice(0, 600),
    skip_reason: q.skip_reason, notes: q.admin_notes || '',
    price: q.price_usd, fraud: q.fraud_flag || false,
  }));
  const compactT = tagged.map(q => ({
    id: q.id, set: q.set_name_guess, title: q.title,
    desc: (q.description || '').slice(0, 600),
    price: q.price_usd,
  }));

  const body = JSON.stringify({
    model: 'claude-haiku-4-5',
    max_tokens: 2000,
    system: [{ type: 'text', text: SYSTEM_PROMPT, cache_control: { type: 'ephemeral' } }],
    messages: [{
      role: 'user',
      content: `Analyze ${skipped.length} SKIPPED + ${tagged.length} TAGGED queue entries.\n\nSKIPPED:\n${JSON.stringify(compactS, null, 1)}\n\nTAGGED:\n${JSON.stringify(compactT, null, 1)}`,
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
  if (r.status !== 200) throw new Error(`Claude ${r.status}: ${r.raw || ''}`);
  const txt = (r.json.content || []).find(c => c.type === 'text')?.text || '';
  const cleaned = txt.replace(/^```(?:json)?\s*/i, '').replace(/\s*```\s*$/, '').trim();
  return JSON.parse(cleaned);
}

(async () => {
  console.log('ISOSerial queue AI analyze — pulling skipped + tagged…');
  const [skipped, tagged] = await Promise.all([fetchSkipped(), fetchTagged()]);
  console.log(`  skipped: ${skipped.length}, tagged: ${tagged.length}`);

  let result;
  if (skipped.length === 0 && tagged.length === 0) {
    result = { blocklist_terms: [], insights: ['No queue feedback yet.'], skip_breakdown: {} };
  } else {
    try {
      result = await callClaude(skipped, tagged);
    } catch (e) {
      console.error('  Claude call failed:', e.message);
      process.exit(1);
    }
  }

  const out = {
    ...result,
    _meta: {
      skipped_analyzed: skipped.length,
      tagged_analyzed:  tagged.length,
      model: 'claude-haiku-4-5',
      analyzed_at: new Date().toISOString(),
    },
  };

  const outPath = path.join(__dirname, 'queue-ai-analysis-latest.json');
  fs.writeFileSync(outPath, JSON.stringify(out, null, 2));
  console.log(`  saved: ${outPath}`);
})();
