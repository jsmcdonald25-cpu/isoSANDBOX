#!/usr/bin/env python3
"""
Card Shop Scraper v2 — Real directory sites
Scrapes actual card shop directories:
  1. SportsCardShops.org
  2. CardStoresNearMe.com
  3. CGC Cards dealer locators
  4. Wizards of the Coast store locator
  5. Pokemon Play store locator (Carde.io)
Merges into card_shops_import.csv.

Usage: py Checklist/scrape_directories_v2.py
Requires: pip install requests beautifulsoup4
"""

import csv
import json
import re
import time
import random
import requests
from pathlib import Path
from bs4 import BeautifulSoup

OUTPUT_FILE = Path(__file__).parent / 'card_shops_directories_v2.csv'
MERGED_FILE = Path(__file__).parent / 'card_shops_import.csv'

HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.9',
}

STATE_CODES = {
    'AL','AK','AZ','AR','CA','CO','CT','DE','FL','GA','HI','ID','IL','IN','IA',
    'KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ',
    'NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT',
    'VA','WA','WV','WI','WY','DC'
}
STATE_NAMES = {
    'alabama':'AL','alaska':'AK','arizona':'AZ','arkansas':'AR','california':'CA',
    'colorado':'CO','connecticut':'CT','delaware':'DE','florida':'FL','georgia':'GA',
    'hawaii':'HI','idaho':'ID','illinois':'IL','indiana':'IN','iowa':'IA','kansas':'KS',
    'kentucky':'KY','louisiana':'LA','maine':'ME','maryland':'MD','massachusetts':'MA',
    'michigan':'MI','minnesota':'MN','mississippi':'MS','missouri':'MO','montana':'MT',
    'nebraska':'NE','nevada':'NV','new-hampshire':'NH','new-jersey':'NJ','new-mexico':'NM',
    'new-york':'NY','north-carolina':'NC','north-dakota':'ND','ohio':'OH','oklahoma':'OK',
    'oregon':'OR','pennsylvania':'PA','rhode-island':'RI','south-carolina':'SC',
    'south-dakota':'SD','tennessee':'TN','texas':'TX','utah':'UT','vermont':'VT',
    'virginia':'VA','washington':'WA','west-virginia':'WV','wisconsin':'WI','wyoming':'WY',
}
CA_PROVS = {'AB','BC','MB','NB','NL','NS','NT','NU','ON','PE','QC','SK','YT'}

all_shops = {}


def add_shop(name, address='', city='', state='', country='US', phone='', lat=0, lng=0, website='', hours='', source='', types_list=None):
    if not name or len(name.strip()) < 2:
        return
    name = name.strip()
    lat = float(lat or 0)
    lng = float(lng or 0)
    key = f"{name.lower()}|{round(lat,2) if lat else 0}|{round(lng,2) if lng else 0}"
    # Also check name-only dedup for shops without coords
    name_key = name.lower().strip()
    if key in all_shops:
        return
    # If no coords, check if we already have this name+state
    if not lat and not lng:
        state_key = f"{name_key}|{state}"
        for existing_key, existing in all_shops.items():
            if existing['name'].lower().strip() == name_key and existing['state'] == state:
                return
    all_shops[key] = {
        'name': name,
        'address': (address or '').strip(),
        'city': (city or '').strip(),
        'state': (state or '').strip(),
        'country': country or 'US',
        'zip': '',
        'phone': (phone or '').strip(),
        'lat': lat,
        'lng': lng,
        'region': '',
        'types': '{' + ','.join(types_list or ['Cards']) + '}',
        'hours': (str(hours or ''))[:500],
        'website': (website or '').strip(),
        'notes': '',
        'google_place_id': '',
        'source': source,
        'verified': 'false',
        'active': 'true',
    }


def classify(name):
    types = []
    n = name.lower()
    if any(w in n for w in ['sport','baseball','football','basketball']): types.append('Sports')
    if any(w in n for w in ['pokemon','poke']): types.append('Pokemon')
    if any(w in n for w in ['magic','mtg']): types.append('MTG')
    if any(w in n for w in ['yugioh','yu-gi-oh']): types.append('Yu-Gi-Oh')
    if any(w in n for w in ['comic']): types.append('Comics')
    if any(w in n for w in ['card','tcg','trading']): types.append('TCG')
    if any(w in n for w in ['game','tabletop']): types.append('Games')
    if any(w in n for w in ['hobby','collectible']): types.append('Collectibles')
    if not types: types.append('Cards')
    return types


def extract_state(text):
    """Try to find a US state code in text."""
    if not text:
        return '', 'US'
    text_upper = text.upper().strip()
    # Direct state code match
    for code in STATE_CODES:
        if f', {code}' in text_upper or f' {code} ' in text_upper or text_upper.endswith(f' {code}'):
            return code, 'US'
    for code in CA_PROVS:
        if f', {code}' in text_upper or f' {code} ' in text_upper:
            return code, 'CA'
    return '', 'US'


# ── Source 1: SportsCardShops.org ──
def scrape_sportscardshops():
    print('\n=== SportsCardShops.org ===')
    before = len(all_shops)

    for slug, code in STATE_NAMES.items():
        url = f'https://www.sportscardshops.org/{slug}/'
        try:
            resp = requests.get(url, headers=HEADERS, timeout=15)
            if resp.status_code != 200:
                continue
            soup = BeautifulSoup(resp.text, 'html.parser')

            # Look for shop listings — they typically have business names in h2/h3/h4 or strong tags
            # Try multiple selectors
            shops_found = 0

            # Pattern: article or div blocks with shop info
            for article in soup.find_all(['article', 'div'], class_=re.compile(r'(listing|shop|store|entry|post|card)', re.I)):
                name_el = article.find(['h2','h3','h4','strong','a'])
                if not name_el:
                    continue
                name = name_el.get_text(strip=True)
                if not name or len(name) < 3 or len(name) > 100:
                    continue

                # Extract address/phone from surrounding text
                text = article.get_text(' ', strip=True)
                phone_match = re.search(r'\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}', text)
                phone = phone_match.group(0) if phone_match else ''

                addr_match = re.search(r'(\d{1,5}\s+[\w\s]+(?:St|Ave|Rd|Dr|Blvd|Ln|Way|Pike|Pkwy|Hwy|Ct|Cir|Pl)\b[^,]*)', text)
                address = addr_match.group(1).strip() if addr_match else ''

                # Try to get website link
                link = article.find('a', href=re.compile(r'^https?://(?!www\.sportscardshops)'))
                website = link['href'] if link else ''

                add_shop(name=name, address=address, city='', state=code, country='US',
                        phone=phone, website=website, source='sportscardshops',
                        types_list=['Sports'] + classify(name))
                shops_found += 1

            # Fallback: just grab all h2/h3 that look like business names
            if shops_found == 0:
                for heading in soup.find_all(['h2','h3','h4']):
                    name = heading.get_text(strip=True)
                    if not name or len(name) < 3 or len(name) > 80:
                        continue
                    # Skip navigation/section headers
                    if any(w in name.lower() for w in ['card shops in','stores in','about','contact','home','menu','search','category','tag']):
                        continue
                    # Check parent for address/phone
                    parent = heading.parent or heading
                    parent_text = parent.get_text(' ', strip=True)
                    phone_match = re.search(r'\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}', parent_text)
                    phone = phone_match.group(0) if phone_match else ''

                    add_shop(name=name, state=code, country='US', phone=phone,
                            source='sportscardshops', types_list=['Sports'] + classify(name))
                    shops_found += 1

            if shops_found:
                print(f'  {code}: {shops_found} shops')

        except Exception as e:
            print(f'  {code}: ERROR {str(e)[:50]}')

        time.sleep(random.uniform(1.0, 2.0))

    added = len(all_shops) - before
    print(f'SportsCardShops.org: {added} new shops (total: {len(all_shops)})')


# ── Source 2: CardStoresNearMe.com ──
def scrape_cardstoresnearme():
    print('\n=== CardStoresNearMe.com ===')
    before = len(all_shops)

    url = 'https://cardstoresnearme.com/search-all-stores'
    try:
        resp = requests.get(url, headers=HEADERS, timeout=20)
        if resp.status_code == 200:
            soup = BeautifulSoup(resp.text, 'html.parser')

            # Try to find store listings
            for el in soup.find_all(['div','li','article','tr'], class_=re.compile(r'(store|shop|listing|result)', re.I)):
                name_el = el.find(['h2','h3','h4','a','strong','td'])
                if not name_el:
                    continue
                name = name_el.get_text(strip=True)
                if not name or len(name) < 3:
                    continue

                text = el.get_text(' ', strip=True)
                state, country = extract_state(text)
                phone_match = re.search(r'\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}', text)
                phone = phone_match.group(0) if phone_match else ''

                add_shop(name=name, state=state, country=country, phone=phone,
                        source='cardstoresnearme', types_list=classify(name))

            # Also try state-by-state pages
            for slug, code in STATE_NAMES.items():
                state_url = f'https://cardstoresnearme.com/{slug}'
                try:
                    resp2 = requests.get(state_url, headers=HEADERS, timeout=15)
                    if resp2.status_code != 200:
                        continue
                    soup2 = BeautifulSoup(resp2.text, 'html.parser')
                    count = 0
                    for el in soup2.find_all(['h2','h3','h4','strong','a']):
                        name = el.get_text(strip=True)
                        if not name or len(name) < 3 or len(name) > 80:
                            continue
                        if any(w in name.lower() for w in ['card stores','stores near','home','about','search','menu','contact','category']):
                            continue
                        parent_text = (el.parent.get_text(' ', strip=True) if el.parent else '')
                        phone_match = re.search(r'\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}', parent_text)
                        phone = phone_match.group(0) if phone_match else ''
                        addr_match = re.search(r'(\d{1,5}\s+[\w\s]+(?:St|Ave|Rd|Dr|Blvd|Ln|Way|Pike|Pkwy|Hwy|Ct)\b[^,]*)', parent_text)
                        address = addr_match.group(1).strip() if addr_match else ''

                        add_shop(name=name, address=address, state=code, country='US', phone=phone,
                                source='cardstoresnearme', types_list=classify(name))
                        count += 1
                    if count:
                        print(f'  {code}: {count} shops')
                except Exception:
                    pass
                time.sleep(random.uniform(0.8, 1.5))

    except Exception as e:
        print(f'  ERROR: {e}')

    added = len(all_shops) - before
    print(f'CardStoresNearMe: {added} new shops (total: {len(all_shops)})')


# ── Source 3: CGC Cards Dealer Locators ──
def scrape_cgc():
    print('\n=== CGC Cards Dealer Locator ===')
    before = len(all_shops)

    for url_path, tag in [('trading-card-dealer-locator', 'TCG'), ('sports-card-dealer-locator', 'Sports')]:
        url = f'https://www.cgccards.com/{url_path}/'
        try:
            resp = requests.get(url, headers=HEADERS, timeout=15)
            if resp.status_code != 200:
                print(f'  {tag}: HTTP {resp.status_code}')
                continue
            soup = BeautifulSoup(resp.text, 'html.parser')

            # CGC likely uses a JS map widget — check for embedded JSON data
            scripts = soup.find_all('script')
            for script in scripts:
                text = script.string or ''
                # Look for JSON arrays of dealer data
                json_matches = re.findall(r'(\[\s*\{[^]]*"name"[^]]*\}[^]]*\])', text, re.DOTALL)
                for match in json_matches:
                    try:
                        dealers = json.loads(match)
                        for d in dealers:
                            name = d.get('name', '') or d.get('title', '')
                            add_shop(
                                name=name,
                                address=d.get('address', '') or d.get('street', ''),
                                city=d.get('city', ''),
                                state=d.get('state', '') or d.get('region', ''),
                                country=d.get('country', 'US'),
                                phone=d.get('phone', ''),
                                lat=d.get('lat', d.get('latitude', 0)),
                                lng=d.get('lng', d.get('longitude', d.get('lon', 0))),
                                website=d.get('website', '') or d.get('url', ''),
                                source='cgc',
                                types_list=[tag] + classify(name),
                            )
                    except json.JSONDecodeError:
                        pass

                # Also look for lat/lng marker data
                marker_matches = re.findall(r'(?:lat|latitude)["\s:]+([0-9.-]+).*?(?:lng|longitude|lon)["\s:]+([0-9.-]+).*?(?:name|title)["\s:]+["\']([^"\']+)', text)
                for lat, lng, name in marker_matches:
                    add_shop(name=name, lat=float(lat), lng=float(lng), source='cgc',
                            types_list=[tag] + classify(name))

            # Also try to find dealer listings in HTML
            for el in soup.find_all(['div','li','article'], class_=re.compile(r'(dealer|store|listing|location|marker)', re.I)):
                name_el = el.find(['h2','h3','h4','strong','a','span'])
                if not name_el:
                    continue
                name = name_el.get_text(strip=True)
                if name and 3 < len(name) < 80:
                    text = el.get_text(' ', strip=True)
                    state, country = extract_state(text)
                    add_shop(name=name, state=state, country=country, source='cgc',
                            types_list=[tag] + classify(name))

            print(f'  {tag}: parsed page')

        except Exception as e:
            print(f'  {tag}: ERROR {str(e)[:50]}')

        time.sleep(1)

    added = len(all_shops) - before
    print(f'CGC: {added} new shops (total: {len(all_shops)})')


# ── Source 4: Wizards of the Coast Store Locator ──
def scrape_wizards():
    print('\n=== Wizards of the Coast Store Locator ===')
    before = len(all_shops)

    # Grid of search points
    search_points = [
        (33.52,-86.80,'AL'),(61.22,-149.90,'AK'),(33.45,-112.07,'AZ'),(34.75,-92.29,'AR'),
        (34.05,-118.24,'CA'),(37.77,-122.42,'CA'),(39.74,-104.99,'CO'),(41.76,-72.68,'CT'),
        (39.74,-75.55,'DE'),(25.76,-80.19,'FL'),(28.54,-81.38,'FL'),(33.75,-84.39,'GA'),
        (41.88,-87.63,'IL'),(39.77,-86.16,'IN'),(41.59,-93.62,'IA'),(38.25,-85.76,'KY'),
        (29.95,-90.07,'LA'),(42.36,-71.06,'MA'),(42.33,-83.05,'MI'),(44.98,-93.27,'MN'),
        (38.63,-90.20,'MO'),(40.74,-74.17,'NJ'),(40.71,-74.01,'NY'),(35.23,-80.84,'NC'),
        (35.05,-85.31,'TN'),(36.16,-86.78,'TN'),(41.50,-81.69,'OH'),(39.96,-83.00,'OH'),
        (45.52,-122.68,'OR'),(39.95,-75.17,'PA'),(29.76,-95.37,'TX'),(32.78,-96.80,'TX'),
        (40.76,-111.89,'UT'),(47.61,-122.33,'WA'),(43.04,-87.91,'WI'),
        (43.65,-79.38,'ON'),(49.28,-123.12,'BC'),(45.50,-73.57,'QC'),(51.05,-114.07,'AB'),
    ]

    for lat, lng, state in search_points:
        country = 'CA' if state in CA_PROVS else 'US'
        # Try the Wizards locator API
        try:
            url = f'https://locator.wizards.com/Service/LocationService.svc/GetLocations'
            # Try REST-style
            url2 = f'https://locator.wizards.com/api/locations?lat={lat}&lng={lng}&radius=100&page=1&pageSize=50'
            resp = requests.get(url2, headers={**HEADERS, 'Accept': 'application/json'}, timeout=10)
            if resp.status_code == 200:
                try:
                    data = resp.json()
                    locations = data if isinstance(data, list) else data.get('results', data.get('locations', []))
                    for loc in locations:
                        name = loc.get('name', '') or loc.get('organizationName', '')
                        add_shop(
                            name=name,
                            address=loc.get('address', '') or loc.get('street1', ''),
                            city=loc.get('city', ''),
                            state=loc.get('state', '') or loc.get('territory', '') or state,
                            country=country,
                            phone=loc.get('phone', ''),
                            lat=loc.get('latitude', loc.get('lat', 0)),
                            lng=loc.get('longitude', loc.get('lng', 0)),
                            website=loc.get('website', '') or loc.get('url', ''),
                            source='wizards',
                            types_list=['MTG', 'Games'],
                        )
                    if locations:
                        print(f'  {state}: {len(locations)} stores')
                except json.JSONDecodeError:
                    pass
        except Exception:
            pass
        time.sleep(random.uniform(0.5, 1.0))

    added = len(all_shops) - before
    print(f'Wizards: {added} new shops (total: {len(all_shops)})')


# ── Source 5: Pokemon Play locator via Carde.io ──
def scrape_pokemon_carde():
    print('\n=== Pokemon Play (Carde.io) ===')
    before = len(all_shops)

    search_points = [
        (33.52,-86.80),(33.45,-112.07),(34.05,-118.24),(37.77,-122.42),
        (39.74,-104.99),(41.76,-72.68),(25.76,-80.19),(28.54,-81.38),
        (33.75,-84.39),(41.88,-87.63),(39.77,-86.16),(42.36,-71.06),
        (42.33,-83.05),(44.98,-93.27),(40.74,-74.17),(40.71,-74.01),
        (35.23,-80.84),(35.05,-85.31),(36.16,-86.78),(41.50,-81.69),
        (45.52,-122.68),(39.95,-75.17),(29.76,-95.37),(32.78,-96.80),
        (47.61,-122.33),(43.65,-79.38),(49.28,-123.12),(45.50,-73.57),
    ]

    for lat, lng in search_points:
        try:
            url = f'https://pokemon.play.carde.io/api/stores/search?lat={lat}&lng={lng}&radius=100'
            resp = requests.get(url, headers={**HEADERS, 'Accept': 'application/json'}, timeout=10)
            if resp.status_code == 200:
                try:
                    data = resp.json()
                    stores = data if isinstance(data, list) else data.get('stores', data.get('results', data.get('data', [])))
                    for s in stores:
                        name = s.get('name', '') or s.get('storeName', '')
                        st = s.get('state', '') or s.get('region', '')
                        ctry = 'CA' if st in CA_PROVS else 'US'
                        add_shop(
                            name=name,
                            address=s.get('address', '') or s.get('street', ''),
                            city=s.get('city', ''),
                            state=st,
                            country=ctry,
                            phone=s.get('phone', ''),
                            lat=s.get('latitude', s.get('lat', 0)),
                            lng=s.get('longitude', s.get('lng', 0)),
                            website=s.get('website', ''),
                            source='pokemon_carde',
                            types_list=['Pokemon', 'TCG'],
                        )
                    if stores:
                        print(f'  ({lat},{lng}): {len(stores)} stores')
                except json.JSONDecodeError:
                    pass
        except Exception:
            pass
        time.sleep(random.uniform(0.5, 1.0))

    added = len(all_shops) - before
    print(f'Pokemon/Carde: {added} new shops (total: {len(all_shops)})')


# ── Source 6: SportsCardPortal.com ──
def scrape_sportscardportal():
    print('\n=== SportsCardPortal.com ===')
    before = len(all_shops)

    url = 'https://www.sportscardportal.com/local_card_shop_locator.php'
    try:
        resp = requests.get(url, headers=HEADERS, timeout=15)
        if resp.status_code == 200:
            soup = BeautifulSoup(resp.text, 'html.parser')

            # Find state links
            state_links = []
            for a in soup.find_all('a', href=True):
                href = a['href']
                if 'state=' in href or '/state/' in href:
                    state_links.append(href)

            if not state_links:
                # Try to parse shops directly from the page
                for el in soup.find_all(['div','tr','li'], class_=re.compile(r'(shop|store|listing|dealer)', re.I)):
                    name_el = el.find(['h2','h3','h4','a','strong','td'])
                    if name_el:
                        name = name_el.get_text(strip=True)
                        if name and 3 < len(name) < 80:
                            text = el.get_text(' ', strip=True)
                            state, country = extract_state(text)
                            add_shop(name=name, state=state, country=country,
                                    source='sportscardportal', types_list=['Sports'] + classify(name))

            # Follow state links
            for href in state_links[:60]:  # limit
                if not href.startswith('http'):
                    href = 'https://www.sportscardportal.com/' + href.lstrip('/')
                try:
                    resp2 = requests.get(href, headers=HEADERS, timeout=15)
                    if resp2.status_code != 200:
                        continue
                    soup2 = BeautifulSoup(resp2.text, 'html.parser')
                    for el in soup2.find_all(['div','tr','li','article'], class_=re.compile(r'(shop|store|listing|dealer|result)', re.I)):
                        name_el = el.find(['h2','h3','h4','a','strong','td'])
                        if name_el:
                            name = name_el.get_text(strip=True)
                            if name and 3 < len(name) < 80:
                                text = el.get_text(' ', strip=True)
                                state, country = extract_state(text)
                                phone_match = re.search(r'\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}', text)
                                phone = phone_match.group(0) if phone_match else ''
                                add_shop(name=name, state=state, country=country, phone=phone,
                                        source='sportscardportal', types_list=['Sports'] + classify(name))
                except Exception:
                    pass
                time.sleep(random.uniform(0.8, 1.5))

    except Exception as e:
        print(f'  ERROR: {e}')

    added = len(all_shops) - before
    print(f'SportsCardPortal: {added} new shops (total: {len(all_shops)})')


def main():
    print('=== Card Shop Directory Scraper v2 ===')
    print(f'Output: {OUTPUT_FILE}')

    scrape_sportscardshops()
    scrape_cardstoresnearme()
    scrape_cgc()
    scrape_wizards()
    scrape_pokemon_carde()
    scrape_sportscardportal()

    print(f'\n=== TOTAL from directories: {len(all_shops)} unique shops ===')

    # Write results
    rows = list(all_shops.values())
    fieldnames = [
        'name','address','city','state','country','zip','phone',
        'lat','lng','region','types','hours','website','notes',
        'google_place_id','source','verified','active'
    ]
    with open(OUTPUT_FILE, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, quoting=csv.QUOTE_ALL)
        writer.writeheader()
        for row in sorted(rows, key=lambda r: (r['country'], r['state'], r['city'], r['name'])):
            writer.writerow(row)

    print(f'Wrote {len(rows)} shops to {OUTPUT_FILE}')

    # Merge
    if MERGED_FILE.exists():
        print(f'\nMerging with {MERGED_FILE.name}...')
        existing = []
        with open(MERGED_FILE, encoding='utf-8') as f:
            existing = list(csv.DictReader(f))

        existing_names = set()
        for r in existing:
            existing_names.add(r['name'].lower().strip())

        added = 0
        for r in rows:
            if r['name'].lower().strip() not in existing_names:
                existing.append(r)
                existing_names.add(r['name'].lower().strip())
                added += 1

        with open(MERGED_FILE, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames, quoting=csv.QUOTE_ALL, extrasaction='ignore')
            writer.writeheader()
            for row in sorted(existing, key=lambda r: (r.get('country',''), r.get('state',''), r.get('name',''))):
                writer.writerow(row)

        print(f'Merged: {added} new, {len(existing)} total in {MERGED_FILE.name}')

    by_state = {}
    for r in rows:
        key = f"{r['country']}/{r['state']}" if r['state'] else '??'
        by_state[key] = by_state.get(key, 0) + 1
    if by_state:
        print('\nBy state:')
        for st in sorted(by_state.keys()):
            print(f'  {st}: {by_state[st]}')


if __name__ == '__main__':
    main()
