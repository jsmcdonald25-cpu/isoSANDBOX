// ============================================================
// GrailISO — Player Profiles + ISO Projections
// netlify/functions/player-profiles.js
// ============================================================
// Fetches MLB season stats + projected stats (unnamed source),
// calculates BUY/HOLD/SELL signals, writes to Supabase players table.
//
// Designed to run within Netlify's 26s timeout.
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
const FANTASY_TEAMS = {1:'BAL',2:'BOS',3:'LAA',4:'CHW',5:'CLE',6:'DET',7:'KC',8:'MIL',9:'MIN',10:'NYY',11:'ATH',12:'SEA',13:'TEX',14:'TOR',15:'ATL',16:'CHC',17:'CIN',18:'HOU',19:'LAD',20:'WAS',21:'NYM',22:'PHI',23:'PIT',24:'STL',25:'SD',26:'SF',27:'COL',28:'MIA',29:'AZ',30:'TB'};
const FANTASY_POS = {1:'SP',2:'C',3:'1B',4:'2B',5:'3B',6:'SS',7:'LF',8:'CF',9:'RF',10:'DH',11:'RP'};

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

// ── BUY/HOLD/SELL signal ───────────────────────────────────
function calcSignal(actual, proj) {
  if (!actual || !proj) return { signal: 'HOLD', strength: 'moderate', score: 0 };
  let delta = 0;
  if (proj.avg && actual.avg) delta += (parseFloat(proj.avg) - parseFloat(actual.avg)) * 200;
  if (proj.hr != null && actual.homeRuns != null) delta += (proj.hr - actual.homeRuns) * 0.5;
  if (proj.rbi != null && actual.rbi != null) delta += (proj.rbi - actual.rbi) * 0.3;
  if (proj.ops && actual.ops) delta += (parseFloat(proj.ops) - parseFloat(actual.ops)) * 50;
  if (proj.era && actual.era) delta -= (parseFloat(proj.era) - parseFloat(actual.era)) * 5;
  if (proj.strikeouts != null && actual.strikeOuts != null) delta += (proj.strikeouts - actual.strikeOuts) * 0.2;
  if (proj.whip && actual.whip) delta -= (parseFloat(proj.whip) - parseFloat(actual.whip)) * 20;
  const score = Math.max(-100, Math.min(100, Math.round(delta)));
  const signal = score >= 15 ? 'BUY' : score <= -15 ? 'SELL' : 'HOLD';
  return { signal, strength: Math.abs(score) >= 30 ? 'strong' : 'moderate', score };
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
    console.log(`[PP] Starting refresh for ${yr}`);

    // 1. Fetch MLB season stats — 2 fast bulk calls
    const [hData, pData] = await Promise.all([
      httpGet(`${MLB}/stats?stats=season&group=hitting&season=${yr}&sportId=1&limit=200&sortStat=onBasePlusSlugging&order=desc`),
      httpGet(`${MLB}/stats?stats=season&group=pitching&season=${yr}&sportId=1&limit=100&sortStat=earnedRunAverage&order=asc`),
    ]);

    const extract = (d) => (d && d.stats && d.stats[0] && d.stats[0].splits) || [];
    const hitters = extract(hData).filter(s => s.stat.gamesPlayed >= 3);
    const pitchers = extract(pData).filter(s => parseFloat(s.stat.inningsPitched) >= 5);
    console.log(`[PP] ${hitters.length} hitters, ${pitchers.length} pitchers`);

    // 2. Fetch projections — 1 call
    const projections = await fetchProjections(yr);
    console.log(`[PP] ${projections.length} projections`);
    const projByName = {};
    projections.forEach(p => { projByName[p.name] = p.projected; });

    // 3. Build profiles from stats (name, team, position all come from stats endpoint)
    const profiles = [];
    const seen = new Set();

    hitters.forEach(s => {
      const pid = s.player.id;
      if (seen.has(pid)) return;
      seen.add(pid);
      const name = s.player.fullName;
      const proj = projByName[name.toLowerCase()] || null;
      const sig = calcSignal(s.stat, proj);
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
        season_stats: s.stat,
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
      const proj = projByName[name.toLowerCase()] || null;
      const sig = calcSignal(s.stat, proj);
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
        season_stats: s.stat,
        projected_stats: proj,
        projection_delta: sig.score,
        iso_signal: sig.signal,
        iso_signal_strength: sig.strength,
        updated_at: new Date().toISOString(),
      });
    });

    console.log(`[PP] ${profiles.length} profiles, ${profiles.filter(p=>p.projected_stats).length} with projections`);

    // 4. Upsert to Supabase in 1-2 batches
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

    console.log(`[PP] Done — ${upserted} upserted`);
    return {
      statusCode: 200, headers,
      body: JSON.stringify({
        success: true,
        total: profiles.length,
        upserted,
        with_projections: profiles.filter(p => p.projected_stats).length,
        buy: profiles.filter(p => p.iso_signal === 'BUY').length,
        hold: profiles.filter(p => p.iso_signal === 'HOLD').length,
        sell: profiles.filter(p => p.iso_signal === 'SELL').length,
      }),
    };
  } catch (err) {
    console.error('[PP] Error:', err);
    return { statusCode: 500, headers, body: JSON.stringify({ error: err.message }) };
  }
};
