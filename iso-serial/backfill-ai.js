#!/usr/bin/env node
/**
 * ISOSerial AI Backfill — runs Claude Haiku 4.5 classification against
 * every queue row that doesn't already have ai_classification.
 *
 * Run once after enabling AI to retro-classify the items already in the
 * review queue (the 300+ from bootstrap, etc.). Subsequent crawler runs
 * classify new listings inline.
 *
 * Usage (from repo root):
 *   node iso-serial/backfill-ai.js
 *
 * Idempotent: re-running only hits rows that are still missing AI data.
 */

require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });
const { classifyListing } = require('./ai-classify');

const SUPABASE_URL          = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE = process.env.SUPABASE_SERVICE_ROLE_KEY;
const ANTHROPIC_API_KEY     = process.env.ANTHROPIC_API_KEY;

if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE) {
  console.error('Missing SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY in .env');
  process.exit(1);
}
if (!ANTHROPIC_API_KEY) {
  console.error('Missing ANTHROPIC_API_KEY in .env');
  process.exit(1);
}

const sbHeaders = {
  'apikey': SUPABASE_SERVICE_ROLE,
  'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE}`,
  'Content-Type': 'application/json',
};

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function fetchUnclassified() {
  // PostgREST: ai_classification is null AND status is pending or fraud (don't waste API on already-tagged or skipped)
  const url = `${SUPABASE_URL}/rest/v1/iso_serial_queue?select=id,title,description,set_name_guess&ai_classification=is.null&status=in.(pending)&order=crawled_at.desc&limit=500`;
  const res = await fetch(url, { headers: sbHeaders });
  if (!res.ok) throw new Error(`Fetch failed (${res.status}): ${await res.text()}`);
  return res.json();
}

async function patchQueue(id, ai) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/iso_serial_queue?id=eq.${id}`, {
    method: 'PATCH',
    headers: { ...sbHeaders, 'Prefer': 'return=minimal' },
    body: JSON.stringify({ ai_classification: ai }),
  });
  if (!res.ok) {
    console.warn(`  Patch failed for #${id} (${res.status}): ${await res.text()}`);
    return false;
  }
  return true;
}

async function main() {
  console.log('\n=== ISOSerial AI Backfill ===');
  console.log(`Time: ${new Date().toISOString()}\n`);

  const rows = await fetchUnclassified();
  console.log(`Found ${rows.length} unclassified pending rows\n`);

  if (rows.length === 0) {
    console.log('Nothing to do.');
    return;
  }

  let success = 0, fail = 0;
  let totalCacheRead = 0, totalCacheWrite = 0, totalInput = 0, totalOutput = 0;

  for (let i = 0; i < rows.length; i++) {
    const r = rows[i];
    process.stdout.write(`[${i + 1}/${rows.length}] #${r.id} `);
    const ai = await classifyListing({
      title: r.title,
      description: r.description,
      setHint: r.set_name_guess,
    });
    if (!ai) {
      console.log('— classify failed');
      fail++;
      continue;
    }
    const ok = await patchQueue(r.id, ai);
    if (ok) {
      success++;
      const u = ai._usage || {};
      totalCacheRead  += (u.cache_read_input_tokens || 0);
      totalCacheWrite += (u.cache_creation_input_tokens || 0);
      totalInput      += (u.input_tokens || 0);
      totalOutput     += (u.output_tokens || 0);
      const tag = `${ai.set_name || '?'} · ${ai.parallel_name || '?'} · /${ai.print_run || '?'} · ${ai.confidence}`;
      console.log(`✓ ${tag}`);
    } else {
      fail++;
    }
    await sleep(150); // be nice to the API
  }

  console.log('\n=== DONE ===');
  console.log(`Success: ${success} | Failed: ${fail}`);
  console.log(`Tokens — input: ${totalInput} | cache write: ${totalCacheWrite} | cache read: ${totalCacheRead} | output: ${totalOutput}`);
  // Cost estimate (Haiku 4.5: $1/M input, $5/M output, $1.25/M cache write, $0.10/M cache read)
  const cost =
    (totalInput      * 1.00 / 1_000_000) +
    (totalCacheWrite * 1.25 / 1_000_000) +
    (totalCacheRead  * 0.10 / 1_000_000) +
    (totalOutput     * 5.00 / 1_000_000);
  console.log(`Approx cost: $${cost.toFixed(4)}`);
}

main()
  .then(() => process.exit(0))
  .catch((err) => { console.error('FATAL:', err); process.exit(1); });
