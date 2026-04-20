# Reddit scam-pattern scraper

Admin-only research tool. Pulls scam/fraud patterns from card subreddits to
train AI recognition of on-platform scam behavior.

**Rules (enforced in code):**
- Never stores Reddit usernames.
- Strips `u/foo`, `/u/foo`, `@foo`, emails, and `seller X` / `buyer X` handles
  from title + body text before writing to Supabase.
- Only stores posts/comments matching the scam-keyword filter.

## Setup

1. Register a Reddit "script" app at https://www.reddit.com/prefs/apps →
   note the `client_id` (under the app name) and `secret`.
2. Install deps: `pip install -r requirements.txt`
3. Run the SQL in `Checklist/reddit_patterns_schema.sql` once in Supabase.
4. Set env vars (bash example):

   ```bash
   export REDDIT_CLIENT_ID=...
   export REDDIT_CLIENT_SECRET=...
   export REDDIT_USER_AGENT="grailiso-research/0.1 by u/yourhandle"
   export SUPABASE_URL="https://jyfaegmnzkarlcximxjo.supabase.co"
   export SUPABASE_SERVICE_ROLE_KEY=...   # admin-side key, bypasses RLS
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

## Scheduling

Run on a daily cadence — don't hammer the Reddit API. 100 QPM limit for
authenticated scripts; one pass across 6 subs is ~12 requests. Use GitHub
Actions cron (see `.github/workflows/` for the ISOsnipe pattern).

## Viewing results

Admin dashboard → **Reddit Patterns** panel. Table shows sub, content preview,
matched keywords, and a permalink to the original Reddit thread. Mark patterns
as useful or dismiss.
