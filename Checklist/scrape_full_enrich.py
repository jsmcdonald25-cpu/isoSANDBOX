#!/usr/bin/env python3
"""
Full enrichment scraper — visits each shop's website and extracts:
- Email addresses
- Facebook URL
- Instagram URL
- eBay store URL
- TCGplayer store URL

Skips breakers (WhatNot, break-focused shops).
Saves progress every 50 shops. Resumes from where it left off.
"""
import csv, re, asyncio, sys, os
from pathlib import Path
from playwright.async_api import async_playwright

# Force UTF-8 output
sys.stdout.reconfigure(encoding='utf-8', errors='replace')

MERGED = Path(__file__).parent / 'card_shops_import.csv'

BREAKER_KEYWORDS = ['whatnot','breaker','break room','case break','box break',
                     'rip room','live break','group break']

def is_breaker(name, website):
    """Check if this is a breaker, not a real shop."""
    text = (name + ' ' + website).lower()
    return any(kw in text for kw in BREAKER_KEYWORDS)

def extract_emails(text):
    emails = re.findall(r'[\w.+-]+@[\w-]+\.[\w.-]+', text)
    skip = ['example.com','sentry.io','wixpress','sentry-next','cloudflare',
            'webpack','localhost','placeholder','test.com','email.com',
            'yoursite','domain.com','yourdomain','changeme','schema.org',
            'w3.org','wix.com','squarespace.com','shopify.com','godaddy.com',
            'googleapis.com','gstatic.com','jquery','bootstrap','fontawesome']
    clean = []
    for e in emails:
        e = e.lower().strip().rstrip('.')
        if len(e) > 60: continue
        if any(s in e for s in skip): continue
        if e.endswith(('.png','.jpg','.svg','.css','.js','.gif','.webp')): continue
        if e.count('@') != 1: continue
        if e not in clean:
            clean.append(e)
    return clean[:3]

def extract_social(html, body_text):
    """Extract social media and marketplace links from page content."""
    all_text = html + ' ' + body_text
    result = {'facebook':'', 'instagram':'', 'ebay':'', 'tcgplayer':''}

    # Facebook
    fb = re.findall(r'https?://(?:www\.)?facebook\.com/[A-Za-z0-9._%-]+/?', all_text)
    for url in fb:
        if '/search' not in url and '/sharer' not in url and '/share' not in url and '/dialog' not in url:
            result['facebook'] = url.rstrip('/')
            break

    # Instagram
    ig = re.findall(r'https?://(?:www\.)?instagram\.com/[A-Za-z0-9._]+/?', all_text)
    for url in ig:
        if '/p/' not in url and '/explore' not in url:
            result['instagram'] = url.rstrip('/')
            break

    # eBay store
    eb = re.findall(r'https?://(?:www\.)?ebay\.com/(?:str|sch|usr)/[A-Za-z0-9._%-]+/?', all_text)
    if eb:
        result['ebay'] = eb[0].rstrip('/')

    # TCGplayer
    tcg = re.findall(r'https?://(?:www\.)?tcgplayer\.com/(?:search/seller|shop)/[A-Za-z0-9._%-]+/?', all_text)
    if tcg:
        result['tcgplayer'] = tcg[0].rstrip('/')
    if not result['tcgplayer']:
        tcg2 = re.findall(r'https?://[A-Za-z0-9._%-]+\.tcgplayerpro\.com/?', all_text)
        if tcg2:
            result['tcgplayer'] = tcg2[0].rstrip('/')

    return result

def save_csv(rows):
    fieldnames = ['name','address','city','state','country','zip','phone',
        'lat','lng','region','types','hours','website','notes',
        'google_place_id','source','verified','active']
    with open(MERGED, 'w', newline='', encoding='utf-8') as f:
        w = csv.DictWriter(f, fieldnames=fieldnames, quoting=csv.QUOTE_ALL, extrasaction='ignore')
        w.writeheader()
        for r in sorted(rows, key=lambda x: (x.get('country',''), x.get('state',''), x.get('name',''))):
            w.writerow(r)


async def main():
    print('=== Full Enrichment Scraper ===')
    print('Extracting: emails, Facebook, Instagram, eBay, TCGplayer')
    print()

    rows = []
    with open(MERGED, encoding='utf-8') as f:
        rows = list(csv.DictReader(f))

    # Find shops that need enrichment (have website, not yet fully enriched)
    # We mark enriched shops by adding 'enriched:yes' to notes
    targets = []
    for i, r in enumerate(rows):
        website = r.get('website','').strip()
        notes = r.get('notes','')
        if website and 'enriched:yes' not in notes:
            if not is_breaker(r.get('name',''), website):
                targets.append(i)

    already = sum(1 for r in rows if 'enriched:yes' in r.get('notes',''))
    print(f'Total shops: {len(rows)}')
    print(f'Already enriched: {already}')
    print(f'To process: {len(targets)}')
    print()

    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context(
            user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/125.0.0.0 Safari/537.36',
            java_script_enabled=True
        )

        found_emails = 0
        found_fb = 0
        found_ig = 0
        found_ebay = 0
        found_tcg = 0
        errors = 0
        total = len(targets)

        for count, idx in enumerate(targets, 1):
            r = rows[idx]
            url = r['website'].strip()
            if not url.startswith('http'):
                url = 'https://' + url

            safe_name = r['name'][:35].encode('ascii','replace').decode()
            print(f'  [{count}/{total}] {safe_name}...', end='', flush=True)

            emails_found = []
            social = {'facebook':'','instagram':'','ebay':'','tcgplayer':''}
            pages_to_check = [url]

            try:
                page = await context.new_page()

                for page_url in pages_to_check:
                    try:
                        await page.goto(page_url, timeout=8000, wait_until='domcontentloaded')
                        await page.wait_for_timeout(1000)

                        html = await page.content()
                        try:
                            body_text = await page.inner_text('body')
                        except Exception:
                            body_text = ''

                        # Extract emails
                        if not emails_found:
                            # Check mailto: links first
                            mailto_links = await page.query_selector_all('a[href^="mailto:"]')
                            for link in mailto_links:
                                try:
                                    href = await link.get_attribute('href')
                                    if href:
                                        em = href.replace('mailto:','').split('?')[0].strip().lower()
                                        if em and '@' in em and em not in emails_found:
                                            emails_found.append(em)
                                except Exception:
                                    pass
                            if not emails_found:
                                emails_found = extract_emails(html + ' ' + body_text)

                        # Extract social links
                        page_social = extract_social(html, body_text)
                        for k in social:
                            if not social[k] and page_social[k]:
                                social[k] = page_social[k]

                        # If we're on the main page and missing stuff, try contact page
                        if page_url == url and (not emails_found or not social['facebook']):
                            for contact_path in ['/contact', '/contact-us', '/about', '/about-us']:
                                try:
                                    contact_url = url.rstrip('/') + contact_path
                                    await page.goto(contact_url, timeout=6000, wait_until='domcontentloaded')
                                    await page.wait_for_timeout(1000)
                                    c_html = await page.content()
                                    try:
                                        c_body = await page.inner_text('body')
                                    except Exception:
                                        c_body = ''

                                    if not emails_found:
                                        c_mailto = await page.query_selector_all('a[href^="mailto:"]')
                                        for link in c_mailto:
                                            try:
                                                href = await link.get_attribute('href')
                                                if href:
                                                    em = href.replace('mailto:','').split('?')[0].strip().lower()
                                                    if em and '@' in em and em not in emails_found:
                                                        emails_found.append(em)
                                            except Exception:
                                                pass
                                        if not emails_found:
                                            emails_found = extract_emails(c_html + ' ' + c_body)

                                    c_social = extract_social(c_html, c_body)
                                    for k in social:
                                        if not social[k] and c_social[k]:
                                            social[k] = c_social[k]

                                    if emails_found:
                                        break
                                except Exception:
                                    pass

                    except Exception:
                        pass

                await page.close()

            except Exception as e:
                errors += 1
                try:
                    await page.close()
                except Exception:
                    pass

            # Update the row
            notes_parts = []
            existing_notes = r.get('notes','').strip()
            # Preserve existing notes but remove old email/social entries
            for part in existing_notes.split(' | '):
                part = part.strip()
                if part and not part.startswith('email:') and not part.startswith('facebook:') and not part.startswith('instagram:') and not part.startswith('ebay:') and not part.startswith('tcgplayer:') and part != 'enriched:yes':
                    notes_parts.append(part)

            if emails_found:
                notes_parts.append('email: ' + ', '.join(emails_found[:3]))
                found_emails += 1
            if social['facebook']:
                notes_parts.append('facebook: ' + social['facebook'])
                found_fb += 1
            if social['instagram']:
                notes_parts.append('instagram: ' + social['instagram'])
                found_ig += 1
            if social['ebay']:
                notes_parts.append('ebay: ' + social['ebay'])
                found_ebay += 1
            if social['tcgplayer']:
                notes_parts.append('tcgplayer: ' + social['tcgplayer'])
                found_tcg += 1

            notes_parts.append('enriched:yes')
            rows[idx]['notes'] = ' | '.join(notes_parts)

            # Status output
            tags = []
            if emails_found: tags.append('E')
            if social['facebook']: tags.append('FB')
            if social['instagram']: tags.append('IG')
            if social['ebay']: tags.append('eB')
            if social['tcgplayer']: tags.append('TCG')
            print(f' {",".join(tags) if tags else "-"}')

            await asyncio.sleep(0.3)

            # Save progress every 50
            if count % 50 == 0:
                save_csv(rows)
                print(f'  [SAVED] emails:{found_emails} fb:{found_fb} ig:{found_ig} ebay:{found_ebay} tcg:{found_tcg}')

        await browser.close()

    # Final save
    save_csv(rows)

    print(f'\n{"="*50}')
    print(f'ENRICHMENT COMPLETE')
    print(f'{"="*50}')
    print(f'  Shops processed: {total}')
    print(f'  Emails found: {found_emails}')
    print(f'  Facebook pages: {found_fb}')
    print(f'  Instagram profiles: {found_ig}')
    print(f'  eBay stores: {found_ebay}')
    print(f'  TCGplayer stores: {found_tcg}')
    print(f'  Errors: {errors}')
    print(f'\n  Total shops: {len(rows)}')
    total_email = sum(1 for r in rows if 'email:' in r.get('notes',''))
    total_fb = sum(1 for r in rows if 'facebook:' in r.get('notes',''))
    total_ig = sum(1 for r in rows if 'instagram:' in r.get('notes',''))
    print(f'  With email: {total_email}')
    print(f'  With Facebook: {total_fb}')
    print(f'  With Instagram: {total_ig}')
    print(f'\n  File: {MERGED}')


if __name__ == '__main__':
    asyncio.run(main())
