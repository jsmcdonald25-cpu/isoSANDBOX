#!/usr/bin/env python3
"""DDG scraper — Canada cities."""
import csv, re, time, random
from pathlib import Path
from ddgs import DDGS

OUTPUT = Path(__file__).parent / 'card_shops_ddg_canada.csv'
MERGED = Path(__file__).parent / 'card_shops_import.csv'

CA_PROVS = {'AB','BC','MB','NB','NL','NS','NT','NU','ON','PE','QC','SK','YT'}
STATE_CODES = {'AL','AK','AZ','AR','CA','CO','CT','DE','DC','FL','GA','HI','ID','IL','IN','IA',
    'KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ',
    'NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT',
    'VA','WA','WV','WI','WY'}

CITIES = [
    ('Toronto','ON'), ('Ottawa','ON'), ('Mississauga','ON'), ('Hamilton','ON'),
    ('London','ON'), ('Kitchener','ON'), ('Windsor','ON'), ('Brampton','ON'),
    ('Markham','ON'), ('Vaughan','ON'), ('Richmond Hill','ON'), ('Burlington','ON'),
    ('Oshawa','ON'), ('Barrie','ON'), ('Kingston','ON'), ('Thunder Bay','ON'),
    ('Sudbury','ON'), ('Guelph','ON'), ('Cambridge','ON'), ('St Catharines','ON'),
    ('Montreal','QC'), ('Quebec City','QC'), ('Laval','QC'), ('Gatineau','QC'),
    ('Longueuil','QC'), ('Sherbrooke','QC'), ('Trois-Rivieres','QC'),
    ('Vancouver','BC'), ('Victoria','BC'), ('Surrey','BC'), ('Burnaby','BC'),
    ('Richmond','BC'), ('Kelowna','BC'), ('Nanaimo','BC'), ('Kamloops','BC'),
    ('Calgary','AB'), ('Edmonton','AB'), ('Red Deer','AB'), ('Lethbridge','AB'),
    ('Winnipeg','MB'), ('Brandon','MB'),
    ('Regina','SK'), ('Saskatoon','SK'),
    ('Halifax','NS'), ('Dartmouth','NS'), ('Sydney','NS'),
    ('Fredericton','NB'), ('Moncton','NB'), ('Saint John','NB'),
    ('St Johns','NL'),
    ('Charlottetown','PE'),
]

QUERIES = [
    'sports card shop in {city} {state} Canada',
    'trading card store {city} {state} Canada',
    'pokemon card shop {city} {state} Canada',
    'local game store {city} {state} Canada',
    'comic book store {city} {state} Canada',
]


def extract_phone(text):
    m = re.search(r'\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}', text)
    return m.group(0) if m else ''

def extract_address(text):
    m = re.search(r'(\d{1,5}\s+[\w\s.]+(?:St|Ave|Rd|Dr|Blvd|Ln|Way|Pike|Pkwy|Hwy|Ct|Cir|Pl|Road|Street|Avenue|Drive|Boulevard|Lane)\b[^,.]*)', text, re.I)
    return m.group(1).strip() if m else ''

def extract_state(text, fallback):
    upper = text.upper()
    for code in CA_PROVS:
        if re.search(r'\b' + code + r'\b', upper):
            return code, 'CA'
    for code in STATE_CODES:
        if re.search(r'\b' + code + r'\b', upper):
            return code, 'US'
    return fallback, 'CA'

def classify(name):
    types = []
    n = name.lower()
    if any(w in n for w in ['sport','baseball','football','basketball','hockey']): types.append('Sports')
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
    print(f'=== DDG Canada City Scraper ===')
    total = len(CITIES) * len(QUERIES)
    print(f'Cities: {len(CITIES)}, Queries: {len(QUERIES)}, Total: {total}')

    all_shops = {}
    done = 0
    errors = 0
    ddgs = DDGS()

    for city, prov in CITIES:
        for q in QUERIES:
            done += 1
            query = q.format(city=city, state=prov)
            print(f'  [{done}/{total}] "{query}"...', end='', flush=True)
            try:
                results = list(ddgs.text(query, max_results=20))
                found = 0
                for r in results:
                    title = r.get('title','')
                    body = r.get('body','')
                    href = r.get('href','')
                    if any(d in href for d in ['yelp.com/search','yellowpages.com/search','google.com/maps','tripadvisor.com']):
                        continue
                    name = title.split(' - ')[0].split(' | ')[0].split(' :: ')[0].strip()
                    name = re.sub(r'\s*\(.*?\)\s*$', '', name).strip()
                    if not is_shop_name(name): continue
                    all_text = f'{title} {body}'.lower()
                    if not any(w in all_text for w in ['card','game','comic','pokemon','tcg','mtg','hobby','collectible','sport','trading']): continue
                    phone = extract_phone(body) or extract_phone(title)
                    if not phone: continue
                    address = extract_address(body) or extract_address(title)
                    st, country = extract_state(f'{body} {title}', prov)
                    key = f"{name.lower()}|{st}"
                    if key in all_shops: continue
                    all_shops[key] = {
                        'name': name, 'address': address, 'city': city, 'state': st,
                        'country': country, 'zip': '', 'phone': phone, 'lat': '', 'lng': '',
                        'region': '', 'types': '{'+','.join(classify(name))+'}', 'hours': '',
                        'website': href if not any(d in href for d in ['yelp.com','yellowpages','facebook.com/search']) else '',
                        'notes': '', 'google_place_id': '', 'source': 'ddg_canada', 'verified': 'false', 'active': 'true',
                    }
                    found += 1
                print(f' {len(results)} results, {found} new (total: {len(all_shops)})')
            except Exception as e:
                errors += 1
                print(f' ERROR: {str(e)[:50]}')
                if 'ratelimit' in str(e).lower(): time.sleep(60)
            time.sleep(random.uniform(2.0, 4.0))

    print(f'\nCanada total: {len(all_shops)}')
    rows = list(all_shops.values())
    fieldnames = ['name','address','city','state','country','zip','phone','lat','lng','region','types','hours','website','notes','google_place_id','source','verified','active']
    with open(OUTPUT, 'w', newline='', encoding='utf-8') as f:
        w = csv.DictWriter(f, fieldnames=fieldnames, quoting=csv.QUOTE_ALL)
        w.writeheader()
        for r in sorted(rows, key=lambda x: (x['state'], x['city'], x['name'])):
            w.writerow(r)
    print(f'Wrote {len(rows)} to {OUTPUT}')

    if MERGED.exists():
        existing = list(csv.DictReader(open(MERGED, encoding='utf-8')))
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
        print(f'Merged: {added} new, {len(existing)} total')

if __name__ == '__main__':
    main()
