#!/usr/bin/env python3
"""
Headless browser scraper — WPN Store Locator + Pokemon Store Locator
Uses Playwright to render JS-heavy pages and extract shop data.
Tags shops as: TCG, Sports, or Both based on source + name analysis.

Merges into card_shops_import.csv.
"""
import csv, json, re, time, random, asyncio
from pathlib import Path
from playwright.async_api import async_playwright

OUTPUT = Path(__file__).parent / 'card_shops_wpn_pokemon.csv'
MERGED = Path(__file__).parent / 'card_shops_import.csv'

STATE_CODES = {'AL','AK','AZ','AR','CA','CO','CT','DE','DC','FL','GA','HI','ID','IL','IN','IA',
    'KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ',
    'NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT',
    'VA','WA','WV','WI','WY'}
CA_PROVS = {'AB','BC','MB','NB','NL','NS','NT','NU','ON','PE','QC','SK','YT'}

# Search grid — major cities to search from
SEARCH_POINTS = [
    (33.52,-86.80,'AL','Birmingham'), (61.22,-149.90,'AK','Anchorage'),
    (33.45,-112.07,'AZ','Phoenix'), (34.75,-92.29,'AR','Little Rock'),
    (34.05,-118.24,'CA','Los Angeles'), (37.77,-122.42,'CA','San Francisco'),
    (32.72,-117.16,'CA','San Diego'), (38.58,-121.49,'CA','Sacramento'),
    (39.74,-104.99,'CO','Denver'), (41.76,-72.68,'CT','Hartford'),
    (39.74,-75.55,'DE','Wilmington'), (25.76,-80.19,'FL','Miami'),
    (28.54,-81.38,'FL','Orlando'), (27.95,-82.46,'FL','Tampa'),
    (30.33,-81.66,'FL','Jacksonville'), (33.75,-84.39,'GA','Atlanta'),
    (21.31,-157.86,'HI','Honolulu'), (43.62,-116.21,'ID','Boise'),
    (41.88,-87.63,'IL','Chicago'), (39.77,-86.16,'IN','Indianapolis'),
    (41.59,-93.62,'IA','Des Moines'), (37.69,-97.34,'KS','Wichita'),
    (38.25,-85.76,'KY','Louisville'), (29.95,-90.07,'LA','New Orleans'),
    (43.66,-70.26,'ME','Portland'), (39.29,-76.61,'MD','Baltimore'),
    (42.36,-71.06,'MA','Boston'), (42.33,-83.05,'MI','Detroit'),
    (42.96,-85.67,'MI','Grand Rapids'), (44.98,-93.27,'MN','Minneapolis'),
    (32.30,-90.18,'MS','Jackson'), (38.63,-90.20,'MO','St Louis'),
    (46.87,-113.99,'MT','Missoula'), (41.26,-95.94,'NE','Omaha'),
    (36.17,-115.14,'NV','Las Vegas'), (42.99,-71.45,'NH','Manchester'),
    (40.74,-74.17,'NJ','Newark'), (35.08,-106.65,'NM','Albuquerque'),
    (40.71,-74.01,'NY','New York'), (42.89,-78.88,'NY','Buffalo'),
    (35.23,-80.84,'NC','Charlotte'), (35.78,-78.64,'NC','Raleigh'),
    (35.05,-85.31,'TN','Chattanooga'), (36.16,-86.78,'TN','Nashville'),
    (35.96,-83.92,'TN','Knoxville'), (35.15,-90.05,'TN','Memphis'),
    (46.88,-96.79,'ND','Fargo'), (41.50,-81.69,'OH','Cleveland'),
    (39.96,-83.00,'OH','Columbus'), (39.10,-84.51,'OH','Cincinnati'),
    (35.47,-97.52,'OK','Oklahoma City'), (45.52,-122.68,'OR','Portland'),
    (39.95,-75.17,'PA','Philadelphia'), (40.44,-80.00,'PA','Pittsburgh'),
    (41.82,-71.41,'RI','Providence'), (34.00,-81.03,'SC','Columbia'),
    (43.55,-96.73,'SD','Sioux Falls'),
    (29.76,-95.37,'TX','Houston'), (32.78,-96.80,'TX','Dallas'),
    (30.27,-97.74,'TX','Austin'), (29.42,-98.49,'TX','San Antonio'),
    (40.76,-111.89,'UT','Salt Lake City'), (44.26,-72.58,'VT','Burlington'),
    (37.54,-77.43,'VA','Richmond'), (47.61,-122.33,'WA','Seattle'),
    (38.35,-81.63,'WV','Charleston'), (43.04,-87.91,'WI','Milwaukee'),
    (42.87,-106.31,'WY','Cheyenne'),
    # Canada
    (43.65,-79.38,'ON','Toronto'), (45.50,-73.57,'QC','Montreal'),
    (49.28,-123.12,'BC','Vancouver'), (51.05,-114.07,'AB','Calgary'),
    (53.55,-113.49,'AB','Edmonton'), (45.42,-75.70,'ON','Ottawa'),
    (49.90,-97.14,'MB','Winnipeg'), (44.65,-63.57,'NS','Halifax'),
]

all_shops = {}


def classify_type(name, source):
    """Classify shop as Sports, TCG, or both."""
    n = name.lower()
    is_sports = any(w in n for w in ['sport','baseball','football','basketball','memorabilia','rookie','bat ','dugout','ballpark','home run','grand slam'])
    is_tcg = any(w in n for w in ['pokemon','magic','mtg','yu-gi-oh','yugioh','tcg','lorcana','game','comic','anime','manga','tabletop','dice','dragon','dungeon','warhammer'])

    types = []
    if is_sports and is_tcg:
        types = ['Sports','TCG']
    elif is_sports:
        types = ['Sports']
    elif is_tcg:
        types = ['TCG']
    elif source == 'wpn':
        types = ['TCG','MTG']
    elif source == 'pokemon':
        types = ['TCG','Pokemon']
    else:
        # Generic card/hobby shop — could be either
        if any(w in n for w in ['card','collectible','hobby','collector']):
            types = ['Sports','TCG']  # likely both
        else:
            types = ['TCG']

    # Add specific sub-types
    if 'pokemon' in n or 'poke' in n:
        if 'Pokemon' not in types: types.append('Pokemon')
    if 'magic' in n or 'mtg' in n:
        if 'MTG' not in types: types.append('MTG')
    if 'comic' in n:
        if 'Comics' not in types: types.append('Comics')

    return types


def add_shop(name, address, city, state, country, phone, lat, lng, website, source):
    if not name or len(name.strip()) < 2:
        return
    name = name.strip()
    key = f"{name.lower()}|{state}"
    if key in all_shops:
        return
    types = classify_type(name, source)
    all_shops[key] = {
        'name': name,
        'address': (address or '').strip(),
        'city': (city or '').strip(),
        'state': (state or '').strip(),
        'country': country or 'US',
        'zip': '',
        'phone': (phone or '').strip(),
        'lat': lat or '',
        'lng': lng or '',
        'region': '',
        'types': '{' + ','.join(types) + '}',
        'hours': '',
        'website': (website or '').strip(),
        'notes': f'source:{source}',
        'google_place_id': '',
        'source': source,
        'verified': 'false',
        'active': 'true',
    }


async def scrape_wpn(browser):
    """Scrape Wizards of the Coast store locator."""
    print('\n=== WPN Store Locator (locator.wizards.com) ===')
    before = len(all_shops)
    page = await browser.new_page()

    for lat, lng, state, city_name in SEARCH_POINTS:
        country = 'CA' if state in CA_PROVS else 'US'
        try:
            url = f'https://locator.wizards.com/?searchType=stores&query={city_name}+{state}&distance=100&page=1&sort=date&sortDirection=asc'
            await page.goto(url, timeout=30000, wait_until='networkidle')
            await page.wait_for_timeout(3000)

            # Try to extract store data from the page
            # Method 1: Look for JSON data in page content
            content = await page.content()

            # Look for store data in script tags or data attributes
            stores_json = re.findall(r'"stores"\s*:\s*(\[[^\]]*\])', content)
            for sj in stores_json:
                try:
                    stores = json.loads(sj)
                    for s in stores:
                        add_shop(
                            name=s.get('name',''), address=s.get('address','') or s.get('street1',''),
                            city=s.get('city',''), state=s.get('state','') or s.get('territory','') or state,
                            country=country, phone=s.get('phone',''),
                            lat=s.get('latitude',s.get('lat',0)), lng=s.get('longitude',s.get('lng',0)),
                            website=s.get('website',''), source='wpn'
                        )
                except json.JSONDecodeError:
                    pass

            # Method 2: Parse visible store cards from HTML
            cards = await page.query_selector_all('[class*="store"], [class*="location"], [class*="result"], [data-store], [data-location]')
            for card in cards:
                try:
                    text = await card.inner_text()
                    name_el = await card.query_selector('h2, h3, h4, strong, [class*="name"], [class*="title"]')
                    name = await name_el.inner_text() if name_el else ''
                    if not name:
                        lines = text.strip().split('\n')
                        name = lines[0].strip() if lines else ''

                    phone_match = re.search(r'\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}', text)
                    phone = phone_match.group(0) if phone_match else ''

                    addr_match = re.search(r'(\d{1,5}\s+[\w\s.]+(?:St|Ave|Rd|Dr|Blvd|Ln|Way|Pike|Pkwy|Hwy|Ct|Road|Street|Avenue|Drive)\b[^,\n]*)', text, re.I)
                    address = addr_match.group(1).strip() if addr_match else ''

                    if name and len(name) > 2:
                        add_shop(name=name, address=address, city='', state=state,
                                country=country, phone=phone, lat=0, lng=0, website='', source='wpn')
                except Exception:
                    pass

            # Method 3: Intercept API calls
            # Check if page made XHR requests with store data
            added_this_city = len(all_shops) - before
            if added_this_city > 0:
                print(f'  WPN {city_name} {state}: found stores')

        except Exception as e:
            print(f'  WPN {city_name} {state}: {str(e)[:50]}')

        await page.wait_for_timeout(random.randint(1000, 2000))

    await page.close()
    added = len(all_shops) - before
    print(f'WPN total: {added} new shops')


async def scrape_wpn_api(page):
    """Try to intercept WPN API calls."""
    stores_found = []

    async def handle_response(response):
        if 'api' in response.url and response.status == 200:
            try:
                data = await response.json()
                if isinstance(data, list):
                    stores_found.extend(data)
                elif isinstance(data, dict):
                    for key in ['stores','results','locations','data']:
                        if key in data and isinstance(data[key], list):
                            stores_found.extend(data[key])
            except Exception:
                pass

    page.on('response', handle_response)
    return stores_found


async def scrape_pokemon(browser):
    """Scrape Pokemon store locator."""
    print('\n=== Pokemon Store Locator ===')
    before = len(all_shops)
    page = await browser.new_page()

    # Intercept API responses
    api_stores = []
    async def capture_response(response):
        url = response.url.lower()
        if ('store' in url or 'location' in url or 'search' in url) and response.status == 200:
            try:
                ct = response.headers.get('content-type','')
                if 'json' in ct:
                    data = await response.json()
                    if isinstance(data, list):
                        api_stores.extend(data)
                    elif isinstance(data, dict):
                        for k in ['stores','results','locations','data','items']:
                            if k in data and isinstance(data[k], list):
                                api_stores.extend(data[k])
            except Exception:
                pass

    page.on('response', capture_response)

    for lat, lng, state, city_name in SEARCH_POINTS:
        country = 'CA' if state in CA_PROVS else 'US'
        api_stores.clear()

        try:
            # Try pokemon.com locator
            url = f'https://www.pokemon.com/us/play-pokemon/pokemon-events/find-an-event-or-league/?pokemon_event_type%5B%5D=0&distance=100&city={city_name}&state={state}'
            await page.goto(url, timeout=30000, wait_until='networkidle')
            await page.wait_for_timeout(3000)

            # Process any API responses captured
            for s in api_stores:
                name = s.get('name','') or s.get('storeName','') or s.get('venue','')
                add_shop(
                    name=name,
                    address=s.get('address','') or s.get('street','') or s.get('address1',''),
                    city=s.get('city',''),
                    state=s.get('state','') or s.get('province','') or state,
                    country=country,
                    phone=s.get('phone',''),
                    lat=s.get('latitude',s.get('lat',0)),
                    lng=s.get('longitude',s.get('lng',s.get('lon',0))),
                    website=s.get('website','') or s.get('url',''),
                    source='pokemon'
                )

            # Also parse HTML
            content = await page.content()
            # Look for store data in embedded JSON
            json_blocks = re.findall(r'(\{[^{}]*"(?:name|storeName)"[^{}]*\})', content)
            for block in json_blocks:
                try:
                    s = json.loads(block)
                    name = s.get('name','') or s.get('storeName','')
                    if name:
                        add_shop(name=name, address=s.get('address',''), city=s.get('city',''),
                                state=s.get('state','') or state, country=country,
                                phone=s.get('phone',''), lat=s.get('lat',0), lng=s.get('lng',0),
                                website=s.get('website',''), source='pokemon')
                except json.JSONDecodeError:
                    pass

            # Parse visible cards
            cards = await page.query_selector_all('[class*="location"], [class*="store"], [class*="venue"], [class*="result"]')
            for card in cards:
                try:
                    text = await card.inner_text()
                    lines = [l.strip() for l in text.split('\n') if l.strip()]
                    if lines:
                        name = lines[0]
                        phone_match = re.search(r'\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}', text)
                        phone = phone_match.group(0) if phone_match else ''
                        if name and len(name) > 2 and len(name) < 80:
                            add_shop(name=name, city=city_name, state=state, country=country,
                                    phone=phone, lat=0, lng=0, website='', source='pokemon',
                                    address='')
                except Exception:
                    pass

            current = len(all_shops) - before
            if current > 0 and current % 50 == 0:
                print(f'  Pokemon: {current} shops so far...')

        except Exception as e:
            pass

        await page.wait_for_timeout(random.randint(1000, 2000))

    await page.close()
    added = len(all_shops) - before
    print(f'Pokemon total: {added} new shops')


async def scrape_carde(browser):
    """Scrape Carde.io Pokemon play network."""
    print('\n=== Carde.io Pokemon Play Network ===')
    before = len(all_shops)
    page = await browser.new_page()

    api_stores = []
    async def capture(response):
        if response.status == 200 and 'json' in response.headers.get('content-type',''):
            try:
                data = await response.json()
                if isinstance(data, list):
                    api_stores.extend(data)
                elif isinstance(data, dict):
                    for k in ['stores','results','data','items','locations']:
                        if k in data and isinstance(data[k], list):
                            api_stores.extend(data[k])
            except Exception:
                pass

    page.on('response', capture)

    for lat, lng, state, city_name in SEARCH_POINTS:
        country = 'CA' if state in CA_PROVS else 'US'
        api_stores.clear()
        try:
            url = f'https://pokemon.play.carde.io/stores/search?lat={lat}&lng={lng}&radius=100'
            await page.goto(url, timeout=20000, wait_until='networkidle')
            await page.wait_for_timeout(2000)

            for s in api_stores:
                name = s.get('name','') or s.get('storeName','')
                add_shop(name=name, address=s.get('address',''), city=s.get('city',''),
                        state=s.get('state','') or state, country=country,
                        phone=s.get('phone',''), lat=s.get('lat',0), lng=s.get('lng',0),
                        website=s.get('website',''), source='pokemon_carde')
        except Exception:
            pass
        await page.wait_for_timeout(random.randint(500, 1500))

    await page.close()
    added = len(all_shops) - before
    print(f'Carde.io total: {added} new shops')


async def main():
    print('=== Headless Browser Scraper — WPN + Pokemon ===')
    print(f'Search points: {len(SEARCH_POINTS)}')

    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)

        await scrape_wpn(browser)
        await scrape_pokemon(browser)
        await scrape_carde(browser)

        await browser.close()

    print(f'\n=== TOTAL from browser scraping: {len(all_shops)} unique shops ===')

    # Type breakdown
    sports_only = sum(1 for s in all_shops.values() if 'Sports' in s['types'] and 'TCG' not in s['types'])
    tcg_only = sum(1 for s in all_shops.values() if 'TCG' in s['types'] and 'Sports' not in s['types'])
    both = sum(1 for s in all_shops.values() if 'Sports' in s['types'] and 'TCG' in s['types'])
    other = len(all_shops) - sports_only - tcg_only - both
    print(f'  Sports only: {sports_only}')
    print(f'  TCG only: {tcg_only}')
    print(f'  Both Sports+TCG: {both}')
    print(f'  Other: {other}')

    rows = list(all_shops.values())
    fieldnames = ['name','address','city','state','country','zip','phone','lat','lng','region',
                  'types','hours','website','notes','google_place_id','source','verified','active']

    with open(OUTPUT, 'w', newline='', encoding='utf-8') as f:
        w = csv.DictWriter(f, fieldnames=fieldnames, quoting=csv.QUOTE_ALL)
        w.writeheader()
        for r in sorted(rows, key=lambda x: (x['country'], x['state'], x['city'], x['name'])):
            w.writerow(r)
    print(f'Wrote {len(rows)} to {OUTPUT}')

    # Merge
    if MERGED.exists():
        existing = list(csv.DictReader(open(MERGED, encoding='utf-8')))
        ex_names = set(r['name'].lower().strip() for r in existing)
        added = 0
        for r in rows:
            if r['name'].lower().strip() not in ex_names:
                existing.append(r)
                ex_names.add(r['name'].lower().strip())
                added += 1
        with open(MERGED, 'w', newline='', encoding='utf-8') as f:
            w = csv.DictWriter(f, fieldnames=fieldnames, quoting=csv.QUOTE_ALL, extrasaction='ignore')
            w.writeheader()
            for r in sorted(existing, key=lambda x: (x.get('country',''), x.get('state',''), x.get('name',''))):
                w.writerow(r)
        print(f'Merged: {added} new, {len(existing)} total in {MERGED.name}')

    by_state = {}
    for r in rows:
        k = f"{r['country']}/{r['state']}" if r['state'] else '??'
        by_state[k] = by_state.get(k, 0) + 1
    if by_state:
        print('\nBy state:')
        for s in sorted(by_state.keys()):
            print(f'  {s}: {by_state[s]}')


if __name__ == '__main__':
    asyncio.run(main())
