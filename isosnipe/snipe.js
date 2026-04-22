/**
 * ISOsnipe v2 — eBay Keyword Arbitrage Engine
 * Per-card/parallel market values, dumps ALL results, dashboard filters live
 *
 * Rules:
 *   Min buy: $15 | Max buy: $98 | Budget cap: $300
 *   Weight: 75% BIN / 25% Auction
 */

require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });
const fs = require('fs');
const path = require('path');

// ─── CONFIG (defaults — dashboard sliders override) ─────
const CONFIG = {
  MIN_BUY: 5,       // pull everything $5+, let dashboard filter
  MAX_BUY: 150,     // pull wide, filter in dashboard
  EBAY_CLIENT_ID: process.env.EBAY_CLIENT_ID,
  EBAY_CLIENT_SECRET: process.env.EBAY_CLIENT_SECRET,
  SUPABASE_URL: process.env.SUPABASE_URL || 'https://jyfaegmnzkarlcximxjo.supabase.co',
  SUPABASE_KEY: process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_KEY,
  DETAIL_CONCURRENCY: 5,        // parallel getItem calls
  MAX_DETAIL_FETCHES: 600,      // safety cap (eBay limit is 5000/day)
};

// ─── TARGET CARDS BY SPECIFIC CARD + PARALLEL ───────────
// TARGETS are loaded from Supabase table `isosnipe_targets` at scan time
// (migrated from the hardcoded list 2026-04-22). Admin manages via the
// "🎯 Targets" panel in admin.html. The const below is kept as a local
// fallback ONLY if Supabase is unreachable at scan start.
// marketAvg = rough comp for that specific card version
const TARGETS_FALLBACK = [
  // ── KEN GRIFFEY JR ──
  { player:'Ken Griffey Jr', card:'1989 Upper Deck #1 Rookie', parallel:'Base', marketAvg:45,
    correct:['1989 Upper Deck Ken Griffey Jr rookie #1','Griffey Jr 1989 UD rookie'],
    misspellings:['1989 upper deck ken griffy jr','Griffy Jr 1989 rookie','Ken Griffee Jr upper deck 1989','1989 UD Griffey rooky','Griffey Jr upperdeck rookie'] },
  { player:'Ken Griffey Jr', card:'1989 Topps Traded #41T', parallel:'Base', marketAvg:20,
    correct:['1989 Topps Traded Griffey Jr 41T','Griffey Jr Topps Traded rookie'],
    misspellings:['1989 topps traded griffy jr','Griffey topps tradded 41T','Ken Griffy topps traded','Griffey 1989 tops traded'] },

  // ── ICHIRO SUZUKI ──
  { player:'Ichiro Suzuki', card:'2001 Topps #726 RC', parallel:'Base', marketAvg:25,
    correct:['2001 Topps Ichiro 726 rookie','Ichiro Suzuki 2001 Topps RC'],
    misspellings:['2001 topps ichero 726','Ichiro Suzki 2001 topps','2001 tops ichiro rookie','Ichiro Susuki topps 726','Ichero Suzuki rookie card'] },
  { player:'Ichiro Suzuki', card:'2001 Topps Chrome Traded #T266', parallel:'Base', marketAvg:55,
    correct:['2001 Topps Chrome Traded Ichiro T266','Ichiro Chrome Traded rookie'],
    misspellings:['2001 topps crome traded ichiro','Ichiro chrome tradded T266','Ichiro topps crome rookie','2001 topps chrome ichero traded','Ichiro Suzki chrome traded'] },
  { player:'Ichiro Suzuki', card:'2001 Bowman Chrome', parallel:'Base', marketAvg:70,
    correct:['2001 Bowman Chrome Ichiro rookie','Ichiro Bowman Chrome RC'],
    misspellings:['2001 bowmen chrome ichiro','Ichiro bowman crome rookie','Ichero bowman chrome','2001 bowmen crome ichiro','Ichiro Suzki bowman chrome'] },

  // ── SHOHEI OHTANI ──
  { player:'Shohei Ohtani', card:'2018 Topps Update RC', parallel:'Base', marketAvg:30,
    correct:['2018 Topps Update Ohtani rookie','Ohtani 2018 Topps RC'],
    misspellings:['2018 topps update otani rookie','Ohtani 2018 tops update','Shoehei Ohtani 2018 topps','2018 topps ohtni rookie','Shohei Otahni 2018 topps'] },
  { player:'Shohei Ohtani', card:'2018 Topps Chrome RC', parallel:'Base', marketAvg:45,
    correct:['2018 Topps Chrome Ohtani rookie','Ohtani Chrome RC 2018'],
    misspellings:['2018 topps crome ohtani','Otani 2018 chrome rookie','Ohtani 2018 tops crome','Shoehei Ohtani chrome 2018','2018 topps crome otahni'] },

  // ── SAL STEWART ──
  { player:'Sal Stewart', card:'1st Bowman', parallel:'Base', marketAvg:18,
    correct:['Sal Stewart 1st Bowman','Sal Stewart Bowman 1st'],
    misspellings:['Sal Stuart 1st bowman','Sal Steward bowman','Sal Stewart 1st bowmen','Sal Stewert bowman','Sal Stuart 1st bowmen'] },
  { player:'Sal Stewart', card:'1st Bowman Chrome', parallel:'Chrome', marketAvg:30,
    correct:['Sal Stewart 1st Bowman Chrome','Sal Stewart Bowman Chrome'],
    misspellings:['Sal Stuart bowman chrome','Sal Stewart bowmen crome','Sal Steward 1st bowman chrome','Sal Stewart 1st bowmen crome','Sal Stewert chrome'] },
  { player:'Sal Stewart', card:'Bowman Refractor', parallel:'Refractor', marketAvg:50,
    correct:['Sal Stewart Bowman refractor','Sal Stewart 1st Bowman refractor'],
    misspellings:['Sal Stewart refactor','Sal Stuart refractor','Sal Steward refractor','Sal Stewart bowmen refactor','Sal Stewart refracter'] },

  // ── DANIEL SUSAC ──
  { player:'Daniel Susac', card:'1st Bowman', parallel:'Base', marketAvg:15,
    correct:['Daniel Susac 1st Bowman','Daniel Susac Bowman'],
    misspellings:['Daniel Susak bowman','Daniel Sussac 1st bowman','Danial Susac bowman','Daniel Susac 1st bowmen','Susac bowmen 1st'] },
  { player:'Daniel Susac', card:'1st Bowman Chrome', parallel:'Chrome', marketAvg:25,
    correct:['Daniel Susac 1st Bowman Chrome','Daniel Susac Bowman Chrome'],
    misspellings:['Daniel Susak bowman chrome','Daniel Sussac chrome','Danial Susac bowman crome','Daniel Susac bowmen crome','Susac 1st bowmen chrome'] },
  { player:'Daniel Susac', card:'Bowman Refractor', parallel:'Refractor', marketAvg:45,
    correct:['Daniel Susac refractor','Susac Bowman refractor'],
    misspellings:['Daniel Susac refactor','Susac refracter','Daniel Susak refractor','Danial Susac refractor','Sussac refactor'] },

  // ── MOISÉS BALLESTEROS ──
  { player:'Moises Ballesteros', card:'1st Bowman', parallel:'Base', marketAvg:12,
    correct:['Moises Ballesteros 1st Bowman','Ballesteros Bowman 1st'],
    misspellings:['Moises Balesteros bowman','Ballesteros 1st bowmen','Moses Ballesteros bowman','Moises Bayesteros 1st','Balesteros bowman chrome'] },
  { player:'Moises Ballesteros', card:'1st Bowman Chrome', parallel:'Chrome', marketAvg:22,
    correct:['Moises Ballesteros Bowman Chrome','Ballesteros 1st Chrome'],
    misspellings:['Ballesteros bowman crome','Moises Balesteros chrome','Moses Ballesteros crome','Ballesteros bowmen chrome'] },

  // ── GEORGE VALERA ──
  { player:'George Valera', card:'1st Bowman', parallel:'Base', marketAvg:10,
    correct:['George Valera 1st Bowman','Valera Bowman 1st'],
    misspellings:['George Valera bowmen','Georg Valera bowman','George Valerra bowman','Valera 1st bowmen'] },
  { player:'George Valera', card:'1st Bowman Chrome', parallel:'Chrome', marketAvg:18,
    correct:['George Valera Bowman Chrome','Valera 1st Chrome'],
    misspellings:['Valera bowman crome','George Valerra chrome','Georg Valera crome','Valera bowmen chrome'] },

  // ── KEVIN MCGONIGLE ──
  { player:'Kevin McGonigle', card:'1st Bowman', parallel:'Base', marketAvg:8,
    correct:['Kevin McGonigle 1st Bowman','McGonigle Bowman 1st'],
    misspellings:['Kevin McGonigle bowmen','McGonigal bowman','Kevin McGoniggal bowman','McGongle 1st bowman'] },
  { player:'Kevin McGonigle', card:'1st Bowman Chrome', parallel:'Chrome', marketAvg:15,
    correct:['Kevin McGonigle Bowman Chrome','McGonigle Chrome 1st'],
    misspellings:['McGonigle bowman crome','Kevin McGonigal chrome','McGoniggal bowman crome','McGongle chrome'] },

  // ── CHASE DELAUTER ──
  { player:'Chase DeLauter', card:'1st Bowman', parallel:'Base', marketAvg:15,
    correct:['Chase DeLauter 1st Bowman','DeLauter Bowman 1st'],
    misspellings:['Chase Delauter bowmen','Chase De Lauter bowman','Chase DeLaughter bowman','Delauter 1st bowmen','Chase Delaughter bowman'] },
  { player:'Chase DeLauter', card:'1st Bowman Chrome', parallel:'Chrome', marketAvg:28,
    correct:['Chase DeLauter Bowman Chrome','DeLauter Chrome 1st'],
    misspellings:['DeLauter bowman crome','Chase Delauter crome','De Lauter bowman chrome','DeLaughter crome'] },

  // ── JJ WETHERHOLT ──
  { player:'JJ Wetherholt', card:'1st Bowman', parallel:'Base', marketAvg:25,
    correct:['JJ Wetherholt 1st Bowman','Wetherholt Bowman 1st'],
    misspellings:['JJ Wetherholt bowmen','JJ Weatherholt bowman','Wetherholt 1st bowmen','JJ Wetherhold bowman','JJ Wetherhalt bowman'] },
  { player:'JJ Wetherholt', card:'1st Bowman Chrome', parallel:'Chrome', marketAvg:45,
    correct:['JJ Wetherholt Bowman Chrome','Wetherholt Chrome 1st'],
    misspellings:['Wetherholt bowman crome','JJ Weatherholt chrome','Wetherhold crome','JJ Wetherhalt bowman chrome'] },

  // ── JUSTIN CRAWFORD ──
  { player:'Justin Crawford', card:'1st Bowman', parallel:'Base', marketAvg:12,
    correct:['Justin Crawford 1st Bowman','Crawford Bowman 1st'],
    misspellings:['Justin Crawfrod bowman','Justin Crowford bowman','Crawford bowmen 1st','Justin Craford bowman'] },
  { player:'Justin Crawford', card:'1st Bowman Chrome', parallel:'Chrome', marketAvg:22,
    correct:['Justin Crawford Bowman Chrome','Crawford Chrome 1st'],
    misspellings:['Crawford bowman crome','Justin Crawfrod chrome','Crowford crome','Justin Craford chrome'] },

  // ── TANNER MURRAY ──
  { player:'Tanner Murray', card:'1st Bowman', parallel:'Base', marketAvg:8,
    correct:['Tanner Murray 1st Bowman','Murray Bowman 1st'],
    misspellings:['Tanner Murry bowman','Tanner Murray bowmen','Taner Murray bowman','Murray 1st bowmen'] },
];

// ─── LOAD TARGETS FROM SUPABASE ─────────────────────────
// Pulled at scan start from isosnipe_targets (is_active=true). Falls back to
// the hardcoded TARGETS_FALLBACK only if the DB call fails or returns zero rows,
// so we never run a scan with no targets.
async function loadTargets() {
  if (!CONFIG.SUPABASE_KEY) {
    console.log('  [warn] No SUPABASE_KEY — using hardcoded fallback targets');
    return TARGETS_FALLBACK;
  }
  try {
    const url = `${CONFIG.SUPABASE_URL}/rest/v1/isosnipe_targets?is_active=eq.true&select=id,player,card,parallel,market_avg,correct_searches,misspellings`;
    const res = await fetch(url, {
      headers: { 'apikey': CONFIG.SUPABASE_KEY, 'Authorization': `Bearer ${CONFIG.SUPABASE_KEY}` },
    });
    if (!res.ok) {
      console.log(`  [warn] Targets fetch ${res.status} — using hardcoded fallback`);
      return TARGETS_FALLBACK;
    }
    const rows = await res.json();
    if (!rows || rows.length === 0) {
      console.log('  [warn] Targets table empty — using hardcoded fallback');
      return TARGETS_FALLBACK;
    }
    return rows.map(r => ({
      _id: r.id,
      player: r.player,
      card: r.card,
      parallel: r.parallel || 'Base',
      marketAvg: parseFloat(r.market_avg),
      correct: Array.isArray(r.correct_searches) ? r.correct_searches : [],
      misspellings: Array.isArray(r.misspellings) ? r.misspellings : [],
    }));
  } catch (e) {
    console.log(`  [warn] Targets fetch failed: ${e.message} — using hardcoded fallback`);
    return TARGETS_FALLBACK;
  }
}

async function stampLastScanned(targetIds) {
  if (!CONFIG.SUPABASE_KEY || !targetIds.length) return;
  try {
    await fetch(`${CONFIG.SUPABASE_URL}/rest/v1/isosnipe_targets?id=in.(${targetIds.join(',')})`, {
      method: 'PATCH',
      headers: {
        'apikey': CONFIG.SUPABASE_KEY,
        'Authorization': `Bearer ${CONFIG.SUPABASE_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ last_scanned_at: new Date().toISOString() }),
    });
  } catch (_) { /* non-fatal */ }
}

// ─── EBAY AUTH ──────────────────────────────────────────
async function getEbayToken() {
  const credentials = Buffer.from(`${CONFIG.EBAY_CLIENT_ID}:${CONFIG.EBAY_CLIENT_SECRET}`).toString('base64');
  const res = await fetch('https://api.ebay.com/identity/v1/oauth2/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'Authorization': `Basic ${credentials}` },
    body: 'grant_type=client_credentials&scope=https%3A%2F%2Fapi.ebay.com%2Foauth%2Fapi_scope',
  });
  if (!res.ok) throw new Error(`eBay auth failed (${res.status}): ${await res.text()}`);
  return (await res.json()).access_token;
}

// ─── EBAY SEARCH ────────────────────────────────────────
async function searchEbay(token, query, buyingFormat) {
  const filter = [
    `price:[${CONFIG.MIN_BUY}..${CONFIG.MAX_BUY}]`,
    'priceCurrency:USD',
    buyingFormat === 'BIN' ? 'buyingOptions:{FIXED_PRICE}' : 'buyingOptions:{AUCTION}',
    'deliveryCountry:US',
  ].join(',');

  const params = new URLSearchParams({ q: query, category_ids: '261328', filter, sort: 'price', limit: '50' });
  const res = await fetch(`https://api.ebay.com/buy/browse/v1/item_summary/search?${params}`, {
    headers: { 'Authorization': `Bearer ${token}`, 'X-EBAY-C-MARKETPLACE-ID': 'EBAY_US' },
  });

  if (!res.ok) {
    if (res.status === 429 || res.status === 204) return [];
    return [];
  }
  return (await res.json()).itemSummaries || [];
}

// ─── PROCESS RESULTS ────────────────────────────────────
// rejectedIds: Set<string> of bare numeric eBay item#s to skip at candidate build.
// Rejected items never enter the candidate pool, so they never hit _snData,
// never get sent to getItem, and never land in the output JSON.
function processResults(items, target, isMisspelling, rejectedIds) {
  const hits = [];
  for (const item of items) {
    const price = parseFloat(item.price?.value || 0);
    if (price < 5) continue;

    const title = item.title || '';
    // Filter junk listings + digital cards + fake/custom cards
    if (/\b(lot|you pick|your choice|mystery|repack|break|bunt|digital|topps digital|e-pack|nft|virtual card)\b/i.test(title)) continue;
    const tLow = title.toLowerCase();
    const JUNK = ['custom','reprint','facsimile','novelty','fantasy card','art card','aceo','tc card',
      'unofficial','not real','fan made','fanmade','homemade','gag gift','limited edit','replica',
      'counterfeit','bootleg','custom blast','art print','fan art','proxy','karat','gold plated',
      'gold foil signature','gold signature series','sketch card','keychain','mix n match','novelty card',
      // Known facsimile/promo producers — always printed signatures, never real autos
      'authentic images','merrick mint','calbee','jimmy dean','sunflower seeds','jumbo gold',
      'sportflics','sport flick','24k gold','23kt gold','22k gold','24kt','23k gold','25kt',
      'skybox autographics','skybox autographic','leaf exhibits','gold edition signature','signature card guard',
      'donruss signature','1994 signature rookies','authentic image'];
    if (JUNK.some(j => tLow.includes(j))) continue;

    // Early rejection block — check item# before building the hit object.
    // Any card you rejected never enters the candidate pool, never hits the
    // output JSON, never gets sent to getItem. Saves API quota + AI tokens.
    const _earlyId = item.legacyItemId || (item.itemId && String(item.itemId).split('|')[1]) || null;
    if (_earlyId && rejectedIds && rejectedIds.has(String(_earlyId))) continue;

    const isBIN = item.buyingOptions?.includes('FIXED_PRICE');
    const delta = ((target.marketAvg - price) / target.marketAvg) * 100;

    // Capture stable eBay item id (legacy = pure numeric "12345…")
    const legacyId = item.legacyItemId
      || (item.itemId && String(item.itemId).split('|')[1])
      || null;

    hits.push({
      player: target.player,
      card: target.card,
      parallel: target.parallel,
      title: title,
      price: price,
      marketAvg: target.marketAvg,
      delta: parseFloat(delta.toFixed(1)),
      type: isBIN ? 'BIN' : 'AUCTION',
      url: item.itemWebUrl,
      itemId: legacyId,                   // bare numeric — used as block key
      itemIdRaw: item.itemId || null,     // full "v1|123|0" form for getItem call
      image: item.thumbnailImages?.[0]?.imageUrl || item.image?.imageUrl || '',
      condition: item.condition || 'Unknown',
      seller: item.seller?.username || null,
      isMisspelling: isMisspelling,
      searchType: isMisspelling ? 'SNIPE' : 'MARKET',
      // Filled in step 5 (detail fetch)
      shortDescription: null,
      description: null,
      itemSpecifics: null,
    });
  }
  return hits;
}

// ─── RATE LIMIT ─────────────────────────────────────────
const sleep = ms => new Promise(r => setTimeout(r, ms));

// ─── REJECTED ITEM# BLOCKLIST (Supabase) ────────────────
async function fetchRejectedItemIds() {
  if (!CONFIG.SUPABASE_KEY) {
    console.log('  [skip] No SUPABASE key — rejection blocklist not loaded');
    return new Set();
  }
  try {
    const url = `${CONFIG.SUPABASE_URL}/rest/v1/isosnipe_rejections?select=ebay_item_id`;
    const res = await fetch(url, {
      headers: {
        'apikey': CONFIG.SUPABASE_KEY,
        'Authorization': `Bearer ${CONFIG.SUPABASE_KEY}`,
      },
    });
    if (!res.ok) {
      console.log(`  [warn] Rejection fetch ${res.status} — skipping blocklist`);
      return new Set();
    }
    const rows = await res.json();
    return new Set(rows.map(r => String(r.ebay_item_id)));
  } catch (e) {
    console.log(`  [warn] Rejection fetch failed: ${e.message}`);
    return new Set();
  }
}

// ─── EBAY GET ITEM (full description + item specifics) ──
async function getItemDetails(token, itemIdRaw) {
  if (!itemIdRaw) return null;
  // eBay expects URL-encoded itemId; itemId already includes "v1|123|0"
  const url = `https://api.ebay.com/buy/browse/v1/item/${encodeURIComponent(itemIdRaw)}`;
  try {
    const res = await fetch(url, {
      headers: { 'Authorization': `Bearer ${token}`, 'X-EBAY-C-MARKETPLACE-ID': 'EBAY_US' },
    });
    if (!res.ok) return null;
    const d = await res.json();
    // Strip HTML tags from description and clamp to 4k chars to keep JSON small
    const stripHtml = s => (s || '').replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim().slice(0, 4000);
    const aspects = {};
    (d.localizedAspects || []).forEach(a => {
      if (a.name && a.value) aspects[a.name] = a.value;
    });
    return {
      shortDescription: d.shortDescription || null,
      description: stripHtml(d.description),
      itemSpecifics: aspects,
    };
  } catch (e) {
    return null;
  }
}

// ─── PARALLEL DETAIL FETCH ──────────────────────────────
async function fetchAllDetails(token, hits, concurrency) {
  let done = 0;
  let i = 0;
  async function worker() {
    while (i < hits.length) {
      const idx = i++;
      const h = hits[idx];
      const det = await getItemDetails(token, h.itemIdRaw);
      if (det) {
        h.shortDescription = det.shortDescription;
        h.description = det.description;
        h.itemSpecifics = det.itemSpecifics;
      }
      done++;
      if (done % 25 === 0) process.stdout.write(`  [details] ${done}/${hits.length}\n`);
      // small delay so we don't hammer eBay
      await sleep(120);
    }
  }
  await Promise.all(Array.from({ length: concurrency }, worker));
  console.log(`  [details] ${done}/${hits.length} ✔`);
}

// ─── MAIN ───────────────────────────────────────────────
async function run() {
  console.log('\n=== ISOsnipe v2.0 ===');
  console.log(`Pulling ALL results $${CONFIG.MIN_BUY}-$${CONFIG.MAX_BUY} — dashboard filters live`);

  console.log('Loading targets from Supabase…');
  const TARGETS = await loadTargets();
  console.log(`Targets: ${TARGETS.length} card/parallel combos across ${[...new Set(TARGETS.map(t=>t.player))].length} players\n`);

  let token;
  try { token = await getEbayToken(); console.log('✔ eBay authenticated\n'); }
  catch (e) { console.error('✘', e.message); process.exit(1); }

  // Pull the rejected item# blocklist BEFORE we start scanning so we can
  // drop hits early and avoid wasting getItem calls on known bad listings.
  console.log('Fetching rejected item# blocklist…');
  const rejectedIds = await fetchRejectedItemIds();
  console.log(`  ${rejectedIds.size} item#s blocked (permanent reject list)\n`);

  const allHits = [];
  let searchCount = 0;

  for (const target of TARGETS) {
    // ── STEP 1: Run correct searches to get REAL market average ──
    const marketPrices = [];
    const correctHits = [];
    for (const q of target.correct.slice(0, 2)) {
      process.stdout.write(`  [market] "${q.substring(0,50)}..." `);
      const bin = await searchEbay(token, q, 'BIN');
      const auc = await searchEbay(token, q, 'AUCTION');
      // Collect prices from legitimate listings for market calc
      [...bin, ...auc].forEach(item => {
        const p = parseFloat(item.price?.value || 0);
        const title = (item.title || '').toLowerCase();
        // Also skip rejected item#s from market avg calc — they'd skew the comp.
        const _mid = item.legacyItemId || (item.itemId && String(item.itemId).split('|')[1]) || null;
        if (_mid && rejectedIds.has(String(_mid))) return;
        const JUNK = ['custom','reprint','facsimile','novelty','fantasy card','art card','aceo','tc card',
          'unofficial','not real','fan made','fanmade','homemade','gag gift','limited edit','replica',
          'counterfeit','bootleg','custom blast','art print','fan art','proxy','karat','gold plated',
          'gold foil signature','gold signature series','sketch card','keychain','mix n match','novelty card',
          'authentic images','merrick mint','calbee','jimmy dean','sunflower seeds','jumbo gold',
          'sportflics','sport flick','24k gold','23kt gold','22k gold','24kt','23k gold','25kt',
          'skybox autographics','leaf exhibits','gold edition signature','signature card guard',
          'donruss signature','1994 signature rookies'];
        if (p > 0 && !JUNK.some(j => title.includes(j))) marketPrices.push(p);
      });
      const h = processResults([...bin, ...auc], target, false, rejectedIds);
      correctHits.push(...h);
      searchCount += 2;
      console.log(`(${h.length} hits)`);
      await sleep(400);
    }

    // ── STEP 2: Calculate real market average (trimmed mean) ──
    let realMarketAvg = target.marketAvg; // fallback to hardcoded if no data
    if (marketPrices.length >= 3) {
      marketPrices.sort((a, b) => a - b);
      // Trim top/bottom 20% to remove outliers
      const trim = Math.floor(marketPrices.length * 0.2);
      const trimmed = marketPrices.slice(trim, marketPrices.length - trim);
      if (trimmed.length > 0) {
        realMarketAvg = Math.round((trimmed.reduce((a, b) => a + b, 0) / trimmed.length) * 100) / 100;
      }
    } else if (marketPrices.length > 0) {
      // Too few to trim — just use median
      marketPrices.sort((a, b) => a - b);
      realMarketAvg = marketPrices[Math.floor(marketPrices.length / 2)];
    }

    console.log(`── ${target.player} | ${target.card} (${target.parallel}) | Market: $${realMarketAvg} (was $${target.marketAvg}, ${marketPrices.length} comps) ──`);

    // ── STEP 3: Recalculate correct hit deltas with real market avg ──
    const liveTarget = { ...target, marketAvg: realMarketAvg };
    correctHits.forEach(h => {
      h.marketAvg = realMarketAvg;
      h.delta = parseFloat(((realMarketAvg - h.price) / realMarketAvg * 100).toFixed(1));
    });
    allHits.push(...correctHits);

    // ── STEP 4: Misspelling searches using real market avg ──
    for (const q of target.misspellings) {
      process.stdout.write(`  [SNIPE] "${q.substring(0,50)}..." `);
      const bin = await searchEbay(token, q, 'BIN');
      const auc = await searchEbay(token, q, 'AUCTION');
      const h = processResults([...bin, ...auc], liveTarget, true, rejectedIds);
      allHits.push(...h);
      searchCount += 2;
      console.log(`(${h.length} hits)`);
      await sleep(400);
    }
    console.log('');
  }

  // Dedupe by itemId (preferred) or URL (fallback for items missing itemId)
  const seen = new Set();
  let unique = allHits.filter(h => {
    const key = h.itemId || h.url;
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });

  // (rejected item#s are already dropped at processResults — no need to re-filter)

  // Fetch full description + item specifics for survivors (cap to MAX_DETAIL_FETCHES)
  const detailTargets = unique.slice(0, CONFIG.MAX_DETAIL_FETCHES).filter(h => h.itemIdRaw);
  if (detailTargets.length > 0) {
    console.log(`\nFetching descriptions for ${detailTargets.length} survivors (concurrency ${CONFIG.DETAIL_CONCURRENCY})…`);
    await fetchAllDetails(token, detailTargets, CONFIG.DETAIL_CONCURRENCY);
  }

  unique.sort((a, b) => b.delta - a.delta);

  const snipes = unique.filter(h => h.isMisspelling);
  const market = unique.filter(h => !h.isMisspelling);

  console.log(`\n=== RESULTS ===`);
  console.log(`Searches: ${searchCount} | Total hits: ${unique.length} | Snipes: ${snipes.length} | Market: ${market.length}`);
  console.log(`Detail-enriched: ${detailTargets.length} | Blocked item#s: ${rejectedIds.size}`);

  if (snipes.length > 0) {
    console.log(`\n🔥 TOP 10 SNIPES:`);
    for (const h of snipes.filter(s => s.delta >= 50).slice(0, 10)) {
      console.log(`  $${h.price} (${h.delta}% below $${h.marketAvg}) | ${h.type} | ${h.player} ${h.parallel} | "${h.title.substring(0, 55)}"`);
    }
  }

  // Save raw data for dashboard
  const resultsFile = path.join(__dirname, 'results', `snipe-latest.json`);
  fs.writeFileSync(resultsFile, JSON.stringify({
    timestamp: new Date().toISOString(),
    searchCount,
    targets: TARGETS.map(t => ({ player: t.player, card: t.card, parallel: t.parallel, marketAvg: t.marketAvg })),
    results: unique,
  }, null, 2));

  console.log(`\nData saved: ${resultsFile}`);
  console.log(`Open isosnipe/dashboard.html in Chrome`);

  // Stamp last_scanned_at on the Supabase target rows we actually processed.
  const scannedIds = TARGETS.map(t => t._id).filter(Boolean);
  if (scannedIds.length) await stampLastScanned(scannedIds);
}

run().catch(e => { console.error('Fatal:', e); process.exit(1); });
