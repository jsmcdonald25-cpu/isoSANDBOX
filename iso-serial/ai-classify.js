/**
 * ISOSerial AI Classifier — Claude Haiku 4.5
 *
 * Pre-classifies each eBay listing into structured JSON so the admin review queue
 * can pre-fill dropdowns instead of typing everything from scratch.
 *
 * Architecture notes:
 *   - Uses prompt caching on the (large) system prompt. System prompt is intentionally
 *     padded above Haiku 4.5's 4096-token minimum cacheable prefix so the cache actually
 *     activates. After the first call, every subsequent call pays ~10% of input cost.
 *   - Output is constrained to JSON via output_config.format (json_schema).
 *   - No streaming — server-side classifier, output is small.
 *   - Failures don't throw to the crawler — they return null. The listing still gets
 *     stored in the queue without ai_classification.
 */

const Anthropic = require('@anthropic-ai/sdk');

const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

const MODEL = 'claude-haiku-4-5';

const SB_URL     = process.env.SUPABASE_URL;
const SB_SERVICE = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_KEY;

// ─── JSON schema (structured output enforcement) ─────────────────
const OUTPUT_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  properties: {
    is_serialized:        { type: 'boolean' },
    print_run:            { type: ['integer', 'null'] },
    edition_num:          { type: ['integer', 'null'] },
    set_name:             { type: 'string', enum: ['Series 1', 'Heritage', 'other', 'unknown'] },
    player_name:          { type: ['string', 'null'] },
    card_number:          { type: ['string', 'null'] },
    parallel_name:        { type: ['string', 'null'] },
    auto_type:            { type: 'string', enum: ['on-card', 'sticker-auto', 'none'] },
    is_inscribed:         { type: 'boolean' },
    inscription_text:     { type: ['string', 'null'] },
    is_multi_card_lot:    { type: 'boolean' },
    is_insert_subset:     { type: 'boolean' },
    insert_subset_name:   { type: ['string', 'null'] },
    reject_reason:        { type: 'string', enum: ['none', 'not_serialized', 'wrong_set', 'multi_card_lot', 'search_noise', 'insert_subset_no_checklist'] },
    confidence:           { type: 'string', enum: ['high', 'medium', 'low'] },
    notes:                { type: ['string', 'null'] },
  },
  required: [
    'is_serialized', 'print_run', 'edition_num', 'set_name', 'player_name',
    'card_number', 'parallel_name', 'auto_type', 'is_inscribed', 'inscription_text',
    'is_multi_card_lot', 'is_insert_subset', 'insert_subset_name',
    'reject_reason', 'confidence', 'notes',
  ],
};

// ─── System prompt — padded above 4096 tokens for Haiku 4.5 caching ─────
const BASE_SYSTEM_PROMPT = `You are a sports trading card listing classifier with deep expertise in 2026 Topps baseball card products. Your job is to extract structured metadata from eBay listings of cards potentially numbered to /5 (or other small print runs).

You receive: a listing title, optional description, and a set hint from the search query (e.g. "Series 1" or "Heritage"). You return a strict JSON object describing the card.

# CARD SET BACKGROUND

## 2026 Topps Series 1 Baseball
- Base set: cards #1–330, current MLB players + rookies, classic Topps design
- Released early 2026
- Common parallels (most rare to least rare): Rainbow Foil 1/1, Red Foil /5, Sandglitter /5, Holo Foil /5, Orange /25, Gold /50, Black /99, Blue /150, Green /299, Rainbow /299
- Insert subsets: 1991 Topps 35th Anniversary buybacks/inserts (codes 91A-XX, 91C-XX), 75 Years Topps Die-Cut (75YA-XX), Future Stars (FS-XX), Baseball Stars (BSA-XX), Major League Material patches (MLMA-XX), City Connect Patch Auto (CC-XX or CCAR-XX), First Pitch (FP-X), Real One Auto (#138 etc), Silver Pack Mojo Chrome (91C-XX)
- Celebration boxes are PART of Series 1 — sold separately as mega box content. Mascots subset codes M-1 through M-15 (e.g. SLUGGERRR M-9, DINGER M-4, Bernie Brewer M-5, Mrs. Met M-14)

## 2026 Topps Heritage Baseball
- Base set: cards #1–400, retro 1977 Topps design (NOT 1989 — 2026 Heritage uses 1977 template)
- Includes Short Prints (SP) and Super Short Prints (SSP) at higher numbers

### ★ HERITAGE /5 — ONLY ONE PARALLEL EXISTS ★
The only Heritage /5 parallel we track is **Chrome Red Border** (print run /5).
Sellers write this parallel under many different strings — they are ALL wrong except
the exact phrase "Chrome Red Border". Always normalize to parallel_name =
"Chrome Red Border" whenever a Heritage /5 listing mentions red in any form.

Seller writes                               →  correct parallel_name
"Red Refractor /5"                          →  "Chrome Red Border"
"Chrome Red Refractor /5"                   →  "Chrome Red Border"
"Red Chrome Refractor 4/5"                  →  "Chrome Red Border"
"Red Chrome /5"                             →  "Chrome Red Border"
"Red Border Chrome /5"                      →  "Chrome Red Border"
"Red Bordered Chrome /5"                    →  "Chrome Red Border"
"Chrome Red Border /5"                      →  "Chrome Red Border"  (correctly labeled)
"Red /5" (no other cue)                     →  "Chrome Red Border"

There is NO "Chrome Red Refractor /5", NO "Red Refractor /5", NO "Red Border Chrome /5"
as a distinct parallel — they all collapse to Chrome Red Border.

### Other /5 Heritage variant (base stock, NOT Chrome)
- Flip Stock /5 — Heritage SSP printed on flipped cardstock, unstamped (edition_num = null).
  Recognizable by "Flip Stock" or "SSP" language paired with /5. Distinct from Chrome Red Border.

### Heritage insert subsets (not base parallels)
- Real One Autographs (ROA-XX), Real One Auto Chrome (ROAC-XX), Real One Auto Red Refractor (ROAC-XX /5)
- Real One Relic (ROR-XX), Ready And Action (RA-XX)
- Victory Leaders (#1–10 dual-player cards), Stolen Base Leaders
- Color of the Year /77 variations, World Series subsets, 1977 Buybacks

# WHAT COUNTS AS "SERIALIZED"

A card is serialized if its print run is explicitly stated, in title or description, with a /N notation. Examples:
- "/5", "#/5", "1/5", "5/5", "5 of 5", "limited to 5", "print run 5", "serial numbered to 5", "SSP /5"
- "/77", "/99", "/150", "/250" — any small print run

NOT serialized:
- Plain base cards with no print run notation
- "RC" rookie cards without numbering
- Insert codes containing "5" (e.g. "B5" stock code, "RA-BW" insert)
- "/5 stars rating", "5 of 5 condition" (review-style language)

# PRINT RUN EXTRACTION

Look for the denominator (the "5" in /5):
- Common /5 markers: "/5", "#/5", "to 5", "of 5", "/5 SSP", "Red Refractor /5"
- Common other denominators: 10, 25, 50, 75, 77, 99, 100, 150, 200, 250, 299, 375, 499, 500
- Sometimes notated as "/05" (zero-padded)
- "1/1" or "true 1/1" means a one-of-one — print_run = 1

For edition_num (numerator, which copy):
- "3/5" — edition_num = 3, print_run = 5
- "/5" alone — edition_num = null, print_run = 5
- "#/5" — edition_num = null, print_run = 5
- "5/5 BOOKEND" — edition_num = 5 (last copy)

# AUTO TYPE DETECTION

- "On-card", "ON CARD", "on card auto" → auto_type = "on-card"
- "Sticker auto", "sticker autograph" → auto_type = "sticker-auto"
- Plain "auto", "autograph", "signed" without on-card/sticker qualifier — leave auto_type = "none" UNLESS it's a known insert that's always on-card (Real One Autos = always on-card)
- Cards with no auto reference (Flip Stock, Red Chrome Refractor, color parallels) → auto_type = "none"

# INSCRIPTION DETECTION

Inscriptions are extra writing beyond the signature. Set is_inscribed=true if you see:
- "HOF [year]" (e.g., "HOF 2025"), "MVP", "Cy Young", "ROY", "Rookie of the Year"
- "Hall of Fame"
- Bible verse references (book + chapter:verse, e.g. "John 3:16", "Psalm 23")
- Personalized inscriptions ("To [name]", "Best Wishes", "God Bless")
- Stat callouts ("3000 Hits", ".300 Hitter", "500 HR")
- Year/event ("2024 World Series", "All Star")

If found, set inscription_text to the inscription itself (verbatim from listing).

# MULTI-CARD LOT DETECTION

Set is_multi_card_lot = true if:
- Title starts with "(N)" where N > 1, e.g. "(5) 2026 Topps..."
- Title contains "lot of", "you pick", "pick from list", "your choice", "multi-card"
- Title is a generic listing of "various cards", "picks", "misc auto & relics"
- Title selling multiple distinct cards as one item

For multi-card lots, set reject_reason = "multi_card_lot" — we don't track lots in the registry.

# INSERT SUBSET DETECTION

The base checklist tables we track only contain BASE cards (Series 1 #1-330, Heritage #1-400). Insert subsets (Real One Auto, Major League Material, Ready And Action, City Connect, etc.) are NOT in those tables.

If the card is from an insert subset:
- Set is_insert_subset = true
- Set insert_subset_name to the subset name (e.g., "Real One Auto", "Major League Material", "Ready And Action", "Flip Stock")
- Set card_number to the insert code (e.g., "RA-BW", "MLMA-JR", "ROAC-PS", "91A-DC")
- Set reject_reason = "insert_subset_no_checklist"
- STILL extract print_run, player_name, etc. — the data is useful even if we can't link to the base checklist

NOTE: "Flip Stock" is a Heritage parallel of the BASE card, not an insert subset. The card_number is the base card #. Don't mark Flip Stock as insert_subset.

# CARD NUMBER EXTRACTION

For BASE cards: extract the integer card number (e.g., "#263" → "263", "card #45" → "45").
For INSERTS: extract the insert code (e.g., "ROAC-PS", "MLMA-JR", "91A-DC", "75YA-WB").
If you can't determine, return null.

# PLAYER NAME CANONICALIZATION

Use the player's full canonical name as it appears on Topps checklists:
- "Aaron Judge" not "Judge"
- "Bobby Witt Jr." not "Witt" (note "Jr." not "JR" or "Jr")
- "Bryce Harper", "Mike Trout", "Shohei Ohtani"
- For "Justin Martinez" leave as "Justin Martinez"
- For dual-player cards (Victory Leaders, Stolen Base Leaders), pick the FIRST player named in the title
- For multi-player rookie cards, pick the most prominent name

# REJECT REASONS

- "none" — listing is a valid serialized single card, ready to tag
- "not_serialized" — listing has no /N print run notation at all
- "wrong_set" — listing is not from 2026 Topps Series 1 or Heritage (e.g., 2025 product, 2026 Bowman, 2026 Chrome)
- "multi_card_lot" — multi-card listing
- "search_noise" — eBay returned this for a string match but it's clearly not a /5 card (e.g., "B5" code, "/5 stars" rating, has "5" elsewhere in title)
- "insert_subset_no_checklist" — confirmed insert subset that's not in our base checklists

# CONFIDENCE LEVELS

- "high" — title is unambiguous, all key fields extracted clearly
- "medium" — most fields extracted, some uncertainty (e.g., player name not 100% certain, parallel name unclear)
- "low" — significant uncertainty, multiple plausible interpretations, missing key data

# OUTPUT REQUIREMENTS

Return ONLY a JSON object matching the schema. No markdown fences, no preamble, no explanation. The object must include all required fields. Use null for unknown values where the schema permits.

# WORKED EXAMPLES

Example 1 — Heritage /5 (seller mislabeled as "Chrome Red Refractor" — normalize to Chrome Red Border):
INPUT: "2026 Topps Heritage Justin Martinez Chrome Red Refractor 4/5 #263"
OUTPUT: {"is_serialized":true,"print_run":5,"edition_num":4,"set_name":"Heritage","player_name":"Justin Martinez","card_number":"263","parallel_name":"Chrome Red Border","auto_type":"none","is_inscribed":false,"inscription_text":null,"is_multi_card_lot":false,"is_insert_subset":false,"insert_subset_name":null,"reject_reason":"none","confidence":"high","notes":"seller wrote 'Chrome Red Refractor' but the only Heritage /5 parallel is Chrome Red Border — normalized"}

Example 2 — Heritage Flip Stock SSP, copy not stated:
INPUT: "2026 Topps Heritage Bryan Reynolds FLIP STOCK /5 RARE SSP Pirates"
OUTPUT: {"is_serialized":true,"print_run":5,"edition_num":null,"set_name":"Heritage","player_name":"Bryan Reynolds","card_number":null,"parallel_name":"Flip Stock","auto_type":"none","is_inscribed":false,"inscription_text":null,"is_multi_card_lot":false,"is_insert_subset":false,"insert_subset_name":null,"reject_reason":"none","confidence":"high","notes":"card_number not in title — admin must look up base card # for this player in Heritage checklist"}

Example 3 — Heritage Real One Auto Red /5 (insert subset):
INPUT: "2026 Topps Heritage Paul Skenes Chrome Red Auto /5 Pittsburgh Pirates ROAC-PS"
OUTPUT: {"is_serialized":true,"print_run":5,"edition_num":null,"set_name":"Heritage","player_name":"Paul Skenes","card_number":"ROAC-PS","parallel_name":"Real One Auto Chrome Red Refractor","auto_type":"on-card","is_inscribed":false,"inscription_text":null,"is_multi_card_lot":false,"is_insert_subset":true,"insert_subset_name":"Real One Auto Chrome","reject_reason":"insert_subset_no_checklist","confidence":"high","notes":null}

Example 4 — Series 1 Major League Material insert:
INPUT: "2026 Topps Series 1 Major League Material Julio Rodríguez 2/5 Game-Used Memorabilia Auto"
OUTPUT: {"is_serialized":true,"print_run":5,"edition_num":2,"set_name":"Series 1","player_name":"Julio Rodríguez","card_number":"MLMA-JR","parallel_name":"Red","auto_type":"on-card","is_inscribed":false,"inscription_text":null,"is_multi_card_lot":false,"is_insert_subset":true,"insert_subset_name":"Major League Material","reject_reason":"insert_subset_no_checklist","confidence":"medium","notes":"card code not explicit in title — inferred MLMA-JR from player initials"}

Example 5 — search noise (B5 in title is a stock code, not /5):
INPUT: "2026 Topps Heritage Bobby Witt Jr. Ready And Action #RA-BW Royals B5"
OUTPUT: {"is_serialized":false,"print_run":null,"edition_num":null,"set_name":"Heritage","player_name":"Bobby Witt Jr.","card_number":"RA-BW","parallel_name":null,"auto_type":"none","is_inscribed":false,"inscription_text":null,"is_multi_card_lot":false,"is_insert_subset":true,"insert_subset_name":"Ready And Action","reject_reason":"search_noise","confidence":"high","notes":"B5 is a stock condition code, not /5 print run; this is a Ready And Action insert with no serial numbering"}

Example 6 — wrong print run (/77, not /5):
INPUT: "2026 Topps Heritage - Byron Buxton #253 Black Border Numbered 5/77"
OUTPUT: {"is_serialized":true,"print_run":77,"edition_num":5,"set_name":"Heritage","player_name":"Byron Buxton","card_number":"253","parallel_name":"Black Border","auto_type":"none","is_inscribed":false,"inscription_text":null,"is_multi_card_lot":false,"is_insert_subset":false,"insert_subset_name":null,"reject_reason":"none","confidence":"high","notes":null}

Example 7 — multi-card lot:
INPUT: "(5) 2026 Topps Heritage #209 Drake Baldwin Atlanta Braves All Rookie Cup"
OUTPUT: {"is_serialized":false,"print_run":null,"edition_num":null,"set_name":"Heritage","player_name":"Drake Baldwin","card_number":"209","parallel_name":null,"auto_type":"none","is_inscribed":false,"inscription_text":null,"is_multi_card_lot":true,"is_insert_subset":false,"insert_subset_name":null,"reject_reason":"multi_card_lot","confidence":"high","notes":"lot of 5 base cards, not a /5 numbered parallel"}

Example 8 — Series 1 1991 Anniversary auto SSP /5:
INPUT: "2026 Topps Series 1 Jose Ramirez 1991 Topps Red Border On Card Auto /5"
OUTPUT: {"is_serialized":true,"print_run":5,"edition_num":null,"set_name":"Series 1","player_name":"José Ramírez","card_number":"91A-JR","parallel_name":"Red Border","auto_type":"on-card","is_inscribed":false,"inscription_text":null,"is_multi_card_lot":false,"is_insert_subset":true,"insert_subset_name":"1991 Topps 35th Anniversary Auto","reject_reason":"insert_subset_no_checklist","confidence":"medium","notes":"card number inferred as 91A-JR from 1991 Anniversary insert pattern"}

Example 9 — High-fraud-risk listing:
INPUT: "2026 Topps Series 1 Roman Anthony RC 1952 Variation Red Ink Auto 5/5"
OUTPUT: {"is_serialized":true,"print_run":5,"edition_num":5,"set_name":"Series 1","player_name":"Roman Anthony","card_number":null,"parallel_name":"1952 Variation Red Ink","auto_type":"on-card","is_inscribed":false,"inscription_text":null,"is_multi_card_lot":false,"is_insert_subset":true,"insert_subset_name":"1952 Variation","reject_reason":"insert_subset_no_checklist","confidence":"medium","notes":"likely SSP variation; pricing in listing should be cross-checked against fraud signals"}

Example 10 — generic auto, no print run:
INPUT: "2026 Topps Series 1 Adley Rutschman Major League Material Auto Red /5"
OUTPUT: {"is_serialized":true,"print_run":5,"edition_num":null,"set_name":"Series 1","player_name":"Adley Rutschman","card_number":"MLMA-AR","parallel_name":"Red","auto_type":"on-card","is_inscribed":false,"inscription_text":null,"is_multi_card_lot":false,"is_insert_subset":true,"insert_subset_name":"Major League Material","reject_reason":"insert_subset_no_checklist","confidence":"medium","notes":null}

Now classify the listing provided in the user message. Return ONLY the JSON object.`;

// ─── Dynamic example injection — learn from admin skip history ───
//
// The crawler runs every 30 min. At the start of each run we pull the most
// recent admin-rejected listings from Supabase and fold them into the system
// prompt as real-world examples. Cache key = full prompt, so within a single
// run every call after the first hits cache. Between runs the prompt changes
// as new skips land — that's a fresh cache write, paid once per run.
//
// We use TTL rather than per-run re-fetch so the Netlify on-demand classifier
// (and backfill script) also benefit without an explicit init call.
const EXAMPLES_TTL_MS      = 5 * 60 * 1000; // 5 min — matches Haiku ephemeral cache
const SKIPPED_EXAMPLE_LIMIT = 15;

let _cachedPrompt   = null;
let _examplesLoaded = 0;

// Map admin skip_reason → classifier reject_reason. Keep this in sync with
// the enum in OUTPUT_SCHEMA above. Not every skip maps to a reject — some
// are "valid listing, admin just couldn't confirm".
const SKIP_TO_REJECT_MAP = `
- skip_reason "not_a_5"                 → reject_reason "not_serialized"
- skip_reason "multi_card_lot"          → reject_reason "multi_card_lot"
- skip_reason "insert_not_in_checklist" → reject_reason "insert_subset_no_checklist"
- skip_reason "cant_id_copy"            → reject_reason "none" (valid /5, admin couldn't ID copy — still extract everything)
- skip_reason "suspected_fraud"         → reject_reason "none" + note fraud signals (admin reviews manually)
- skip_reason "poor_photos"             → reject_reason "none" (valid, admin needs better pics)
- skip_reason "other"                   → judgment call based on admin_note
`.trim();

async function fetchSkippedExamples() {
  if (!SB_URL || !SB_SERVICE) return [];
  const url = `${SB_URL}/rest/v1/iso_serial_queue` +
    `?status=eq.skipped` +
    `&skip_reason=not.is.null` +
    `&title=not.is.null` +
    `&select=title,skip_reason,admin_notes,set_name_guess` +
    `&order=tagged_at.desc.nullslast` +
    `&limit=${SKIPPED_EXAMPLE_LIMIT}`;
  try {
    const res = await fetch(url, {
      headers: { apikey: SB_SERVICE, Authorization: `Bearer ${SB_SERVICE}` },
    });
    if (!res.ok) return [];
    const rows = await res.json();
    return Array.isArray(rows) ? rows : [];
  } catch (_) {
    return [];
  }
}

// Phase 2: recent admin corrections → injected as "ADMIN CORRECTION" examples
// so the classifier learns what admin actually picks for each kind of listing.
const CORRECTIONS_LIMIT = 15;
async function fetchCorrectionExamples() {
  if (!SB_URL || !SB_SERVICE) return [];
  const url = `${SB_URL}/rest/v1/iso_serial_ai_corrections`
    + `?fields_changed=gt.0`              // only rows where admin actually fixed something
    + `&listing_title=not.is.null`
    + `&select=listing_title,set_name_guess,ai_snapshot,admin_snapshot,diff`
    + `&order=created_at.desc`
    + `&limit=${CORRECTIONS_LIMIT}`;
  try {
    const res = await fetch(url, {
      headers: { apikey: SB_SERVICE, Authorization: `Bearer ${SB_SERVICE}` },
    });
    if (!res.ok) return [];
    const rows = await res.json();
    return Array.isArray(rows) ? rows : [];
  } catch (_) {
    return [];
  }
}

function formatExamplesBlock(rows) {
  if (!rows || rows.length === 0) return '';
  const lines = rows.map((r, i) => {
    const title = (r.title || '').replace(/\s+/g, ' ').trim().slice(0, 200);
    const setHint = r.set_name_guess || 'unknown';
    const note = (r.admin_notes || '').replace(/\s+/g, ' ').trim().slice(0, 200);
    return `${i + 1}. TITLE: "${title}"\n   SET HINT: ${setHint}\n   SKIP REASON: ${r.skip_reason}${note ? `\n   ADMIN NOTE: "${note}"` : ''}`;
  }).join('\n\n');

  return `\n\n# LEARN FROM RECENT ADMIN REJECTIONS

Below are ${rows.length} real listings that the admin personally rejected from the review queue in the last crawler runs. Study them. When a new listing resembles these patterns, apply the matching reject_reason. Mapping:

${SKIP_TO_REJECT_MAP}

ADMIN-REJECTED LISTINGS:

${lines}

End of admin-rejected examples. Apply these patterns to the listing you classify next.`;
}

// Format admin corrections as "the model said X, admin changed it to Y" examples.
// Strongest teaching signal — shows exact admin preference for real seller wording.
function formatCorrectionsBlock(rows){
  if (!rows || rows.length === 0) return '';
  const entries = rows.map((r, i) => {
    const title = (r.listing_title || '').replace(/\s+/g,' ').trim().slice(0,200);
    const diff = r.diff || {};
    const fixes = Object.entries(diff)
      .filter(([k]) => !k.startsWith('_') && k !== 'edition_num') // skip internal + admin-fill-ins
      .slice(0, 6)  // keep compact
      .map(([k, v]) => `       ${k}: "${v.before || '(empty)'}" → "${v.after || '(empty)'}"`)
      .join('\n');
    if (!fixes) return null;
    return `${i + 1}. TITLE: "${title}"\n   SET: ${r.set_name_guess || 'unknown'}\n   ADMIN CORRECTED:\n${fixes}`;
  }).filter(Boolean);
  if (entries.length === 0) return '';
  return `\n\n# LEARN FROM ADMIN CORRECTIONS

Below are ${entries.length} recent cases where YOUR earlier classification was wrong and the
admin fixed specific fields. Study the before/after — the "after" column is the correct answer
for that kind of listing. Apply the same correction rule when you see similar titles again.

${entries.join('\n\n')}

End of admin corrections.`;
}

async function getSystemPrompt() {
  const fresh = _cachedPrompt && (Date.now() - _examplesLoaded) < EXAMPLES_TTL_MS;
  if (fresh) return _cachedPrompt;

  const [skippedRows, correctionRows] = await Promise.all([
    fetchSkippedExamples(),
    fetchCorrectionExamples(),
  ]);
  _cachedPrompt = BASE_SYSTEM_PROMPT
    + formatExamplesBlock(skippedRows)
    + formatCorrectionsBlock(correctionRows);
  _examplesLoaded = Date.now();
  if (skippedRows.length > 0 || correctionRows.length > 0) {
    console.log(`  AI classifier: loaded ${skippedRows.length} skipped + ${correctionRows.length} correction examples into prompt`);
  }
  return _cachedPrompt;
}

// ─── Main classify function ──────────────────────────────────────
async function classifyListing({ title, description, setHint }) {
  if (!process.env.ANTHROPIC_API_KEY) {
    return null;
  }

  const systemPrompt = await getSystemPrompt();

  const userText = `Set hint from eBay search: ${setHint || 'unknown'}

Listing title: ${title || '(no title)'}

Listing description: ${(description || '(none)').slice(0, 1500)}

Return ONLY the JSON object.`;

  try {
    const response = await client.messages.create({
      model: MODEL,
      max_tokens: 1000,
      system: [
        { type: 'text', text: systemPrompt, cache_control: { type: 'ephemeral' } },
      ],
      messages: [
        { role: 'user', content: userText },
      ],
      // Relying on system-prompt instructions to produce strict JSON.
      // output_config.format with json_schema rejects in the current API;
      // Haiku 4.5 is reliable at "return ONLY JSON" when instructed.
    });

    // Parse the JSON output
    const block = response.content.find(b => b.type === 'text');
    if (!block) return null;
    let jsonText = block.text.trim();
    // Strip code fences if Haiku wrapped them despite instructions
    jsonText = jsonText.replace(/^```(?:json)?\s*/i, '').replace(/```\s*$/i, '').trim();

    let parsed;
    try {
      parsed = JSON.parse(jsonText);
    } catch (e) {
      console.warn(`  AI classify: JSON parse failed (${e.message}); raw=${jsonText.slice(0, 200)}`);
      return null;
    }

    // Attach token usage for monitoring
    parsed._usage = {
      input_tokens: response.usage?.input_tokens,
      output_tokens: response.usage?.output_tokens,
      cache_creation_input_tokens: response.usage?.cache_creation_input_tokens,
      cache_read_input_tokens: response.usage?.cache_read_input_tokens,
    };
    parsed._model = MODEL;
    parsed._classified_at = new Date().toISOString();

    return parsed;
  } catch (e) {
    if (e instanceof Anthropic.RateLimitError) {
      console.warn(`  AI classify: rate limited`);
    } else if (e instanceof Anthropic.APIError) {
      console.warn(`  AI classify: API error ${e.status}: ${e.message}`);
    } else {
      console.warn(`  AI classify: ${e.message}`);
    }
    return null;
  }
}

module.exports = { classifyListing };
