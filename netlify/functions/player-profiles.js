// ============================================================
// GrailISO — Player Profiles + ISO Projections
// netlify/functions/player-profiles.js
// ============================================================
// Compares LAST YEAR's full season stats vs THIS YEAR's projections
// to generate BUY/HOLD/SELL card investment signals.
//
// The arbitrage: cards are priced on last year's performance.
// If projections say a player is about to break out, BUY before
// the market catches up. If regression is coming, SELL now.
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

// ── Team maps ──────────────────────────────────────────────
const MLB_TEAMS = {108:'LAA',109:'AZ',110:'BAL',111:'BOS',112:'CHC',113:'CIN',114:'CLE',115:'COL',116:'DET',117:'HOU',118:'KC',119:'LAD',120:'WAS',121:'NYM',133:'ATH',134:'PIT',135:'SD',136:'SEA',137:'SF',138:'STL',139:'TB',140:'TEX',141:'TOR',142:'MIN',143:'PHI',144:'ATL',145:'CHW',146:'MIA',147:'NYY',158:'MIL'};

// ── Fetch projections ──────────────────────────────────────
async function fetchProjections(yr) {
  const url = `https://lm-api-reads.fantasy.espn.com/apis/v3/games/flb/seasons/${yr}/segments/0/leaguedefaults/3?view=kona_player_info`;
  const filterHeader = JSON.stringify({
    players: {
      limit: 300,
      sortPercOwned: { sortAsc: false, sortPriority: 1 },
      filterStatsForSourceIds: { value: [`00${yr}`] },
      filterSlotIds: { value: [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14] },
    }
  });

  return new Promise((resolve) => {
    const u = new URL(url);
    const req = https.request(u, {
      method: 'GET', hostname: u.hostname, path: u.pathname + u.search,
      headers: { 'X-Fantasy-Filter': filterHeader, 'Accept': 'application/json' },
    }, (res) => {
      let data = '';
      res.on('data', (c) => (data += c));
      res.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          const players = (parsed.players || []).map(p => {
            const info = p.player || {};
            const stats = (info.stats || []).find(s => s.id === `00${yr}`);
            const proj = stats ? stats.stats || {} : {};
            return {
              name: (info.fullName || '').toLowerCase(),
              projected: {
                avg: proj[2] ? proj[2].toFixed(3) : null,
                hr: Math.round(proj[5] || 0) || null,
                rbi: Math.round(proj[6] || 0) || null,
                sb: Math.round(proj[11] || 0) || null,
                ops: proj[19] ? proj[19].toFixed(3) : null,
                runs: Math.round(proj[20] || 0) || null,
                era: proj[22] ? proj[22].toFixed(2) : null,
                wins: Math.round(proj[26] || 0) || null,
                strikeouts: Math.round(proj[32] || 0) || null,
                ip: proj[34] ? proj[34].toFixed(1) : null,
                whip: proj[36] ? proj[36].toFixed(2) : null,
              }
            };
          });
          resolve(players);
        } catch (e) { console.warn('[Proj] Parse failed:', e.message); resolve([]); }
      });
    });
    req.on('error', () => resolve([]));
    req.end();
  });
}

// ── Card Investment Signal Engine ──────────────────────────
// Compares last year's FULL season to this year's PROJECTION.
// Cards are priced on past performance — the signal finds
// where the market hasn't caught up to the projection yet.
//
// STRONG BUY  — Major breakout projected, card underpriced
// BUY         — Stats trending up, market hasn't adjusted
// HOLD        — Fair value, no clear edge
// SELL        — Regression coming, market still inflated
// STRONG SELL — Major decline projected, dump now
//
function calcSignal(lastYearStats, projectedStats, playerType) {
  if (!lastYearStats || !projectedStats) return { signal: 'HOLD', strength: 'neutral', score: 0, reason: 'No projection data' };

  let score = 0;
  const reasons = [];

  if (playerType === 'hitter') {
    // AVG delta — massive signal. +.030 is a huge breakout
    const lastAvg = parseFloat(lastYearStats.avg) || 0;
    const projAvg = parseFloat(projectedStats.avg) || 0;
    if (lastAvg > 0 && projAvg > 0) {
      const avgDelta = projAvg - lastAvg;
      score += avgDelta * 300; // .030 jump = +9 points
      if (avgDelta >= 0.020) reasons.push(`AVG +${(avgDelta*1000).toFixed(0)} pts`);
      if (avgDelta <= -0.020) reasons.push(`AVG ${(avgDelta*1000).toFixed(0)} pts`);
    }

    // HR delta — 10+ HR jump is significant
    const lastHR = lastYearStats.homeRuns || 0;
    const projHR = projectedStats.hr || 0;
    if (lastHR > 0 || projHR > 0) {
      const hrDelta = projHR - lastHR;
      score += hrDelta * 1.2; // +10 HR = +12 points
      if (hrDelta >= 5) reasons.push(`+${hrDelta} HR`);
      if (hrDelta <= -5) reasons.push(`${hrDelta} HR`);
    }

    // RBI delta
    const lastRBI = lastYearStats.rbi || 0;
    const projRBI = projectedStats.rbi || 0;
    if (lastRBI > 0 || projRBI > 0) {
      const rbiDelta = projRBI - lastRBI;
      score += rbiDelta * 0.4;
      if (Math.abs(rbiDelta) >= 15) reasons.push(`${rbiDelta>0?'+':''}${rbiDelta} RBI`);
    }

    // OPS delta — .050+ is big
    const lastOPS = parseFloat(lastYearStats.ops) || 0;
    const projOPS = parseFloat(projectedStats.ops) || 0;
    if (lastOPS > 0 && projOPS > 0) {
      const opsDelta = projOPS - lastOPS;
      score += opsDelta * 80;
      if (opsDelta >= 0.040) reasons.push(`OPS +${(opsDelta*1000).toFixed(0)}`);
      if (opsDelta <= -0.040) reasons.push(`OPS ${(opsDelta*1000).toFixed(0)}`);
    }

    // SB delta — speed is trending more valuable
    const lastSB = lastYearStats.stolenBases || 0;
    const projSB = projectedStats.sb || 0;
    if (lastSB > 0 || projSB > 0) {
      score += (projSB - lastSB) * 0.5;
    }

  } else {
    // PITCHER signals — lower ERA/WHIP = better (invert delta)

    // ERA delta — 0.50+ drop is huge
    const lastERA = parseFloat(lastYearStats.era) || 0;
    const projERA = parseFloat(projectedStats.era) || 0;
    if (lastERA > 0 && projERA > 0) {
      const eraDelta = lastERA - projERA; // positive = improvement
      score += eraDelta * 10;
      if (eraDelta >= 0.40) reasons.push(`ERA -${eraDelta.toFixed(2)}`);
      if (eraDelta <= -0.40) reasons.push(`ERA +${Math.abs(eraDelta).toFixed(2)}`);
    }

    // K delta
    const lastK = lastYearStats.strikeOuts || 0;
    const projK = projectedStats.strikeouts || 0;
    if (lastK > 0 || projK > 0) {
      const kDelta = projK - lastK;
      score += kDelta * 0.3;
      if (kDelta >= 20) reasons.push(`+${kDelta} K`);
      if (kDelta <= -20) reasons.push(`${kDelta} K`);
    }

    // W delta
    const lastW = lastYearStats.wins || 0;
    const projW = projectedStats.wins || 0;
    if (lastW > 0 || projW > 0) {
      score += (projW - lastW) * 2;
    }

    // WHIP delta — lower = better
    const lastWHIP = parseFloat(lastYearStats.whip) || 0;
    const projWHIP = parseFloat(projectedStats.whip) || 0;
    if (lastWHIP > 0 && projWHIP > 0) {
      const whipDelta = lastWHIP - projWHIP; // positive = improvement
      score += whipDelta * 25;
      if (whipDelta >= 0.10) reasons.push(`WHIP -${whipDelta.toFixed(2)}`);
      if (whipDelta <= -0.10) reasons.push(`WHIP +${Math.abs(whipDelta).toFixed(2)}`);
    }
  }

  // Clamp to -100 to +100
  score = Math.max(-100, Math.min(100, Math.round(score)));

  // 5-tier signal
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
    console.log(`[PP] Refresh: comparing ${lastYr} actuals vs ${yr} projections`);

    // 1. Fetch LAST YEAR's full season stats (the baseline — what cards are priced on)
    //    AND this year's stats (for current context)
    const [hLast, pLast, hThis, pThis] = await Promise.all([
      httpGet(`${MLB}/stats?stats=season&group=hitting&season=${lastYr}&sportId=1&limit=300&sortStat=onBasePlusSlugging&order=desc`),
      httpGet(`${MLB}/stats?stats=season&group=pitching&season=${lastYr}&sportId=1&limit=150&sortStat=earnedRunAverage&order=asc`),
      httpGet(`${MLB}/stats?stats=season&group=hitting&season=${yr}&sportId=1&limit=200&sortStat=onBasePlusSlugging&order=desc`),
      httpGet(`${MLB}/stats?stats=season&group=pitching&season=${yr}&sportId=1&limit=100&sortStat=earnedRunAverage&order=asc`),
    ]);

    const extract = (d) => (d && d.stats && d.stats[0] && d.stats[0].splits) || [];

    // Last year's stats keyed by player ID
    const lastYearHitters = {};
    extract(hLast).forEach(s => { lastYearHitters[s.player.id] = s.stat; });
    const lastYearPitchers = {};
    extract(pLast).filter(s => parseFloat(s.stat.inningsPitched) >= 20).forEach(s => { lastYearPitchers[s.player.id] = s.stat; });

    // This year's roster (tells us who is active + current team/position)
    const hitters = extract(hThis).filter(s => s.stat.gamesPlayed >= 1);
    const pitchers = extract(pThis).filter(s => parseFloat(s.stat.inningsPitched) >= 1);

    console.log(`[PP] ${lastYr}: ${Object.keys(lastYearHitters).length}H/${Object.keys(lastYearPitchers).length}P | ${yr}: ${hitters.length}H/${pitchers.length}P`);

    // 2. Fetch projections for this year
    const projections = await fetchProjections(yr);
    console.log(`[PP] ${projections.length} projections`);
    const projByName = {};
    projections.forEach(p => { projByName[p.name] = p.projected; });

    // 3. Build profiles: compare last year actual → this year projected
    const profiles = [];
    const seen = new Set();

    hitters.forEach(s => {
      const pid = s.player.id;
      if (seen.has(pid)) return;
      seen.add(pid);
      const name = s.player.fullName;
      const lastStats = lastYearHitters[pid] || null;
      const proj = projByName[name.toLowerCase()] || null;
      const sig = calcSignal(lastStats, proj, 'hitter');
      const tm = s.team ? (MLB_TEAMS[s.team.id] || '') : '';
      const pos = s.position ? s.position.abbreviation : '';
      profiles.push({
        mlb_id: pid,
        full_name: name,
        position: pos,
        team: tm,
        team_id: s.team ? s.team.id : null,
        active: true,
        headshot_url: `https://img.mlbstatic.com/mlb-photos/image/upload/d_people:generic:headshot:67:current.png/w_426,q_auto:best/v1/people/${pid}/headshot/67/current`,
        player_type: 'hitter',
        season_stats: lastStats || s.stat,
        projected_stats: proj,
        projection_delta: sig.score,
        iso_signal: sig.signal,
        iso_signal_strength: sig.strength,
        updated_at: new Date().toISOString(),
      });
    });

    pitchers.forEach(s => {
      const pid = s.player.id;
      if (seen.has(pid)) return;
      seen.add(pid);
      const name = s.player.fullName;
      const lastStats = lastYearPitchers[pid] || null;
      const proj = projByName[name.toLowerCase()] || null;
      const sig = calcSignal(lastStats, proj, 'pitcher');
      const tm = s.team ? (MLB_TEAMS[s.team.id] || '') : '';
      const pos = s.position ? s.position.abbreviation : 'P';
      profiles.push({
        mlb_id: pid,
        full_name: name,
        position: pos,
        team: tm,
        team_id: s.team ? s.team.id : null,
        active: true,
        headshot_url: `https://img.mlbstatic.com/mlb-photos/image/upload/d_people:generic:headshot:67:current.png/w_426,q_auto:best/v1/people/${pid}/headshot/67/current`,
        player_type: 'pitcher',
        season_stats: lastStats || s.stat,
        projected_stats: proj,
        projection_delta: sig.score,
        iso_signal: sig.signal,
        iso_signal_strength: sig.strength,
        updated_at: new Date().toISOString(),
      });
    });

    const buys = profiles.filter(p => p.iso_signal.includes('BUY'));
    const sells = profiles.filter(p => p.iso_signal.includes('SELL'));
    const holds = profiles.filter(p => p.iso_signal === 'HOLD');
    console.log(`[PP] ${profiles.length} profiles | BUY:${buys.length} HOLD:${holds.length} SELL:${sells.length}`);

    // 4. Upsert to Supabase
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

    // Top BUY and SELL picks for logging
    const topBuys = buys.sort((a,b) => b.projection_delta - a.projection_delta).slice(0,10).map(p => `${p.full_name} (${p.iso_signal} ${p.projection_delta>0?'+':''}${p.projection_delta})`);
    const topSells = sells.sort((a,b) => a.projection_delta - b.projection_delta).slice(0,10).map(p => `${p.full_name} (${p.iso_signal} ${p.projection_delta})`);

    return {
      statusCode: 200, headers,
      body: JSON.stringify({
        success: true,
        comparison: `${lastYr} actuals vs ${yr} projections`,
        total: profiles.length,
        upserted,
        with_projections: profiles.filter(p => p.projected_stats).length,
        strong_buy: profiles.filter(p => p.iso_signal === 'STRONG BUY').length,
        buy: profiles.filter(p => p.iso_signal === 'BUY').length,
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
