#!/usr/bin/env python3
"""Merge card_shops_usa_canada.csv into card_shops_import.csv, dedup, no nulls."""
import csv, re

STATE_CODES = {'AL','AK','AZ','AR','CA','CO','CT','DE','FL','GA','HI','ID','IL','IN','IA',
    'KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ',
    'NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT',
    'VA','WA','WV','WI','WY','DC'}
CA_PROVS = {'AB','BC','MB','NB','NL','NS','NT','NU','ON','PE','QC','SK','YT'}

def parse_address(raw_addr):
    raw = raw_addr.strip().rstrip(',').strip()
    raw = re.sub(r',?\s*(USA|United States|Canada)\s*$', '', raw, flags=re.I).strip()
    raw = re.sub(r',?\s*(www\.\S+|https?://\S+)\s*$', '', raw, flags=re.I).strip()
    parts = [p.strip() for p in raw.split(',')]
    street, city, state, zip_code = '', '', '', ''

    # Find the part with state code
    state_idx = -1
    for i, p in enumerate(parts):
        for code in STATE_CODES | CA_PROVS:
            if re.search(r'\b' + code + r'\b', p.upper()):
                state = code
                zm = re.search(r'(\d{5})', p)
                if zm:
                    zip_code = zm.group(1)
                state_idx = i
                break
        if state:
            break

    if state and state_idx >= 0:
        # Everything before state_idx-1 is street, state_idx-1 is city
        if state_idx >= 2:
            street = ', '.join(parts[:state_idx-1])
            city = parts[state_idx-1]
        elif state_idx == 1:
            street = parts[0]
            city = ''
        else:
            street = ''
    else:
        street = raw

    return street.strip().rstrip(','), city.strip(), state, zip_code


def classify(name):
    types = []
    n = name.lower()
    if any(w in n for w in ['sport','baseball','football','basketball']): types.append('Sports')
    if any(w in n for w in ['pokemon','poke']): types.append('Pokemon')
    if any(w in n for w in ['magic','mtg']): types.append('MTG')
    if any(w in n for w in ['comic']): types.append('Comics')
    if any(w in n for w in ['card','tcg','trading']): types.append('TCG')
    if any(w in n for w in ['game','tabletop']): types.append('Games')
    if any(w in n for w in ['hobby','collectible','memorabilia']): types.append('Collectibles')
    if not types: types.append('Cards')
    return types


# Load new file
new_shops = []
with open('Checklist/card_shops_usa_canada.csv', encoding='utf-8') as f:
    for r in csv.DictReader(f):
        new_shops.append(r)

# Load existing
existing = []
with open('Checklist/card_shops_import.csv', encoding='utf-8') as f:
    existing = list(csv.DictReader(f))

existing_names = set(r['name'].lower().strip() for r in existing)
print(f'Existing shops: {len(existing)}')
print(f'New shops to process: {len(new_shops)}')

# Dedup within new file by name+first30 of address
seen = set()
deduped = []
for r in new_shops:
    name = r.get('shop_name', '').strip()
    addr = r.get('address', '').strip()
    phone = r.get('phone', '').strip()
    if not name or not addr or not phone:
        continue
    key = f"{name.lower()}|{addr[:30].lower()}"
    if key in seen:
        continue
    seen.add(key)
    deduped.append(r)

print(f'After internal dedup + require name/addr/phone: {len(deduped)}')

# Parse and build rows
new_rows = []
for r in deduped:
    name = r['shop_name'].strip()
    raw_addr = r['address'].strip()
    phone = r.get('phone', '').strip()
    website = r.get('website', '').strip()
    country_raw = r.get('country', '').strip()

    street, city, state, zip_code = parse_address(raw_addr)
    country = 'CA' if 'canada' in country_raw.lower() or state in CA_PROVS else 'US'

    if not state:
        continue

    new_rows.append({
        'name': name,
        'address': street,
        'city': city,
        'state': state,
        'country': country,
        'zip': zip_code,
        'phone': phone,
        'lat': '',
        'lng': '',
        'region': '',
        'types': '{' + ','.join(classify(name)) + '}',
        'hours': '',
        'website': website,
        'notes': '',
        'google_place_id': '',
        'source': 'directory_list',
        'verified': 'false',
        'active': 'true',
    })

print(f'Parsed with state: {len(new_rows)}')

# Merge
added = 0
for r in new_rows:
    if r['name'].lower().strip() not in existing_names:
        existing.append(r)
        existing_names.add(r['name'].lower().strip())
        added += 1

# Filter to complete records only: name + address + state + phone required
final = []
for r in existing:
    name = r.get('name', '').strip()
    addr = r.get('address', '').strip()
    state = r.get('state', '').strip()
    phone = r.get('phone', '').strip()
    if name and addr and state and phone:
        final.append(r)

fieldnames = ['name', 'address', 'city', 'state', 'country', 'zip', 'phone',
    'lat', 'lng', 'region', 'types', 'hours', 'website', 'notes',
    'google_place_id', 'source', 'verified', 'active']

with open('Checklist/card_shops_import.csv', 'w', newline='', encoding='utf-8') as f:
    w = csv.DictWriter(f, fieldnames=fieldnames, quoting=csv.QUOTE_ALL, extrasaction='ignore')
    w.writeheader()
    for r in sorted(final, key=lambda x: (x.get('country', ''), x.get('state', ''), x.get('city', ''), x.get('name', ''))):
        w.writerow(r)

print(f'\nNew shops added from directory list: {added}')
print(f'Final total (complete records only - name/addr/state/phone): {len(final)}')
tn = sum(1 for r in final if r.get('state') == 'TN')
nc = sum(1 for r in final if r.get('state') == 'NC')
print(f'TN: {tn}')
print(f'NC: {nc}')
