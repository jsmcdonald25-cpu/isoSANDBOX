#!/usr/bin/env python3
"""DDG scraper — second pass, all 50 states with different queries to find shops missed in pass 1."""
import csv, re, time, random
from pathlib import Path
from ddgs import DDGS

OUTPUT = Path(__file__).parent / 'card_shops_ddg_pass2.csv'
MERGED = Path(__file__).parent / 'card_shops_import.csv'

STATE_CODES = {'AL','AK','AZ','AR','CA','CO','CT','DE','DC','FL','GA','HI','ID','IL','IN','IA',
    'KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ',
    'NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT',
    'VA','WA','WV','WI','WY'}
CA_PROVS = {'AB','BC','MB','NB','NL','NS','NT','NU','ON','PE','QC','SK','YT'}

# Different queries than pass 1 to find new results
QUERIES = [
    'card shop near {city} {state}',
    'baseball card store {city} {state}',
    'hobby card shop {city} {state}',
    'collectibles store {city} {state}',
    'sports memorabilia shop {city} {state}',
    'TCG shop {city} {state}',
]

# All major + mid-size US cities, different emphasis than pass 1
CITIES = [
    # States that need more coverage
    ('Knoxville','TN'), ('Memphis','TN'), ('Nashville','TN'), ('Chattanooga','TN'),
    ('Clarksville','TN'), ('Murfreesboro','TN'), ('Jackson','TN'), ('Johnson City','TN'),
    ('Kingsport','TN'), ('Cookeville','TN'), ('Franklin','TN'), ('Maryville','TN'),
    ('Oak Ridge','TN'), ('Pigeon Forge','TN'), ('Sevierville','TN'), ('Columbia','TN'),
    # NC deeper
    ('Charlotte','NC'), ('Raleigh','NC'), ('Greensboro','NC'), ('Durham','NC'),
    ('Winston-Salem','NC'), ('Fayetteville','NC'), ('Wilmington','NC'), ('Asheville','NC'),
    ('Hickory','NC'), ('Gastonia','NC'), ('Salisbury','NC'), ('Kannapolis','NC'),
    ('New Bern','NC'), ('Greenville','NC'), ('Sanford','NC'), ('Statesville','NC'),
    # Top 100 US metros not heavily covered in pass 1
    ('Birmingham','AL'), ('Huntsville','AL'), ('Mobile','AL'), ('Tuscaloosa','AL'), ('Dothan','AL'),
    ('Anchorage','AK'),
    ('Phoenix','AZ'), ('Tucson','AZ'), ('Mesa','AZ'), ('Scottsdale','AZ'), ('Flagstaff','AZ'),
    ('Little Rock','AR'), ('Fort Smith','AR'), ('Jonesboro','AR'),
    ('Los Angeles','CA'), ('San Francisco','CA'), ('San Diego','CA'), ('Sacramento','CA'),
    ('Fresno','CA'), ('Bakersfield','CA'), ('Riverside','CA'), ('Modesto','CA'), ('Stockton','CA'),
    ('Denver','CO'), ('Colorado Springs','CO'), ('Fort Collins','CO'), ('Pueblo','CO'),
    ('Hartford','CT'), ('New Haven','CT'), ('Stamford','CT'), ('Danbury','CT'), ('Norwalk','CT'),
    ('Wilmington','DE'), ('Dover','DE'),
    ('Miami','FL'), ('Tampa','FL'), ('Orlando','FL'), ('Jacksonville','FL'),
    ('Fort Lauderdale','FL'), ('St Petersburg','FL'), ('Sarasota','FL'), ('Pensacola','FL'),
    ('Tallahassee','FL'), ('Gainesville','FL'), ('Daytona Beach','FL'), ('Naples','FL'),
    ('Atlanta','GA'), ('Savannah','GA'), ('Augusta','GA'), ('Macon','GA'), ('Columbus','GA'),
    ('Honolulu','HI'),
    ('Boise','ID'), ('Idaho Falls','ID'), ('Nampa','ID'),
    ('Chicago','IL'), ('Springfield','IL'), ('Peoria','IL'), ('Rockford','IL'), ('Champaign','IL'),
    ('Indianapolis','IN'), ('Fort Wayne','IN'), ('Evansville','IN'), ('South Bend','IN'),
    ('Des Moines','IA'), ('Cedar Rapids','IA'), ('Davenport','IA'), ('Sioux City','IA'),
    ('Wichita','KS'), ('Overland Park','KS'), ('Topeka','KS'), ('Lawrence','KS'),
    ('Louisville','KY'), ('Lexington','KY'), ('Bowling Green','KY'), ('Owensboro','KY'),
    ('New Orleans','LA'), ('Baton Rouge','LA'), ('Shreveport','LA'), ('Lafayette','LA'),
    ('Portland','ME'), ('Bangor','ME'), ('Lewiston','ME'),
    ('Baltimore','MD'), ('Frederick','MD'), ('Rockville','MD'), ('Annapolis','MD'),
    ('Boston','MA'), ('Worcester','MA'), ('Springfield','MA'), ('Lowell','MA'),
    ('Detroit','MI'), ('Grand Rapids','MI'), ('Ann Arbor','MI'), ('Lansing','MI'), ('Kalamazoo','MI'), ('Flint','MI'),
    ('Minneapolis','MN'), ('St Paul','MN'), ('Rochester','MN'), ('Duluth','MN'), ('Bloomington','MN'),
    ('Jackson','MS'), ('Gulfport','MS'), ('Hattiesburg','MS'), ('Southaven','MS'),
    ('St Louis','MO'), ('Kansas City','MO'), ('Springfield','MO'), ('Columbia','MO'),
    ('Billings','MT'), ('Missoula','MT'), ('Great Falls','MT'), ('Bozeman','MT'),
    ('Omaha','NE'), ('Lincoln','NE'), ('Grand Island','NE'),
    ('Las Vegas','NV'), ('Reno','NV'), ('Henderson','NV'),
    ('Manchester','NH'), ('Concord','NH'), ('Nashua','NH'),
    ('Newark','NJ'), ('Jersey City','NJ'), ('Toms River','NJ'), ('Edison','NJ'), ('Cherry Hill','NJ'),
    ('Albuquerque','NM'), ('Santa Fe','NM'), ('Las Cruces','NM'),
    ('New York City','NY'), ('Buffalo','NY'), ('Rochester','NY'), ('Syracuse','NY'), ('Albany','NY'), ('Yonkers','NY'),
    ('Fargo','ND'), ('Bismarck','ND'), ('Grand Forks','ND'), ('Minot','ND'),
    ('Columbus','OH'), ('Cleveland','OH'), ('Cincinnati','OH'), ('Dayton','OH'), ('Toledo','OH'), ('Akron','OH'), ('Canton','OH'),
    ('Oklahoma City','OK'), ('Tulsa','OK'), ('Norman','OK'), ('Broken Arrow','OK'),
    ('Portland','OR'), ('Eugene','OR'), ('Salem','OR'), ('Bend','OR'), ('Medford','OR'),
    ('Philadelphia','PA'), ('Pittsburgh','PA'), ('Allentown','PA'), ('Erie','PA'), ('Reading','PA'), ('Scranton','PA'),
    ('Providence','RI'), ('Warwick','RI'), ('Cranston','RI'),
    ('Charleston','SC'), ('Columbia','SC'), ('Greenville','SC'), ('Myrtle Beach','SC'), ('Spartanburg','SC'),
    ('Sioux Falls','SD'), ('Rapid City','SD'),
    ('Houston','TX'), ('Dallas','TX'), ('Austin','TX'), ('San Antonio','TX'), ('Fort Worth','TX'),
    ('El Paso','TX'), ('Plano','TX'), ('Lubbock','TX'), ('Corpus Christi','TX'), ('Waco','TX'),
    ('Salt Lake City','UT'), ('Provo','UT'), ('Ogden','UT'), ('St George','UT'),
    ('Burlington','VT'), ('Rutland','VT'),
    ('Virginia Beach','VA'), ('Richmond','VA'), ('Norfolk','VA'), ('Roanoke','VA'), ('Arlington','VA'),
    ('Seattle','WA'), ('Tacoma','WA'), ('Spokane','WA'), ('Vancouver','WA'), ('Bellevue','WA'),
    ('Charleston','WV'), ('Huntington','WV'), ('Morgantown','WV'),
    ('Milwaukee','WI'), ('Madison','WI'), ('Green Bay','WI'), ('Appleton','WI'), ('Kenosha','WI'),
    ('Cheyenne','WY'), ('Casper','WY'), ('Laramie','WY'),
]


def extract_phone(text):
    m = re.search(r'\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}', text)
    return m.group(0) if m else ''

def extract_address(text):
    m = re.search(r'(\d{1,5}\s+[\w\s.]+(?:St|Ave|Rd|Dr|Blvd|Ln|Way|Pike|Pkwy|Hwy|Ct|Cir|Pl|Road|Street|Avenue|Drive|Boulevard|Lane)\b[^,.]*)', text, re.I)
    return m.group(1).strip() if m else ''

def extract_state(text, fallback):
    upper = text.upper()
    for code in STATE_CODES:
        if re.search(r'\b' + code + r'\b', upper):
            return code, 'US'
    for code in CA_PROVS:
        if re.search(r'\b' + code + r'\b', upper):
            return code, 'CA'
    return fallback, 'US'

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
    low = name.lower()
    skip = ['best card shops','top 10','top card','where to buy','guide to','list of',
            'directory','near me','card shops in','stores in','yelp','yellowpages',
            'mapquest','tripadvisor','groupon','facebook','reddit','google maps','foursquare']
    return not any(s in low for s in skip) and 3 <= len(name) <= 80


def main():
    print(f'=== DDG Pass 2 — All 50 States ===')
    total = len(CITIES) * len(QUERIES)
    print(f'Cities: {len(CITIES)}, Queries: {len(QUERIES)}, Total: {total}')

    # Load existing names to skip known shops
    existing_names = set()
    if MERGED.exists():
        for r in csv.DictReader(open(MERGED, encoding='utf-8')):
            existing_names.add(r['name'].lower().strip())
    print(f'Known shops to skip: {len(existing_names)}')

    all_shops = {}
    done = 0
    errors = 0
    ddgs = DDGS()

    for city, state in CITIES:
        for q in QUERIES:
            done += 1
            query = q.format(city=city, state=state)
            print(f'  [{done}/{total}] "{query}"...', end='', flush=True)
            try:
                results = list(ddgs.text(query, max_results=20))
                found = 0
                for r in results:
                    title = r.get('title','')
                    body = r.get('body','')
                    href = r.get('href','')
                    if any(d in href for d in ['yelp.com/search','yellowpages.com/search','google.com/maps','tripadvisor.com']): continue
                    name = title.split(' - ')[0].split(' | ')[0].split(' :: ')[0].strip()
                    name = re.sub(r'\s*\(.*?\)\s*$', '', name).strip()
                    if not is_shop_name(name): continue
                    if name.lower().strip() in existing_names: continue
                    all_text = f'{title} {body}'.lower()
                    if not any(w in all_text for w in ['card','game','comic','pokemon','tcg','mtg','hobby','collectible','sport','trading','memorabilia']): continue
                    phone = extract_phone(body) or extract_phone(title)
                    if not phone: continue
                    address = extract_address(body) or extract_address(title)
                    st, country = extract_state(f'{body} {title}', state)
                    key = f"{name.lower()}|{st}"
                    if key in all_shops: continue
                    all_shops[key] = {
                        'name': name, 'address': address, 'city': city, 'state': st,
                        'country': country, 'zip': '', 'phone': phone, 'lat': '', 'lng': '',
                        'region': '', 'types': '{'+','.join(classify(name))+'}', 'hours': '',
                        'website': href if not any(d in href for d in ['yelp.com','yellowpages','facebook.com/search']) else '',
                        'notes': '', 'google_place_id': '', 'source': 'ddg_pass2', 'verified': 'false', 'active': 'true',
                    }
                    found += 1
                print(f' {len(results)} results, {found} new (total: {len(all_shops)})')
            except Exception as e:
                errors += 1
                print(f' ERROR: {str(e)[:50]}')
                if 'ratelimit' in str(e).lower(): time.sleep(60)
            time.sleep(random.uniform(2.0, 4.0))

    print(f'\nPass 2 total new: {len(all_shops)}')
    rows = list(all_shops.values())
    fieldnames = ['name','address','city','state','country','zip','phone','lat','lng','region','types','hours','website','notes','google_place_id','source','verified','active']
    with open(OUTPUT, 'w', newline='', encoding='utf-8') as f:
        w = csv.DictWriter(f, fieldnames=fieldnames, quoting=csv.QUOTE_ALL)
        w.writeheader()
        for r in sorted(rows, key=lambda x: (x['country'], x['state'], x['city'], x['name'])):
            w.writerow(r)
    print(f'Wrote {len(rows)} to {OUTPUT}')

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
        print(f'Merged: {added} new, {len(existing)} total')

    by_state = {}
    for r in rows:
        k = f"{r['country']}/{r['state']}"
        by_state[k] = by_state.get(k, 0) + 1
    if by_state:
        print('\nNew shops by state:')
        for s in sorted(by_state.keys()):
            print(f'  {s}: {by_state[s]}')

if __name__ == '__main__':
    main()
