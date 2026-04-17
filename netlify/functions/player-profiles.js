// ============================================================
// GrailISO — Player Profiles + ISO Projections
// netlify/functions/player-profiles.js
// ============================================================
// Fetches MLB player bios + season stats + projected stats,
// calculates BUY/HOLD/SELL signals, writes to Supabase.
//
// Callable via POST. Can also be scheduled for daily refresh.
// ============================================================

const https = require('https');

const MLB = 'https://statsapi.mlb.com/api/v1';
const SB_URL = 'https://jyfaegmnzkarlcximxjo.supabase.co';
const SB_KEY = process.env.SUPABASE_SERVICE_KEY
  || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp5ZmFlZ21uemthcmxjeGlteGpvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMyNzU3MDMsImV4cCI6MjA4ODg1MTcwM30.e6U1TZECRlEV9LkTm9NY6ljIJVRKhajE6VvRaBLlaCA';

// ── HTTP helpers ───────────────────────────────────────────
function httpGet(url, headers) {
  return new Promise((resolve, reject) => {
    const u = new URL(url);
    const opts = { hostname: u.hostname, path: u.pathname + u.search, headers: headers || {} };
    https.get(url, opts, (res) => {
      let data = '';
      res.on('data', (c) => (data += c));
      res.on('end', () => {
        try { resolve({ status: res.statusCode, data: JSON.parse(data) }); }
        catch (e) { resolve({ status: res.statusCode, data: null, raw: data }); }
      });
    }).on('error', reject);
  });
}

function httpReq(url, method, body, headers) {
  return new Promise((resolve, reject) => {
    const u = new URL(url);
    const bodyStr = typeof body === 'string' ? body : JSON.stringify(body);
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

// ── Fetch projections from fantasy source (no branding) ────
async function fetchProjections(yr) {
  // Fantasy projection source — returns player stats predictions
  const url = `https://lm-api-reads.fantasy.espn.com/apis/v3/games/flb/seasons/${yr}/segments/0/leaguedefaults/3?view=kona_player_info`;
  const filterHeader = JSON.stringify({
    players: {
      limit: 500,
      sortPercOwned: { sortAsc: false, sortPriority: 1 },
      filterStatsForSourceIds: { value: [`00${yr}`] }, // projected stats
      filterSlotIds: { value: [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14] },
    }
  });

  try {
    const u = new URL(url);
    const res = await new Promise((resolve, reject) => {
      const req = https.request(u, {
        method: 'GET',
        hostname: u.hostname,
        path: u.pathname + u.search,
        headers: {
          'X-Fantasy-Filter': filterHeader,
          'Accept': 'application/json',
        },
      }, (response) => {
        let data = '';
        response.on('data', (c) => (data += c));
        response.on('end', () => {
          try { resolve({ status: response.statusCode, data: JSON.parse(data) }); }
          catch (e) { resolve({ status: response.statusCode, data: null }); }
        });
      });
      req.on('error', reject);
      req.end();
    });

    if (res.status !== 200 || !res.data) {
      console.warn(`[Projections] Source returned ${res.status}`);
      return [];
    }

    const players = res.data.players || [];
    return players.map(p => {
      const info = p.player || {};
      const stats = (info.stats || []).find(s => s.id === `00${yr}`);
      const projected = stats ? stats.stats || {} : {};

      // Fantasy stat ID mapping (standard fantasy baseball stat IDs)
      // Hitting: 0=AB, 1=H, 2=AVG, 3=2B, 5=HR, 6=RBI, 8=BB, 11=SB, 17=OBP, 18=SLG, 19=OPS, 20=R
      // Pitching: 22=ERA, 26=W, 27=L, 28=SV, 32=K, 34=IP, 36=WHIP
      return {
        fantasy_id: info.id,
        full_name: info.fullName || '',
        first_name: info.firstName || '',
        last_name: info.lastName || '',
        team_abbrev: info.proTeamId ? _teamFromId(info.proTeamId) : '',
        position: _posFromSlot(info.defaultPositionId),
        projected_stats: {
          // Hitting
          ab: projected[0] || null,
          hits: projected[1] || null,
          avg: projected[2] ? projected[2].toFixed(3) : null,
          doubles: projected[3] || null,
          hr: projected[5] || null,
          rbi: projected[6] || null,
          bb: projected[8] || null,
          sb: projected[11] || null,
          obp: projected[17] ? projected[17].toFixed(3) : null,
          slg: projected[18] ? projected[18].toFixed(3) : null,
          ops: projected[19] ? projected[19].toFixed(3) : null,
          runs: projected[20] || null,
          // Pitching
          era: projected[22] ? projected[22].toFixed(2) : null,
          wins: projected[26] || null,
          losses: projected[27] || null,
          saves: projected[28] || null,
          strikeouts: projected[32] || null,
          ip: projected[34] ? projected[34].toFixed(1) : null,
          whip: projected[36] ? projected[36].toFixed(2) : null,
        }
      };
    });
  } catch (e) {
    console.error('[Projections] Fetch failed:', e.message);
    return [];
  }
}

// ── Fantasy source team/position mappings ──────────────────
function _teamFromId(id) {
  const map = {1:'BAL',2:'BOS',3:'LAA',4:'CHW',5:'CLE',6:'DET',7:'KC',8:'MIL',9:'MIN',10:'NYY',
    11:'ATH',12:'SEA',13:'TEX',14:'TOR',15:'ATL',16:'CHC',17:'CIN',18:'HOU',19:'LAD',20:'WAS',
    21:'NYM',22:'PHI',23:'PIT',24:'STL',25:'SD',26:'SF',27:'COL',28:'MIA',29:'AZ',30:'TB'};
  return map[id] || '';
}
function _posFromSlot(id) {
  const map = {1:'SP',2:'C',3:'1B',4:'2B',5:'3B',6:'SS',7:'LF',8:'CF',9:'RF',10:'DH',11:'RP'};
  return map[id] || '';
}

// ── Fetch MLB bios for a batch of player IDs ──────────────
async function fetchMLBBios(playerIds) {
  const bios = {};
  // MLB API allows hydrating multiple people
  // Batch in groups of 50
  for (let i = 0; i < playerIds.length; i += 50) {
    const batch = playerIds.slice(i, i + 50).join(',');
    try {
      const res = await httpGet(`${MLB}/people?personIds=${batch}&hydrate=currentTeam,stats(type=[career,yearByYear],group=[hitting,pitching])`, {});
      if (res.data && res.data.people) {
        res.data.people.forEach(p => {
          bios[p.id] = {
            mlb_id: p.id,
            full_name: p.fullName || '',
            first_name: p.firstName || '',
            last_name: p.lastName || '',
            birth_date: p.birthDate || null,
            birth_city: p.birthCity || null,
            birth_state: p.birthStateProvince || null,
            birth_country: p.birthCountry || null,
            height: p.height || null,
            weight: p.weight || null,
            bats: p.batSide ? p.batSide.code : null,
            throws: p.pitchHand ? p.pitchHand.code : null,
            debut_date: p.mlbDebutDate || null,
            position: p.primaryPosition ? p.primaryPosition.abbreviation : null,
            team: p.currentTeam ? p.currentTeam.abbreviation : null,
            team_id: p.currentTeam ? p.currentTeam.id : null,
            number: p.primaryNumber || null,
            active: p.active || false,
            headshot_url: `https://img.mlbstatic.com/mlb-photos/image/upload/d_people:generic:headshot:67:current.png/w_426,q_auto:best/v1/people/${p.id}/headshot/67/current`,
          };
        });
      }
    } catch (e) { console.warn(`[Bios] Batch fetch failed:`, e.message); }
  }
  return bios;
}

// ── Match projections to MLB IDs by name ──────────────────
function matchPlayers(projections, mlbPlayers) {
  const mlbByName = {};
  Object.values(mlbPlayers).forEach(p => {
    mlbByName[p.full_name.toLowerCase()] = p;
    // Also try last, first
    const key2 = `${p.last_name}, ${p.first_name}`.toLowerCase();
    mlbByName[key2] = p;
  });

  const matched = [];
  projections.forEach(proj => {
    const key = proj.full_name.toLowerCase();
    const mlb = mlbByName[key];
    if (mlb) {
      matched.push({ ...mlb, projected_stats: proj.projected_stats, fantasy_id: proj.fantasy_id });
    }
  });
  return matched;
}

// ── Calculate BUY/HOLD/SELL signal ────────────────────────
function calcSignal(actual2025, projected, cardPrice) {
  // Compare key stats: projected vs actual
  // Hitter: AVG, HR, RBI, OPS
  // Pitcher: ERA, W, K, WHIP

  let delta = 0; // positive = trending up, negative = trending down

  if (actual2025 && projected) {
    if (projected.avg && actual2025.avg) {
      delta += (parseFloat(projected.avg) - parseFloat(actual2025.avg)) * 200; // AVG movement × 200
    }
    if (projected.hr != null && actual2025.homeRuns != null) {
      delta += (projected.hr - actual2025.homeRuns) * 0.5; // HR delta
    }
    if (projected.rbi != null && actual2025.rbi != null) {
      delta += (projected.rbi - actual2025.rbi) * 0.3; // RBI delta
    }
    if (projected.ops && actual2025.ops) {
      delta += (parseFloat(projected.ops) - parseFloat(actual2025.ops)) * 50; // OPS movement
    }
    // Pitching (lower ERA = better, so invert)
    if (projected.era && actual2025.era) {
      delta -= (parseFloat(projected.era) - parseFloat(actual2025.era)) * 5; // ERA decrease = good
    }
    if (projected.strikeouts != null && actual2025.strikeOuts != null) {
      delta += (projected.strikeouts - actual2025.strikeOuts) * 0.2;
    }
    if (projected.whip && actual2025.whip) {
      delta -= (parseFloat(projected.whip) - parseFloat(actual2025.whip)) * 20; // WHIP decrease = good
    }
  }

  // Normalize to -100 to +100
  const score = Math.max(-100, Math.min(100, Math.round(delta)));

  // Signal thresholds
  let signal = 'HOLD';
  if (score >= 15) signal = 'BUY';
  else if (score <= -15) signal = 'SELL';

  // Price factor: if card is cheap AND stats trending up = strong BUY
  // if card is expensive AND stats trending down = strong SELL
  let strength = 'moderate';
  if (cardPrice != null) {
    if (signal === 'BUY' && cardPrice < 10) strength = 'strong';
    if (signal === 'SELL' && cardPrice > 20) strength = 'strong';
  }

  return { signal, strength, score };
}

// ── Main handler ──────────────────────────────────────────
exports.handler = async (event) => {
  const headers = {
    'Access-Control-Allow-Origin': 'https://isosandbox.com',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Content-Type': 'application/json',
  };

  if (event.httpMethod === 'OPTIONS') return { statusCode: 200, headers, body: '' };
  if (event.httpMethod !== 'POST') return { statusCode: 405, headers, body: '{"error":"Method not allowed"}' };

  try {
    const body = JSON.parse(event.body || '{}');
    const action = body.action || 'refresh';
    const yr = body.year || new Date().getFullYear();

    if (action === 'refresh') {
      console.log(`[Player Profiles] Starting refresh for ${yr}`);

      // 1. Fetch current season stats from MLB API (top players)
      const [hRes, pRes] = await Promise.all([
        httpGet(`${MLB}/stats?stats=season&group=hitting&season=${yr}&sportId=1&limit=200&sortStat=onBasePlusSlugging&order=desc`, {}),
        httpGet(`${MLB}/stats?stats=season&group=pitching&season=${yr}&sportId=1&limit=100&sortStat=earnedRunAverage&order=asc`, {}),
      ]);

      const extractSplits = (d) => (d.data && d.data.stats && d.data.stats[0] && d.data.stats[0].splits) || [];
      const hitters = extractSplits(hRes);
      const pitchers = extractSplits(pRes).filter(s => parseFloat(s.stat.inningsPitched) >= 10);

      // Collect unique player IDs
      const pidSet = new Set();
      hitters.forEach(s => pidSet.add(s.player.id));
      pitchers.forEach(s => pidSet.add(s.player.id));
      const allPids = [...pidSet];

      console.log(`[Player Profiles] ${allPids.length} unique players from MLB stats`);

      // 2. Fetch bios
      const bios = await fetchMLBBios(allPids);
      console.log(`[Player Profiles] ${Object.keys(bios).length} bios fetched`);

      // 3. Fetch projections (next year or current year)
      const projections = await fetchProjections(yr);
      console.log(`[Player Profiles] ${projections.length} projections fetched`);

      // 4. Build player profiles with current stats + projections + signals
      const profiles = [];
      const statsByPid = {};
      hitters.forEach(s => { statsByPid[s.player.id] = { type: 'hitter', stats: s.stat }; });
      pitchers.forEach(s => {
        if (statsByPid[s.player.id]) {
          statsByPid[s.player.id].pitching = s.stat;
        } else {
          statsByPid[s.player.id] = { type: 'pitcher', stats: s.stat };
        }
      });

      // Match projections by name
      const projByName = {};
      projections.forEach(p => { projByName[p.full_name.toLowerCase()] = p; });

      allPids.forEach(pid => {
        const bio = bios[pid];
        if (!bio) return;
        const current = statsByPid[pid];
        if (!current) return;

        const proj = projByName[bio.full_name.toLowerCase()];
        const projStats = proj ? proj.projected_stats : null;
        const signal = calcSignal(current.stats, projStats, null); // price filled later

        profiles.push({
          mlb_id: pid,
          full_name: bio.full_name,
          first_name: bio.first_name,
          last_name: bio.last_name,
          position: bio.position,
          team: bio.team,
          team_id: bio.team_id,
          birth_date: bio.birth_date,
          birth_city: bio.birth_city,
          birth_state: bio.birth_state,
          birth_country: bio.birth_country,
          height: bio.height,
          weight: bio.weight,
          bats: bio.bats,
          throws: bio.throws,
          debut_date: bio.debut_date,
          jersey_number: bio.number,
          active: bio.active,
          headshot_url: bio.headshot_url,
          player_type: current.type,
          season_stats: current.stats,
          projected_stats: projStats,
          projection_delta: signal.score,
          iso_signal: signal.signal,
          iso_signal_strength: signal.strength,
          updated_at: new Date().toISOString(),
        });
      });

      console.log(`[Player Profiles] ${profiles.length} profiles built`);

      // 5. Upsert to Supabase (players table)
      let upserted = 0;
      for (let i = 0; i < profiles.length; i += 50) {
        const chunk = profiles.slice(i, i + 50);
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
        else console.error(`[Player Profiles] Upsert error: ${res.status} ${res.body.slice(0,200)}`);
      }

      return {
        statusCode: 200,
        headers,
        body: JSON.stringify({
          success: true,
          total_profiles: profiles.length,
          upserted,
          projections_matched: profiles.filter(p => p.projected_stats).length,
          buy_signals: profiles.filter(p => p.iso_signal === 'BUY').length,
          sell_signals: profiles.filter(p => p.iso_signal === 'SELL').length,
        }),
      };
    }

    // Action: lookup single player
    if (action === 'lookup') {
      const { mlb_id, name } = body;
      if (!mlb_id && !name) return { statusCode: 400, headers, body: '{"error":"mlb_id or name required"}' };

      let query = '';
      if (mlb_id) query = `mlb_id=eq.${mlb_id}`;
      else query = `full_name=ilike.*${encodeURIComponent(name)}*`;

      const res = await httpGet(`${SB_URL}/rest/v1/players?${query}&limit=5`, {
        'apikey': SB_KEY,
        'Authorization': `Bearer ${SB_KEY}`,
      });

      return { statusCode: 200, headers, body: JSON.stringify(res.data || []) };
    }

    return { statusCode: 400, headers, body: '{"error":"Unknown action"}' };

  } catch (err) {
    console.error('[Player Profiles] Error:', err);
    return { statusCode: 500, headers, body: JSON.stringify({ error: err.message }) };
  }
};
