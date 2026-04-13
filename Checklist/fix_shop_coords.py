"""
fix_shop_coords.py — Fill missing lat/lng for card_shops from city/state lookup

Reads card_shops_import.csv, builds a city/state → lat/lng centroid from
shops that already have coordinates, then generates UPDATE SQL for every
shop that's missing coords.

Fallback chain:
  1. City + State match from existing good shops
  2. State centroid from existing good shops
  3. Country centroid (US=39.8,-98.6, CA=56.1,-106.3)

Output: fix_shop_coords.sql — paste in Supabase SQL Editor

Usage: py fix_shop_coords.py
"""

import csv
import sys
from collections import defaultdict

CSV_PATH = 'card_shops_import.csv'
OUT_PATH = 'fix_shop_coords.sql'

# Country-level fallbacks
COUNTRY_FALLBACK = {
    'US': (39.8283, -98.5795),   # geographic center of contiguous US
    'CA': (56.1304, -106.3468),  # geographic center of Canada
}

def main():
    # Read CSV
    with open(CSV_PATH, 'r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        rows = list(reader)

    print(f'Total shops in CSV: {len(rows)}')

    # Separate good-coord vs missing-coord shops
    good = []
    missing = []
    for r in rows:
        lat = r.get('lat', '').strip()
        lng = r.get('lng', '').strip()
        try:
            lat_f = float(lat) if lat else 0.0
            lng_f = float(lng) if lng else 0.0
        except ValueError:
            lat_f = lng_f = 0.0

        if lat_f != 0.0 and lng_f != 0.0:
            r['_lat'] = lat_f
            r['_lng'] = lng_f
            good.append(r)
        else:
            missing.append(r)

    print(f'Shops with coordinates: {len(good)}')
    print(f'Shops missing coordinates: {len(missing)}')

    # Build city+state → [lat, lng] lookup from good shops
    city_state_coords = defaultdict(list)
    state_coords = defaultdict(list)

    for r in good:
        city = (r.get('city', '') or '').strip().upper()
        state = (r.get('state', '') or '').strip().upper()
        country = (r.get('country', '') or '').strip().upper()
        key = f'{city}|{state}|{country}'
        city_state_coords[key].append((r['_lat'], r['_lng']))
        if state:
            state_coords[f'{state}|{country}'].append((r['_lat'], r['_lng']))

    # Compute centroids
    def centroid(pairs):
        if not pairs:
            return None
        avg_lat = sum(p[0] for p in pairs) / len(pairs)
        avg_lng = sum(p[1] for p in pairs) / len(pairs)
        return (round(avg_lat, 6), round(avg_lng, 6))

    city_centroids = {k: centroid(v) for k, v in city_state_coords.items()}
    state_centroids = {k: centroid(v) for k, v in state_coords.items()}

    # Generate UPDATE statements for missing shops
    updates = []
    stats = {'city': 0, 'state': 0, 'country': 0, 'none': 0}

    for r in missing:
        name = (r.get('name', '') or '').strip()
        city = (r.get('city', '') or '').strip().upper()
        state = (r.get('state', '') or '').strip().upper()
        country = (r.get('country', '') or '').strip().upper()

        # Try city+state match
        key = f'{city}|{state}|{country}'
        coord = city_centroids.get(key)
        source = 'city'

        # Fallback: state centroid
        if not coord:
            skey = f'{state}|{country}'
            coord = state_centroids.get(skey)
            source = 'state'

        # Fallback: country centroid
        if not coord:
            coord = COUNTRY_FALLBACK.get(country)
            source = 'country'

        if not coord:
            stats['none'] += 1
            continue

        stats[source] += 1
        lat, lng = coord

        # Escape single quotes in name for SQL
        safe_name = name.replace("'", "''")
        safe_city = city.replace("'", "''")

        updates.append(
            f"UPDATE card_shops SET lat = {lat}, lng = {lng} "
            f"WHERE name = '{safe_name}' AND lat IS NOT DISTINCT FROM "
            f"(SELECT lat FROM card_shops WHERE name = '{safe_name}' "
            f"AND (lat IS NULL OR lat = 0) LIMIT 1);\n"
            f"-- source: {source} ({city}, {state}, {country})"
        )

    # Simpler approach — just match by name + city + state, only update if lat=0 or null
    updates = []
    stats = {'city': 0, 'state': 0, 'country': 0, 'none': 0}

    for r in missing:
        name = (r.get('name', '') or '').strip()
        city = (r.get('city', '') or '').strip().upper()
        state = (r.get('state', '') or '').strip().upper()
        country = (r.get('country', '') or '').strip().upper()

        key = f'{city}|{state}|{country}'
        coord = city_centroids.get(key)
        source = 'city'

        if not coord:
            skey = f'{state}|{country}'
            coord = state_centroids.get(skey)
            source = 'state'

        if not coord:
            coord = COUNTRY_FALLBACK.get(country)
            source = 'country'

        if not coord:
            stats['none'] += 1
            continue

        stats[source] += 1
        lat, lng = coord
        safe_name = name.replace("'", "''")

        updates.append(
            f"UPDATE card_shops SET lat = {lat}, lng = {lng} "
            f"WHERE name = '{safe_name}' "
            f"AND (lat IS NULL OR lat = 0) "
            f"AND (lng IS NULL OR lng = 0);"
            f"  -- {source}: {city}, {state}"
        )

    # Also add the specific Underdog fix with exact coordinates
    updates.insert(0,
        "-- Exact fix: Underdog Collectibles, Knoxville TN\n"
        "UPDATE card_shops SET lat = 35.9606, lng = -83.9207 "
        "WHERE name = 'UNDERDOG COLLECTIBLES' AND state = 'TN';"
    )

    # Write SQL file
    with open(OUT_PATH, 'w', encoding='utf-8') as f:
        f.write('-- fix_shop_coords.sql\n')
        f.write(f'-- Generated from {CSV_PATH}\n')
        f.write(f'-- {len(updates)} UPDATE statements\n')
        f.write(f'-- Resolution: city={stats["city"]}, state={stats["state"]}, country={stats["country"]}, unresolved={stats["none"]}\n')
        f.write('-- Only updates shops where lat IS NULL or lat = 0 (safe to re-run)\n\n')
        f.write('BEGIN;\n\n')
        f.write('\n'.join(updates))
        f.write('\n\nCOMMIT;\n')

    print(f'\nWrote {OUT_PATH}')
    print(f'  {len(updates)} UPDATE statements')
    print(f'  Resolved by city: {stats["city"]}')
    print(f'  Resolved by state: {stats["state"]}')
    print(f'  Resolved by country: {stats["country"]}')
    print(f'  Unresolved: {stats["none"]}')

if __name__ == '__main__':
    main()
