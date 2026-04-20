"""
Reddit scam-pattern scraper for GrailISO admin research.

NO-AUTH version — uses Reddit's public .json endpoints, no app registration needed.
Rate-limited (gentler than PRAW); fine for personal daily cadence across 6 subs.

Rules (hard):
  - Never store Reddit usernames (author field ignored entirely).
  - Aggressively strip u/foo, /u/foo, @foo, emails, seller/buyer X handles.
  - Only store posts/comments matching scam-keyword filter.

Usage:
  pip install -r requirements.txt
  export SUPABASE_URL="https://jyfaegmnzkarlcximxjo.supabase.co"
  export SUPABASE_SERVICE_ROLE_KEY="..."
  python scrape_reddit_patterns.py [--limit 100] [--dry-run]
"""
from __future__ import annotations
import argparse
import os
import re
import sys
import time
from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from typing import Iterable

import requests


SUBREDDITS = [
    "baseballcards",
    "tradingcards",
    "baseballcardsbst",
    "sportcardsforsale",
    "sportscards",
    "sportscardtracker",
]

KEYWORDS = [
    "scam", "scammer", "scammed", "scamming",
    "fraud", "fraudulent", "defraud",
    "fake", "faked", "counterfeit", "reprint",
    "avoid", "beware", "warning", "caution",
    "ripoff", "rip off", "ripped off", "ripping off",
    "dispute", "chargeback", "charge back",
    "shill", "shilled", "shilling",
    "reseal", "resealed", "resealing",
    "trimmed", "trimming", "altered", "tampered",
    "ghost", "ghosted", "ghosting",
    "didn't ship", "never shipped", "didn't send", "never sent",
    "stole", "stolen",
    "switched", "bait and switch", "bait-and-switch",
    "bootleg", "custom", "homemade",
    "no refund", "refuses to refund",
    "bad buyer", "bad seller",
    "psa altered", "bgs altered",
]

USER_PATTERNS = [
    re.compile(r"\b/?u/[A-Za-z0-9_\-]{3,}", re.IGNORECASE),
    re.compile(r"@[A-Za-z0-9_\-]{3,}"),
]
HANDLE_CONTEXT = re.compile(
    r"\b(seller|buyer|user|member|account|username|handle|ebay id|ebay user)\s+(?:is\s+|named\s+|called\s+)?([A-Za-z0-9_\-]{4,})",
    re.IGNORECASE,
)
EMAIL_PATTERN = re.compile(r"[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}")

USER_AGENT = "grailiso-research/0.1 (personal research script)"
BASE = "https://www.reddit.com"


def strip_usernames(text: str | None) -> str:
    if not text:
        return ""
    out = text
    for pat in USER_PATTERNS:
        out = pat.sub("[user]", out)
    out = EMAIL_PATTERN.sub("[user]", out)
    out = HANDLE_CONTEXT.sub(lambda m: f"{m.group(1)} [user]", out)
    return out.strip()


def keyword_matches(text: str) -> list[str]:
    if not text:
        return []
    lower = text.lower()
    return sorted({kw for kw in KEYWORDS if kw in lower})


@dataclass
class Pattern:
    subreddit: str
    post_id: str
    post_type: str
    title: str | None
    content: str
    permalink: str
    matched_keywords: list[str]
    score: int
    num_comments: int
    created_utc: str


def fetch_json(url: str, params: dict | None = None, retries: int = 3) -> dict | None:
    headers = {"User-Agent": USER_AGENT}
    for attempt in range(retries):
        try:
            r = requests.get(url, headers=headers, params=params, timeout=20)
            if r.status_code == 429:
                wait = 10 * (attempt + 1)
                print(f"[rate-limit] 429, sleeping {wait}s...", file=sys.stderr)
                time.sleep(wait)
                continue
            if r.status_code >= 400:
                print(f"[warn] {url} → {r.status_code}", file=sys.stderr)
                return None
            return r.json()
        except requests.RequestException as e:
            print(f"[warn] {url} → {e}", file=sys.stderr)
            time.sleep(3 * (attempt + 1))
    return None


def iter_submissions(sub: str, limit: int) -> Iterable[Pattern]:
    url = f"{BASE}/r/{sub}/new.json"
    data = fetch_json(url, params={"limit": min(limit, 100)})
    if not data:
        return
    for child in data.get("data", {}).get("children", []):
        s = child.get("data", {})
        title = s.get("title", "") or ""
        body  = s.get("selftext", "") or ""
        combined = f"{title}\n{body}"
        kws = keyword_matches(combined)
        if not kws:
            continue
        permalink = s.get("permalink", "")
        yield Pattern(
            subreddit=sub,
            post_id=f"t3_{s.get('id','')}",
            post_type="submission",
            title=strip_usernames(title),
            content=strip_usernames(body) or strip_usernames(title),
            permalink=f"{BASE}{permalink}" if permalink else "",
            matched_keywords=kws,
            score=int(s.get("score") or 0),
            num_comments=int(s.get("num_comments") or 0),
            created_utc=datetime.fromtimestamp(int(s.get("created_utc") or 0), tz=timezone.utc).isoformat(),
        )


def iter_comments(sub: str, limit: int) -> Iterable[Pattern]:
    url = f"{BASE}/r/{sub}/comments.json"
    data = fetch_json(url, params={"limit": min(limit, 100)})
    if not data:
        return
    for child in data.get("data", {}).get("children", []):
        c = child.get("data", {})
        body = c.get("body", "") or ""
        kws = keyword_matches(body)
        if not kws:
            continue
        permalink = c.get("permalink", "")
        yield Pattern(
            subreddit=sub,
            post_id=f"t1_{c.get('id','')}",
            post_type="comment",
            title=None,
            content=strip_usernames(body),
            permalink=f"{BASE}{permalink}" if permalink else "",
            matched_keywords=kws,
            score=int(c.get("score") or 0),
            num_comments=0,
            created_utc=datetime.fromtimestamp(int(c.get("created_utc") or 0), tz=timezone.utc).isoformat(),
        )


def supabase_upsert(rows: list[Pattern], dry_run: bool = False) -> None:
    if dry_run or not rows:
        return
    url = os.environ["SUPABASE_URL"].rstrip("/")
    key = os.environ["SUPABASE_SERVICE_ROLE_KEY"]
    endpoint = f"{url}/rest/v1/reddit_patterns"
    headers = {
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
        "Prefer": "resolution=ignore-duplicates,return=minimal",
    }
    payload = [asdict(r) for r in rows]
    CHUNK = 200
    for i in range(0, len(payload), CHUNK):
        r = requests.post(endpoint, headers=headers, json=payload[i:i+CHUNK], timeout=30)
        if r.status_code >= 300:
            print(f"[error] supabase upsert {r.status_code}: {r.text[:200]}", file=sys.stderr)
            return
    print(f"[ok] upserted {len(rows)} patterns")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--limit", type=int, default=100,
                    help="posts/comments per sub per pass (max 100 via JSON endpoint)")
    ap.add_argument("--dry-run", action="store_true",
                    help="print results, do not write to Supabase")
    ap.add_argument("--submissions-only", action="store_true")
    ap.add_argument("--comments-only", action="store_true")
    ap.add_argument("--pause", type=float, default=3.0,
                    help="seconds between subs (default 3 — keep it gentle)")
    args = ap.parse_args()

    if not args.dry_run:
        for key in ("SUPABASE_URL", "SUPABASE_SERVICE_ROLE_KEY"):
            if not os.environ.get(key):
                print(f"[error] missing env var: {key}", file=sys.stderr)
                return 1

    all_rows: list[Pattern] = []
    for sub in SUBREDDITS:
        print(f"[scan] r/{sub}")
        try:
            if not args.comments_only:
                for p in iter_submissions(sub, args.limit):
                    all_rows.append(p)
                time.sleep(args.pause)
            if not args.submissions_only:
                for p in iter_comments(sub, args.limit):
                    all_rows.append(p)
        except Exception as e:
            print(f"[warn] r/{sub} failed: {e}", file=sys.stderr)
        time.sleep(args.pause)

    print(f"[total] {len(all_rows)} matched patterns across {len(SUBREDDITS)} subs")

    if args.dry_run:
        for r in all_rows[:10]:
            print(f"  [{r.subreddit}] {r.post_type} kws={r.matched_keywords} :: {(r.title or r.content)[:100]}")
        print("[dry-run] no write to Supabase")
        return 0

    supabase_upsert(all_rows)
    return 0


if __name__ == "__main__":
    sys.exit(main())
