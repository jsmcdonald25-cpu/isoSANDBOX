#!/usr/bin/env python3
"""
Card Shop Scraper — DuckDuckGo Text Search (free, no API key)
Uses duckduckgo_search to find card shops, then geocodes via Nominatim.
Merges into card_shops_import.csv.

Usage: py Checklist/scrape_ddg.py
Requires: pip install duckduckgo_search requests
"""

import csv
import re
import time
import random
import requests
from pathlib import Path
from duckduckgo_search import DDGS

OUTPUT_FILE = Path(__file__).parent / 'card_shops_ddg.csv'
MERGED_FILE = Path(__file__).parent / 'card_shops_import.csv'

SEARCH_QUERIES = [
    'trading card shops near',
    'sports card stores in',
    'pokemon card shops in',
    'local game stores in',
    'comic book stores in',
    'best card shops in',
]

LOCATIONS = [
    # All 50 states
    'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado',
    'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho',
    'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana',
    'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi',
    'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey',
    'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma',
    'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota',
    'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington',
    'West Virginia', 'Wisconsin', 'Wyoming',
    # Key metros
    'Chattanooga TN', 'Nashville TN', 'Knoxville TN', 'Memphis TN',
    'Charlotte NC', 'Raleigh NC', 'Atlanta GA', 'Chicago IL',
    'New York City', 'Los Angeles', 'Houston TX', 'Phoenix AZ',
    'Philadelphia', 'San Diego', 'Dallas TX', 'Austin TX',
    'Seattle', 'Denver', 'Miami', 'Tampa FL', 'Orlando FL',
    'Detroit', 'Minneapolis', 'Cleveland OH', 'Cincinnati OH',
    'Pittsburgh', 'St Louis', 'Kansas City', 'Indianapolis',
    'Portland OR', 'Las Vegas', 'Salt Lake City', 'Boston',
    'Toronto Canada', 'Vancouver Canada', 'Montreal Canada', 'Calgary Canada',
]

STATE_NAME_TO_CODE = {
    'alabama': 'AL', 'alaska': 'AK', 'arizona': 'AZ', 'arkansas': 'AR',
    'california': 'CA', 'colorado': 'CO', 'connecticut': 'CT', 'delaware': 'DE',
    'florida': 'FL', 'georgia': 'GA', 'hawaii': 'HI', 'idaho': 'ID',
    'illinois': 'IL', 'indiana': 'IN', 'iowa': 'IA', 'kansas': 'KS',
    'kentucky': 'KY', 'louisiana': 'LA', 'maine': 'ME', 'maryland': 'MD',
    'massachusetts': 'MA', 'michigan': 'MI', 'minnesota': 'MN', 'mississippi': 'MS',
    'missouri': 'MO', 'montana': 'MT', 'nebraska': 'NE', 'nevada': 'NV',
    'new hampshire': 'NH', 'new jersey': 'NJ', 'new mexico': 'NM', 'new york': 'NY',
    'north carolina': 'NC', 'north dakota': 'ND', 'ohio': 'OH', 'oklahoma': 'OK',
    'oregon': 'OR', 'pennsylvania': 'PA', 'rhode island': 'RI', 'south carolina': 'SC',
    'south dakota': 'SD', 'tennessee': 'TN', 'texas': 'TX', 'utah': 'UT',
    'vermont': 'VT', 'virginia': 'VA', 'washington': 'WA', 'west virginia': 'WV',
    'wisconsin': 'WI', 'wyoming': 'WY',
}
STATE_CODES = set(STATE_NAME_TO_CODE.values())
CA_PROVS = {'AB', 'BC', 'MB', 'NB', 'NL', 'NS', 'NT', 'NU', 'ON', 'PE', 'QC', 'SK', 'YT'}


def parse_state(text, search_loc):
    """Extract state code from text or search location."""
    if not text:
        text = ''
    text_upper = text.upper()
    for code in STATE_CODES:
        if f', {code} ' in text_upper or f', {code},' in text_upper or text_upper.endswith(f', {code}') or f' {code} ' in text_upper:
            return code, 'US'
    for code in CA_PROVS:
        if f', {code} ' in text_upper or f', {code},' in text_upper:
            return code, 'CA'
    loc_lower = search_loc.lower().strip()
    if 'canada' in loc_lower:
        return '', 'CA'
    for name, code in STATE_NAME_TO_CODE.items():
        if name in loc_lower or code in search_loc.upper().split():
            return code, 'US'
    return '', 'US'


def geocode(query):
    """Geocode an address using Nominatim (free, 1 req/sec)."""
    try:
        resp = requests.get(
            'https://nominatim.openstreetmap.org/search',
            params={'q': query, 'format': 'json', 'limit': 1},
            headers={'User-Agent': 'GrailISO-CardShopScraper/1.0'},
            timeout=10
        )
        if resp.status_code == 200:
            data = resp.json()
            if data:
                return float(data[0]['lat']), float(data[0]['lon'])
    except Exception:
        pass
    return 0.0, 0.0


def classify_types(name):
    """Guess shop types from name."""
    types = []
    n = name.lower()
    if any(w in n for w in ['sport', 'baseball', 'football', 'basketball']):
        types.append('Sports')
    if any(w in n for w in ['pokemon', 'poke']):
        types.append('Pokemon')
    if any(w in n for w in ['magic', 'mtg']):
        types.append('MTG')
    if any(w in n for w in ['yugioh', 'yu-gi-oh']):
        types.append('Yu-Gi-Oh')
    if any(w in n for w in ['comic']):
        types.append('Comics')
    if any(w in n for w in ['card', 'tcg', 'trading']):
        types.append('TCG')
    if any(w in n for w in ['game', 'tabletop', 'dice', 'board']):
        types.append('Games')
    if any(w in n for w in ['hobby', 'collectible', 'collector']):
        types.append('Collectibles')
    if not types:
        types.append('Cards')
    return types


def extract_shops_from_results(results, search_loc):
    """Parse DDG text search results into shop entries."""
    shops = []
    for r in results:
        title = r.get('title', '')
        body = r.get('body', '')
        href = r.get('href', '')

        # Skip aggregator/directory pages
        skip_domains = ['yelp.com/search', 'yellowpages.com/search', 'mapquest.com',
                        'facebook.com/search', 'tripadvisor.com', 'groupon.com',
                        'google.com/maps', 'bbb.org/search', 'foursquare.com/explore']
        if any(d in href for d in skip_domains):
            continue

        # Try to extract a shop name — clean up title
        name = title.split(' - ')[0].split(' | ')[0].split(' :: ')[0].strip()
        # Remove trailing location info like "... in Nashville"
        name = re.sub(r'\s+in\s+\w[\w\s,]+$', '', name).strip()
        # Remove "Best X" / "Top X" / "X Best" prefixes
        name = re.sub(r'^(best|top|\d+\s+best|\d+\s+top)\s+', '', name, flags=re.IGNORECASE).strip()

        if not name or len(name) < 3 or len(name) > 80:
            continue

        # Skip list/article pages
        list_patterns = ['best card shops', 'top 10', 'top card', 'where to buy',
                         'guide to', 'list of', 'directory', 'review of']
        if any(p in name.lower() for p in list_patterns):
            continue

        # Check if this looks like a real business (has address-like content)
        all_text = f'{title} {body}'.lower()
        card_keywords = ['card', 'game', 'comic', 'pokemon', 'tcg', 'mtg', 'hobby',
                         'collectible', 'sport', 'trading', 'tabletop']
        if not any(kw in all_text for kw in card_keywords):
            continue

        # Try to extract address from body text
        addr_match = re.search(r'(\d{1,5}\s+[\w\s]+(?:St|Ave|Rd|Dr|Blvd|Ln|Way|Pike|Pkwy|Hwy|Court|Ct|Circle|Cir|Place|Pl|Trail|Trl)[\w\s.,#]*)', body)
        address = addr_match.group(1).strip() if addr_match else ''

        state, country = parse_state(f'{body} {title}', search_loc)

        shops.append({
            'name': name,
            'address': address,
            'state': state,
            'country': country,
            'website': href if 'yelp.com' not in href and 'yellowpages' not in href else '',
            'body': body,
        })

    return shops


def main():
    print('=== Card Shop Scraper -- DuckDuckGo Text (free, no API key) ===')
    print(f'Searching {len(LOCATIONS)} locations x {len(SEARCH_QUERIES)} queries')
    print(f'Output: {OUTPUT_FILE}')
    print()

    all_shops = {}  # dedup by lowercase name + state
    total = len(LOCATIONS) * len(SEARCH_QUERIES)
    done = 0
    errors = 0
    geocode_queue = []

    ddgs = DDGS()

    for loc in LOCATIONS:
        for query in SEARCH_QUERIES:
            done += 1
            search_term = f'{query} {loc}'
            print(f'  [{done}/{total}] "{search_term}"...', end='', flush=True)

            try:
                results = list(ddgs.text(search_term, max_results=15))
                shops = extract_shops_from_results(results, loc)
                new = 0
                for s in shops:
                    key = s['name'].lower().strip()
                    if key in all_shops:
                        continue
                    all_shops[key] = s
                    new += 1

                print(f' {len(results)} results, {len(shops)} shops, {new} new (total: {len(all_shops)})')

            except Exception as e:
                errors += 1
                err_msg = str(e)[:60]
                print(f' ERROR: {err_msg}')
                if 'ratelimit' in err_msg.lower() or '429' in err_msg or 'too many' in err_msg.lower():
                    print('    Rate limited -- waiting 45s...')
                    time.sleep(45)

            time.sleep(random.uniform(1.5, 3.0))

    print(f'\nTotal unique shops from DDG text search: {len(all_shops)}')
    if errors:
        print(f'Errors encountered: {errors}')

    # Geocode shops that have addresses
    print(f'\nGeocoding shops with addresses (1 req/sec, Nominatim)...')
    geocoded = 0
    shops_list = list(all_shops.values())
    for i, s in enumerate(shops_list):
        addr = s.get('address', '')
        state = s.get('state', '')
        if addr and state:
            query = f"{addr}, {state}"
            lat, lng = geocode(query)
            if lat and lng:
                s['lat'] = lat
                s['lng'] = lng
                geocoded += 1
            time.sleep(1.1)  # Nominatim rate limit
            if (i+1) % 25 == 0:
                print(f'  Geocoded {i+1}/{len(shops_list)} ({geocoded} successful)...')
    print(f'  Geocoded {geocoded}/{len(shops_list)} shops')

    # Build final rows
    rows = []
    for s in shops_list:
        rows.append({
            'name': s['name'],
            'address': s.get('address', ''),
            'city': '',
            'state': s.get('state', ''),
            'country': s.get('country', 'US'),
            'zip': '',
            'phone': '',
            'lat': s.get('lat', 0),
            'lng': s.get('lng', 0),
            'region': '',
            'types': '{' + ','.join(classify_types(s['name'])) + '}',
            'hours': '',
            'website': s.get('website', ''),
            'notes': '',
            'google_place_id': '',
            'source': 'ddg',
            'verified': 'false',
            'active': 'true',
        })
    fieldnames = [
        'name', 'address', 'city', 'state', 'country', 'zip', 'phone',
        'lat', 'lng', 'region', 'types', 'hours', 'website', 'notes',
        'google_place_id', 'source', 'verified', 'active'
    ]
    with open(OUTPUT_FILE, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, quoting=csv.QUOTE_ALL)
        writer.writeheader()
        for row in sorted(rows, key=lambda r: (r['country'], r['state'], r['city'], r['name'])):
            writer.writerow(row)

    print(f'Wrote {len(rows)} shops to {OUTPUT_FILE}')

    # Merge with existing import CSV
    if MERGED_FILE.exists():
        print(f'\nMerging with existing {MERGED_FILE.name}...')
        existing = []
        with open(MERGED_FILE, encoding='utf-8') as f:
            existing = list(csv.DictReader(f))

        existing_keys = set()
        for r in existing:
            lat = float(r.get('lat', 0) or 0)
            lng = float(r.get('lng', 0) or 0)
            existing_keys.add(f"{r['name'].lower().strip()}|{round(lat,2)}|{round(lng,2)}")

        added = 0
        for r in rows:
            lat = float(r.get('lat', 0) or 0)
            lng = float(r.get('lng', 0) or 0)
            key = f"{r['name'].lower().strip()}|{round(lat,2)}|{round(lng,2)}"
            if key not in existing_keys:
                existing.append(r)
                existing_keys.add(key)
                added += 1

        with open(MERGED_FILE, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames, quoting=csv.QUOTE_ALL, extrasaction='ignore')
            writer.writeheader()
            for row in sorted(existing, key=lambda r: (r.get('country',''), r.get('state',''), r.get('name',''))):
                writer.writerow(row)

        print(f'Merged: {added} new shops added, {len(existing)} total in {MERGED_FILE.name}')

    # Summary
    by_state = {}
    for r in rows:
        key = f"{r['country']}/{r['state']}" if r['state'] else '??'
        by_state[key] = by_state.get(key, 0) + 1
    if by_state:
        print('\nDDG shops by state/province:')
        for st in sorted(by_state.keys()):
            print(f'  {st}: {by_state[st]}')


if __name__ == '__main__':
    main()
