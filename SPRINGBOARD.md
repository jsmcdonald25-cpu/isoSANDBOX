# GrailISO — Session Springboard
**[SYS] GrailISO_v1.4.0 :: BUILD 20260311 :: STABLE**
_End of session — March 11, 2026_

---

## PASTE THIS INTO A NEW CLAUDE SESSION TO RESUME INSTANTLY

---

## CRITICAL SESSION RULE
When token count approaches 190,000 — STOP immediately. Generate updated SPRINGBOARD.md and PROJECT.md. Tell Scott to open a new thread. This is non-negotiable. Never skip this.

---

## WHERE WE LEFT OFF

isoSANDBOX is set up and files are pushed to GitHub. Next immediate step is connecting Netlify to the isoSANDBOX repo, pointing isosandbox.com DNS, and then wiring Supabase so auth and vault actually work.

### Completed this session:
1. ✅ card-catalog.html v1.2.1 — Score sets, ticker, ghost logo, JS bug fixed
2. ✅ vault-ui-mockup.html — full collection manager UI with match engine
3. ✅ grailiso-vault-schema.sql — 7 tables, 2 triggers, RLS
4. ✅ isoSANDBOX repo created — github.com/jsmcdonald25-cpu/isoSANDBOX
5. ✅ isosandbox-setup-guide.md — full Netlify + DNS walkthrough
6. ✅ netlify.toml — routing, redirects, security headers, cache rules
7. ✅ index.html — root redirect to dashboard
8. ✅ .gitignore — blocks node_modules, .env, .DS_Store
9. ✅ All files pushed to isoSANDBOX repo
10. ✅ SPRINGBOARD + PROJECT.md updated to v1.4.0

---

## isoSANDBOX STATUS

| Item | Status |
|---|---|
| GitHub repo | ✅ github.com/jsmcdonald25-cpu/isoSANDBOX |
| Netlify site | ⚠️ Not yet connected |
| isosandbox.com DNS | ⚠️ Not yet pointed at Netlify |
| Supabase sandbox project | ⚠️ Not yet created |
| Schema run on sandbox DB | ⚠️ Not yet run |
| Supabase keys wired into files | ⚠️ Not yet done |

### What works on sandbox right now:
- Card catalog (hardcoded JS, no DB needed)
- Vault UI mockup (static demo data)
- All visual/design elements
- Routing via netlify.toml

### What is broken until Supabase is wired:
- Login / auth flow
- Dynamic data fetching
- Vault backend features

---

## FILES IN isoSANDBOX REPO

| File | Description |
|---|---|
| `index.html` | Root redirect → dashboard.html |
| `netlify.toml` | Routing, redirects, headers, cache |
| `.gitignore` | Blocks node_modules, .env, OS junk |
| `dashboard.html` | Main user dashboard ~129KB |
| `card-catalog.html` | Card catalog — 522 cards, 13 sets |
| `auth.html` | 4-step onboarding |
| `card-viewer.html` | Card viewer — NEVER MODIFY |
| `vault-ui-mockup.html` | Vault UI — standalone mockup |
| `grailiso-vault-schema.sql` | Supabase schema — 7 tables + triggers |
| `package.json` | Stripe dependency — node_modules NOT committed |
| `dilmar.html` | Dev joke page — remove before production |

---

## NEXT SESSION — DO IN ORDER

### Step 1 — Connect Netlify to isoSANDBOX
1. app.netlify.com → Add new site → Import from GitHub
2. Select `jsmcdonald25-cpu/isoSANDBOX`
3. Branch: `main` | Build command: blank | Publish dir: `/`
4. Deploy

### Step 2 — Point isosandbox.com at Netlify
In Namecheap DNS for isosandbox.com:
- A record: `@` → `75.2.60.5`
- CNAME: `www` → `apex-loadbalancer.netlify.com`
Then in Netlify → Domain management → Add isosandbox.com → Enable HTTPS

### Step 3 — Create Supabase sandbox project
1. supabase.com → New project → name: `grailiso-sandbox`
2. SQL Editor → run `supabase-schema.sql`
3. SQL Editor → run `grailiso-vault-schema.sql`
4. Copy Project URL + anon key

### Step 4 — Wire Supabase keys into sandbox files
- Netlify sandbox site → Environment variables → add SUPABASE_URL + SUPABASE_ANON_KEY
- Hardcode sandbox keys directly into HTML files for now (no build step yet)

### Step 5 — Wire card catalog to Supabase (big job — next major build)
- Build CSV of all 522 cards for bulk import into `cards` table
- Rewrite card-catalog.html to fetch from Supabase instead of hardcoded JS

---

## THE VAULT FEATURE — LOCKED

Free digital collection manager. Users add cards → passive ISO match engine fires → sellers notified when buyers want their cards.

**Credit model:**
- Signup: +5 | Upload front+back scans: +2 | Post ISO: -1 | Respond to match: -1

**Two auto-firing Supabase triggers:**
- vault INSERT → scans all active ISOs for matches
- iso INSERT → scans all vault cards for matches

---

## DOMAIN STATUS

| Domain | Status |
|---|---|
| grailiso.com | ✅ OWNED — LIVE |
| isosandbox.com | ✅ OWNED — not yet on Netlify |
| isograde.com | 🔲 Purchase (replaces isograding.com — taken) |
| grailvault.com | 🔲 Purchase (replaces isovault.com — taken) |
| isodefender.com | 🔲 Purchase |
| isobiometrics.com | 🔲 Purchase |
| grail-iso.com | 🔲 Purchase |

---

## KEY ARCHITECTURE

| Item | Value |
|---|---|
| Production site | grailiso.com (Netlify) |
| Sandbox site | isosandbox.com (Netlify — not yet live) |
| Production repo | github.com/jsmcdonald25-cpu/grailiso-web |
| Sandbox repo | github.com/jsmcdonald25-cpu/isoSANDBOX |
| Both DBs | Supabase — schemas built, NEITHER YET RUN |
| Password gate | `grail2026` |

---

## DESIGN SYSTEM (permanent — never change)

- Background: `#0D1F33` — PERMANENT
- GRAIL = `#FFFFFF` | ISO = `#00AAFF`
- Green `#00E887` = matches | Gold `#FFB800` = credits | Red `#FF3B5C` = urgent
- Fonts: Bebas Neue (headlines) / Barlow Condensed (UI)
- `card-viewer.html` — NEVER MODIFIED
- FOMO Engine = real data only, no fake timers
- FOMO admin dashboard `/admin/fomo` — DO NOT BUILD YET

---

## LEGAL

| Item | Status |
|---|---|
| GrailISO LLC | ✅ Formed (Delaware) |
| Tennessee Foreign LLC | ⚠️ REQUIRED — do this week |
| UPS Store mailbox | ⚠️ Not opened |
| Attorney consult | ⚠️ Pending |

---

*Upload this file at the start of the next session to resume with full context.*
*SPRINGBOARD v1.4.0 — March 11, 2026*
