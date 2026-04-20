"""
fraud_scraper.py — defensive research tool for GrailISO v2

Scrapes public web pages describing card/TCG/Pokemon fraud techniques so we can
build countermeasures into grail2. Runs DuckDuckGo HTML search for each query in
queries.txt, fetches each result, extracts readable text, and writes:

  results/YYYY-MM-DD_HHMM/raw.jsonl      — one JSON record per page
  results/YYYY-MM-DD_HHMM/report.md      — human-readable summary

Usage:
  python fraud_scraper.py                      # run all queries
  python fraud_scraper.py --max-results 5      # top N per query (default 8)
  python fraud_scraper.py --queries foo.txt    # custom query file
  python fraud_scraper.py --delay 2.5          # politeness delay seconds

No API keys. No auth. Public pages only.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import time
from dataclasses import asdict, dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Iterable
from urllib.parse import parse_qs, unquote, urlparse

import requests
from bs4 import BeautifulSoup

ROOT = Path(__file__).parent
RESULTS_DIR = ROOT / "results"
DEFAULT_QUERIES = ROOT / "queries.txt"

DDG_HTML = "https://html.duckduckgo.com/html/"
UA = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
    "AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/120.0 Safari/537.36"
)
HEADERS = {"User-Agent": UA, "Accept-Language": "en-US,en;q=0.9"}

# Skip domains that rarely yield useful technique detail or block scraping.
SKIP_DOMAINS = {
    "pinterest.com", "youtube.com", "facebook.com", "instagram.com",
    "tiktok.com", "twitter.com", "x.com",
}

# Keywords that indicate the page actually discusses fraud technique (signal filter).
# Split into categories so the report can tell detection content apart from
# offensive-angle / method content.
METHOD_WORDS = [
    # physical alteration
    "trim", "trimmed", "trimming", "recolor", "recolored", "bleach", "bleached",
    "acetone", "soak", "soaking", "press", "pressed", "iron", "ironed",
    "heat gun", "steam", "steamed", "sharpie", "marker", "razor", "guillotine",
    "sand", "polish", "magic eraser", "clean", "cleaned", "whiten", "whitening",
    "doctor", "doctored", "doctoring",
    # reproduction
    "inkjet", "photolithography", "print", "printed", "printer", "scanner",
    "reprint", "reprinted", "forgery", "forged", "replica", "knockoff",
    # packaging / grading
    "reseal", "resealed", "resealing", "reholder", "reholdered", "crack out",
    "crack and resubmit", "regrade", "tamper", "tampered",
    # scam mechanics
    "shill", "chargeback", "return scam", "empty box", "swap", "switched",
    "fake tracking",
]
DETECTION_WORDS = [
    "how to spot", "how to tell", "detect", "detection", "authenticate",
    "authenticity", "spot a fake", "identify fake", "verify",
]
GENERIC_WORDS = ["fake", "counterfeit", "altered", "scam", "fraud"]

TECHNIQUE_SIGNALS = METHOD_WORDS + DETECTION_WORDS + GENERIC_WORDS


@dataclass
class PageResult:
    query: str
    url: str
    title: str
    snippet: str
    status: int
    content: str = ""
    signals_hit: list[str] = field(default_factory=list)
    method_hits: list[str] = field(default_factory=list)
    detection_hits: list[str] = field(default_factory=list)
    generic_hits: list[str] = field(default_factory=list)
    error: str = ""


def load_queries(path: Path) -> list[str]:
    lines = path.read_text(encoding="utf-8").splitlines()
    return [q.strip() for q in lines if q.strip() and not q.strip().startswith("#")]


def ddg_search(query: str, max_results: int, session: requests.Session) -> list[dict]:
    """DuckDuckGo HTML search. Returns list of {title, url, snippet}."""
    resp = session.post(DDG_HTML, data={"q": query}, headers=HEADERS, timeout=20)
    resp.raise_for_status()
    soup = BeautifulSoup(resp.text, "html.parser")
    out: list[dict] = []
    for result in soup.select("div.result"):
        a = result.select_one("a.result__a")
        snippet_el = result.select_one("a.result__snippet") or result.select_one(".result__snippet")
        if not a:
            continue
        raw_href = a.get("href", "")
        url = _unwrap_ddg(raw_href)
        if not url:
            continue
        host = urlparse(url).netloc.lower().lstrip("www.")
        if any(host.endswith(bad) for bad in SKIP_DOMAINS):
            continue
        out.append({
            "title": a.get_text(" ", strip=True),
            "url": url,
            "snippet": snippet_el.get_text(" ", strip=True) if snippet_el else "",
        })
        if len(out) >= max_results:
            break
    return out


def _unwrap_ddg(href: str) -> str:
    """DDG wraps URLs as /l/?uddg=<encoded>. Unwrap to the real URL."""
    if href.startswith("//"):
        href = "https:" + href
    parsed = urlparse(href)
    if parsed.path.endswith("/l/") or "uddg" in parsed.query:
        qs = parse_qs(parsed.query)
        if "uddg" in qs:
            return unquote(qs["uddg"][0])
    if href.startswith("http"):
        return href
    return ""


def fetch_page(url: str, session: requests.Session) -> tuple[int, str, str]:
    """Returns (status_code, title, main_text)."""
    resp = session.get(url, headers=HEADERS, timeout=25, allow_redirects=True)
    status = resp.status_code
    if status >= 400:
        return status, "", ""
    ctype = resp.headers.get("Content-Type", "")
    if "html" not in ctype.lower():
        return status, "", ""
    soup = BeautifulSoup(resp.text, "html.parser")
    for tag in soup(["script", "style", "nav", "footer", "header", "aside", "form", "noscript"]):
        tag.decompose()
    title = (soup.title.get_text(strip=True) if soup.title else "")
    # Pick whichever of article/main/body yields the most text — some sites use
    # stub <article> tags that hold no actual content.
    candidates = [c for c in (soup.find("article"), soup.find("main"), soup.body) if c]
    if not candidates:
        candidates = [soup]
    best = max(candidates, key=lambda c: len(c.get_text(" ", strip=True)))
    text = best.get_text("\n", strip=True)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return status, title, text[:20000]


def score_signals(text: str) -> dict[str, list[str]]:
    lower = text.lower()
    method = [s for s in METHOD_WORDS if s in lower]
    detection = [s for s in DETECTION_WORDS if s in lower]
    generic = [s for s in GENERIC_WORDS if s in lower]
    return {
        "method": method,
        "detection": detection,
        "generic": generic,
        "all": method + detection + generic,
    }


def run(queries: list[str], max_results: int, delay: float) -> Path:
    stamp = datetime.now().strftime("%Y-%m-%d_%H%M")
    out_dir = RESULTS_DIR / stamp
    out_dir.mkdir(parents=True, exist_ok=True)
    raw_path = out_dir / "raw.jsonl"
    report_path = out_dir / "report.md"

    session = requests.Session()
    all_results: list[PageResult] = []

    with raw_path.open("w", encoding="utf-8") as raw_f:
        for qi, query in enumerate(queries, 1):
            print(f"[{qi}/{len(queries)}] {query}")
            try:
                hits = ddg_search(query, max_results, session)
            except Exception as e:
                print(f"  search failed: {e}")
                time.sleep(delay)
                continue

            for h in hits:
                print(f"  -> {h['url'][:90]}")
                res = PageResult(query=query, url=h["url"], title=h["title"], snippet=h["snippet"], status=0)
                try:
                    status, title, text = fetch_page(h["url"], session)
                    res.status = status
                    if title:
                        res.title = title
                    res.content = text
                    scores = score_signals(text)
                    res.method_hits = scores["method"]
                    res.detection_hits = scores["detection"]
                    res.generic_hits = scores["generic"]
                    res.signals_hit = scores["all"]
                except Exception as e:
                    res.error = str(e)[:300]
                raw_f.write(json.dumps(asdict(res), ensure_ascii=False) + "\n")
                raw_f.flush()
                all_results.append(res)
                time.sleep(delay)

    write_report(report_path, all_results)
    print(f"\nDone. {len(all_results)} pages fetched.")
    print(f"  raw:    {raw_path}")
    print(f"  report: {report_path}")
    return out_dir


def write_report(path: Path, results: list[PageResult]) -> None:
    # Primary ranking: method hits (offensive-angle content) desc.
    # Secondary: total signals. Ties broken by query and url.
    by_method = sorted(
        results,
        key=lambda r: (-len(r.method_hits), -len(r.signals_hit), r.query, r.url),
    )
    by_query: dict[str, list[PageResult]] = {}
    for r in by_method:
        by_query.setdefault(r.query, []).append(r)

    lines: list[str] = []
    lines.append(f"# Card fraud research report")
    lines.append(f"Generated: {datetime.now().isoformat(timespec='seconds')}")
    lines.append(f"Pages: {len(results)}  |  Queries: {len(by_query)}")
    lines.append("")
    lines.append("## TOP METHOD PAGES (offensive-angle content — how it's done)")
    lines.append("Ranked by count of method/technique keywords (trim, reseal, press, inkjet, etc.).")
    lines.append("")
    shown = 0
    for r in by_method:
        if not r.method_hits:
            break
        lines.append(f"- **[M:{len(r.method_hits)} D:{len(r.detection_hits)}]** [{r.title or r.url}]({r.url})")
        lines.append(f"  - query: `{r.query}`")
        lines.append(f"  - method: {', '.join(r.method_hits)}")
        if r.detection_hits:
            lines.append(f"  - detection: {', '.join(r.detection_hits)}")
        if r.snippet:
            lines.append(f"  - snippet: {r.snippet[:240]}")
        shown += 1
        if shown >= 30:
            break
    if shown == 0:
        lines.append("_(no method-angle pages found — try rerunning or broaden queries)_")
    lines.append("")
    lines.append("## All results by query")
    lines.append("Badge format: [M=method-hits D=detection-hits G=generic-hits]")
    for q, items in by_query.items():
        lines.append(f"\n### {q}")
        for r in items:
            badge = f"[M:{len(r.method_hits)} D:{len(r.detection_hits)} G:{len(r.generic_hits)}]"
            lines.append(f"- {badge} [{r.title or r.url}]({r.url}) — status {r.status}")
            if r.method_hits:
                lines.append(f"  method: {', '.join(r.method_hits)}")
            if r.error:
                lines.append(f"  error: {r.error}")
    path.write_text("\n".join(lines), encoding="utf-8")


def parse_args(argv: list[str]) -> argparse.Namespace:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--queries", type=Path, default=DEFAULT_QUERIES)
    p.add_argument("--max-results", type=int, default=8)
    p.add_argument("--delay", type=float, default=2.0, help="Seconds between requests")
    return p.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    if not args.queries.exists():
        print(f"Query file not found: {args.queries}", file=sys.stderr)
        return 1
    queries = load_queries(args.queries)
    if not queries:
        print("No queries to run.", file=sys.stderr)
        return 1
    run(queries, args.max_results, args.delay)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
