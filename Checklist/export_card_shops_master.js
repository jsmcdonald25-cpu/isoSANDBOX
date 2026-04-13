const fs = require('fs');
const path = require('path');

const inputPath = path.join(__dirname, 'card_shops_import.csv');
const outputPath = path.join(__dirname, 'card_shops_master_clean.csv');

const chainNamePatterns = [
  /\bwalmart\b/i,
  /\btarget\b/i,
  /\bcvs\b/i,
  /\bwalgreens\b/i,
  /\bgamestop\b/i,
  /\beb games\b/i,
  /\bthe ups store\b/i,
  /\bbest buy\b/i,
];

const junkNamePatterns = [
  /\bdirectory\b/i,
  /\bnear\b/i,
  /\bphotos and videos\b/i,
  /\be-gift cards\b/i,
  /\belectronics store\b/i,
  /\bSportsCardForum\b/i,
  /\bMiscellaneous Retail/i,
  /\bA retail store in\b/i,
  /^\(\d{3}\)/,             // name starts with phone number
  /^\d{3}-\d{3}/,           // name is a phone number
  /\bStores, Nec\b/i,
  /\bsportscard-stores\.com\b/i,
];

const blockedWebsitePatterns = [
  /chamberofcommerce\.com/i,
  /cdncompanies\.com/i,
  /showmelocal\.com/i,
  /sportscard-stores\.com/i,
  /discoverdurham\.com/i,
  /alberta-local\./i,
  /theupsstore\.com/i,
  /ebay\./i,
  /yelp\./i,
  /kijiji\./i,
  /anycard\.com/i,
];

function parseCsv(text) {
  const rows = [];
  let row = [];
  let field = '';
  let inQuotes = false;

  for (let i = 0; i < text.length; i += 1) {
    const ch = text[i];
    const next = text[i + 1];

    if (ch === '"') {
      if (inQuotes && next === '"') {
        field += '"';
        i += 1;
      } else {
        inQuotes = !inQuotes;
      }
      continue;
    }

    if (ch === ',' && !inQuotes) {
      row.push(field);
      field = '';
      continue;
    }

    if ((ch === '\n' || ch === '\r') && !inQuotes) {
      if (ch === '\r' && next === '\n') {
        i += 1;
      }
      row.push(field);
      field = '';
      if (row.length > 1 || row[0] !== '') {
        rows.push(row);
      }
      row = [];
      continue;
    }

    field += ch;
  }

  if (field.length || row.length) {
    row.push(field);
    rows.push(row);
  }

  const headers = rows.shift() || [];
  return rows.map((cols) => {
    const obj = {};
    headers.forEach((header, index) => {
      obj[header] = cols[index] ?? '';
    });
    return obj;
  });
}

function csvEscape(value) {
  const text = String(value ?? '');
  return `"${text.replace(/"/g, '""')}"`;
}

function normalizeText(value) {
  return String(value || '').trim();
}

function normalizeName(value) {
  return normalizeText(value)
    .replace(/\s+/g, ' ')
    .replace(/[–—]/g, '-')
    .trim();
}

function parseNotes(notes) {
  const result = {
    email: '',
    facebook_url: '',
    instagram_url: '',
    ebay_url: '',
    tcgplayer_url: '',
    x_url: '',
    discord: '',
    other_notes: '',
  };

  const parts = String(notes || '')
    .split('|')
    .map((part) => part.trim())
    .filter(Boolean);

  const other = [];
  for (const part of parts) {
    const lower = part.toLowerCase();
    if (lower.startsWith('email:')) {
      result.email = part.slice(6).trim();
      continue;
    }
    if (lower.startsWith('facebook:')) {
      result.facebook_url = part.slice(9).trim();
      continue;
    }
    if (lower.startsWith('instagram:')) {
      result.instagram_url = part.slice(10).trim();
      continue;
    }
    if (lower.startsWith('ebay:')) {
      result.ebay_url = part.slice(5).trim();
      continue;
    }
    if (lower.startsWith('tcgplayer:')) {
      result.tcgplayer_url = part.slice(10).trim();
      continue;
    }
    if (lower.startsWith('x:')) {
      result.x_url = part.slice(2).trim();
      continue;
    }
    if (lower.startsWith('discord:')) {
      result.discord = part.slice(8).trim();
      continue;
    }
    if (lower !== 'enriched:yes') {
      other.push(part);
    }
  }

  result.other_notes = other.join(' | ');
  return result;
}

function looksBad(row, parsed) {
  const name = normalizeName(row.name);
  const website = normalizeText(row.website);

  if (!name || !row.address || !row.city || !row.state || !row.phone) {
    return true;
  }

  if (chainNamePatterns.some((pattern) => pattern.test(name))) {
    return true;
  }

  if (junkNamePatterns.some((pattern) => pattern.test(name))) {
    return true;
  }

  if (blockedWebsitePatterns.some((pattern) => pattern.test(website))) {
    return true;
  }

  if (/^https?:\/\/(www\.)?instagram\.com\/[^/]+\/?$/i.test(website) && /@/.test(name)) {
    return true;
  }

  if (/^https?:\/\/(www\.)?facebook\.com\/profile\.php/i.test(website)) {
    return true;
  }

  if (/bootstrap@/i.test(parsed.email)) {
    return true;
  }

  // Address contains "in<CityName>" glued together — scraper artifact
  if (/\bin[A-Z][a-z]/.test(row.address || '')) {
    return true;
  }

  // Name is clearly a scraped page title (too long, contains URLs or descriptions)
  if (name.length > 80) {
    return true;
  }

  // Name contains "Leave Us A Review" or similar scraped junk
  if (/leave us a review|follow us|tiktok:|visit the website/i.test(name)) {
    return true;
  }

  // Name is clearly a scraped listing, not a shop
  if (/\bstorage unit auction\b|\bupcoming.*card shows\b|\b\d+ best\b/i.test(name)) {
    return true;
  }

  // Address has scraped junk glued in (e.g. "341 Loudon RoadConcord")
  if (/[a-z][A-Z]/.test(row.address || '') && !/Suite|NW|NE|SW|SE|LLC|Ave|St/.test(row.address || '')) {
    // camelCase in address usually means glued scraper text — but allow normal abbreviations
    const addr = row.address || '';
    if (/[a-z]{3,}[A-Z][a-z]{3,}/.test(addr)) {
      return true;
    }
  }

  // Phone area code doesn't match state — strong signal of misassigned state from scrapers
  // Only filter scraped sources, not manual or osm
  const src = normalizeText(row.source);
  if (src.startsWith('ddg') || src === 'sportscardportal') {
    const city = normalizeText(row.city).toLowerCase();
    const state = normalizeText(row.state);
    // Known misassignments: state=IN but city is not in Indiana
    if (state === 'IN') {
      const indianaCities = new Set([
        'indianapolis','fort wayne','bloomington','evansville','south bend',
        'lafayette','muncie','terre haute','columbus','anderson','kokomo',
        'richmond','bedford','greenwood','carmel','fishers','noblesville',
        'avon','plainfield','greenfield','shelbyville','martinsville',
        'connersville','vincennes','new albany','jeffersonville','lawrence',
        'speedway','brownsburg','danville','westfield','zionsville',
        'mishawaka','goshen','elkhart','valparaiso','michigan city',
        'crown point','schererville','merrillville','highland','hammond',
        'gary','portage','hobart','chesterton','warsaw','marion',
        'logansport','peru','huntington','wabash','decatur','angola',
        'auburn','kendallville','seymour','jasper','scottsburg',
        'madison','frankfort','crawfordsville','lebanon','greensburg',
        'batesville','lawrenceburg','tell city','linton','sullivan',
        'washington','princeton','mount vernon','newburgh','boonville',
        'west lafayette','jeffersonville','clarksville','sellersburg',
      ]);
      if (!indianaCities.has(city)) {
        return true;
      }
    }
  }

  return false;
}

function splitEmail(value) {
  return String(value || '')
    .split(',')
    .map((entry) => entry.trim())
    .filter(Boolean)
    .join('; ');
}

const seedPath = path.join(__dirname, '..', 'card_shops.csv');

function parseSeedRow(line) {
  // Seed CSV: Area,Name,"full address",Phone,Hours,Specialties,Notes
  const cols = [];
  let field = '';
  let inQ = false;
  for (let i = 0; i < line.length; i++) {
    const ch = line[i];
    if (ch === '"') { inQ = !inQ; continue; }
    if (ch === ',' && !inQ) { cols.push(field); field = ''; continue; }
    field += ch;
  }
  cols.push(field);
  if (cols.length < 7) return null;

  const addrFull = cols[2].trim();
  // Parse "street, city, state zip" from full address
  const addrParts = addrFull.split(',').map(s => s.trim());
  let street = '', city = '', state = '', zip = '';
  if (addrParts.length >= 3) {
    street = addrParts.slice(0, -2).join(', ');
    city = addrParts[addrParts.length - 2];
    const stZip = addrParts[addrParts.length - 1].split(/\s+/);
    state = stZip[0] || '';
    zip = stZip[1] || '';
  }

  const phone = cols[3].trim() === 'Unknown' ? '' : cols[3].trim();
  const specialties = cols[5].trim();
  const types = specialties
    .split(',')
    .map(s => s.trim())
    .filter(s => /Sports|Pokemon|MTG|Yu-Gi-Oh|Comics|Board Games|TCG|Cards|Memorabilia|D&D|Lorcana|Warhammer/i.test(s))
    .join(',');

  return {
    name: cols[1].trim(),
    address: street,
    city: city,
    state: state,
    country: 'US',
    zip: zip,
    phone: phone,
    email: '',
    facebook_url: '',
    instagram_url: '',
    website: '',
    x_url: '',
    discord: '',
    ebay_url: '',
    tcgplayer_url: '',
    types: types || specialties,
    hours: cols[4].trim(),
    lat: '',
    lng: '',
    source: 'manual_seed',
    notes: cols[6].trim(),
  };
}

function main() {
  const text = fs.readFileSync(inputPath, 'utf8');
  const rows = parseCsv(text);
  const deduped = new Map();
  const phoneIndex = new Map(); // phone → nameKey for cross-matching

  for (const row of rows) {
    const parsed = parseNotes(row.notes);
    if (looksBad(row, parsed)) {
      continue;
    }

    const clean = {
      name: normalizeName(row.name),
      address: normalizeText(row.address),
      city: normalizeText(row.city),
      state: normalizeText(row.state),
      country: normalizeText(row.country),
      zip: normalizeText(row.zip),
      phone: normalizeText(row.phone),
      email: splitEmail(parsed.email),
      facebook_url: parsed.facebook_url,
      instagram_url: parsed.instagram_url,
      website: normalizeText(row.website),
      x_url: parsed.x_url,
      discord: parsed.discord,
      ebay_url: parsed.ebay_url,
      tcgplayer_url: parsed.tcgplayer_url,
      types: normalizeText(row.types).replace(/^\{|\}$/g, ''),
      hours: normalizeText(row.hours),
      lat: normalizeText(row.lat),
      lng: normalizeText(row.lng),
      source: normalizeText(row.source),
      notes: parsed.other_notes,
    };

    if (/facebook\.com/i.test(clean.website) && !clean.facebook_url) {
      clean.facebook_url = clean.website;
      clean.website = '';
    }
    if (/instagram\.com/i.test(clean.website) && !clean.instagram_url) {
      clean.instagram_url = clean.website;
      clean.website = '';
    }

    // Normalize name for dedup: lowercase, strip punctuation, collapse whitespace
    const normName = clean.name.toLowerCase()
      .replace(/[''`]/g, '')
      .replace(/&/g, 'and')
      .replace(/[^a-z0-9\s]/g, ' ')
      .replace(/\s+/g, ' ')
      .trim();
    const normCity = clean.city.toLowerCase().replace(/[^a-z0-9]/g, '');
    const phone10 = clean.phone.replace(/\D/g, '').slice(-10);

    // Primary key: normalized name + city
    const nameKey = normName + '|' + normCity;

    // Phone key: last 10 digits (if we have one)
    const phoneKey = phone10.length >= 7 ? phone10 : null;

    // Check for existing match by name+city OR by phone
    let existing = deduped.get(nameKey);
    let matchKey = nameKey;
    if (!existing && phoneKey && phoneIndex.has(phoneKey)) {
      matchKey = phoneIndex.get(phoneKey);
      existing = deduped.get(matchKey);
    }

    if (!existing) {
      deduped.set(nameKey, clean);
      if (phoneKey) phoneIndex.set(phoneKey, nameKey);
      continue;
    }

    // Merge: keep the row with more data, backfill missing fields
    if (!existing.email && clean.email) existing.email = clean.email;
    if (!existing.facebook_url && clean.facebook_url) existing.facebook_url = clean.facebook_url;
    if (!existing.instagram_url && clean.instagram_url) existing.instagram_url = clean.instagram_url;
    if (!existing.website && clean.website) existing.website = clean.website;
    if (!existing.ebay_url && clean.ebay_url) existing.ebay_url = clean.ebay_url;
    if (!existing.tcgplayer_url && clean.tcgplayer_url) existing.tcgplayer_url = clean.tcgplayer_url;
    if (!existing.hours && clean.hours) existing.hours = clean.hours;
    if (!existing.notes && clean.notes) existing.notes = clean.notes;
    if (!existing.phone && clean.phone) existing.phone = clean.phone;
    if (!existing.address && clean.address) existing.address = clean.address;
    if (!existing.zip && clean.zip) existing.zip = clean.zip;
    if ((!existing.lat || existing.lat === '0') && clean.lat && clean.lat !== '0') existing.lat = clean.lat;
    if ((!existing.lng || existing.lng === '0') && clean.lng && clean.lng !== '0') existing.lng = clean.lng;
    // Prefer shorter/cleaner name (scraped names often have junk appended)
    if (clean.name.length < existing.name.length && clean.name.length > 3) existing.name = clean.name;
  }

  // Backfill from old seed file — add any manually curated shops missing from import
  let seedBackfilled = 0;
  if (fs.existsSync(seedPath)) {
    const seedText = fs.readFileSync(seedPath, 'utf8');
    const seedLines = seedText.split('\n').slice(1).filter(l => l.trim());
    for (const line of seedLines) {
      const row = parseSeedRow(line);
      if (!row || !row.name) continue;

      const key = [
        row.name.toLowerCase(),
        row.city.toLowerCase(),
        row.state.toLowerCase(),
        row.phone.replace(/\D/g, ''),
      ].join('|');

      // Also check by name substring match against existing keys
      const nameKey = row.name.toLowerCase();
      let found = deduped.has(key);
      if (!found) {
        for (const [k] of deduped) {
          if (k.startsWith(nameKey.substring(0, 15))) { found = true; break; }
        }
      }

      if (!found) {
        deduped.set(key, row);
        seedBackfilled++;
      }
    }
  }
  if (seedBackfilled > 0) {
    console.log(`Backfilled ${seedBackfilled} shops from seed file`);
  }

  const outputRows = Array.from(deduped.values()).sort((a, b) => {
    return (
      a.country.localeCompare(b.country) ||
      a.state.localeCompare(b.state) ||
      a.city.localeCompare(b.city) ||
      a.name.localeCompare(b.name)
    );
  });

  const headers = [
    'name',
    'address',
    'city',
    'state',
    'country',
    'zip',
    'phone',
    'email',
    'facebook_url',
    'instagram_url',
    'website',
    'x_url',
    'discord',
    'ebay_url',
    'tcgplayer_url',
    'types',
    'hours',
    'lat',
    'lng',
    'source',
    'notes',
  ];

  const lines = [headers.map(csvEscape).join(',')];
  for (const row of outputRows) {
    lines.push(headers.map((header) => csvEscape(row[header])).join(','));
  }

  fs.writeFileSync(outputPath, `${lines.join('\n')}\n`, 'utf8');

  const counts = {
    total: outputRows.length,
    email: outputRows.filter((row) => row.email).length,
    facebook: outputRows.filter((row) => row.facebook_url).length,
    instagram: outputRows.filter((row) => row.instagram_url).length,
    website: outputRows.filter((row) => row.website).length,
  };

  console.log(`Wrote ${counts.total} rows to ${outputPath}`);
  console.log(`With email: ${counts.email}`);
  console.log(`With Facebook: ${counts.facebook}`);
  console.log(`With Instagram: ${counts.instagram}`);
  console.log(`With website: ${counts.website}`);
}

main();
