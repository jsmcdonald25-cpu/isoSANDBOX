#!/usr/bin/env python3
"""
Targeted DDG scraper — searches for card shops in every US city with 50k+ population.
Extracts shop names, addresses, phones from search results.
Merges into card_shops_import.csv.
"""
import csv, re, time, random
from pathlib import Path
from ddgs import DDGS

OUTPUT = Path(__file__).parent / 'card_shops_ddg_targeted.csv'
MERGED = Path(__file__).parent / 'card_shops_import.csv'

STATE_CODES = {'AL','AK','AZ','AR','CA','CO','CT','DE','DC','FL','GA','HI','ID','IL','IN','IA',
    'KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ',
    'NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT',
    'VA','WA','WV','WI','WY'}

# Every US city 50k+ population, plus smaller cities in underrepresented states
CITIES = [
    # TN — extra coverage
    ('Knoxville','TN'), ('Memphis','TN'), ('Nashville','TN'), ('Chattanooga','TN'),
    ('Clarksville','TN'), ('Murfreesboro','TN'), ('Franklin','TN'), ('Jackson','TN'),
    ('Johnson City','TN'), ('Kingsport','TN'), ('Hendersonville','TN'), ('Cookeville','TN'),
    ('Collierville','TN'), ('Smyrna','TN'), ('Germantown','TN'), ('Bartlett','TN'),
    # NC — extra coverage
    ('Charlotte','NC'), ('Raleigh','NC'), ('Greensboro','NC'), ('Durham','NC'),
    ('Winston-Salem','NC'), ('Fayetteville','NC'), ('Cary','NC'), ('Wilmington','NC'),
    ('High Point','NC'), ('Concord','NC'), ('Asheville','NC'), ('Gastonia','NC'),
    ('Jacksonville','NC'), ('Hickory','NC'), ('Mooresville','NC'), ('Huntersville','NC'),
    # AL
    ('Birmingham','AL'), ('Huntsville','AL'), ('Montgomery','AL'), ('Mobile','AL'), ('Tuscaloosa','AL'),
    # AK
    ('Anchorage','AK'), ('Fairbanks','AK'), ('Juneau','AK'),
    # AZ
    ('Phoenix','AZ'), ('Tucson','AZ'), ('Mesa','AZ'), ('Scottsdale','AZ'), ('Tempe','AZ'), ('Gilbert','AZ'),
    # AR
    ('Little Rock','AR'), ('Fort Smith','AR'), ('Fayetteville','AR'), ('Springdale','AR'),
    # CA
    ('Los Angeles','CA'), ('San Francisco','CA'), ('San Diego','CA'), ('San Jose','CA'),
    ('Sacramento','CA'), ('Fresno','CA'), ('Long Beach','CA'), ('Oakland','CA'),
    ('Bakersfield','CA'), ('Anaheim','CA'), ('Riverside','CA'), ('Irvine','CA'),
    # CO
    ('Denver','CO'), ('Colorado Springs','CO'), ('Aurora','CO'), ('Fort Collins','CO'), ('Boulder','CO'),
    # CT
    ('Hartford','CT'), ('New Haven','CT'), ('Stamford','CT'), ('Bridgeport','CT'), ('Danbury','CT'),
    # DE
    ('Wilmington','DE'), ('Dover','DE'), ('Newark','DE'),
    # FL
    ('Miami','FL'), ('Tampa','FL'), ('Orlando','FL'), ('Jacksonville','FL'), ('Fort Lauderdale','FL'),
    ('St Petersburg','FL'), ('Sarasota','FL'), ('Naples','FL'), ('Pensacola','FL'), ('Tallahassee','FL'),
    # GA
    ('Atlanta','GA'), ('Savannah','GA'), ('Augusta','GA'), ('Columbus','GA'), ('Marietta','GA'),
    # HI
    ('Honolulu','HI'), ('Pearl City','HI'), ('Maui','HI'),
    # ID
    ('Boise','ID'), ('Nampa','ID'), ('Idaho Falls','ID'),
    # IL
    ('Chicago','IL'), ('Springfield','IL'), ('Peoria','IL'), ('Rockford','IL'), ('Naperville','IL'),
    # IN
    ('Indianapolis','IN'), ('Fort Wayne','IN'), ('Evansville','IN'), ('South Bend','IN'), ('Bloomington','IN'),
    # IA
    ('Des Moines','IA'), ('Cedar Rapids','IA'), ('Davenport','IA'), ('Iowa City','IA'),
    # KS
    ('Wichita','KS'), ('Overland Park','KS'), ('Kansas City','KS'), ('Topeka','KS'), ('Olathe','KS'),
    # KY
    ('Louisville','KY'), ('Lexington','KY'), ('Bowling Green','KY'), ('Covington','KY'),
    # LA
    ('New Orleans','LA'), ('Baton Rouge','LA'), ('Shreveport','LA'), ('Lafayette','LA'),
    # ME
    ('Portland','ME'), ('Bangor','ME'), ('Lewiston','ME'),
    # MD
    ('Baltimore','MD'), ('Annapolis','MD'), ('Frederick','MD'), ('Rockville','MD'),
    # MA
    ('Boston','MA'), ('Worcester','MA'), ('Springfield','MA'), ('Cambridge','MA'),
    # MI
    ('Detroit','MI'), ('Grand Rapids','MI'), ('Ann Arbor','MI'), ('Lansing','MI'), ('Kalamazoo','MI'),
    # MN
    ('Minneapolis','MN'), ('St Paul','MN'), ('Rochester','MN'), ('Duluth','MN'), ('Bloomington','MN'),
    # MS
    ('Jackson','MS'), ('Gulfport','MS'), ('Southaven','MS'), ('Hattiesburg','MS'),
    # MO
    ('St Louis','MO'), ('Kansas City','MO'), ('Springfield','MO'), ('Columbia','MO'),
    # MT
    ('Billings','MT'), ('Missoula','MT'), ('Great Falls','MT'), ('Bozeman','MT'),
    # NE
    ('Omaha','NE'), ('Lincoln','NE'),
    # NV
    ('Las Vegas','NV'), ('Reno','NV'), ('Henderson','NV'),
    # NH
    ('Manchester','NH'), ('Concord','NH'), ('Nashua','NH'),
    # NJ
    ('Newark','NJ'), ('Jersey City','NJ'), ('Hoboken','NJ'), ('Edison','NJ'), ('Toms River','NJ'),
    # NM
    ('Albuquerque','NM'), ('Santa Fe','NM'), ('Las Cruces','NM'),
    # NY
    ('New York City','NY'), ('Buffalo','NY'), ('Rochester','NY'), ('Syracuse','NY'), ('Albany','NY'),
    # ND
    ('Fargo','ND'), ('Bismarck','ND'), ('Grand Forks','ND'), ('Minot','ND'),
    # OH
    ('Columbus','OH'), ('Cleveland','OH'), ('Cincinnati','OH'), ('Dayton','OH'), ('Toledo','OH'), ('Akron','OH'),
    # OK
    ('Oklahoma City','OK'), ('Tulsa','OK'), ('Norman','OK'),
    # OR
    ('Portland','OR'), ('Eugene','OR'), ('Salem','OR'), ('Bend','OR'), ('Beaverton','OR'),
    # PA
    ('Philadelphia','PA'), ('Pittsburgh','PA'), ('Allentown','PA'), ('Erie','PA'), ('Reading','PA'),
    # RI
    ('Providence','RI'), ('Warwick','RI'), ('Cranston','RI'),
    # SC
    ('Charleston','SC'), ('Columbia','SC'), ('Greenville','SC'), ('Rock Hill','SC'), ('Spartanburg','SC'),
    # SD
    ('Sioux Falls','SD'), ('Rapid City','SD'),
    # TX
    ('Houston','TX'), ('Dallas','TX'), ('Austin','TX'), ('San Antonio','TX'), ('Fort Worth','TX'),
    ('El Paso','TX'), ('Arlington','TX'), ('Plano','TX'), ('Lubbock','TX'), ('Corpus Christi','TX'),
    # UT
    ('Salt Lake City','UT'), ('Provo','UT'), ('Ogden','UT'), ('St George','UT'),
    # VT
    ('Burlington','VT'), ('South Burlington','VT'), ('Rutland','VT'),
    # VA
    ('Virginia Beach','VA'), ('Richmond','VA'), ('Norfolk','VA'), ('Arlington','VA'), ('Roanoke','VA'),
    # WA
    ('Seattle','WA'), ('Tacoma','WA'), ('Spokane','WA'), ('Bellevue','WA'), ('Vancouver','WA'),
    # WV
    ('Charleston','WV'), ('Huntington','WV'), ('Morgantown','WV'),
    # WI
    ('Milwaukee','WI'), ('Madison','WI'), ('Green Bay','WI'), ('Appleton','WI'),
    # WY
    ('Cheyenne','WY'), ('Casper','WY'), ('Laramie','WY'),
    # Canada
    ('Toronto','ON'), ('Vancouver','BC'), ('Montreal','QC'), ('Calgary','AB'),
    ('Edmonton','AB'), ('Ottawa','ON'), ('Winnipeg','MB'), ('Halifax','NS'),
]

QUERIES = [
    'sports card shop in {city} {state}',
    'trading card store {city} {state}',
    'pokemon card shop {city} {state}',
    'local card shop {city} {state}',
]

CA_PROVS = {'AB','BC','MB','NB','NL','NS','NT','NU','ON','PE','QC','SK','YT'}


def extract_phone(text):
    m = re.search(r'\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}', text)
    return m.group(0) if m else ''


def extract_address(text):
    m = re.search(r'(\d{1,5}\s+[\w\s.]+(?:St|Ave|Rd|Dr|Blvd|Ln|Way|Pike|Pkwy|Hwy|Ct|Cir|Pl|Road|Street|Avenue|Drive|Boulevard|Lane|Circle|Place|Trail|Highway)\b[^,.]*)', text, re.I)
    return m.group(1).strip() if m else ''


def extract_state(text, fallback_state):
    text_upper = text.upper()
    for code in STATE_CODES:
        if re.search(r'\b' + code + r'\b', text_upper):
            return code, 'US'
    for code in CA_PROVS:
        if re.search(r'\b' + code + r'\b', text_upper):
            return code, 'CA'
    country = 'CA' if fallback_state in CA_PROVS else 'US'
    return fallback_state, country


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


def is_shop_name(name):
    """Filter out directory/article titles, keep actual business names."""
    low = name.lower()
    skip = ['best card shops', 'top 10', 'top card', 'where to buy', 'guide to',
            'list of', 'directory', 'near me', 'card shops in', 'stores in',
            'yelp', 'yellowpages', 'mapquest', 'tripadvisor', 'groupon',
            'facebook', 'reddit', 'google maps', 'foursquare']
    return not any(s in low for s in skip) and 3 <= len(name) <= 80


def main():
    print(f'=== DDG Targeted City Scraper ===')
    print(f'Cities: {len(CITIES)}, Queries per city: {len(QUERIES)}')
    total = len(CITIES) * len(QUERIES)
    print(f'Total searches: {total}')
    print()

    all_shops = {}
    done = 0
    errors = 0
    ddgs = DDGS()

    for city, state in CITIES:
        for q_template in QUERIES:
            done += 1
            query = q_template.format(city=city, state=state)
            print(f'  [{done}/{total}] "{query}"...', end='', flush=True)

            try:
                results = list(ddgs.text(query, max_results=20))
                found = 0
                for r in results:
                    title = r.get('title', '')
                    body = r.get('body', '')
                    href = r.get('href', '')

                    # Skip aggregator sites
                    if any(d in href for d in ['yelp.com/search', 'yellowpages.com/search',
                        'google.com/maps', 'tripadvisor.com', 'groupon.com', 'bbb.org/search']):
                        continue

                    # Extract shop name from title
                    name = title.split(' - ')[0].split(' | ')[0].split(' :: ')[0].strip()
                    name = re.sub(r'\s*\(.*?\)\s*$', '', name).strip()

                    if not is_shop_name(name):
                        continue

                    # Need card-related keyword somewhere
                    all_text = f'{title} {body}'.lower()
                    card_words = ['card', 'game', 'comic', 'pokemon', 'tcg', 'mtg', 'magic',
                                  'hobby', 'collectible', 'sport', 'trading', 'memorabilia']
                    if not any(w in all_text for w in card_words):
                        continue

                    phone = extract_phone(body) or extract_phone(title)
                    address = extract_address(body) or extract_address(title)
                    st, country = extract_state(f'{body} {title}', state)

                    # Only keep if we got a phone (that's Scott's requirement)
                    if not phone:
                        continue

                    key = f"{name.lower()}|{st}"
                    if key in all_shops:
                        continue

                    all_shops[key] = {
                        'name': name,
                        'address': address,
                        'city': city,
                        'state': st,
                        'country': country,
                        'zip': '',
                        'phone': phone,
                        'lat': '',
                        'lng': '',
                        'region': '',
                        'types': '{' + ','.join(classify(name)) + '}',
                        'hours': '',
                        'website': href if not any(d in href for d in ['yelp.com','yellowpages','facebook.com/search']) else '',
                        'notes': '',
                        'google_place_id': '',
                        'source': 'ddg_targeted',
                        'verified': 'false',
                        'active': 'true',
                    }
                    found += 1

                print(f' {len(results)} results, {found} new shops (total: {len(all_shops)})')

            except Exception as e:
                errors += 1
                msg = str(e)[:50]
                print(f' ERROR: {msg}')
                if 'ratelimit' in msg.lower() or '429' in msg:
                    print('    Rate limited, waiting 60s...')
                    time.sleep(60)

            time.sleep(random.uniform(2.0, 4.0))

    print(f'\nTotal from DDG targeted: {len(all_shops)}')
    if errors:
        print(f'Errors: {errors}')

    rows = list(all_shops.values())
    fieldnames = ['name','address','city','state','country','zip','phone',
        'lat','lng','region','types','hours','website','notes',
        'google_place_id','source','verified','active']

    with open(OUTPUT, 'w', newline='', encoding='utf-8') as f:
        w = csv.DictWriter(f, fieldnames=fieldnames, quoting=csv.QUOTE_ALL)
        w.writeheader()
        for r in sorted(rows, key=lambda x: (x['country'], x['state'], x['city'], x['name'])):
            w.writerow(r)
    print(f'Wrote {len(rows)} to {OUTPUT}')

    # Merge
    if MERGED.exists():
        print(f'\nMerging with {MERGED.name}...')
        existing = []
        with open(MERGED, encoding='utf-8') as f:
            existing = list(csv.DictReader(f))
        existing_names = set(r['name'].lower().strip() for r in existing)

        added = 0
        for r in rows:
            if r['name'].lower().strip() not in existing_names:
                existing.append(r)
                existing_names.add(r['name'].lower().strip())
                added += 1

        with open(MERGED, 'w', newline='', encoding='utf-8') as f:
            w = csv.DictWriter(f, fieldnames=fieldnames, quoting=csv.QUOTE_ALL, extrasaction='ignore')
            w.writeheader()
            for r in sorted(existing, key=lambda x: (x.get('country',''), x.get('state',''), x.get('name',''))):
                w.writerow(r)
        print(f'Added {added} new, total in merged: {len(existing)}')

    by_state = {}
    for r in rows:
        k = f"{r['country']}/{r['state']}"
        by_state[k] = by_state.get(k, 0) + 1
    if by_state:
        print('\nBy state:')
        for s in sorted(by_state.keys()):
            print(f'  {s}: {by_state[s]}')


if __name__ == '__main__':
    main()
