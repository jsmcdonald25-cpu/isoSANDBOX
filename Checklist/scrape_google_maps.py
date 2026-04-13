#!/usr/bin/env python3
"""
Card Shop Scraper — Google Maps search (no API key)
Uses the public Google Maps search endpoint to find card shops.
Merges results into card_shops_import.csv alongside OSM data.

Usage: py Checklist/scrape_google_maps.py

Requires: pip install requests beautifulsoup4
"""

import csv
import json
import re
import time
import random
import requests
from pathlib import Path
from urllib.parse import quote_plus

OUTPUT_FILE = Path(__file__).parent / 'card_shops_google.csv'
MERGED_FILE = Path(__file__).parent / 'card_shops_import.csv'

# Rotate user agents to avoid blocks
USER_AGENTS = [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:128.0) Gecko/20100101 Firefox/128.0',
]

SEARCH_QUERIES = [
    'trading card shop',
    'sports card store',
    'pokemon card shop',
    'TCG game store',
    'comic book card shop',
    'card game store',
]

# Major metros + mid-size cities for coverage
SEARCH_LOCATIONS = [
    # Top 50 US metros
    'New York NY', 'Los Angeles CA', 'Chicago IL', 'Houston TX', 'Phoenix AZ',
    'Philadelphia PA', 'San Antonio TX', 'San Diego CA', 'Dallas TX', 'San Jose CA',
    'Austin TX', 'Jacksonville FL', 'Fort Worth TX', 'Columbus OH', 'Charlotte NC',
    'Indianapolis IN', 'San Francisco CA', 'Seattle WA', 'Denver CO', 'Nashville TN',
    'Oklahoma City OK', 'El Paso TX', 'Washington DC', 'Boston MA', 'Las Vegas NV',
    'Portland OR', 'Memphis TN', 'Louisville KY', 'Baltimore MD', 'Milwaukee WI',
    'Albuquerque NM', 'Tucson AZ', 'Fresno CA', 'Sacramento CA', 'Mesa AZ',
    'Kansas City MO', 'Atlanta GA', 'Omaha NE', 'Colorado Springs CO', 'Raleigh NC',
    'Long Beach CA', 'Virginia Beach VA', 'Miami FL', 'Oakland CA', 'Minneapolis MN',
    'Tampa FL', 'Tulsa OK', 'Arlington TX', 'New Orleans LA', 'Cleveland OH',
    # Mid-size / underrepresented states
    'Chattanooga TN', 'Knoxville TN', 'Murfreesboro TN', 'Clarksville TN',
    'Pittsburgh PA', 'Cincinnati OH', 'St Louis MO', 'Detroit MI', 'Grand Rapids MI',
    'Buffalo NY', 'Rochester NY', 'Syracuse NY', 'Albany NY',
    'Hartford CT', 'Providence RI', 'Richmond VA', 'Norfolk VA',
    'Charleston SC', 'Columbia SC', 'Greenville SC',
    'Birmingham AL', 'Huntsville AL', 'Mobile AL',
    'Jackson MS', 'Little Rock AR', 'Baton Rouge LA',
    'Des Moines IA', 'Cedar Rapids IA', 'Wichita KS',
    'Boise ID', 'Salt Lake City UT', 'Provo UT',
    'Anchorage AK', 'Honolulu HI',
    'Billings MT', 'Sioux Falls SD', 'Fargo ND', 'Cheyenne WY',
    'Burlington VT', 'Portland ME', 'Manchester NH',
    'Wilmington DE', 'Charleston WV', 'Lexington KY',
    'Spokane WA', 'Tacoma WA', 'Eugene OR',
    'Reno NV', 'Bakersfield CA', 'Riverside CA',
    'Orlando FL', 'St Petersburg FL', 'Fort Lauderdale FL',
    # Canada
    'Toronto ON Canada', 'Vancouver BC Canada', 'Montreal QC Canada',
    'Calgary AB Canada', 'Edmonton AB Canada', 'Ottawa ON Canada',
    'Winnipeg MB Canada', 'Halifax NS Canada', 'Hamilton ON Canada',
    'Victoria BC Canada', 'Regina SK Canada', 'Saskatoon SK Canada',
]

# State lookup from city names (rough, for fallback)
US_STATES_ABBREV = {
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
    'wisconsin': 'WI', 'wyoming': 'WY', 'district of columbia': 'DC',
}
STATE_CODES = set(US_STATES_ABBREV.values())
CA_CODES = {'AB', 'BC', 'MB', 'NB', 'NL', 'NS', 'NT', 'NU', 'ON', 'PE', 'QC', 'SK', 'YT'}


def search_google_maps(query, location):
    """Search Google Maps via the public search URL and parse results from embedded JSON."""
    url = f'https://www.google.com/maps/search/{quote_plus(query + " near " + location)}'
    headers = {
        'User-Agent': random.choice(USER_AGENTS),
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept': 'text/html,application/xhtml+xml',
    }
    try:
        resp = requests.get(url, headers=headers, timeout=20)
        if resp.status_code != 200:
            return []

        # Google Maps embeds place data in the page as JSON
        # Look for the data payload
        text = resp.text
        results = []

        # Try to find place names and addresses from the HTML
        # Google Maps returns data in various formats, try multiple patterns

        # Pattern 1: Look for structured data in script tags
        # Google embeds business data as arrays in window.APP_INITIALIZATION_STATE
        name_pattern = re.findall(r'\["([^"]{3,60})","[^"]*","[^"]*",\[null,null,([0-9.-]+),([0-9.-]+)\]', text)

        # Pattern 2: aria-label on result items
        aria_names = re.findall(r'aria-label="([^"]{3,80})"', text)

        # Pattern 3: Look for business listings with addresses
        # These appear as arrays like [null,"Business Name",null,null,[null,null,lat,lng],"Address"]
        biz_pattern = re.findall(
            r'\[null,"([^"]{3,80})"[^\]]*?\[null,null,([0-9.-]+),([0-9.-]+)\].*?"([\d]+ [^"]{5,80})"',
            text, re.DOTALL
        )

        for match in name_pattern:
            name, lat, lng = match
            # Filter out non-business names
            if len(name) < 3 or name.startswith('http') or '<' in name:
                continue
            try:
                results.append({
                    'name': name,
                    'lat': float(lat),
                    'lng': float(lng),
                    'address': '',
                })
            except ValueError:
                continue

        for match in biz_pattern:
            name, lat, lng, addr = match
            if len(name) < 3 or name.startswith('http') or '<' in name:
                continue
            try:
                results.append({
                    'name': name,
                    'lat': float(lat),
                    'lng': float(lng),
                    'address': addr,
                })
            except ValueError:
                continue

        return results
    except Exception as e:
        print(f'    ERROR: {e}')
        return []


def parse_state_from_location(location):
    """Extract state code from search location string."""
    parts = location.strip().split()
    if 'Canada' in location:
        for p in parts:
            if p.upper() in CA_CODES:
                return p.upper(), 'CA'
        return '', 'CA'
    for p in parts:
        if p.upper() in STATE_CODES:
            return p.upper(), 'US'
    return '', 'US'


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


def main():
    print('=== Card Shop Scraper — Google Maps (no API key) ===')
    print(f'Searching {len(SEARCH_LOCATIONS)} locations x {len(SEARCH_QUERIES)} queries')
    print(f'Output: {OUTPUT_FILE}')
    print()

    all_shops = {}  # dedup by lowercase name + rounded coords
    total = len(SEARCH_LOCATIONS) * len(SEARCH_QUERIES)
    done = 0

    for loc in SEARCH_LOCATIONS:
        state, country = parse_state_from_location(loc)
        for query in SEARCH_QUERIES:
            done += 1
            print(f'  [{done}/{total}] "{query}" near {loc}...', end='', flush=True)

            results = search_google_maps(query, loc)
            new = 0
            for r in results:
                key = f"{r['name'].lower().strip()}|{round(r['lat'],2)}|{round(r['lng'],2)}"
                if key not in all_shops:
                    all_shops[key] = {
                        'name': r['name'],
                        'address': r.get('address', ''),
                        'city': '',
                        'state': state,
                        'country': country,
                        'zip': '',
                        'phone': '',
                        'lat': r['lat'],
                        'lng': r['lng'],
                        'region': '',
                        'types': '{' + ','.join(classify_types(r['name'])) + '}',
                        'hours': '',
                        'website': '',
                        'notes': f'Google Maps search: {loc}',
                        'google_place_id': '',
                        'source': 'google_search',
                        'verified': 'false',
                        'active': 'true',
                    }
                    new += 1

            print(f' {len(results)} results, {new} new (total: {len(all_shops)})')

            # Random delay to avoid rate limiting
            time.sleep(random.uniform(1.5, 3.5))

    print(f'\nTotal unique shops from Google Maps: {len(all_shops)}')

    # Write Google results
    rows = list(all_shops.values())
    fieldnames = [
        'name', 'address', 'city', 'state', 'country', 'zip', 'phone',
        'lat', 'lng', 'region', 'types', 'hours', 'website', 'notes',
        'google_place_id', 'source', 'verified', 'active'
    ]
    with open(OUTPUT_FILE, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, quoting=csv.QUOTE_ALL)
        writer.writeheader()
        for row in sorted(rows, key=lambda r: (r['country'], r['state'], r['name'])):
            writer.writerow(row)

    print(f'Wrote {len(rows)} shops to {OUTPUT_FILE}')

    # Now merge with existing import CSV if it exists
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
    print('\nGoogle Maps shops by state/province:')
    for st in sorted(by_state.keys()):
        print(f'  {st}: {by_state[st]}')


if __name__ == '__main__':
    main()
