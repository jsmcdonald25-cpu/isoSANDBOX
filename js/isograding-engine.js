/*  ═══════════════════════════════════════════════════════════════════════
    ISOGrading Scoring Engine  —  isosandbox.com
    12×12 grid (144 cells) · 12 categories · 0–1000 scale
    Shared between isograding-scan.html and dashboard.html
    ═══════════════════════════════════════════════════════════════════════ */

window.ISOGradingEngine = (function () {
  'use strict';

  // ── 12 scoring categories ──────────────────────────────────────────
  const CATEGORIES = [
    // Big 4 (heavier weight)
    'centering', 'corners', 'edges', 'surface',
    // Secondary 8
    'surface_micro', 'light_reflection', 'card_flatness',
    'print_registration', 'border_consistency', 'edge_fiber',
    'corner_geometry', 'handling_wear'
  ];

  const BIG4 = ['centering', 'corners', 'edges', 'surface'];

  // ── Default weights (sum = 1000) ───────────────────────────────────
  const DEFAULT_WEIGHTS = {
    centering: 150, corners: 150, edges: 150, surface: 150,
    surface_micro: 50, light_reflection: 50, card_flatness: 50,
    print_registration: 50, border_consistency: 50, edge_fiber: 50,
    corner_geometry: 50, handling_wear: 50
  };

  // ── Zone multipliers ───────────────────────────────────────────────
  // Each zone type amplifies certain categories and dampens others.
  // A cell's weighted score = base_score × zone_multiplier for that category.
  // Multipliers are normalized so total across all cells still sums to category weight.
  const DEFAULT_ZONE_MULTIPLIERS = {
    corner: {
      centering: 0.8, corners: 2.5, edges: 1.2, surface: 0.5,
      surface_micro: 0.5, light_reflection: 0.6, card_flatness: 0.6,
      print_registration: 0.5, border_consistency: 1.0, edge_fiber: 1.0,
      corner_geometry: 2.5, handling_wear: 0.8
    },
    edge: {
      centering: 0.8, corners: 1.0, edges: 2.5, surface: 0.7,
      surface_micro: 0.7, light_reflection: 0.8, card_flatness: 0.8,
      print_registration: 0.6, border_consistency: 2.0, edge_fiber: 2.5,
      corner_geometry: 0.6, handling_wear: 1.0
    },
    center: {
      centering: 1.5, corners: 0.3, edges: 0.4, surface: 2.0,
      surface_micro: 2.0, light_reflection: 1.5, card_flatness: 1.5,
      print_registration: 2.0, border_consistency: 0.5, edge_fiber: 0.3,
      corner_geometry: 0.3, handling_wear: 1.2
    }
  };

  // ── Grid constants ─────────────────────────────────────────────────
  const ROWS = 12;
  const COLS = 12;
  const CELL_COUNT = ROWS * COLS; // 144
  const ROW_LABELS = 'ABCDEFGHIJKL'.split('');

  // ── Zone classification ────────────────────────────────────────────
  // Corner = cells in 2×2 blocks at each corner
  // Edge   = cells on the outer 2 rows/cols (excluding corners)
  // Center = everything else
  function classifyZone(row, col) {
    var isTop    = row < 2;
    var isBottom = row >= ROWS - 2;
    var isLeft   = col < 2;
    var isRight  = col >= COLS - 2;

    if ((isTop || isBottom) && (isLeft || isRight)) return 'corner';
    if (isTop || isBottom || isLeft || isRight) return 'edge';
    return 'center';
  }

  // ── Cell coordinate helpers ────────────────────────────────────────
  function cellIndex(row, col) { return row * COLS + col; }
  function cellCoords(row, col) { return ROW_LABELS[row] + '-' + (col + 1); }
  function indexToRowCol(idx) { return { row: Math.floor(idx / COLS), col: idx % COLS }; }

  // ── Build zone map (cached) ────────────────────────────────────────
  var _zoneMap = null;
  function getZoneMap() {
    if (_zoneMap) return _zoneMap;
    _zoneMap = new Array(CELL_COUNT);
    for (var r = 0; r < ROWS; r++) {
      for (var c = 0; c < COLS; c++) {
        _zoneMap[cellIndex(r, c)] = classifyZone(r, c);
      }
    }
    return _zoneMap;
  }

  // Count cells per zone type (for normalization)
  function countZones() {
    var zm = getZoneMap();
    var counts = { corner: 0, edge: 0, center: 0 };
    for (var i = 0; i < CELL_COUNT; i++) counts[zm[i]]++;
    return counts;
  }

  // ── Normalization factors ──────────────────────────────────────────
  // For each category, compute how much weight each cell contributes
  // so the total across all 144 cells sums exactly to the category weight.
  //
  //   norm_factor[cat] = weight[cat] / sum_over_all_cells(zone_mult[zone_of_cell][cat])
  //   cell_max[cat][cellIdx] = norm_factor[cat] × zone_mult[zone][cat]
  //
  function buildNormFactors(weights, zoneMults) {
    weights = weights || DEFAULT_WEIGHTS;
    zoneMults = zoneMults || DEFAULT_ZONE_MULTIPLIERS;
    var zm = getZoneMap();
    var factors = {};

    CATEGORIES.forEach(function (cat) {
      var totalMult = 0;
      for (var i = 0; i < CELL_COUNT; i++) {
        totalMult += (zoneMults[zm[i]][cat] || 1.0);
      }
      factors[cat] = weights[cat] / totalMult;
    });

    return factors;
  }

  // ── Score a single cell ────────────────────────────────────────────
  // rawScores: { centering: 0.0–1.0, corners: 0.0–1.0, ... }
  //   1.0 = perfect, 0.0 = destroyed
  // Returns: { centering: weighted_pts, corners: weighted_pts, ... }
  function scoreCell(row, col, rawScores, normFactors, zoneMults) {
    zoneMults = zoneMults || DEFAULT_ZONE_MULTIPLIERS;
    var zone = classifyZone(row, col);
    var result = {};

    CATEGORIES.forEach(function (cat) {
      var raw = (rawScores && rawScores[cat] != null) ? rawScores[cat] : 1.0;
      var mult = zoneMults[zone][cat] || 1.0;
      result[cat] = raw * normFactors[cat] * mult;
    });

    return result;
  }

  // ── Score one side (front or back) ─────────────────────────────────
  // cellDataArray: Array[144] of { centering: 0–1, corners: 0–1, ... }
  //   null/missing entries treated as perfect (1.0)
  // Returns: { centering: total, corners: total, ..., total: sum }
  function scoreSide(cellDataArray, weights, zoneMults) {
    var nf = buildNormFactors(weights, zoneMults);
    var totals = {};
    CATEGORIES.forEach(function (cat) { totals[cat] = 0; });

    for (var i = 0; i < CELL_COUNT; i++) {
      var rc = indexToRowCol(i);
      var raw = (cellDataArray && cellDataArray[i]) || null;
      var cellScores = scoreCell(rc.row, rc.col, raw, nf, zoneMults);
      CATEGORIES.forEach(function (cat) {
        totals[cat] += cellScores[cat];
      });
    }

    var total = 0;
    CATEGORIES.forEach(function (cat) {
      totals[cat] = Math.round(totals[cat] * 10) / 10;
      total += totals[cat];
    });
    totals.total = Math.round(total * 10) / 10;

    return totals;
  }

  // ── Score full card (front + back averaged 50/50) ──────────────────
  function scoreCard(frontCells, backCells, weights, zoneMults) {
    var frontScores = scoreSide(frontCells, weights, zoneMults);
    var backScores  = scoreSide(backCells, weights, zoneMults);

    var breakdown = {};
    CATEGORIES.forEach(function (cat) {
      breakdown[cat] = Math.round(((frontScores[cat] + backScores[cat]) / 2) * 10) / 10;
    });

    var total = 0;
    CATEGORIES.forEach(function (cat) { total += breakdown[cat]; });
    total = Math.round(total * 10) / 10;

    return {
      total: total,
      breakdown: breakdown,
      front: frontScores,
      back: backScores,
      grade: scoreToGrade(total)
    };
  }

  // ── Delta between two scans ────────────────────────────────────────
  function computeDelta(scoreA, scoreB) {
    var delta = {};
    CATEGORIES.forEach(function (cat) {
      delta[cat] = Math.round(((scoreB.breakdown[cat] || 0) - (scoreA.breakdown[cat] || 0)) * 10) / 10;
    });
    delta.total = Math.round(((scoreB.total || 0) - (scoreA.total || 0)) * 10) / 10;
    return delta;
  }

  // ── Grade equivalence mapping ──────────────────────────────────────
  // 0–1000 → traditional 1–10 grades
  var GRADE_TABLE = [
    { min: 985, max: 1000, grade: 10,   label: 'GEM MINT',      tier: 'pristine' },
    { min: 960, max: 984,  grade: 9.5,  label: 'GEM MINT',      tier: 'gem' },
    { min: 920, max: 959,  grade: 9,    label: 'MINT',           tier: 'mint' },
    { min: 880, max: 919,  grade: 8.5,  label: 'NM-MT+',        tier: 'near_mint_plus' },
    { min: 830, max: 879,  grade: 8,    label: 'NM-MT',          tier: 'near_mint' },
    { min: 780, max: 829,  grade: 7.5,  label: 'NM+',            tier: 'nm_plus' },
    { min: 720, max: 779,  grade: 7,    label: 'NM',             tier: 'nm' },
    { min: 650, max: 719,  grade: 6.5,  label: 'EX-MT+',         tier: 'ex_mt_plus' },
    { min: 580, max: 649,  grade: 6,    label: 'EX-MT',           tier: 'ex_mt' },
    { min: 500, max: 579,  grade: 5.5,  label: 'EX+',             tier: 'ex_plus' },
    { min: 420, max: 499,  grade: 5,    label: 'EX',              tier: 'ex' },
    { min: 340, max: 419,  grade: 4.5,  label: 'VG-EX+',          tier: 'vg_ex_plus' },
    { min: 260, max: 339,  grade: 4,    label: 'VG-EX',            tier: 'vg_ex' },
    { min: 200, max: 259,  grade: 3.5,  label: 'VG+',              tier: 'vg_plus' },
    { min: 150, max: 199,  grade: 3,    label: 'VG',               tier: 'vg' },
    { min: 100, max: 149,  grade: 2.5,  label: 'GOOD+',            tier: 'good_plus' },
    { min: 60,  max: 99,   grade: 2,    label: 'GOOD',             tier: 'good' },
    { min: 30,  max: 59,   grade: 1.5,  label: 'FAIR',             tier: 'fair' },
    { min: 0,   max: 29,   grade: 1,    label: 'POOR',             tier: 'poor' }
  ];

  function scoreToGrade(totalScore) {
    totalScore = Math.round(totalScore);
    for (var i = 0; i < GRADE_TABLE.length; i++) {
      if (totalScore >= GRADE_TABLE[i].min) {
        return {
          grade: GRADE_TABLE[i].grade,
          label: GRADE_TABLE[i].label,
          tier: GRADE_TABLE[i].tier,
          range: GRADE_TABLE[i].min + '–' + GRADE_TABLE[i].max
        };
      }
    }
    return { grade: 1, label: 'POOR', tier: 'poor', range: '0–29' };
  }

  // ── Display score (982 → "98.2") ───────────────────────────────────
  function formatScore(score) {
    return (Math.round(score * 10) / 100).toFixed(1);
  }

  // ── Simulated scan data (alpha demo) ───────────────────────────────
  // Generates realistic-looking cell data with zone-appropriate issues.
  // This is placeholder until real vision/manual scoring is wired up.
  function generateDemoData(options) {
    options = options || {};
    var quality = options.quality || 0.94; // 0.0–1.0 baseline quality
    var issueCount = options.issues || 4;

    var cells = new Array(CELL_COUNT);
    var findings = [];
    var zm = getZoneMap();

    // Start all cells near-perfect
    for (var i = 0; i < CELL_COUNT; i++) {
      cells[i] = {};
      CATEGORIES.forEach(function (cat) {
        // Base quality with slight random variance
        cells[i][cat] = Math.min(1.0, quality + (Math.random() * 0.06 - 0.03));
      });
    }

    // Inject realistic issues
    var usedCells = {};
    for (var f = 0; f < issueCount; f++) {
      var idx, zone, rc;
      // Pick a cell we haven't already used
      do {
        idx = Math.floor(Math.random() * CELL_COUNT);
      } while (usedCells[idx]);
      usedCells[idx] = true;

      rc = indexToRowCol(idx);
      zone = zm[idx];

      // Pick issue category biased by zone
      var cat;
      if (zone === 'corner') {
        cat = Math.random() < 0.7 ? 'corners' : (Math.random() < 0.5 ? 'corner_geometry' : 'surface');
      } else if (zone === 'edge') {
        cat = Math.random() < 0.7 ? 'edges' : (Math.random() < 0.5 ? 'edge_fiber' : 'handling_wear');
      } else {
        cat = Math.random() < 0.6 ? 'surface' : (Math.random() < 0.5 ? 'surface_micro' : 'print_registration');
      }

      var severity = Math.random();
      var deduction, sevLabel, desc;

      if (severity < 0.5) {
        // Minor
        cells[idx][cat] = 0.5 + Math.random() * 0.3;
        sevLabel = 'minor';
        desc = _issueDesc(cat, 'minor');
      } else if (severity < 0.85) {
        // Major
        cells[idx][cat] = 0.2 + Math.random() * 0.3;
        sevLabel = 'major';
        desc = _issueDesc(cat, 'major');
      } else {
        // Severe
        cells[idx][cat] = Math.random() * 0.2;
        sevLabel = 'severe';
        desc = _issueDesc(cat, 'severe');
      }

      findings.push({
        cellIndex: idx,
        coords: cellCoords(rc.row, rc.col),
        zone: zone,
        category: cat,
        severity: sevLabel,
        description: desc,
        rawScore: cells[idx][cat]
      });
    }

    return { cells: cells, findings: findings };
  }

  // Issue description generator
  function _issueDesc(cat, severity) {
    var descs = {
      centering:          { minor: 'Slight off-center registration', major: 'Noticeable centering shift', severe: 'Significant misalignment' },
      corners:            { minor: 'Minor corner softness', major: 'Corner whitening visible', severe: 'Corner ding / damage' },
      edges:              { minor: 'Light edge wear', major: 'Edge chipping present', severe: 'Edge delamination' },
      surface:            { minor: 'Hairline surface scratch', major: 'Surface scuff / mark', severe: 'Deep surface damage' },
      surface_micro:      { minor: 'Minor print line', major: 'Visible print defect', severe: 'Significant print flaw' },
      light_reflection:   { minor: 'Slight gloss inconsistency', major: 'Cleaning residue detected', severe: 'Surface treatment damage' },
      card_flatness:      { minor: 'Slight warp detected', major: 'Noticeable bow/bend', severe: 'Significant warping' },
      print_registration: { minor: 'Minor color shift', major: 'Layer misregistration', severe: 'Severe print misalignment' },
      border_consistency: { minor: 'Slight border variance', major: 'Uneven border thickness', severe: 'Major border irregularity' },
      edge_fiber:         { minor: 'Minor fiber lifting', major: 'Edge fraying visible', severe: 'Significant fiber damage' },
      corner_geometry:    { minor: 'Slight corner asymmetry', major: 'Corner rounding uneven', severe: 'Corner geometry distortion' },
      handling_wear:      { minor: 'Light handling marks', major: 'Directional wear pattern', severe: 'Heavy handling damage' }
    };
    return (descs[cat] && descs[cat][severity]) || 'Condition issue detected';
  }

  // ── Heatmap data for grid visualization ────────────────────────────
  // Takes cell data array + category, returns array of 144 severity levels (0–5)
  // 0=perfect, 1=good, 2=ok, 3=minor, 4=issue, 5=severe
  function buildHeatmap(cellDataArray, category) {
    var heatmap = new Array(CELL_COUNT);
    for (var i = 0; i < CELL_COUNT; i++) {
      var raw = (cellDataArray && cellDataArray[i] && cellDataArray[i][category] != null)
        ? cellDataArray[i][category] : 1.0;

      if (raw >= 0.95)      heatmap[i] = 0; // perfect
      else if (raw >= 0.85) heatmap[i] = 1; // good
      else if (raw >= 0.70) heatmap[i] = 2; // ok
      else if (raw >= 0.50) heatmap[i] = 3; // minor
      else if (raw >= 0.25) heatmap[i] = 4; // issue
      else                  heatmap[i] = 5; // severe
    }
    return heatmap;
  }

  // Severity colors for heatmap rendering
  var HEATMAP_COLORS = [
    'rgba(0,204,102,0.10)',   // 0 perfect
    'rgba(0,204,102,0.25)',   // 1 good
    'rgba(0,170,255,0.20)',   // 2 ok
    'rgba(255,140,0,0.25)',   // 3 minor
    'rgba(255,68,68,0.30)',   // 4 issue
    'rgba(255,68,68,0.55)'    // 5 severe
  ];

  var HEATMAP_LABELS = ['Perfect', 'Good', 'OK', 'Minor', 'Issue', 'Severe'];

  // ── 5-Scan pipeline types ──────────────────────────────────────────
  var SCAN_TYPES = [
    { number: 1, key: 'vault_pic',   label: 'Vault Pic',   desc: 'Original upload baseline', requiresQR: false },
    { number: 2, key: 'qr_live',     label: 'QR Live',     desc: 'Seller proof-of-card',     requiresQR: true  },
    { number: 3, key: 'hub_intake',  label: 'Hub Intake',  desc: 'Raw condition at arrival',  requiresQR: true  },
    { number: 4, key: 'prepped',     label: 'Prepped',     desc: 'After cleaning/stabilization', requiresQR: true },
    { number: 5, key: 'post_prep',   label: 'Post-Prep',   desc: 'Final scan before shipping', requiresQR: true  }
  ];

  // ── Public API ─────────────────────────────────────────────────────
  return {
    CATEGORIES:       CATEGORIES,
    BIG4:             BIG4,
    ROWS:             ROWS,
    COLS:             COLS,
    CELL_COUNT:       CELL_COUNT,
    ROW_LABELS:       ROW_LABELS,
    SCAN_TYPES:       SCAN_TYPES,
    GRADE_TABLE:      GRADE_TABLE,
    HEATMAP_COLORS:   HEATMAP_COLORS,
    HEATMAP_LABELS:   HEATMAP_LABELS,
    DEFAULT_WEIGHTS:  DEFAULT_WEIGHTS,
    DEFAULT_ZONE_MULTIPLIERS: DEFAULT_ZONE_MULTIPLIERS,

    classifyZone:     classifyZone,
    cellIndex:        cellIndex,
    cellCoords:       cellCoords,
    indexToRowCol:    indexToRowCol,
    getZoneMap:       getZoneMap,
    countZones:       countZones,
    buildNormFactors: buildNormFactors,
    scoreCell:        scoreCell,
    scoreSide:        scoreSide,
    scoreCard:        scoreCard,
    computeDelta:     computeDelta,
    scoreToGrade:     scoreToGrade,
    formatScore:      formatScore,
    generateDemoData: generateDemoData,
    buildHeatmap:     buildHeatmap
  };
})();
