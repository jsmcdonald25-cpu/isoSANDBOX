#!/usr/bin/env python3
"""
Card Shop Scraper — Directory Sites (free, no API key)
Scrapes card/game store locators:
  1. TCGplayer Store Locator API
  2. Wizards of the Coast (WPN) Store Locator
  3. Pokemon Event Locator
Merges into card_shops_import.csv.

Usage: py Checklist/scrape_directories.py
"""

import csv
import json
import time
import random
import requests
from pathlib import Path
from math import radians, cos, sin, asin, sqrt

OUTPUT_FILE = Path(__file__).parent / 'card_shops_directories.csv'
MERGED_FILE = Path(__file__).parent / 'card_shops_import.csv'

HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
    'Accept': 'application/json, text/html, */*',
    'Accept-Language': 'en-US,en;q=0.9',
}

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

# Grid of lat/lng points across the US — search each point with a radius
# Covers the continental US in ~50mi grid
US_SEARCH_GRID = [
    # Major population centers + fill gaps
    (33.52, -86.80, 'AL'), (61.22, -149.90, 'AK'), (33.45, -112.07, 'AZ'),
    (34.75, -92.29, 'AR'), (34.05, -118.24, 'CA'), (37.77, -122.42, 'CA'),
    (32.72, -117.16, 'CA'), (38.58, -121.49, 'CA'), (36.75, -119.77, 'CA'),
    (39.74, -104.99, 'CO'), (41.76, -72.68, 'CT'), (39.74, -75.55, 'DE'),
    (25.76, -80.19, 'FL'), (28.54, -81.38, 'FL'), (27.95, -82.46, 'FL'),
    (30.33, -81.66, 'FL'), (33.75, -84.39, 'GA'), (21.31, -157.86, 'HI'),
    (43.62, -116.21, 'ID'), (41.88, -87.63, 'IL'), (39.77, -86.16, 'IN'),
    (41.59, -93.62, 'IA'), (37.69, -97.34, 'KS'), (38.25, -85.76, 'KY'),
    (29.95, -90.07, 'LA'), (43.66, -70.26, 'ME'), (39.29, -76.61, 'MD'),
    (42.36, -71.06, 'MA'), (42.33, -83.05, 'MI'), (42.96, -85.67, 'MI'),
    (44.98, -93.27, 'MN'), (32.30, -90.18, 'MS'), (38.63, -90.20, 'MO'),
    (39.10, -94.58, 'MO'), (46.87, -113.99, 'MT'), (41.26, -95.94, 'NE'),
    (36.17, -115.14, 'NV'), (42.99, -71.45, 'NH'), (40.74, -74.17, 'NJ'),
    (35.08, -106.65, 'NM'), (40.71, -74.01, 'NY'), (42.89, -78.88, 'NY'),
    (43.05, -76.15, 'NY'), (35.23, -80.84, 'NC'), (35.78, -78.64, 'NC'),
    (46.88, -96.79, 'ND'), (41.50, -81.69, 'OH'), (39.96, -83.00, 'OH'),
    (39.10, -84.51, 'OH'), (35.47, -97.52, 'OK'), (45.52, -122.68, 'OR'),
    (39.95, -75.17, 'PA'), (40.44, -80.00, 'PA'), (41.82, -71.41, 'RI'),
    (34.00, -81.03, 'SC'), (32.78, -79.93, 'SC'), (43.55, -96.73, 'SD'),
    (36.16, -86.78, 'TN'), (35.05, -85.31, 'TN'), (35.96, -83.92, 'TN'),
    (35.15, -90.05, 'TN'), (29.76, -95.37, 'TX'), (32.78, -96.80, 'TX'),
    (30.27, -97.74, 'TX'), (29.42, -98.49, 'TX'), (31.76, -106.49, 'TX'),
    (40.76, -111.89, 'UT'), (44.26, -72.58, 'VT'), (37.54, -77.43, 'VA'),
    (36.85, -75.98, 'VA'), (47.61, -122.33, 'WA'), (38.35, -81.63, 'WV'),
    (43.04, -87.91, 'WI'), (42.87, -106.31, 'WY'),
    # Canada
    (43.65, -79.38, 'ON'), (45.50, -73.57, 'QC'), (49.28, -123.12, 'BC'),
    (51.05, -114.07, 'AB'), (53.55, -113.49, 'AB'), (45.42, -75.70, 'ON'),
    (49.90, -97.14, 'MB'), (44.65, -63.57, 'NS'),
]

CA_PROVS = {'AB', 'BC', 'MB', 'NB', 'NL', 'NS', 'NT', 'NU', 'ON', 'PE', 'QC', 'SK', 'YT'}

all_shops = {}  # global dedup


def add_shop(name, address, city, state, country, phone, lat, lng, website, hours, source, types_list):
    """Add a shop to the global dict, deduped by name+coords."""
    if not name or len(name) < 2:
        return
    key = f"{name.lower().strip()}|{round(lat,2) if lat else 0}|{round(lng,2) if lng else 0}"
    if key in all_shops:
        return
    all_shops[key] = {
        'name': name.strip(),
        'address': address or '',
        'city': city or '',
        'state': state or '',
        'country': country or 'US',
        'zip': '',
        'phone': phone or '',
        'lat': lat or 0,
        'lng': lng or 0,
        'region': '',
        'types': '{' + ','.join(types_list or ['Cards']) + '}',
        'hours': (str(hours) or '')[:500],
        'website': website or '',
        'notes': '',
        'google_place_id': '',
        'source': source,
        'verified': 'false',
        'active': 'true',
    }


def classify(name):
    """Guess shop types from name."""
    types = []
    n = name.lower()
    if any(w in n for w in ['sport', 'baseball', 'football', 'basketball']): types.append('Sports')
    if any(w in n for w in ['pokemon', 'poke']): types.append('Pokemon')
    if any(w in n for w in ['magic', 'mtg']): types.append('MTG')
    if any(w in n for w in ['yugioh', 'yu-gi-oh']): types.append('Yu-Gi-Oh')
    if any(w in n for w in ['comic']): types.append('Comics')
    if any(w in n for w in ['card', 'tcg', 'trading']): types.append('TCG')
    if any(w in n for w in ['game', 'tabletop']): types.append('Games')
    if any(w in n for w in ['hobby', 'collectible']): types.append('Collectibles')
    if not types: types.append('Cards')
    return types


# ── Source 1: TCGplayer Store Locator ──
def scrape_tcgplayer():
    """TCGplayer has a store locator API that returns nearby stores."""
    print('\n=== TCGplayer Store Locator ===')
    before = len(all_shops)

    for lat, lng, state in US_SEARCH_GRID:
        country = 'CA' if state in CA_PROVS else 'US'
        url = f'https://store.tcgplayer.com/admin/storelocationservice/findnearby?latitude={lat}&longitude={lng}&radiusInMiles=75'
        try:
            resp = requests.get(url, headers=HEADERS, timeout=15)
            if resp.status_code != 200:
                # Try alternative endpoint
                url2 = f'https://www.tcgplayer.com/near/me?lat={lat}&lng={lng}&range=75'
                resp = requests.get(url2, headers=HEADERS, timeout=15)
                if resp.status_code != 200:
                    continue
                # Try to parse HTML for store data
                continue

            data = resp.json()
            stores = data if isinstance(data, list) else data.get('results', data.get('stores', []))
            for s in stores:
                name = s.get('name', '') or s.get('storeName', '')
                add_shop(
                    name=name,
                    address=s.get('address', '') or s.get('street', ''),
                    city=s.get('city', ''),
                    state=s.get('state', '') or state,
                    country=country,
                    phone=s.get('phone', ''),
                    lat=s.get('latitude', s.get('lat', 0)),
                    lng=s.get('longitude', s.get('lng', 0)),
                    website=s.get('website', '') or s.get('url', ''),
                    hours='',
                    source='tcgplayer',
                    types_list=['TCG'] + classify(name),
                )
            if stores:
                print(f'  {state} ({lat},{lng}): {len(stores)} stores')
        except Exception as e:
            pass
        time.sleep(random.uniform(0.5, 1.5))

    added = len(all_shops) - before
    print(f'TCGplayer: {added} new shops added (total: {len(all_shops)})')


# ── Source 2: Wizards of the Coast / WPN Store Locator ──
def scrape_wpn():
    """WPN (Wizards Play Network) store locator for MTG shops."""
    print('\n=== WPN Store Locator (MTG shops) ===')
    before = len(all_shops)

    for lat, lng, state in US_SEARCH_GRID:
        country = 'CA' if state in CA_PROVS else 'US'
        # WPN Locator API
        url = 'https://locator.wizards.com/Service/LocationService.svc/GetLocations'
        payload = {
            'request': {
                'Latitude': lat,
                'Longitude': lng,
                'PageSize': 50,
                'PageIndex': 0,
                'Radius': 75,
                'CountryCode': country,
            }
        }
        try:
            resp = requests.post(url, json=payload, headers={**HEADERS, 'Content-Type': 'application/json'}, timeout=15)
            if resp.status_code == 200:
                data = resp.json()
                locations = data.get('d', {}).get('Results', []) if isinstance(data.get('d'), dict) else []
                if not locations and isinstance(data, list):
                    locations = data
                for loc in locations:
                    name = loc.get('Name', '') or loc.get('BusinessName', '')
                    add_shop(
                        name=name,
                        address=loc.get('Address', '') or loc.get('Street', ''),
                        city=loc.get('City', ''),
                        state=loc.get('State', '') or loc.get('Region', '') or state,
                        country=country,
                        phone=loc.get('Phone', ''),
                        lat=loc.get('Latitude', loc.get('Lat', 0)),
                        lng=loc.get('Longitude', loc.get('Lng', 0)),
                        website=loc.get('Website', ''),
                        hours='',
                        source='wpn',
                        types_list=['MTG', 'Games'],
                    )
                if locations:
                    print(f'  {state} ({lat},{lng}): {len(locations)} stores')
        except Exception as e:
            pass
        time.sleep(random.uniform(0.5, 1.5))

    # Also try the newer API
    try:
        url = 'https://locator-api.wizards.com/graphql'
        for lat, lng, state in US_SEARCH_GRID:
            country = 'CA' if state in CA_PROVS else 'US'
            query = {
                'query': '''query($lat:Float!,$lng:Float!,$dist:Int){
                    searchLocations(lat:$lat,lng:$lng,maxDistance:$dist,first:50){
                        edges{node{name,address{line1,city,state,postalCode,country},latitude,longitude,phone,website}}
                    }
                }''',
                'variables': {'lat': lat, 'lng': lng, 'dist': 120}
            }
            resp = requests.post(url, json=query, headers=HEADERS, timeout=15)
            if resp.status_code == 200:
                data = resp.json()
                edges = data.get('data', {}).get('searchLocations', {}).get('edges', [])
                for edge in edges:
                    n = edge.get('node', {})
                    addr = n.get('address', {})
                    name = n.get('name', '')
                    add_shop(
                        name=name,
                        address=addr.get('line1', ''),
                        city=addr.get('city', ''),
                        state=addr.get('state', '') or state,
                        country=addr.get('country', country),
                        phone=n.get('phone', ''),
                        lat=n.get('latitude', 0),
                        lng=n.get('longitude', 0),
                        website=n.get('website', ''),
                        hours='',
                        source='wpn',
                        types_list=['MTG', 'Games'],
                    )
                if edges:
                    print(f'  WPN GQL {state}: {len(edges)} stores')
            time.sleep(random.uniform(0.5, 1.0))
    except Exception as e:
        print(f'  WPN GraphQL failed: {e}')

    added = len(all_shops) - before
    print(f'WPN: {added} new shops added (total: {len(all_shops)})')


# ── Source 3: Pokemon Store/Event Locator ──
def scrape_pokemon():
    """Pokemon store/event locator."""
    print('\n=== Pokemon Store Locator ===')
    before = len(all_shops)

    for lat, lng, state in US_SEARCH_GRID:
        country = 'CA' if state in CA_PROVS else 'US'
        # Pokemon event locator API
        url = f'https://www.pokemon.com/api/pokemontcg/store-locator?latitude={lat}&longitude={lng}&distance=75'
        try:
            resp = requests.get(url, headers=HEADERS, timeout=15)
            if resp.status_code == 200:
                try:
                    data = resp.json()
                    stores = data if isinstance(data, list) else data.get('stores', data.get('results', []))
                    for s in stores:
                        name = s.get('name', '') or s.get('storeName', '')
                        add_shop(
                            name=name,
                            address=s.get('address', '') or s.get('street', ''),
                            city=s.get('city', ''),
                            state=s.get('state', '') or state,
                            country=country,
                            phone=s.get('phone', ''),
                            lat=s.get('latitude', s.get('lat', 0)),
                            lng=s.get('longitude', s.get('lng', 0)),
                            website=s.get('website', ''),
                            hours='',
                            source='pokemon',
                            types_list=['Pokemon', 'TCG'],
                        )
                    if stores:
                        print(f'  {state} ({lat},{lng}): {len(stores)} stores')
                except json.JSONDecodeError:
                    pass
        except Exception as e:
            pass
        time.sleep(random.uniform(0.5, 1.5))

    added = len(all_shops) - before
    print(f'Pokemon: {added} new shops added (total: {len(all_shops)})')


def main():
    print('=== Card Shop Directory Scraper ===')
    print(f'Grid points: {len(US_SEARCH_GRID)}')
    print(f'Output: {OUTPUT_FILE}')

    # Run all scrapers
    scrape_tcgplayer()
    scrape_wpn()
    scrape_pokemon()

    print(f'\n=== TOTAL from directories: {len(all_shops)} unique shops ===')

    # Write directory results
    rows = list(all_shops.values())
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

        print(f'Merged: {added} new from directories, {len(existing)} total in {MERGED_FILE.name}')

    # Summary
    by_state = {}
    for r in rows:
        key = f"{r['country']}/{r['state']}" if r['state'] else '??'
        by_state[key] = by_state.get(key, 0) + 1
    if by_state:
        print('\nDirectory shops by state/province:')
        for st in sorted(by_state.keys()):
            print(f'  {st}: {by_state[st]}')


if __name__ == '__main__':
    main()
