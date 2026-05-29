// ============================================================
// GrailISO — Power Rankings Daily Refresh
// netlify/functions/power-rankings-refresh.js
// ============================================================
// Scheduled to run daily at 5am EST (10:00 UTC).
// Fetches all MLB season stats + game logs for yesterday's players,
// calculates ISO Scores, writes to power_rankings_cache in Supabase.
//
// Also callable manually via POST for testing.
// ============================================================

const https = require('https');

// Netlify scheduled function config
exports.config = { schedule: '0 10 * * *' }; // 10:00 UTC = 5:00 AM EST

const MLB = 'https://statsapi.mlb.com/api/v1';
const SB_URL = 'https://jyfaegmnzkarlcximxjo.supabase.co';
const SB_KEY = process.env.SUPABASE_SERVICE_KEY
  || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp5ZmFlZ21uemthcmxjeGlteGpvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMyNzU3MDMsImV4cCI6MjA4ODg1MTcwM30.e6U1TZECRlEV9LkTm9NY6ljIJVRKhajE6VvRaBLlaCA';

// ── HTTP helper ─────────────────────────────────────────────
function httpGet(url) {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let data = '';
      res.on('data', (c) => (data += c));
      res.on('end', () => {
        try { resolve(JSON.parse(data)); } catch (e) { resolve(null); }
      });
    }).on('error', reject);
  });
}

function httpDelete(url, headers) {
  return new Promise((resolve, reject) => {
    const u = new URL(url);
    const req = https.request(u, {
      method: 'DELETE',
      hostname: u.hostname,
      path: u.pathname + u.search,
      headers: { ...headers },
    }, (res) => {
      let data = '';
      res.on('data', (c) => (data += c));
      res.on('end', () => resolve({ statusCode: res.statusCode, body: data }));
    });
    req.on('error', reject);
    req.end();
  });
}

function httpPost(url, body, headers) {
  return new Promise((resolve, reject) => {
    const u = new URL(url);
    const req = https.request(u, {
      method: 'POST',
      hostname: u.hostname,
      path: u.pathname + u.search,
      headers: { ...headers, 'Content-Length': Buffer.byteLength(body) },
    }, (res) => {
      let data = '';
      res.on('data', (c) => (data += c));
      res.on('end', () => resolve({ statusCode: res.statusCode, body: data }));
    });
    req.on('error', reject);
    req.write(body);
    req.end();
  });
}

// ── Team abbreviations ──────────────────────────────────────
const TEAMS = {108:'LAA',109:'AZ',110:'BAL',111:'BOS',112:'CHC',113:'CIN',114:'CLE',115:'COL',116:'DET',117:'HOU',118:'KC',119:'LAD',120:'WAS',121:'NYM',133:'ATH',134:'PIT',135:'SD',136:'SEA',137:'SF',138:'STL',139:'TB',140:'TEX',141:'TOR',142:'MIN',143:'PHI',144:'ATL',145:'CHW',146:'MIA',147:'NYY',158:'MIL'};

// ── Raw production score (pure talent — no price) ───────────
// Superstars/positions rank by this so actual best players rise.
function rawHit(s) {
  const avg = parseFloat(s.avg) || 0, hr = s.homeRuns || 0, rbi = s.rbi || 0;
  const ops = parseFloat(s.ops) || 0, sb = s.stolenBases || 0, gp = s.gamesPlayed || 1;
  const hrPG = hr / gp, rbiPG = rbi / gp, sbPG = sb / gp;
  return (avg * 400) + (ops * 120) + (hrPG * 200) + (rbiPG * 100) + (sbPG * 80);
}
function rawPit(s) {
  // Weights halved from prior version so pitcher raw score lands ~350-500
  // for top performers (same range as rawHit). Previously a good cheap
  // pitcher would blow past the 1000 cap once price factor applied.
  const era = parseFloat(s.era) || 9, whip = parseFloat(s.whip) || 2;
  const k = s.strikeOuts || 0, ip = parseFloat(s.inningsPitched) || 1, w = s.wins || 0;
  const kPer9 = (k / ip) * 9;
  const eraScore = Math.max(0, 250 - (era * 30));
  const whipScore = Math.max(0, 200 - (whip * 75));
  const kScore = Math.min(100, kPer9 * 9);
  const wScore = Math.min(40, w * 8);
  return eraScore + whipScore * 0.6 + kScore + wScore;
}

// ── ISO Score: price-boosted (DISPLAY column on rankings page) ─
function isoHit(s, price) {
  const statScore = rawHit(s);
  const p = Math.max(price || 1, 0.5);
  const priceFactor = Math.min(1.3, 1 + (1 / Math.log2(p + 2)) * 0.5);
  return Math.min(1000, Math.round(statScore * priceFactor));
}
function isoPit(s, price) {
  const statScore = rawPit(s);
  const p = Math.max(price || 1, 0.5);
  const priceFactor = Math.min(1.3, 1 + (1 / Math.log2(p + 2)) * 0.5);
  return Math.min(1000, Math.round(statScore * priceFactor));
}

// ── Value Score ─────────────────────────────────────────────
function valScore(iso, price) {
  if (!price || price <= 0) return Math.round(iso);
  const priceMod = 1 + Math.max(-0.3, Math.min(0.2, (10 - price) / 50));
  return Math.min(1000, Math.round(iso * priceMod));
}

// ── Aggregate last 5 game stats from game log ───────────────
function aggLast5Hitting(games) {
  const last5 = games.slice(-5);
  if (!last5.length) return null;
  let ab = 0, h = 0, hr = 0, rbi = 0, sb = 0, bb = 0;
  last5.forEach(g => {
    const s = g.stat;
    ab += s.atBats || 0; h += s.hits || 0; hr += s.homeRuns || 0;
    rbi += s.rbi || 0; sb += s.stolenBases || 0; bb += s.baseOnBalls || 0;
  });
  const avg = ab > 0 ? (h / ab).toFixed(3) : '.000';
  const obp = (ab + bb) > 0 ? ((h + bb) / (ab + bb)).toFixed(3) : '.000';
  const slg = ab > 0 ? ((h + hr * 3) / ab).toFixed(3) : '.000'; // simplified SLG
  const ops = (parseFloat(obp) + parseFloat(slg)).toFixed(3);
  return { avg, homeRuns: hr, rbi, ops, stolenBases: sb, gamesPlayed: last5.length };
}

function aggLast5Pitching(games) {
  const last5 = games.slice(-5);
  if (!last5.length) return null;
  let ip = 0, er = 0, k = 0, w = 0, l = 0, ha = 0, bb = 0, sv = 0;
  last5.forEach(g => {
    const s = g.stat;
    ip += parseFloat(s.inningsPitched) || 0; er += s.earnedRuns || 0;
    k += s.strikeOuts || 0; w += s.wins || 0; l += s.losses || 0;
    ha += s.hits || 0; bb += s.baseOnBalls || 0; sv += s.saves || 0;
  });
  const era = ip > 0 ? ((er / ip) * 9).toFixed(2) : '0.00';
  const whip = ip > 0 ? ((ha + bb) / ip).toFixed(2) : '0.00';
  return { era, wins: w, losses: l, strikeOuts: k, whip, inningsPitched: ip.toFixed(1), saves: sv, gamesPlayed: last5.length };
}

// ── Get yesterday's date (EST) ──────────────────────────────
function yesterdayEST() {
  const now = new Date();
  // EST = UTC-5
  const est = new Date(now.getTime() - 5 * 60 * 60 * 1000);
  est.setDate(est.getDate() - 1);
  return est.toISOString().slice(0, 10);
}

function todayEST() {
  const now = new Date();
  const est = new Date(now.getTime() - 5 * 60 * 60 * 1000);
  return est.toISOString().slice(0, 10);
}

// ── Fetch previous day's rankings for movement tracking ─────
async function getPrevRanks() {
  try {
    const yesterday = yesterdayEST();
    const url = `${SB_URL}/rest/v1/power_rankings_cache?select=player_id,category,rank_season,rank_last5&data_date=eq.${yesterday}&limit=2000`;
    const res = await httpGet(url.replace('https://', 'https://'));
    // httpGet won't work with Supabase auth headers — use httpPost with GET workaround
    // Actually, let's use a simpler approach
    return {};
  } catch (e) { return {}; }
}

// ── Baseball Reference WAR scrape ───────────────────────────
// BR exposes WAR on their value-batting / value-pitching pages.
// We parse HTML directly (no API). Returns map: normalizedKey → war.
const BR_UA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

function normalizeName(s) {
  if (!s) return '';
  return s.normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase().replace(/[^a-z]/g, '');
}

// BR team code → MLB team abbrev mapping (tiebreaker on name collisions)
const BR_TEAM_TO_MLB = {
  'ARI':'AZ','ATL':'ATL','BAL':'BAL','BOS':'BOS','CHC':'CHC','CHW':'CHW','CIN':'CIN','CLE':'CLE',
  'COL':'COL','DET':'DET','HOU':'HOU','KCR':'KC','LAA':'LAA','LAD':'LAD','MIA':'MIA','MIL':'MIL',
  'MIN':'MIN','NYM':'NYM','NYY':'NYY','OAK':'ATH','ATH':'ATH','PHI':'PHI','PIT':'PIT','SDP':'SD',
  'SEA':'SEA','SFG':'SF','STL':'STL','TBR':'TB','TEX':'TEX','TOR':'TOR','WSN':'WAS',
};

function httpGetText(url) {
  return new Promise((resolve, reject) => {
    const u = new URL(url);
    https.get({
      hostname: u.hostname, path: u.pathname + u.search,
      headers: { 'User-Agent': BR_UA, 'Accept': 'text/html' },
    }, (res) => {
      let data = '';
      res.on('data', (c) => (data += c));
      res.on('end', () => resolve({ status: res.statusCode, body: data }));
    }).on('error', reject);
  });
}

function parseBRWarTable(html, tableId, warField) {
  const tableMatch = html.match(new RegExp('<table[^>]*id="' + tableId + '"[^>]*>([\\s\\S]*?)</table>'));
  if (!tableMatch) return [];
  const tbodyMatch = tableMatch[1].match(/<tbody[^>]*>([\s\S]*?)<\/tbody>/);
  if (!tbodyMatch) return [];
  const rows = [...tbodyMatch[1].matchAll(/<tr[^>]*>([\s\S]*?)<\/tr>/g)];
  const out = [];
  for (const m of rows) {
    const row = m[1];
    const name = row.match(/data-stat="name_display"[^>]*>\s*<a[^>]*>([^<]+)/);
    const team = row.match(/data-stat="team_name_abbr"[^>]*>(?:<a[^>]*>)?([^<]+)/);
    const warCell = row.match(new RegExp('<td[^>]*data-stat="' + warField + '"[^>]*>([\\s\\S]*?)</td>'));
    if (warCell && name) {
      const clean = warCell[1].replace(/<[^>]+>/g, '').trim();
      const w = parseFloat(clean);
      if (!isNaN(w)) {
        out.push({
          name: name[1].trim(),
          team: (team ? team[1].trim() : ''),
          war: w,
        });
      }
    }
  }
  return out;
}

async function fetchBRWar(year) {
  const out = { hitters: [], pitchers: [] };
  try {
    const [bat, pit] = await Promise.all([
      httpGetText('https://www.baseball-reference.com/leagues/majors/' + year + '-value-batting.shtml'),
      httpGetText('https://www.baseball-reference.com/leagues/majors/' + year + '-value-pitching.shtml'),
    ]);
    if (bat.status === 200) {
      out.hitters = parseBRWarTable(bat.body, 'players_value_batting', 'b_war');
      console.log('[PR Refresh] BR bWAR hitters parsed: ' + out.hitters.length);
    } else {
      console.warn('[PR Refresh] BR bWAR hitters HTTP ' + bat.status);
    }
    if (pit.status === 200) {
      out.pitchers = parseBRWarTable(pit.body, 'players_value_pitching', 'p_war');
      console.log('[PR Refresh] BR bWAR pitchers parsed: ' + out.pitchers.length);
    } else {
      console.warn('[PR Refresh] BR bWAR pitchers HTTP ' + pit.status);
    }
  } catch (e) {
    console.warn('[PR Refresh] BR WAR fetch failed (non-fatal):', e.message);
  }
  return out;
}

function buildWarLookup(brRows) {
  const map = {};
  for (const r of brRows) {
    const mlbTm = BR_TEAM_TO_MLB[r.team] || r.team;
    const key = normalizeName(r.name) + '|' + mlbTm;
    if (!(key in map) || map[key] < r.war) map[key] = r.war;
    const nameOnly = normalizeName(r.name);
    if (!(nameOnly in map) || map[nameOnly] < r.war) map[nameOnly] = r.war;
  }
  return map;
}

function warFor(split, lookup) {
  if (!split || !split.player) return null;
  const tm = TEAMS[split.team && split.team.id] || '';
  const k1 = normalizeName(split.player.fullName) + '|' + tm;
  if (k1 in lookup) return lookup[k1];
  const k2 = normalizeName(split.player.fullName);
  if (k2 in lookup) return lookup[k2];
  return null;
}

// ── Composite score: WAR + in-season production + card-price discount ──
// "Power Players" formula per Scott — three EQUAL components, each 0-500:
//   WAR:   bWAR × 100, capped 500 (5.0 WAR maxes)
//   STATS: rawHit / rawPit, capped 500
//   PRICE: max(0, 500 - price × 10) — $0 = 500, $25 = 250, $50+ = 0
// Sum them: total 0-1500. Equal weight means a player must be high on
// ALL THREE to top the list (great talent + producing now + cheap card).
// Missing price treated as $20 (neutral median) so unmatched-eBay players
// neither win nor lose by default. Missing WAR treated as 0 so newcomers
// don't get a free pass.
function combinedScore(war, rawStat, price) {
  const warPts = Math.min(500, Math.max(0, (war || 0) * 100));
  const statPts = Math.min(500, Math.max(0, rawStat || 0));
  const p = (price == null || price <= 0) ? 20 : price;
  const pricePts = Math.max(0, Math.min(500, 500 - p * 10));
  return Math.round(warPts + statPts + pricePts);
}

// ── Fake/junk card filter ────────────────────────────────────
const JUNK_TERMS = [
  'custom', 'reprint', 'facsimile', 'novelty', 'fantasy card',
  'art card', 'aceo', 'tc card', 'unofficial', 'not real',
  'fan made', 'fanmade', 'homemade', 'home made', 'gag gift',
  'limited edit', 'replica', 'counterfeit', 'bootleg',
  'custom blast', 'art print', 'fan art', 'proxy',
];
function isJunkListing(title) {
  if (!title) return false;
  const t = title.toLowerCase();
  return JUNK_TERMS.some(term => t.includes(term));
}

// ── eBay pricing helpers ────────────────────────────────────
const EBAY_AUTH_URL = 'https://api.ebay.com/identity/v1/oauth2/token';
const EBAY_BROWSE_URL = 'https://api.ebay.com/buy/browse/v1/item_summary/search';

function httpsRequest(url, options, body) {
  return new Promise((resolve, reject) => {
    const u = typeof url === 'string' ? new URL(url) : url;
    const req = https.request(u, options, (res) => {
      let data = '';
      res.on('data', (c) => (data += c));
      res.on('end', () => resolve({ statusCode: res.statusCode, body: data }));
    });
    req.on('error', reject);
    if (body) req.write(body);
    req.end();
  });
}

async function getEbayToken() {
  const clientId = process.env.EBAY_CLIENT_ID;
  const clientSecret = process.env.EBAY_CLIENT_SECRET;
  if (!clientId || !clientSecret) return null;
  const creds = Buffer.from(`${clientId}:${clientSecret}`).toString('base64');
  const postBody = 'grant_type=client_credentials&scope=https%3A%2F%2Fapi.ebay.com%2Foauth%2Fapi_scope';
  const url = new URL(EBAY_AUTH_URL);
  const res = await httpsRequest(url, {
    method: 'POST', hostname: url.hostname, path: url.pathname,
    headers: { 'Content-Type': 'application/x-www-form-urlencoded', Authorization: `Basic ${creds}`, 'Content-Length': Buffer.byteLength(postBody) },
  }, postBody);
  if (res.statusCode !== 200) { console.warn('[PR] eBay auth failed:', res.statusCode); return null; }
  return JSON.parse(res.body).access_token;
}

async function ebayAvgPrice(token, playerName) {
  const yr = new Date().getFullYear();
  // Try current year + player name (no brand lock — catches Topps, Bowman, Panini, etc.)
  // Add "baseball card" to filter out non-card results
  const q = encodeURIComponent(`${yr} ${playerName} baseball card`);
  const url = new URL(`${EBAY_BROWSE_URL}?q=${q}&filter=buyingOptions:{FIXED_PRICE|AUCTION}&limit=40`);
  const res = await httpsRequest(url, {
    method: 'GET', hostname: url.hostname, path: `${url.pathname}${url.search}`,
    headers: { Authorization: `Bearer ${token}`, 'X-EBAY-C-MARKETPLACE-ID': 'EBAY_US', 'Content-Type': 'application/json' },
  });
  if (res.statusCode !== 200) return null;
  const data = JSON.parse(res.body);
  const prices = (data.itemSummaries || [])
    .filter(i => i.price && i.price.value && !isJunkListing(i.title))
    .map(i => parseFloat(i.price.value))
    .filter(p => p >= 0.99) // Floor: cut junk lots, damaged, combo listings
    .sort((a, b) => a - b);
  // Drop top 2 most expensive (graded slabs, parallels, autos that skew the avg)
  if (prices.length > 4) prices.splice(-2);
  if (!prices.length) return null;
  const trimmed = prices;
  return Math.round((trimmed.reduce((a, b) => a + b, 0) / trimmed.length) * 100) / 100;
}

// ── Main refresh logic ──────────────────────────────────────
async function refreshRankings() {
  const yr = new Date().getFullYear();
  const today = todayEST();
  const yesterday = yesterdayEST();
  console.log(`[PR Refresh] Starting for ${today}, season ${yr}`);

  // 1. Fetch all season stats (bulk MLB calls) + Baseball Reference WAR
  const [hData, pData, rhData, rpData, brWar] = await Promise.all([
    httpGet(`${MLB}/stats?stats=season&group=hitting&season=${yr}&sportId=1&limit=500&sortStat=onBasePlusSlugging&order=desc`),
    httpGet(`${MLB}/stats?stats=season&group=pitching&season=${yr}&sportId=1&limit=200&sortStat=earnedRunAverage&order=asc`),
    httpGet(`${MLB}/stats?stats=season&group=hitting&season=${yr}&sportId=1&limit=100&sortStat=onBasePlusSlugging&order=desc&playerPool=rookies`),
    httpGet(`${MLB}/stats?stats=season&group=pitching&season=${yr}&sportId=1&limit=50&sortStat=earnedRunAverage&order=asc&playerPool=rookies`),
    fetchBRWar(yr),
  ]);
  const warHitMap = buildWarLookup(brWar.hitters || []);
  const warPitMap = buildWarLookup(brWar.pitchers || []);
  console.log('[PR Refresh] WAR lookups built — hitters:' + Object.keys(warHitMap).length + ' pitchers:' + Object.keys(warPitMap).length);

  const extract = (d) => (d && d.stats && d.stats[0] && d.stats[0].splits) || [];
  // Dedup by player ID — MLB API returns separate splits for traded players
  function dedup(splits) {
    const seen = new Set();
    return splits.filter(s => {
      if (seen.has(s.player.id)) return false;
      seen.add(s.player.id);
      return true;
    });
  }
  const hitters = dedup(extract(hData).filter(s => s.stat.gamesPlayed >= 5));
  const pitchers = dedup(extract(pData).filter(s => parseFloat(s.stat.inningsPitched) >= 10));
  // Rookies need a real sample — tiny-sample call-ups (e.g. 6 AB / .500) were ranking #1
  const rookieHitters = dedup(extract(rhData).filter(s => (s.stat.gamesPlayed || 0) >= 20 && (s.stat.atBats || 0) >= 50));
  const rookiePitchers = dedup(extract(rpData).filter(s => parseFloat(s.stat.inningsPitched) >= 15));

  console.log(`[PR Refresh] Season: ${hitters.length} hitters, ${pitchers.length} pitchers, ${rookieHitters.length} rookie H, ${rookiePitchers.length} rookie P`);

  // 2. Get yesterday's schedule to find who played
  let playedYesterday = new Set();
  try {
    const sched = await httpGet(`${MLB}/schedule?date=${yesterday}&sportId=1&hydrate=lineups`);
    if (sched && sched.dates && sched.dates[0]) {
      sched.dates[0].games.forEach(g => {
        ['home', 'away'].forEach(side => {
          const lineup = g.lineups && g.lineups[side + 'Players'];
          if (lineup) lineup.forEach(p => playedYesterday.add(p.id));
        });
      });
    }
    console.log(`[PR Refresh] ${playedYesterday.size} players in yesterday's games`);
  } catch (e) { console.warn('[PR Refresh] Schedule fetch failed:', e.message); }

  // 3. Fetch game logs for players who played yesterday (hitting + pitching)
  const last5Map = {}; // playerId → {hitting: stats, pitching: stats}
  const playerIds = new Set();
  hitters.slice(0, 100).forEach(s => playerIds.add(s.player.id));
  pitchers.slice(0, 50).forEach(s => playerIds.add(s.player.id));
  rookieHitters.slice(0, 30).forEach(s => playerIds.add(s.player.id));
  rookiePitchers.slice(0, 20).forEach(s => playerIds.add(s.player.id));

  // Only fetch game logs for players who played yesterday OR top 50 (ensure coverage)
  const toFetch = [...playerIds].filter((id, i) => playedYesterday.has(id) || i < 50);
  console.log(`[PR Refresh] Fetching game logs for ${toFetch.length} players`);

  // Batch game log fetches (10 concurrent)
  for (let i = 0; i < toFetch.length; i += 10) {
    const batch = toFetch.slice(i, i + 10);
    const results = await Promise.all(batch.map(async (pid) => {
      try {
        // Check if hitter or pitcher
        const isHitter = hitters.some(s => s.player.id === pid) || rookieHitters.some(s => s.player.id === pid);
        const isPitcher = pitchers.some(s => s.player.id === pid) || rookiePitchers.some(s => s.player.id === pid);
        const logs = {};
        if (isHitter) {
          const d = await httpGet(`${MLB}/people/${pid}/stats?stats=gameLog&group=hitting&season=${yr}&sportId=1`);
          const games = (d && d.stats && d.stats[0] && d.stats[0].splits) || [];
          logs.hitting = aggLast5Hitting(games);
        }
        if (isPitcher) {
          const d = await httpGet(`${MLB}/people/${pid}/stats?stats=gameLog&group=pitching&season=${yr}&sportId=1`);
          const games = (d && d.stats && d.stats[0] && d.stats[0].splits) || [];
          logs.pitching = aggLast5Pitching(games);
        }
        return { pid, logs };
      } catch (e) { return { pid, logs: {} }; }
    }));
    results.forEach(r => { last5Map[r.pid] = r.logs; });
  }

  console.log(`[PR Refresh] Game logs fetched for ${Object.keys(last5Map).length} players`);

  // 3b. Fetch eBay avg prices for unique players
  const _priceMap = {}; // playerId → avg price
  try {
    const ebayToken = await getEbayToken();
    if (ebayToken) {
      // Collect unique players — top hitters + pitchers + rookies
      const pricePlayers = [];
      const seenPids = new Set();
      const addPlayer = (s) => {
        if (!seenPids.has(s.player.id)) {
          seenPids.add(s.player.id);
          pricePlayers.push({ id: s.player.id, name: s.player.fullName });
        }
      };
      hitters.slice(0, 30).forEach(addPlayer);
      pitchers.slice(0, 15).forEach(addPlayer);
      rookieHitters.slice(0, 15).forEach(addPlayer);
      rookiePitchers.slice(0, 10).forEach(addPlayer);

      console.log(`[PR Refresh] Fetching eBay prices for ${pricePlayers.length} players`);

      // Batch 5 at a time to stay within rate limits
      for (let i = 0; i < pricePlayers.length; i += 5) {
        const batch = pricePlayers.slice(i, i + 5);
        const results = await Promise.all(batch.map(async (p) => {
          try {
            const avg = await ebayAvgPrice(ebayToken, p.name);
            return { id: p.id, avg };
          } catch (e) { return { id: p.id, avg: null }; }
        }));
        results.forEach(r => { if (r.avg != null) _priceMap[r.id] = r.avg; });
      }
      console.log(`[PR Refresh] eBay prices fetched: ${Object.keys(_priceMap).length} players with prices`);
    } else {
      console.warn('[PR Refresh] No eBay credentials — skipping price fetch');
    }
  } catch (e) {
    console.warn('[PR Refresh] eBay pricing failed (non-fatal):', e.message);
  }

  // 4. Build rankings for all categories
  const rows = [];

  // Helper to build a cache row
  function buildRow(split, type, category, seasonRank, last5Rank, isRookie) {
    const pid = split.player.id;
    const tm = TEAMS[split.team && split.team.id] || '';
    const pos = split.position ? split.position.abbreviation : '';
    const seasonStats = split.stat;
    const l5 = last5Map[pid];
    const last5Stats = type === 'h' ? (l5 && l5.hitting) : (l5 && l5.pitching);
    const price = _priceMap[pid] || 5;
    const isoSeason = type === 'h' ? isoHit(seasonStats, price) : isoPit(seasonStats, price);
    const isoLast5 = last5Stats ? (type === 'h' ? isoHit(last5Stats, price) : isoPit(last5Stats, price)) : isoSeason;
    const valSeason = valScore(isoSeason, price);
    const valLast5 = valScore(isoLast5, price);
    // WAR + composite (Power Players score) — pass real price or null
    const war = type === 'h' ? warFor(split, warHitMap) : warFor(split, warPitMap);
    const rawSeason = type === 'h' ? rawHit(seasonStats) : rawPit(seasonStats);
    const realPrice = (pid in _priceMap) ? _priceMap[pid] : null;
    const combinedSeason = combinedScore(war, rawSeason, realPrice);
    // Stuff WAR + combined into season_stats JSON (no schema change required)
    const seasonStatsWithWar = Object.assign({}, seasonStats, {
      bwar: war,
      combined_score: combinedSeason,
    });

    return {
      player_id: pid,
      player_name: split.player.fullName,
      team: tm,
      position: pos,
      category: category,
      rank_season: seasonRank,
      rank_last5: last5Rank,
      prev_rank_season: null,
      prev_rank_last5: null,
      season_stats: seasonStatsWithWar,
      last5_stats: last5Stats || seasonStats,
      iso_score_season: isoSeason,
      iso_score_last5: isoLast5,
      value_score_season: valSeason,
      value_score_last5: valLast5,
      card_price: _priceMap[pid] || null,
      card_price_pct: null,
      is_rookie: isRookie,
      data_date: today,
    };
  }

  // Helper: get price for a split's player ($5 fallback for ISO display only)
  const _pp = (s) => _priceMap[s.player.id] || 5;
  // For combined score, pass null when price is missing so the formula
  // uses its own $20 neutral default (not the $5 ISO-display fallback).
  const _ppOrNull = (s) => (s.player.id in _priceMap) ? _priceMap[s.player.id] : null;
  // Helper: combined "Power Players" score for sorting (WAR + stats + price)
  const _comboH = (s) => combinedScore(warFor(s, warHitMap), rawHit(s.stat), _ppOrNull(s));
  const _comboP = (s) => combinedScore(warFor(s, warPitMap), rawPit(s.stat), _ppOrNull(s));

  // Superstars — Hitters: top 15 by Power Players combined score (WAR+stats+price)
  const supersSorted = [...hitters].sort((a, b) => _comboH(b) - _comboH(a));
  supersSorted.slice(0, 15).forEach((s, i) => rows.push(buildRow(s, 'h', 'superstars-h', i + 1, i + 1, false)));

  // Superstars — Pitchers: top 10 by Power Players combined score
  const pitchersSorted = [...pitchers].sort((a, b) => _comboP(b) - _comboP(a));
  pitchersSorted.slice(0, 10).forEach((s, i) => rows.push(buildRow(s, 'p', 'superstars-p', i + 1, i + 1, false)));

  // Rookies — Hitters: WAR thin for rookies, falls back to raw stats via combinedScore
  const rookieHSorted = [...rookieHitters].sort((a, b) => _comboH(b) - _comboH(a));
  rookieHSorted.slice(0, 10).forEach((s, i) => rows.push(buildRow(s, 'h', 'rookies-h', i + 1, i + 1, true)));

  // Rookies — Pitchers
  const rookiePSorted = [...rookiePitchers].sort((a, b) => _comboP(b) - _comboP(a));
  rookiePSorted.slice(0, 10).forEach((s, i) => rows.push(buildRow(s, 'p', 'rookies-p', i + 1, i + 1, true)));

  // Unicorn — Hitters: the next 10 Power Players after Superstars top 15.
  // Same combinedScore sort, just slots 16-25. Keeps the whole page on
  // one consistent ranking (no mystery secondary metric).
  const superHIds = new Set(supersSorted.slice(0, 15).map(s => s.player.id));
  const unicornH = [...hitters]
    .filter(s => !superHIds.has(s.player.id))
    .sort((a, b) => _comboH(b) - _comboH(a));
  unicornH.slice(0, 10).forEach((s, i) => rows.push(buildRow(s, 'h', 'unicorn-h', i + 1, i + 1, false)));

  // Unicorn — Pitchers: next 10 Power Players after Superstars top 10
  const superPIds = new Set(pitchersSorted.slice(0, 10).map(s => s.player.id));
  const unicornP = [...pitchers]
    .filter(s => !superPIds.has(s.player.id))
    .sort((a, b) => _comboP(b) - _comboP(a));
  unicornP.slice(0, 10).forEach((s, i) => rows.push(buildRow(s, 'p', 'unicorn-p', i + 1, i + 1, false)));

  // Position-specific (hitters by position, ranked by Power Players score)
  const positions = ['C', '1B', '2B', '3B', 'SS', 'LF', 'CF', 'RF', 'DH'];
  positions.forEach(pos => {
    const filtered = hitters.filter(s => s.position && s.position.abbreviation === pos);
    filtered.sort((a, b) => _comboH(b) - _comboH(a));
    filtered.slice(0, 10).forEach((s, i) => rows.push(buildRow(s, 'h', 'pos-' + pos, i + 1, i + 1, false)));
  });

  // Pitchers position (mirror of superstars-p)
  pitchersSorted.slice(0, 10).forEach((s, i) => rows.push(buildRow(s, 'p', 'pos-P', i + 1, i + 1, false)));

  // 5. Recalculate last5 ranks using actual last5 ISO scores
  const categories = ['superstars-h', 'superstars-p', 'rookies-h', 'rookies-p', 'unicorn-h', 'unicorn-p', ...positions.map(p => 'pos-' + p), 'pos-P'];
  categories.forEach(cat => {
    const catRows = rows.filter(r => r.category === cat);
    catRows.sort((a, b) => b.iso_score_last5 - a.iso_score_last5);
    catRows.forEach((r, i) => { r.rank_last5 = i + 1; });
  });

  // 6. Fetch previous day's ranks for movement arrows
  try {
    const prevUrl = `${SB_URL}/rest/v1/power_rankings_cache?select=player_id,category,rank_season,rank_last5&data_date=eq.${yesterday}&limit=2000`;
    const prevRes = await httpPost(prevUrl, '', {
      'apikey': SB_KEY,
      'Authorization': `Bearer ${SB_KEY}`,
      'Content-Type': 'application/json',
      'Content-Length': '0',
    });
    // This won't work with POST — let me use a GET-style approach
  } catch (e) { /* prev ranks unavailable on first run */ }

  console.log(`[PR Refresh] Built ${rows.length} ranking rows`);

  // 7. Delete today's existing rows first, then insert fresh
  try {
    const delRes = await httpDelete(`${SB_URL}/rest/v1/power_rankings_cache?data_date=eq.${today}`, {
      'apikey': SB_KEY,
      'Authorization': `Bearer ${SB_KEY}`,
    });
    console.log(`[PR Refresh] Deleted old rows for ${today}: ${delRes.statusCode}`);
  } catch (e) { console.warn('[PR Refresh] Delete failed (non-fatal):', e.message); }

  // Insert fresh rows in chunks of 100
  for (let i = 0; i < rows.length; i += 100) {
    const chunk = rows.slice(i, i + 100);
    const body = JSON.stringify(chunk);
    const res = await httpPost(`${SB_URL}/rest/v1/power_rankings_cache`, body, {
      'Content-Type': 'application/json',
      'apikey': SB_KEY,
      'Authorization': `Bearer ${SB_KEY}`,
      'Prefer': 'resolution=merge-duplicates',
    });
    if (res.statusCode >= 300) {
      console.error(`[PR Refresh] Upsert error chunk ${i}: ${res.statusCode} ${res.body.slice(0, 200)}`);
    }
  }

  console.log(`[PR Refresh] Complete — ${rows.length} rows written for ${today}`);
  return { total: rows.length, date: today, hitters: hitters.length, pitchers: pitchers.length };
}

// ── Netlify Handler ─────────────────────────────────────────
exports.handler = async (event) => {
  const headers = {
    'Access-Control-Allow-Origin': 'https://isosandbox.com',
    'Content-Type': 'application/json',
  };

  try {
    const result = await refreshRankings();

    // Also refresh player profiles + ISO signals via HTTP call
    let profileResult = null;
    try {
      const ppUrl = 'https://isosandbox.com/.netlify/functions/player-profiles';
      const ppRes = await new Promise((resolve, reject) => {
        const body = JSON.stringify({});
        const u = new URL(ppUrl);
        const req = https.request(u, {
          method: 'POST', hostname: u.hostname, path: u.pathname,
          headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(body) },
        }, (res) => {
          let data = '';
          res.on('data', c => data += c);
          res.on('end', () => resolve({ status: res.statusCode, body: data }));
        });
        req.on('error', reject);
        req.write(body);
        req.end();
      });
      profileResult = JSON.parse(ppRes.body || '{}');
      console.log(`[PR Refresh] Player profiles: ${profileResult.total||0} profiles, BUY:${profileResult.buy||0} SELL:${profileResult.sell||0}`);
    } catch (ppErr) {
      console.warn('[PR Refresh] Player profiles refresh failed (non-fatal):', ppErr.message);
    }

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({ success: true, ...result, profiles: profileResult }),
    };
  } catch (err) {
    console.error('[PR Refresh] Fatal error:', err);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: err.message }),
    };
  }
};
