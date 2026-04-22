#!/usr/bin/env node
/**
 * ISOSerial — AI Learning Stats Computer
 *
 * Rolls queue history into daily snapshots so we can SEE whether the
 * AI classifier is actually learning from admin actions over time.
 *
 * Agreement logic:
 *   - AI said reject_reason != 'none' AND admin skipped → AGREEMENT (AI flagged junk, admin confirmed)
 *   - AI said reject_reason == 'none' AND admin tagged  → AGREEMENT (AI approved, admin confirmed)
 *   - AI said reject_reason != 'none' AND admin tagged  → DISAGREEMENT (AI over-rejected)
 *   - AI said reject_reason == 'none' AND admin skipped → DISAGREEMENT (AI missed junk)
 *   - Pending queue rows don't count either way.
 *
 * Backfills all historical dates where iso_serial_queue has rows and
 * upserts via (snapshot_date) unique constraint.
 *
 * Env: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
 */

require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

const SB_URL     = process.env.SUPABASE_URL;
const SB_SERVICE = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_KEY;

if (!SB_URL || !SB_SERVICE) throw new Error('Missing SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY');

const sbHeaders = {
  apikey: SB_SERVICE,
  Authorization: `Bearer ${SB_SERVICE}`,
  'Content-Type': 'application/json',
};

// Date key helper — YYYY-MM-DD from any timestamp
function dayKey(ts) {
  if (!ts) return null;
  return new Date(ts).toISOString().slice(0, 10);
}

// Decide whether an AI pre-classification agreed with admin's action
function isAgreement(aiClass, status) {
  if (!aiClass || typeof aiClass !== 'object') return null;
  const aiRejected = aiClass.reject_reason && aiClass.reject_reason !== 'none';
  const adminTagged = status === 'tagged_new' || status === 'tagged_existing';
  const adminSkipped = status === 'skipped';
  if (!adminTagged && !adminSkipped) return null; // no admin action yet
  // Agreement cases
  if (aiRejected && adminSkipped) return true;
  if (!aiRejected && adminTagged) return true;
  return false;
}

async function fetchAllQueueRows() {
  // Pull all rows that have either been admin-acted-on OR have AI classification.
  // Paginated because iso_serial_queue can grow large.
  const PAGE = 1000;
  const rows = [];
  let offset = 0;
  while (true) {
    const url = `${SB_URL}/rest/v1/iso_serial_queue`
      + `?select=id,status,ai_classification,crawled_at,tagged_at`
      + `&order=crawled_at.asc`
      + `&limit=${PAGE}&offset=${offset}`;
    const res = await fetch(url, { headers: sbHeaders });
    if (!res.ok) throw new Error(`Fetch failed (${res.status}): ${await res.text()}`);
    const chunk = await res.json();
    rows.push(...chunk);
    if (chunk.length < PAGE) break;
    offset += PAGE;
  }
  return rows;
}

function computeStats(rows) {
  // Bucket by snapshot_date. Use crawled_at as the "day this listing landed".
  // For agreement we use the admin action; a listing crawled on day X but
  // tagged on day Y counts toward day X's classifier batch (the AI made its
  // call on day X). That way "did day-X's classifier run agree with admin"
  // is a fair question.
  const byDay = new Map();

  function bucket(date) {
    if (!byDay.has(date)) {
      byDay.set(date, {
        snapshot_date: date,
        classifier_calls: 0,
        tagged_count: 0,
        skipped_count: 0,
        pending_count: 0,
        agreement_count: 0,
        disagreement_count: 0,
        confidence_high: 0,
        confidence_medium: 0,
        confidence_low: 0,
      });
    }
    return byDay.get(date);
  }

  for (const r of rows) {
    const date = dayKey(r.crawled_at);
    if (!date) continue;
    const b = bucket(date);

    if (r.ai_classification) {
      b.classifier_calls++;
      const conf = (r.ai_classification.confidence || '').toLowerCase();
      if (conf === 'high')   b.confidence_high++;
      else if (conf === 'medium') b.confidence_medium++;
      else if (conf === 'low') b.confidence_low++;
    }

    if (r.status === 'tagged_new' || r.status === 'tagged_existing') b.tagged_count++;
    else if (r.status === 'skipped') b.skipped_count++;
    else b.pending_count++;

    const agree = isAgreement(r.ai_classification, r.status);
    if (agree === true)  b.agreement_count++;
    else if (agree === false) b.disagreement_count++;
  }

  // Compute agreement_pct per day
  const stats = [];
  for (const b of byDay.values()) {
    const total = b.agreement_count + b.disagreement_count;
    b.agreement_pct = total > 0 ? Number(((b.agreement_count / total) * 100).toFixed(2)) : 0;
    // blocklist_terms: left at 0 here; the crawler emits that number in its
    // own log — we'd need a log parse or crawler-side write to populate it.
    b.blocklist_terms = 0;
    stats.push(b);
  }
  stats.sort((a,b) => a.snapshot_date.localeCompare(b.snapshot_date));
  return stats;
}

async function upsertStats(rows) {
  if (rows.length === 0) return { ok: 0, err: 0 };
  const CHUNK = 100;
  let ok = 0, err = 0;
  for (let i = 0; i < rows.length; i += CHUNK) {
    const chunk = rows.slice(i, i + CHUNK);
    const res = await fetch(
      `${SB_URL}/rest/v1/iso_serial_ai_stats?on_conflict=snapshot_date`,
      {
        method: 'POST',
        headers: { ...sbHeaders, Prefer: 'return=minimal,resolution=merge-duplicates' },
        body: JSON.stringify(chunk),
      }
    );
    if (!res.ok) {
      console.warn(`Upsert chunk ${i} failed (${res.status}): ${(await res.text()).slice(0,200)}`);
      err += chunk.length;
    } else {
      ok += chunk.length;
    }
  }
  return { ok, err };
}

async function main() {
  const started = Date.now();
  console.log(`\n=== ISOSerial AI Stats — ${new Date().toISOString()} ===`);

  const rows = await fetchAllQueueRows();
  console.log(`Loaded ${rows.length} queue rows`);

  const stats = computeStats(rows);
  console.log(`Computed ${stats.length} daily snapshots\n`);

  for (const s of stats) {
    console.log(`  ${s.snapshot_date}  calls=${s.classifier_calls}  tagged=${s.tagged_count}  skipped=${s.skipped_count}  pending=${s.pending_count}  agreement=${s.agreement_pct}% (${s.agreement_count}/${s.agreement_count + s.disagreement_count})  conf=H${s.confidence_high}/M${s.confidence_medium}/L${s.confidence_low}`);
  }

  const { ok, err } = await upsertStats(stats);
  const runtime = ((Date.now() - started)/1000).toFixed(1);
  console.log(`\n=== DONE in ${runtime}s | Upserted ${ok} (errors: ${err}) ===\n`);
}

main().then(()=>process.exit(0)).catch(e => { console.error('FATAL:', e); process.exit(1); });
