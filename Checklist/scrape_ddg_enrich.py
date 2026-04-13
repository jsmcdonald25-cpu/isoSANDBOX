#!/usr/bin/env python3
"""DDG enrichment pass — searches each shop by name to fill in website and email."""
import csv, re, time, random
from pathlib import Path
from ddgs import DDGS

MERGED = Path(__file__).parent / 'card_shops_import.csv'

def extract_email(text):
    m = re.search(r'[\w.+-]+@[\w-]+\.[\w.-]+', text)
    if m:
        email = m.group(0).lower()
        # Skip fake/generic emails
        if any(d in email for d in ['example.com','sentry.io','wixpress','sentry-next']):
            return ''
        return email
    return ''

def extract_website(text, href=''):
    # Try to find a real business website (not yelp/facebook/yellowpages)
    skip_domains = ['yelp.com','yellowpages.com','facebook.com','google.com','mapquest.com',
                    'tripadvisor.com','bbb.org','foursquare.com','groupon.com','reddit.com',
                    'wikipedia.org','twitter.com','instagram.com','tiktok.com','youtube.com',
                    'linkedin.com','pinterest.com','apple.com','amazon.com']

    # Check href first
    if href and not any(d in href.lower() for d in skip_domains):
        return href

    # Look for URLs in text
    urls = re.findall(r'https?://[\w.-]+(?:/[\w./-]*)?', text)
    for u in urls:
        if not any(d in u.lower() for d in skip_domains):
            return u

    # Look for www. URLs
    www = re.findall(r'www\.[\w.-]+\.[\w]+', text)
    for w in www:
        if not any(d in w.lower() for d in skip_domains):
            return 'https://' + w

    return ''


def main():
    print('=== DDG Enrichment Pass — Websites & Emails ===')

    rows = []
    with open(MERGED, encoding='utf-8') as f:
        rows = list(csv.DictReader(f))

    print(f'Total shops: {len(rows)}')

    # Find shops missing website
    need_website = [i for i, r in enumerate(rows) if not r.get('website','').strip()]
    need_any = [i for i, r in enumerate(rows) if not r.get('website','').strip()]

    print(f'Missing website: {len(need_website)}')
    print(f'Shops to enrich: {len(need_any)}')
    print()

    ddgs = DDGS()
    enriched_web = 0
    enriched_email = 0
    errors = 0
    total = len(need_any)

    for count, idx in enumerate(need_any, 1):
        r = rows[idx]
        name = r['name'].strip()
        city = r.get('city','').strip()
        state = r.get('state','').strip()

        query = f'{name} {city} {state}'
        print(f'  [{count}/{total}] "{query}"...', end='', flush=True)

        try:
            results = list(ddgs.text(query, max_results=5))
            website = ''
            email = ''

            for res in results:
                title = res.get('title','')
                body = res.get('body','')
                href = res.get('href','')

                if not website:
                    website = extract_website(body, href)
                if not email:
                    email = extract_email(body) or extract_email(title)

                if website and email:
                    break

            if website and not rows[idx].get('website','').strip():
                rows[idx]['website'] = website
                enriched_web += 1

            # Store email in notes field if found
            if email:
                existing_notes = rows[idx].get('notes','').strip()
                if email not in existing_notes:
                    rows[idx]['notes'] = (existing_notes + ' | email: ' + email).strip(' | ')
                    enriched_email += 1

            status = ''
            if website: status += 'W'
            if email: status += 'E'
            print(f' {status or "-"}')

        except Exception as e:
            errors += 1
            print(f' ERROR: {str(e)[:40]}')
            if 'ratelimit' in str(e).lower():
                print('    Rate limited, waiting 60s...')
                time.sleep(60)

        time.sleep(random.uniform(1.5, 3.0))

    print(f'\nEnrichment complete:')
    print(f'  Websites found: {enriched_web}')
    print(f'  Emails found: {enriched_email}')
    print(f'  Errors: {errors}')

    # Write back
    fieldnames = ['name','address','city','state','country','zip','phone',
        'lat','lng','region','types','hours','website','notes',
        'google_place_id','source','verified','active']

    with open(MERGED, 'w', newline='', encoding='utf-8') as f:
        w = csv.DictWriter(f, fieldnames=fieldnames, quoting=csv.QUOTE_ALL, extrasaction='ignore')
        w.writeheader()
        for r in sorted(rows, key=lambda x: (x.get('country',''), x.get('state',''), x.get('name',''))):
            w.writerow(r)

    print(f'Updated {MERGED.name}')

    # Final stats
    has_web = sum(1 for r in rows if r.get('website','').strip())
    has_email = sum(1 for r in rows if 'email:' in r.get('notes',''))
    print(f'\nFinal: {len(rows)} shops, {has_web} with website, {has_email} with email')


if __name__ == '__main__':
    main()
