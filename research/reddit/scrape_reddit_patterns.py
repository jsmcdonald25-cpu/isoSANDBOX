"""
Reddit scam-pattern scraper for GrailISO admin research.

Purpose: build a pattern library of scam techniques, red flags, and bad-actor
behaviors from card-community subreddits. Trains admin AI to recognize
techniques on-platform. Does NOT build a name/blacklist database.

Rules (hard):
  - Never store Reddit usernames (author field ignored entirely).
  - Aggressively strip u/foo, /u/foo, @foo from title + body text.
  - Strip eBay-handle patterns from body text before storage.
  - Only store posts/comments matching scam-keyword filter.

Usage:
  Set env vars:
    REDDIT_CLIENT_ID
    REDDIT_CLIENT_SECRET
    REDDIT_USER_AGENT   (e.g. "grailiso-research-bot/0.1 by u/yourhandle")
    SUPABASE_URL        (e.g. https://jyfaegmnzkarlcximxjo.supabase.co)
    SUPABASE_SERVICE_ROLE_KEY   (server-side key, needed to bypass RLS for insert)

  Install:
    pip install -r requirements.txt

  Run:
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

import praw   # type: ignore
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
    # scam vocabulary
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

# Match u/foo, /u/foo, @foo — conservative on word chars
USER_PATTERNS = [
    re.compile(r"\b/?u/[A-Za-z0-9_\-]{3,}", re.IGNORECASE),
    re.compile(r"@[A-Za-z0-9_\-]{3,}"),
]

# "seller X", "buyer X", "user X" — strip the handle after
HANDLE_CONTEXT = re.compile(
    r"\b(seller|buyer|user|member|account|username|handle|ebay id|ebay user)\s+(?:is\s+|named\s+|called\s+)?([A-Za-z0-9_\-]{4,})",
    re.IGNORECASE,
)

# Email-like (just in case)
EMAIL_PATTERN = re.compile(r"[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}")


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
    post_type: str  # 'submission' | 'comment'
    title: str | None
    content: str
    permalink: str
    matched_keywords: list[str]
    score: int
    num_comments: int
    created_utc: str  # iso8601


def iter_submissions(reddit: praw.Reddit, sub: str, limit: int) -> Iterable[Pattern]:
    sr = reddit.subreddit(sub)
    for s in sr.new(limit=limit):
        body = s.selftext or ""
        combined = f"{s.title}\n{body}"
        kws = keyword_matches(combined)
        if not kws:
            continue
        yield Pattern(
            subreddit=sub,
            post_id=f"t3_{s.id}",
            post_type="submission",
            title=strip_usernames(s.title),
            content=strip_usernames(body) or strip_usernames(s.title),
            permalink=f"https://www.reddit.com{s.permalink}",
            matched_keywords=kws,
            score=int(s.score or 0),
            num_comments=int(s.num_comments or 0),
            created_utc=datetime.fromtimestamp(s.created_utc, tz=timezone.utc).isoformat(),
        )


def iter_comments(reddit: praw.Reddit, sub: str, limit: int) -> Iterable[Pattern]:
    sr = reddit.subreddit(sub)
    for c in sr.comments(limit=limit):
        body = c.body or ""
        kws = keyword_matches(body)
        if not kws:
            continue
        yield Pattern(
            subreddit=sub,
            post_id=f"t1_{c.id}",
            post_type="comment",
            title=None,
            content=strip_usernames(body),
            permalink=f"https://www.reddit.com{c.permalink}",
            matched_keywords=kws,
            score=int(c.score or 0),
            num_comments=0,
            created_utc=datetime.fromtimestamp(c.created_utc, tz=timezone.utc).isoformat(),
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
    # Supabase has a 1 MB body limit — chunk at 200 rows
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
                    help="posts/comments per sub per pass (default 100)")
    ap.add_argument("--dry-run", action="store_true",
                    help="print results, do not write to Supabase")
    ap.add_argument("--submissions-only", action="store_true")
    ap.add_argument("--comments-only", action="store_true")
    args = ap.parse_args()

    for key in ("REDDIT_CLIENT_ID", "REDDIT_CLIENT_SECRET", "REDDIT_USER_AGENT"):
        if not os.environ.get(key):
            print(f"[error] missing env var: {key}", file=sys.stderr)
            return 1
    if not args.dry_run:
        for key in ("SUPABASE_URL", "SUPABASE_SERVICE_ROLE_KEY"):
            if not os.environ.get(key):
                print(f"[error] missing env var: {key}", file=sys.stderr)
                return 1

    reddit = praw.Reddit(
        client_id=os.environ["REDDIT_CLIENT_ID"],
        client_secret=os.environ["REDDIT_CLIENT_SECRET"],
        user_agent=os.environ["REDDIT_USER_AGENT"],
    )
    reddit.read_only = True

    all_rows: list[Pattern] = []
    for sub in SUBREDDITS:
        print(f"[scan] r/{sub}")
        try:
            if not args.comments_only:
                for p in iter_submissions(reddit, sub, args.limit):
                    all_rows.append(p)
            if not args.submissions_only:
                for p in iter_comments(reddit, sub, args.limit):
                    all_rows.append(p)
        except Exception as e:
            print(f"[warn] r/{sub} failed: {e}", file=sys.stderr)
        time.sleep(1)  # gentle pacing

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
