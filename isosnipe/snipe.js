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
};

// ─── TARGET CARDS BY SPECIFIC CARD + PARALLEL ───────────
// marketAvg = rough comp for that specific card version
const TARGETS = [
  // ── KEN GRIFFEY JR ──
  { player:'Ken Griffey Jr', card:'1989 Upper Deck #1 Rookie', parallel:'Base', marketAvg:45,
    correct:['1989 Upper Deck Ken Griffey Jr rookie #1','Griffey Jr 1989 UD rookie'],
    misspellings:['1989 upper deck ken griffy jr','Griffy Jr 1989 rookie','Ken Griffee Jr upper deck 1989','1989 UD Griffey rooky','Griffey Jr upperdeck rookie'] },
  { player:'Ken Griffey Jr', card:'1989 Topps Traded #41T', parallel:'Base', marketAvg:20,
    correct:['1989 Topps Traded Griffey Jr 41T','Griffey Jr Topps Traded rookie'],
    misspellings:['1989 topps traded griffy jr','Griffey topps tradded 41T','Ken Griffy topps traded','Griffey 1989 tops traded'] },
  { player:'Ken Griffey Jr', card:'Refractor (any year)', parallel:'Refractor', marketAvg:65,
    correct:['Ken Griffey Jr refractor','Griffey Jr Chrome refractor'],
    misspellings:['Ken Griffey Jr refactor','Griffey refacter','Griffey chrome refactor','Griffey refracter','Ken Griffy refractor','Griffey Jr crome refractor'] },
  { player:'Ken Griffey Jr', card:'Auto (any)', parallel:'Autograph', marketAvg:85,
    correct:['Ken Griffey Jr auto','Ken Griffey Jr autograph card'],
    misspellings:['Ken Griffey Jr autogragh','Griffey autogaph','Griffey Jr auot card','Ken Griffy auto','Griffey autographed baseball card','Griffey signatured card'] },
  { player:'Ken Griffey Jr', card:'Numbered Parallel (any)', parallel:'Numbered', marketAvg:55,
    correct:['Ken Griffey Jr numbered','Griffey Jr /99','Griffey Jr serial numbered'],
    misspellings:['Ken Griffey Jr numberd','Griffey paralel numbered','Griffey Jr /99 paralell','Griffey numbred card','Griffy Jr numbered'] },

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
  { player:'Ichiro Suzuki', card:'Refractor (any)', parallel:'Refractor', marketAvg:80,
    correct:['Ichiro refractor','Ichiro Suzuki Chrome refractor'],
    misspellings:['Ichiro refactor','Ichiro refracter','Ichiro crome refractor','Ichero refractor','Ichiro Suzki refractor'] },
  { player:'Ichiro Suzuki', card:'Auto (any)', parallel:'Autograph', marketAvg:90,
    correct:['Ichiro Suzuki auto','Ichiro autograph card'],
    misspellings:['Ichiro autogragh','Ichiro Suzuki auot','Ichero auto card','Ichiro signatured','Ichiro Suzki autograph'] },

  // ── SHOHEI OHTANI ──
  { player:'Shohei Ohtani', card:'2018 Topps Update RC', parallel:'Base', marketAvg:30,
    correct:['2018 Topps Update Ohtani rookie','Ohtani 2018 Topps RC'],
    misspellings:['2018 topps update otani rookie','Ohtani 2018 tops update','Shoehei Ohtani 2018 topps','2018 topps ohtni rookie','Shohei Otahni 2018 topps'] },
  { player:'Shohei Ohtani', card:'2018 Topps Chrome RC', parallel:'Base', marketAvg:45,
    correct:['2018 Topps Chrome Ohtani rookie','Ohtani Chrome RC 2018'],
    misspellings:['2018 topps crome ohtani','Otani 2018 chrome rookie','Ohtani 2018 tops crome','Shoehei Ohtani chrome 2018','2018 topps crome otahni'] },
  { player:'Shohei Ohtani', card:'Refractor (any)', parallel:'Refractor', marketAvg:75,
    correct:['Ohtani refractor','Shohei Ohtani Chrome refractor'],
    misspellings:['Ohtani refactor','Ohtani refracter','Otani refractor','Ohtani crome refractor','Shoehei Ohtani refractor','Ohtani refactor chrome'] },
  { player:'Shohei Ohtani', card:'Auto (any)', parallel:'Autograph', marketAvg:95,
    correct:['Shohei Ohtani auto','Ohtani autograph card'],
    misspellings:['Ohtani autogragh','Shohei Otani auto','Ohtani auot card','Ohtani signatured','Shoehei Ohtani autograph','Otahni auto card'] },
  { player:'Shohei Ohtani', card:'Numbered Parallel (any)', parallel:'Numbered', marketAvg:60,
    correct:['Ohtani numbered','Shohei Ohtani /99','Ohtani serial numbered'],
    misspellings:['Ohtani numberd','Ohtani paralel numbered','Otani numbered card','Ohtani numbred','Shoehei Ohtani numbered'] },
  { player:'Shohei Ohtani', card:'Insert (any)', parallel:'Insert', marketAvg:25,
    correct:['Ohtani insert card','Shohei Ohtani Topps insert'],
    misspellings:['Ohtani insurt card','Otani insert','Ohtani topps insrt','Ohtani speical insert'] },

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
  { player:'Sal Stewart', card:'Auto (any)', parallel:'Autograph', marketAvg:65,
    correct:['Sal Stewart auto','Sal Stewart autograph'],
    misspellings:['Sal Stewart autogragh','Sal Stuart auto','Sal Steward autograph','Sal Stewart auot','Sal Stewert auto card'] },

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
  { player:'Daniel Susac', card:'Auto (any)', parallel:'Autograph', marketAvg:55,
    correct:['Daniel Susac auto','Daniel Susac autograph'],
    misspellings:['Daniel Susac autogragh','Susac auot card','Danial Susac auto','Daniel Susak autograph','Sussac auto card'] },
];

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
function processResults(items, target, isMisspelling) {
  const hits = [];
  for (const item of items) {
    const price = parseFloat(item.price?.value || 0);
    if (price < 5) continue;

    const title = item.title || '';
    // Filter junk listings + digital cards
    if (/\b(lot|you pick|your choice|mystery|repack|break|bunt|digital|topps digital|e-pack|nft|virtual card)\b/i.test(title)) continue;

    const isBIN = item.buyingOptions?.includes('FIXED_PRICE');
    const delta = ((target.marketAvg - price) / target.marketAvg) * 100;

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
      image: item.thumbnailImages?.[0]?.imageUrl || item.image?.imageUrl || '',
      condition: item.condition || 'Unknown',
      isMisspelling: isMisspelling,
      searchType: isMisspelling ? 'SNIPE' : 'MARKET',
    });
  }
  return hits;
}

// ─── RATE LIMIT ─────────────────────────────────────────
const sleep = ms => new Promise(r => setTimeout(r, ms));

// ─── MAIN ───────────────────────────────────────────────
async function run() {
  console.log('\n=== ISOsnipe v2.0 ===');
  console.log(`Pulling ALL results $${CONFIG.MIN_BUY}-$${CONFIG.MAX_BUY} — dashboard filters live`);
  console.log(`Targets: ${TARGETS.length} card/parallel combos across ${[...new Set(TARGETS.map(t=>t.player))].length} players\n`);

  let token;
  try { token = await getEbayToken(); console.log('✔ eBay authenticated\n'); }
  catch (e) { console.error('✘', e.message); process.exit(1); }

  const allHits = [];
  let searchCount = 0;

  for (const target of TARGETS) {
    console.log(`── ${target.player} | ${target.card} (${target.parallel}) | Market: $${target.marketAvg} ──`);

    // Correct searches (2 max per target)
    for (const q of target.correct.slice(0, 2)) {
      process.stdout.write(`  [market] "${q.substring(0,50)}..." `);
      const bin = await searchEbay(token, q, 'BIN');
      const auc = await searchEbay(token, q, 'AUCTION');
      const h = processResults([...bin, ...auc], target, false);
      allHits.push(...h);
      searchCount += 2;
      console.log(`(${h.length} hits)`);
      await sleep(400);
    }

    // Misspelling searches (all)
    for (const q of target.misspellings) {
      process.stdout.write(`  [SNIPE] "${q.substring(0,50)}..." `);
      const bin = await searchEbay(token, q, 'BIN');
      const auc = await searchEbay(token, q, 'AUCTION');
      const h = processResults([...bin, ...auc], target, true);
      allHits.push(...h);
      searchCount += 2;
      console.log(`(${h.length} hits)`);
      await sleep(400);
    }
    console.log('');
  }

  // Dedupe by URL
  const seen = new Set();
  const unique = allHits.filter(h => { if (seen.has(h.url)) return false; seen.add(h.url); return true; });
  unique.sort((a, b) => b.delta - a.delta);

  const snipes = unique.filter(h => h.isMisspelling);
  const market = unique.filter(h => !h.isMisspelling);

  console.log(`=== RESULTS ===`);
  console.log(`Searches: ${searchCount} | Total hits: ${unique.length} | Snipes: ${snipes.length} | Market: ${market.length}`);

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
}

run().catch(e => { console.error('Fatal:', e); process.exit(1); });
