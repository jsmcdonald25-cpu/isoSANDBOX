#!/usr/bin/env python3
"""
Card Shop Scraper — Overpass API (OpenStreetMap) + free geocoding
No API key required. Finds card/game/comic shops across US + Canada.

Usage:
  py Checklist/scrape_card_shops.py
  Then import Checklist/card_shops_import.csv via Supabase Table Editor.

Requires: pip install requests
"""

import csv
import time
import requests
from pathlib import Path

OUTPUT_FILE = Path(__file__).parent / 'card_shops_import.csv'
OVERPASS_URL = 'https://overpass-api.de/api/interpreter'

# Overpass QL query — finds shops tagged as trading card, game, or comic shops in US + CA
# OpenStreetMap tags: shop=games, shop=trade, shop=collector, leisure=games
OVERPASS_QUERY = """
[out:json][timeout:120];
(
  // US bounding box
  node["shop"="games"](24.5,-125.0,49.5,-66.9);
  node["shop"="collector"](24.5,-125.0,49.5,-66.9);
  node["shop"="trade"](24.5,-125.0,49.5,-66.9);
  node["shop"="comics"](24.5,-125.0,49.5,-66.9);
  node["shop"="hobby"](24.5,-125.0,49.5,-66.9);
  way["shop"="games"](24.5,-125.0,49.5,-66.9);
  way["shop"="collector"](24.5,-125.0,49.5,-66.9);
  way["shop"="trade"](24.5,-125.0,49.5,-66.9);
  way["shop"="comics"](24.5,-125.0,49.5,-66.9);
  way["shop"="hobby"](24.5,-125.0,49.5,-66.9);
  // Canada bounding box
  node["shop"="games"](41.7,-141.0,83.1,-52.6);
  node["shop"="collector"](41.7,-141.0,83.1,-52.6);
  node["shop"="trade"](41.7,-141.0,83.1,-52.6);
  node["shop"="comics"](41.7,-141.0,83.1,-52.6);
  node["shop"="hobby"](41.7,-141.0,83.1,-52.6);
  way["shop"="games"](41.7,-141.0,83.1,-52.6);
  way["shop"="collector"](41.7,-141.0,83.1,-52.6);
  way["shop"="trade"](41.7,-141.0,83.1,-52.6);
  way["shop"="comics"](41.7,-141.0,83.1,-52.6);
  way["shop"="hobby"](41.7,-141.0,83.1,-52.6);
);
out center body;
"""

# US state bounding boxes for state assignment
US_STATES = {
    'AL': (30.22, -88.47, 35.01, -84.89), 'AK': (51.21, -179.15, 71.37, -129.98),
    'AZ': (31.33, -114.81, 37.00, -109.04), 'AR': (33.00, -94.62, 36.50, -89.64),
    'CA': (32.53, -124.41, 42.01, -114.13), 'CO': (36.99, -109.06, 41.00, -102.04),
    'CT': (40.95, -73.73, 42.05, -71.79), 'DE': (38.45, -75.79, 39.84, -75.05),
    'FL': (24.40, -87.63, 31.00, -80.03), 'GA': (30.36, -85.61, 35.00, -80.84),
    'HI': (18.91, -160.24, 22.24, -154.81), 'ID': (42.00, -117.24, 49.00, -111.04),
    'IL': (36.97, -91.51, 42.51, -87.02), 'IN': (37.77, -88.10, 41.76, -84.78),
    'IA': (40.38, -96.64, 43.50, -90.14), 'KS': (36.99, -102.05, 40.00, -94.59),
    'KY': (36.50, -89.57, 39.15, -81.96), 'LA': (28.93, -94.04, 33.02, -88.82),
    'ME': (43.06, -71.08, 47.46, -66.95), 'MD': (37.91, -79.49, 39.72, -75.05),
    'MA': (41.24, -73.51, 42.89, -69.93), 'MI': (41.70, -90.42, 48.30, -82.41),
    'MN': (43.50, -97.24, 49.38, -89.49), 'MS': (30.17, -91.66, 34.99, -88.10),
    'MO': (35.99, -95.77, 40.61, -89.10), 'MT': (44.36, -116.05, 49.00, -104.04),
    'NE': (39.99, -104.05, 43.00, -95.31), 'NV': (35.00, -120.01, 42.00, -114.04),
    'NH': (42.70, -72.56, 45.31, -70.70), 'NJ': (38.93, -75.56, 41.36, -73.89),
    'NM': (31.33, -109.05, 37.00, -103.00), 'NY': (40.50, -79.76, 45.02, -71.86),
    'NC': (33.84, -84.32, 36.59, -75.46), 'ND': (45.94, -104.05, 49.00, -96.55),
    'OH': (38.40, -84.82, 41.98, -80.52), 'OK': (33.62, -103.00, 37.00, -94.43),
    'OR': (41.99, -124.57, 46.29, -116.46), 'PA': (39.72, -80.52, 42.27, -74.69),
    'RI': (41.15, -71.86, 42.02, -71.12), 'SC': (32.03, -83.35, 35.22, -78.54),
    'SD': (42.48, -104.06, 45.95, -96.44), 'TN': (34.98, -90.31, 36.68, -81.65),
    'TX': (25.84, -106.65, 36.50, -93.51), 'UT': (36.99, -114.05, 42.00, -109.04),
    'VT': (42.73, -73.44, 45.02, -71.46), 'VA': (36.54, -83.68, 39.47, -75.24),
    'WA': (45.54, -124.85, 49.00, -116.92), 'WV': (37.20, -82.64, 40.64, -77.72),
    'WI': (42.49, -92.89, 47.08, -86.25), 'WY': (40.99, -111.06, 45.01, -104.05),
    'DC': (38.79, -77.12, 38.99, -76.91),
}

CA_PROVINCES = {
    'ON': (41.7, -95.2, 56.9, -74.3), 'QC': (45.0, -79.8, 62.6, -57.1),
    'BC': (48.3, -139.1, 60.0, -114.0), 'AB': (49.0, -120.0, 60.0, -110.0),
    'MB': (49.0, -102.1, 60.0, -88.9), 'SK': (49.0, -110.0, 60.0, -101.4),
    'NS': (43.4, -66.4, 47.0, -59.7), 'NB': (44.6, -69.1, 48.1, -63.8),
}


def get_state(lat, lng):
    """Determine US state or CA province from coordinates."""
    for st, (s, w, n, e) in US_STATES.items():
        if s <= lat <= n and w <= lng <= e:
            return st, 'US'
    for prov, (s, w, n, e) in CA_PROVINCES.items():
        if s <= lat <= n and w <= lng <= e:
            return prov, 'CA'
    return '', 'US'


def classify_types(tags, name):
    """Guess card shop types from OSM tags and name."""
    types = []
    name_lower = (name or '').lower()
    all_text = name_lower + ' ' + ' '.join(str(v) for v in tags.values()).lower()

    if any(w in all_text for w in ['sport', 'baseball', 'football', 'basketball']):
        types.append('Sports')
    if any(w in all_text for w in ['pokemon', 'pokémon']):
        types.append('Pokemon')
    if any(w in all_text for w in ['magic', 'mtg']):
        types.append('MTG')
    if any(w in all_text for w in ['yugioh', 'yu-gi-oh']):
        types.append('Yu-Gi-Oh')
    if any(w in all_text for w in ['comic']):
        types.append('Comics')
    if any(w in all_text for w in ['trading card', 'tcg', 'card game', 'collectible card']):
        types.append('TCG')
    if any(w in all_text for w in ['hobby', 'miniature', 'warhammer']):
        types.append('Hobby')
    if not types:
        shop_type = tags.get('shop', '')
        if shop_type == 'games':
            types.append('Games')
        elif shop_type == 'comics':
            types.append('Comics')
        elif shop_type in ('collector', 'trade'):
            types.append('Collectibles')
        else:
            types.append('Cards')
    return types


def format_hours(tags):
    """Extract opening hours from OSM tags."""
    return tags.get('opening_hours', '')


def parse_address(tags):
    """Build address from OSM addr:* tags."""
    parts = []
    street_num = tags.get('addr:housenumber', '')
    street = tags.get('addr:street', '')
    if street_num and street:
        parts.append(f'{street_num} {street}')
    elif street:
        parts.append(street)
    suite = tags.get('addr:unit', '') or tags.get('addr:suite', '')
    if suite:
        parts.append(f'Suite {suite}')
    return ', '.join(parts)


def main():
    print('=== Card Shop Scraper (OpenStreetMap — free, no API key) ===')
    print(f'Output: {OUTPUT_FILE}')
    print()
    print('Querying Overpass API for game/card/comic/hobby shops in US + Canada...')
    print('(This may take 30-60 seconds)')
    print()

    resp = requests.post(OVERPASS_URL, data={'data': OVERPASS_QUERY}, timeout=180)
    if resp.status_code != 200:
        print(f'ERROR: Overpass API returned {resp.status_code}')
        print(resp.text[:500])
        return

    data = resp.json()
    elements = data.get('elements', [])
    print(f'Raw results: {len(elements)} places')

    rows = []
    seen_names = set()

    for el in elements:
        tags = el.get('tags', {})
        name = tags.get('name', '')
        if not name:
            continue

        # Filter: only keep shops likely to sell trading cards
        shop_type = tags.get('shop', '')
        name_lower = name.lower()
        all_tags_text = ' '.join(str(v) for v in tags.values()).lower()
        # Always keep games and comics shops
        is_game_or_comic = shop_type in ('games', 'comics')
        # For trade/collector/hobby, require card-related keywords
        card_keywords = ['card', 'game', 'comic', 'pokemon', 'tcg', 'mtg', 'magic',
                         'yugioh', 'yu-gi-oh', 'collectible', 'hobby', 'sport',
                         'anime', 'manga', 'toy', 'geek', 'nerd', 'tabletop',
                         'miniature', 'warhammer', 'dice', 'dungeon', 'dragon',
                         'board game', 'lorcana', 'funko']
        has_card_keyword = any(kw in name_lower or kw in all_tags_text for kw in card_keywords)
        if not is_game_or_comic and not has_card_keyword:
            continue

        # Get coordinates (nodes have lat/lon directly, ways use center)
        if el['type'] == 'way':
            center = el.get('center', {})
            lat = center.get('lat', 0)
            lng = center.get('lon', 0)
        else:
            lat = el.get('lat', 0)
            lng = el.get('lon', 0)

        if not lat or not lng:
            continue

        # Dedup by name + rough location
        dedup_key = f"{name.lower().strip()}|{round(lat,2)}|{round(lng,2)}"
        if dedup_key in seen_names:
            continue
        seen_names.add(dedup_key)

        state, country = get_state(lat, lng)
        city = tags.get('addr:city', '')
        address = parse_address(tags)
        phone = tags.get('phone', '') or tags.get('contact:phone', '')
        website = tags.get('website', '') or tags.get('contact:website', '')
        hours = format_hours(tags)
        types = classify_types(tags, name)
        zip_code = tags.get('addr:postcode', '')

        rows.append({
            'name': name,
            'address': address,
            'city': city,
            'state': state,
            'country': country,
            'zip': zip_code,
            'phone': phone,
            'lat': lat,
            'lng': lng,
            'region': '',
            'types': '{' + ','.join(types) + '}',
            'hours': hours,
            'website': website,
            'notes': f'OSM {el["type"]}/{el["id"]}',
            'google_place_id': '',
            'source': 'osm',
            'verified': 'false',
            'active': 'true',
        })

    print(f'After filtering/dedup: {len(rows)} shops')

    # Write CSV
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

    print(f'\nWrote {len(rows)} shops to {OUTPUT_FILE}')
    print('Import via Supabase Table Editor > card_shops > Insert > Import CSV')

    # Summary
    by_state = {}
    for row in rows:
        key = f"{row['country']}/{row['state']}" if row['state'] else '??'
        by_state[key] = by_state.get(key, 0) + 1
    print('\nShops by state/province:')
    for st in sorted(by_state.keys()):
        print(f'  {st}: {by_state[st]}')


if __name__ == '__main__':
    main()
