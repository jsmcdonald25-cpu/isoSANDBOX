# Reddit scam-pattern scraper (no-auth)

Admin-only research tool. Pulls scam/fraud patterns from card subreddits to
train AI recognition of on-platform scam behavior.

Uses Reddit's public `.json` endpoints — no app registration, no client_id,
no client_secret. Gentle pacing to avoid rate-limits.

**Rules (enforced in code):**
- Never stores Reddit usernames.
- Strips `u/foo`, `/u/foo`, `@foo`, emails, and `seller X` / `buyer X` handles
  from title + body text before writing to Supabase.
- Only stores posts/comments matching the scam-keyword filter.

## Setup

1. Run `Checklist/reddit_patterns_schema.sql` in Supabase (creates the table).
2. Install deps: `pip install -r requirements.txt`
3. Set two env vars (bash):

   ```bash
   export SUPABASE_URL="https://jyfaegmnzkarlcximxjo.supabase.co"
   export SUPABASE_SERVICE_ROLE_KEY="..."   # Project Settings → API → service_role
   ```

## Usage

```bash
# Dry run (no Supabase write, prints first 10 matches)
python scrape_reddit_patterns.py --limit 50 --dry-run

# Live run — writes to Supabase
python scrape_reddit_patterns.py --limit 100

# Submissions or comments only
python scrape_reddit_patterns.py --submissions-only
python scrape_reddit_patterns.py --comments-only
```

## Rate limits

Reddit throttles anonymous `.json` requests aggressively. If you see `[rate-limit] 429`
in stderr, the script will back off automatically. For daily use, one run a day with
`--pause 5` is safe. Don't loop it.

## Viewing results

Admin dashboard → **Reddit Patterns** panel. Table shows sub, content preview,
matched keywords, and a permalink to the original Reddit thread. Mark patterns
as useful or dismiss.
