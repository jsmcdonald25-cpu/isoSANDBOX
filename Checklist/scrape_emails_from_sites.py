#!/usr/bin/env python3
"""
Visit each shop's website and scrape email addresses from the page.
Updates card_shops_import.csv with found emails in the notes field.
"""
import csv, re, asyncio, time
from pathlib import Path
from playwright.async_api import async_playwright

MERGED = Path(__file__).parent / 'card_shops_import.csv'

def extract_emails(text):
    """Find all email addresses in text, filter out junk."""
    emails = re.findall(r'[\w.+-]+@[\w-]+\.[\w.-]+', text)
    skip = ['example.com','sentry.io','wixpress','sentry-next','cloudflare',
            'webpack','localhost','placeholder','test.com','email.com',
            'yoursite','domain.com','yourdomain','changeme','schema.org',
            'w3.org','wix.com','squarespace.com','shopify.com','godaddy.com']
    clean = []
    for e in emails:
        e = e.lower().strip().rstrip('.')
        if len(e) > 50: continue
        if any(s in e for s in skip): continue
        if e.endswith('.png') or e.endswith('.jpg') or e.endswith('.svg'): continue
        if e not in clean:
            clean.append(e)
    return clean


async def main():
    print('=== Email Scraper — Visiting Shop Websites ===')

    rows = []
    with open(MERGED, encoding='utf-8') as f:
        rows = list(csv.DictReader(f))

    # Find shops with websites but no email (skips already-enriched ones for resume)
    targets = []
    for i, r in enumerate(rows):
        website = r.get('website','').strip()
        notes = r.get('notes','')
        if website and 'email:' not in notes:
            targets.append(i)
    # Count already done
    already_have = sum(1 for r in rows if 'email:' in r.get('notes',''))
    print(f'Already have email: {already_have}')

    print(f'Total shops: {len(rows)}')
    print(f'Have website, need email: {len(targets)}')
    print()

    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context(
            user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/125.0.0.0 Safari/537.36',
            java_script_enabled=True
        )

        found = 0
        errors = 0
        total = len(targets)

        for count, idx in enumerate(targets, 1):
            r = rows[idx]
            url = r['website'].strip()
            if not url.startswith('http'):
                url = 'https://' + url

            safe_name = r["name"][:40].encode('ascii','replace').decode()
            safe_url = url[:50].encode('ascii','replace').decode()
            print(f'  [{count}/{total}] {safe_name} -> {safe_url}...', end='', flush=True)

            try:
                page = await context.new_page()
                await page.goto(url, timeout=15000, wait_until='domcontentloaded')
                await page.wait_for_timeout(2000)

                # Get all text content
                content = await page.content()
                body_text = await page.inner_text('body')

                # Also check for mailto: links
                mailto_links = await page.query_selector_all('a[href^="mailto:"]')
                mailto_emails = []
                for link in mailto_links:
                    href = await link.get_attribute('href')
                    if href:
                        email = href.replace('mailto:','').split('?')[0].strip().lower()
                        if email and '@' in email:
                            mailto_emails.append(email)

                # Extract from page text + HTML
                all_emails = extract_emails(content + ' ' + body_text)

                # Prioritize mailto: links, then page content
                final_emails = list(dict.fromkeys(mailto_emails + all_emails))[:3]  # max 3

                if final_emails:
                    existing_notes = rows[idx].get('notes','').strip()
                    email_str = 'email: ' + ', '.join(final_emails)
                    if existing_notes:
                        rows[idx]['notes'] = existing_notes + ' | ' + email_str
                    else:
                        rows[idx]['notes'] = email_str
                    found += 1
                    print(f' {", ".join(final_emails).encode("ascii","replace").decode()}')
                else:
                    # Try contact/about page
                    contact_found = False
                    for path in ['/contact', '/about', '/contact-us', '/about-us']:
                        try:
                            contact_url = url.rstrip('/') + path
                            await page.goto(contact_url, timeout=10000, wait_until='domcontentloaded')
                            await page.wait_for_timeout(1500)
                            contact_content = await page.content()
                            contact_text = await page.inner_text('body')
                            contact_emails = extract_emails(contact_content + ' ' + contact_text)

                            mailto2 = await page.query_selector_all('a[href^="mailto:"]')
                            for link in mailto2:
                                href = await link.get_attribute('href')
                                if href:
                                    em = href.replace('mailto:','').split('?')[0].strip().lower()
                                    if em and '@' in em and em not in contact_emails:
                                        contact_emails.insert(0, em)

                            if contact_emails:
                                final = list(dict.fromkeys(contact_emails))[:3]
                                existing_notes = rows[idx].get('notes','').strip()
                                email_str = 'email: ' + ', '.join(final)
                                rows[idx]['notes'] = (existing_notes + ' | ' + email_str).strip(' | ')
                                found += 1
                                print(f' {", ".join(final)} (from {path})')
                                contact_found = True
                                break
                        except Exception:
                            pass

                    if not contact_found:
                        print(f' -')

                await page.close()

            except Exception as e:
                errors += 1
                err = str(e)[:40]
                print(f' ERR: {err}')
                try:
                    await page.close()
                except Exception:
                    pass

            # Brief delay between requests
            await asyncio.sleep(0.5)

            # Save progress every 100 shops
            if count % 100 == 0:
                fieldnames = ['name','address','city','state','country','zip','phone',
                    'lat','lng','region','types','hours','website','notes',
                    'google_place_id','source','verified','active']
                with open(MERGED, 'w', newline='', encoding='utf-8') as f:
                    w = csv.DictWriter(f, fieldnames=fieldnames, quoting=csv.QUOTE_ALL, extrasaction='ignore')
                    w.writeheader()
                    for r2 in sorted(rows, key=lambda x: (x.get('country',''), x.get('state',''), x.get('name',''))):
                        w.writerow(r2)
                print(f'  [Saved progress: {found} emails found so far]')

        await browser.close()

    print(f'\nEmail scraping complete:')
    print(f'  Emails found: {found}')
    print(f'  Errors: {errors}')
    print(f'  Total visited: {total}')

    # Final save
    fieldnames = ['name','address','city','state','country','zip','phone',
        'lat','lng','region','types','hours','website','notes',
        'google_place_id','source','verified','active']
    with open(MERGED, 'w', newline='', encoding='utf-8') as f:
        w = csv.DictWriter(f, fieldnames=fieldnames, quoting=csv.QUOTE_ALL, extrasaction='ignore')
        w.writeheader()
        for r in sorted(rows, key=lambda x: (x.get('country',''), x.get('state',''), x.get('name',''))):
            w.writerow(r)

    has_email = sum(1 for r in rows if 'email:' in r.get('notes',''))
    print(f'\nFinal: {len(rows)} shops, {has_email} with email')
    print(f'Updated {MERGED}')


if __name__ == '__main__':
    asyncio.run(main())
