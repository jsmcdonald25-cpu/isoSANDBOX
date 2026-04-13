#!/usr/bin/env python3
"""
Master runner — waits for pass 1 to finish, then runs:
  1. Canada cities
  2. Pass 2 (all 50 states, different queries)
  3. Enrichment (websites + emails)
  4. Final report
"""
import subprocess, sys, csv
from pathlib import Path

MERGED = Path(__file__).parent / 'card_shops_import.csv'
PY = sys.executable

def count():
    rows = list(csv.DictReader(open(MERGED, encoding='utf-8')))
    total = len(rows)
    has_phone = sum(1 for r in rows if r.get('phone','').strip())
    has_web = sum(1 for r in rows if r.get('website','').strip())
    has_email = sum(1 for r in rows if 'email:' in r.get('notes',''))
    tn = sum(1 for r in rows if r.get('state')=='TN')
    nc = sum(1 for r in rows if r.get('state')=='NC')
    return total, has_phone, has_web, has_email, tn, nc

def run(script, label):
    print(f'\n{"="*60}')
    print(f'  {label}')
    print(f'{"="*60}\n')
    result = subprocess.run([PY, '-u', str(Path(__file__).parent / script)], cwd=str(Path(__file__).parent.parent))
    t, p, w, e, tn, nc = count()
    print(f'\n  >> After {label}: {t} total shops, TN={tn}, NC={nc}, phones={p}, websites={w}, emails={e}')
    return result.returncode

print('='*60)
print('  CARD SHOP SCRAPER — FULL RUN')
print('='*60)

t, p, w, e, tn, nc = count()
print(f'\nStarting point: {t} shops, TN={tn}, NC={nc}')

# Step 1: Canada
run('scrape_ddg_canada.py', 'STEP 1: Canada Cities')

# Step 2: Pass 2 — all 50 states different queries
run('scrape_ddg_pass2.py', 'STEP 2: All 50 States (Pass 2)')

# Step 3: Enrichment — websites + emails
run('scrape_ddg_enrich.py', 'STEP 3: Enrich Websites & Emails')

# Final report
print('\n' + '='*60)
print('  FINAL REPORT')
print('='*60)

rows = list(csv.DictReader(open(MERGED, encoding='utf-8')))
total = len(rows)
has_phone = sum(1 for r in rows if r.get('phone','').strip())
has_web = sum(1 for r in rows if r.get('website','').strip())
has_email = sum(1 for r in rows if 'email:' in r.get('notes',''))

by_state = {}
for r in rows:
    k = f"{r.get('country','US')}/{r.get('state','??')}"
    by_state[k] = by_state.get(k, 0) + 1

print(f'\n  Total shops: {total}')
print(f'  With phone: {has_phone}')
print(f'  With website: {has_web}')
print(f'  With email: {has_email}')
print(f'\n  By state/province:')
for s in sorted(by_state.keys()):
    print(f'    {s}: {by_state[s]}')

print(f'\n  File: {MERGED}')
print(f'\n  Next: DELETE FROM card_shops; then import the CSV via Supabase Table Editor.')
print('='*60)
