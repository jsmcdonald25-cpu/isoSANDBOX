// ============================================================
// GrailISO — Player Profiles + ISO Signals
// netlify/functions/player-profiles.js
// ============================================================
// Compares LAST YEAR's stats through the same # of games as THIS
// YEAR to generate BUY/HOLD/SELL card investment signals.
//
// Vets: 2025 game log sliced to same GP as 2026 → compare
// Rookies: 2025 MiLB stats (weighted ~85% for AAA) vs 2026 MLB
// ============================================================

const https = require('https');

const MLB = 'https://statsapi.mlb.com/api/v1';
const SB_URL = 'https://jyfaegmnzkarlcximxjo.supabase.co';
const SB_KEY = process.env.SUPABASE_SERVICE_KEY
  || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp5ZmFlZ21uemthcmxjeGlteGpvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMyNzU3MDMsImV4cCI6MjA4ODg1MTcwM30.e6U1TZECRlEV9LkTm9NY6ljIJVRKhajE6VvRaBLlaCA';

// ── HTTP helpers ───────────────────────────────────────────
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

function httpReq(url, method, bodyStr, headers) {
  return new Promise((resolve, reject) => {
    const u = new URL(url);
    const req = https.request(u, {
      method,
      hostname: u.hostname,
      path: u.pathname + u.search,
      headers: { ...headers, 'Content-Length': Buffer.byteLength(bodyStr) },
    }, (res) => {
      let data = '';
      res.on('data', (c) => (data += c));
      res.on('end', () => resolve({ status: res.statusCode, body: data }));
    });
    req.on('error', reject);
    req.write(bodyStr);
    req.end();
  });
}

// ── Team map ──────────────────────────────────────────────
const MLB_TEAMS = {108:'LAA',109:'AZ',110:'BAL',111:'BOS',112:'CHC',113:'CIN',114:'CLE',115:'COL',116:'DET',117:'HOU',118:'KC',119:'LAD',120:'WAS',121:'NYM',133:'ATH',134:'PIT',135:'SD',136:'SEA',137:'SF',138:'STL',139:'TB',140:'TEX',141:'TOR',142:'MIN',143:'PHI',144:'ATL',145:'CHW',146:'MIA',147:'NYY',158:'MIL'};

// ── Aggregate game log to stats through N games ───────────
function aggHitting(games) {
  if (!games.length) return null;
  let ab = 0, h = 0, hr = 0, rbi = 0, sb = 0, bb = 0, gp = games.length;
  games.forEach(g => {
    const s = g.stat;
    ab += s.atBats || 0; h += s.hits || 0; hr += s.homeRuns || 0;
    rbi += s.rbi || 0; sb += s.stolenBases || 0; bb += s.baseOnBalls || 0;
  });
  const avg = ab > 0 ? (h / ab).toFixed(3) : '.000';
  const obp = (ab + bb) > 0 ? ((h + bb) / (ab + bb)).toFixed(3) : '.000';
  const slg = ab > 0 ? ((h + hr * 3) / ab).toFixed(3) : '.000';
  const ops = (parseFloat(obp) + parseFloat(slg)).toFixed(3);
  return { avg, homeRuns: hr, rbi, ops, stolenBases: sb, gamesPlayed: gp, atBats: ab, hits: h };
}

function aggPitching(games) {
  if (!games.length) return null;
  let ip = 0, er = 0, k = 0, w = 0, l = 0, ha = 0, bb = 0, sv = 0, gp = games.length;
  games.forEach(g => {
    const s = g.stat;
    ip += parseFloat(s.inningsPitched) || 0; er += s.earnedRuns || 0;
    k += s.strikeOuts || 0; w += s.wins || 0; l += s.losses || 0;
    ha += s.hits || 0; bb += s.baseOnBalls || 0; sv += s.saves || 0;
  });
  const era = ip > 0 ? ((er / ip) * 9).toFixed(2) : '0.00';
  const whip = ip > 0 ? ((ha + bb) / ip).toFixed(2) : '0.00';
  return { era, wins: w, losses: l, strikeOuts: k, whip, inningsPitched: ip.toFixed(1), saves: sv, gamesPlayed: gp };
}

// ── MiLB weight factors ───────────────────────────────────
// MiLB stats inflate vs MLB. These factors scale them down.
const MILB_WEIGHT = {
  11: 0.87, // AAA → ~87% of MLB equivalent
  12: 0.78, // AA  → ~78%
  13: 0.70, // A+  → ~70%
  14: 0.62, // A   → ~62%
};

function weightMiLBHitting(stats, sportId) {
  if (!stats) return null;
  const w = MILB_WEIGHT[sportId] || 0.80;
  return {
    avg: (parseFloat(stats.avg) * w).toFixed(3),
    homeRuns: Math.round((stats.homeRuns || 0) * w),
    rbi: Math.round((stats.rbi || 0) * w),
    ops: (parseFloat(stats.ops) * w).toFixed(3),
    stolenBases: Math.round((stats.stolenBases || 0) * w),
    gamesPlayed: stats.gamesPlayed || 0,
    _milbLevel: sportId,
    _milbWeight: w,
  };
}

function weightMiLBPitching(stats, sportId) {
  if (!stats) return null;
  const w = MILB_WEIGHT[sportId] || 0.80;
  // For pitchers, ERA/WHIP go UP when weighted (worse in MLB)
  const invW = 1 + (1 - w); // e.g. AAA: 1.13
  return {
    era: (parseFloat(stats.era) * invW).toFixed(2),
    wins: Math.round((stats.wins || 0) * w),
    losses: stats.losses || 0,
    strikeOuts: Math.round((stats.strikeOuts || 0) * w),
    whip: (parseFloat(stats.whip) * invW).toFixed(2),
    inningsPitched: stats.inningsPitched || '0.0',
    saves: stats.saves || 0,
    gamesPlayed: stats.gamesPlayed || 0,
    _milbLevel: sportId,
    _milbWeight: w,
  };
}

// ── Signal calculation ────────────────────────────────────
// Compares baseline (last year same point OR weighted MiLB)
// vs current year actual stats. Positive = improving = BUY.
function calcSignal(baseline, current, playerType) {
  if (!baseline || !current) return { signal: 'HOLD', strength: 'neutral', score: 0, reason: 'Insufficient data' };

  let score = 0;
  const reasons = [];

  if (playerType === 'hitter') {
    const baseAvg = parseFloat(baseline.avg) || 0;
    const currAvg = parseFloat(current.avg) || 0;
    if (baseAvg > 0 && currAvg > 0) {
      const d = currAvg - baseAvg;
      score += d * 300;
      if (d >= 0.020) reasons.push(`AVG +${(d * 1000).toFixed(0)} pts`);
      if (d <= -0.020) reasons.push(`AVG ${(d * 1000).toFixed(0)} pts`);
    }

    const baseHR = baseline.homeRuns || 0;
    const currHR = current.homeRuns || 0;
    const baseGP = baseline.gamesPlayed || 1;
    const currGP = current.gamesPlayed || 1;
    // Compare HR rate per game
    const hrRateDelta = (currHR / currGP) - (baseHR / baseGP);
    score += hrRateDelta * 80;
    if (hrRateDelta >= 0.1) reasons.push(`HR pace +${(hrRateDelta * currGP).toFixed(0)}`);
    if (hrRateDelta <= -0.1) reasons.push(`HR pace ${(hrRateDelta * currGP).toFixed(0)}`);

    const baseRBI = baseline.rbi || 0;
    const currRBI = current.rbi || 0;
    const rbiRateDelta = (currRBI / currGP) - (baseRBI / baseGP);
    score += rbiRateDelta * 40;

    const baseOPS = parseFloat(baseline.ops) || 0;
    const currOPS = parseFloat(current.ops) || 0;
    if (baseOPS > 0 && currOPS > 0) {
      const d = currOPS - baseOPS;
      score += d * 80;
      if (d >= 0.040) reasons.push(`OPS +${(d * 1000).toFixed(0)}`);
      if (d <= -0.040) reasons.push(`OPS ${(d * 1000).toFixed(0)}`);
    }

    const baseSB = baseline.stolenBases || 0;
    const currSB = current.stolenBases || 0;
    score += ((currSB / currGP) - (baseSB / baseGP)) * 30;

  } else {
    // Pitcher — lower ERA/WHIP = better
    const baseERA = parseFloat(baseline.era) || 0;
    const currERA = parseFloat(current.era) || 0;
    if (baseERA > 0 && currERA > 0) {
      const d = baseERA - currERA; // positive = improvement
      score += d * 10;
      if (d >= 0.40) reasons.push(`ERA -${d.toFixed(2)}`);
      if (d <= -0.40) reasons.push(`ERA +${Math.abs(d).toFixed(2)}`);
    }

    const baseK = baseline.strikeOuts || 0;
    const currK = current.strikeOuts || 0;
    const baseGP = baseline.gamesPlayed || 1;
    const currGP = current.gamesPlayed || 1;
    const kRateDelta = (currK / currGP) - (baseK / baseGP);
    score += kRateDelta * 5;
    if (kRateDelta >= 1) reasons.push(`K/G +${kRateDelta.toFixed(1)}`);

    const baseW = baseline.wins || 0;
    const currW = current.wins || 0;
    score += ((currW / currGP) - (baseW / baseGP)) * 20;

    const baseWHIP = parseFloat(baseline.whip) || 0;
    const currWHIP = parseFloat(current.whip) || 0;
    if (baseWHIP > 0 && currWHIP > 0) {
      const d = baseWHIP - currWHIP;
      score += d * 25;
      if (d >= 0.10) reasons.push(`WHIP -${d.toFixed(2)}`);
      if (d <= -0.10) reasons.push(`WHIP +${Math.abs(d).toFixed(2)}`);
    }
  }

  score = Math.max(-100, Math.min(100, Math.round(score)));

  let signal, strength;
  if (score >= 25)       { signal = 'STRONG BUY';  strength = 'strong'; }
  else if (score >= 8)   { signal = 'BUY';         strength = 'moderate'; }
  else if (score <= -25) { signal = 'STRONG SELL';  strength = 'strong'; }
  else if (score <= -8)  { signal = 'SELL';         strength = 'moderate'; }
  else                   { signal = 'HOLD';         strength = 'neutral'; }

  return { signal, strength, score, reason: reasons.join(' · ') || 'Marginal change' };
}

// ── Main ───────────────────────────────────────────────────
exports.handler = async (event) => {
  const headers = {
    'Access-Control-Allow-Origin': 'https://isosandbox.com',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Content-Type': 'application/json',
  };
  if (event.httpMethod === 'OPTIONS') return { statusCode: 200, headers, body: '' };
  if (event.httpMethod !== 'POST') return { statusCode: 405, headers, body: '{"error":"POST only"}' };

  try {
    const yr = new Date().getFullYear();
    const lastYr = yr - 1;
    console.log(`[PP] Refresh: ${lastYr} same-point stats vs ${yr} actuals`);

    // 1. Fetch THIS YEAR's current stats (tells us who is active + GP count)
    const [hThis, pThis] = await Promise.all([
      httpGet(`${MLB}/stats?stats=season&group=hitting&season=${yr}&sportId=1&limit=300&sortStat=onBasePlusSlugging&order=desc`),
      httpGet(`${MLB}/stats?stats=season&group=pitching&season=${yr}&sportId=1&limit=150&sortStat=earnedRunAverage&order=asc`),
    ]);

    const extract = (d) => (d && d.stats && d.stats[0] && d.stats[0].splits) || [];
    const hitters = extract(hThis).filter(s => s.stat.gamesPlayed >= 3);
    const pitchers = extract(pThis).filter(s => parseFloat(s.stat.inningsPitched) >= 3);

    // Dedup by player ID
    const seenH = new Set();
    const dedupH = hitters.filter(s => { if (seenH.has(s.player.id)) return false; seenH.add(s.player.id); return true; });
    const seenP = new Set();
    const dedupP = pitchers.filter(s => { if (seenP.has(s.player.id)) return false; seenP.add(s.player.id); return true; });

    console.log(`[PP] ${yr}: ${dedupH.length} hitters, ${dedupP.length} pitchers`);

    // 2. For each active player, fetch LAST YEAR's game log and slice to same GP
    //    Also check if they're a rookie (no last year MLB stats → use MiLB)
    const profiles = [];
    const allPlayers = [
      ...dedupH.slice(0, 150).map(s => ({ split: s, type: 'hitter' })),
      ...dedupP.slice(0, 75).map(s => ({ split: s, type: 'pitcher' })),
    ];

    // Batch 10 at a time
    for (let i = 0; i < allPlayers.length; i += 10) {
      const batch = allPlayers.slice(i, i + 10);
      const results = await Promise.all(batch.map(async ({ split, type }) => {
        const pid = split.player.id;
        const name = split.player.fullName;
        const currentStats = split.stat;
        const currentGP = currentStats.gamesPlayed || 1;
        const tm = split.team ? (MLB_TEAMS[split.team.id] || '') : '';
        const pos = split.position ? split.position.abbreviation : (type === 'pitcher' ? 'P' : '');

        let baseline = null;
        let isRookie = false;
        let baselineSource = 'mlb_yoy'; // 'mlb_yoy' or 'milb_weighted'

        try {
          // Try last year's MLB game log
          const group = type === 'hitter' ? 'hitting' : 'pitching';
          const logData = await httpGet(`${MLB}/people/${pid}/stats?stats=gameLog&group=${group}&season=${lastYr}&sportId=1`);
          const games = (logData && logData.stats && logData.stats[0] && logData.stats[0].splits) || [];

          if (games.length >= 5) {
            // Vet path: slice to same # of games as current year
            const sliced = games.slice(0, currentGP);
            baseline = type === 'hitter' ? aggHitting(sliced) : aggPitching(sliced);
          } else {
            // Rookie path: try MiLB stats from last year
            isRookie = true;
            baselineSource = 'milb_weighted';

            // Try AAA first, then AA, then A+
            for (const sportId of [11, 12, 13]) {
              const milbData = await httpGet(`${MLB}/people/${pid}/stats?stats=season&group=${group}&season=${lastYr}&sportId=${sportId}`);
              const milbSplits = (milbData && milbData.stats && milbData.stats[0] && milbData.stats[0].splits) || [];
              if (milbSplits.length && milbSplits[0].stat) {
                const milbStats = milbSplits[0].stat;
                if (type === 'hitter' && (milbStats.gamesPlayed || 0) >= 10) {
                  baseline = weightMiLBHitting(milbStats, sportId);
                  break;
                } else if (type === 'pitcher' && parseFloat(milbStats.inningsPitched || 0) >= 10) {
                  baseline = weightMiLBPitching(milbStats, sportId);
                  break;
                }
              }
            }
          }
        } catch (e) { /* non-fatal — player gets HOLD */ }

        const sig = calcSignal(baseline, currentStats, type);

        return {
          mlb_id: pid,
          full_name: name,
          position: pos,
          team: tm,
          team_id: split.team ? split.team.id : null,
          active: true,
          headshot_url: `https://img.mlbstatic.com/mlb-photos/image/upload/d_people:generic:headshot:67:current.png/w_426,q_auto:best/v1/people/${pid}/headshot/67/current`,
          player_type: type,
          is_rookie: isRookie,
          baseline_source: baselineSource,
          baseline_stats: baseline,
          season_stats: currentStats,
          projected_stats: null, // no longer using ESPN projections
          projection_delta: sig.score,
          iso_signal: sig.signal,
          iso_signal_strength: sig.strength,
          signal_reason: sig.reason,
          updated_at: new Date().toISOString(),
        };
      }));

      results.forEach(r => { if (r) profiles.push(r); });
    }

    const buys = profiles.filter(p => p.iso_signal.includes('BUY'));
    const sells = profiles.filter(p => p.iso_signal.includes('SELL'));
    const holds = profiles.filter(p => p.iso_signal === 'HOLD');
    console.log(`[PP] ${profiles.length} profiles | BUY:${buys.length} HOLD:${holds.length} SELL:${sells.length}`);

    // 3. Upsert to Supabase
    let upserted = 0;
    for (let i = 0; i < profiles.length; i += 100) {
      const chunk = profiles.slice(i, i + 100);
      const res = await httpReq(
        `${SB_URL}/rest/v1/players?on_conflict=mlb_id`,
        'POST',
        JSON.stringify(chunk),
        {
          'Content-Type': 'application/json',
          'apikey': SB_KEY,
          'Authorization': `Bearer ${SB_KEY}`,
          'Prefer': 'resolution=merge-duplicates',
        }
      );
      if (res.status < 300) upserted += chunk.length;
      else console.error(`[PP] Upsert error: ${res.status} ${res.body.slice(0, 300)}`);
    }

    const topBuys = buys.sort((a, b) => b.projection_delta - a.projection_delta).slice(0, 10)
      .map(p => `${p.full_name} (${p.iso_signal} ${p.projection_delta > 0 ? '+' : ''}${p.projection_delta}${p.is_rookie ? ' ROOKIE' : ''})`);
    const topSells = sells.sort((a, b) => a.projection_delta - b.projection_delta).slice(0, 10)
      .map(p => `${p.full_name} (${p.iso_signal} ${p.projection_delta})`);

    return {
      statusCode: 200, headers,
      body: JSON.stringify({
        success: true,
        method: `${lastYr} same-point-in-season stats vs ${yr} actuals (MiLB weighted for rookies)`,
        total: profiles.length,
        upserted,
        rookies: profiles.filter(p => p.is_rookie).length,
        strong_buy: profiles.filter(p => p.iso_signal === 'STRONG BUY').length,
        buy: buys.length,
        hold: holds.length,
        sell: profiles.filter(p => p.iso_signal === 'SELL').length,
        strong_sell: profiles.filter(p => p.iso_signal === 'STRONG SELL').length,
        top_buys: topBuys,
        top_sells: topSells,
      }),
    };
  } catch (err) {
    console.error('[PP] Error:', err);
    return { statusCode: 500, headers, body: JSON.stringify({ error: err.message }) };
  }
};
