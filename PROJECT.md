# GrailISO — Master Project Document
**Version:** 1.3.0
**Last Updated:** March 10, 2026
**Status:** 🟡 Pre-Launch — Active Development

---

## 1. WHAT IS GRAILISO

GrailISO is a card marketplace built around one action: posting an ISO (In Search Of). Collectors post what they want, the platform matches them to sellers — including sellers who don't even know they're selling yet.

The core loop:
1. Buyer posts an ISO for a specific card + parallel
2. Platform broadcasts it to all matching vault holders
3. Seller gets notified, clicks interested, contact is made
4. Both sides transact off-platform (for now)

Every feature is built around one rule: **create FOMO for buyers AND sellers.**

---

## 2. LIVE INFRASTRUCTURE

| Item | Value |
|---|---|
| Site | grailiso.com |
| Host | Netlify |
| Password gate | `grail2026` |
| Repo | github.com/jsmcdonald25-cpu/grailiso-web |
| Database | Supabase (schema built, NOT YET RUN) |
| Auth provider | Supabase Auth |
| Payments | Stripe (Identity + card on file) |

---

## 3. FILE INVENTORY

### Active Files (in repo or built)

| File | Description | Size | Status |
|---|---|---|---|
| `dashboard.html` | Main user dashboard | ~129KB | Built, NOT pushed |
| `card-catalog.html` | Card catalog — 13 sets, 522 cards | 81KB | Built, NOT pushed |
| `auth.html` | 4-step onboarding flow | — | Built |
| `auth-step1-username.html` | Auth Step 1 — username selection | — | Built |
| `isoscan-scoreboard.jsx` | ISO/SCAN leaderboard React component | — | Built |
| `vault-ui-mockup.html` | Vault UI — standalone mockup | — | Built, NOT wired |
| `grailiso-vault-schema.sql` | Supabase vault schema — 7 tables | — | Built, NOT run |
| `supabase-schema.sql` | Supabase auth schema | — | Built, NOT run |
| `PROJECT.md` | This file | — | ✅ Current |

### Not Yet Built
- Notification feed panel (bell icon exists, panel not built)
- FOMO admin dashboard (`/admin/fomo`) — DO NOT BUILD YET
- Match email templates
- Seller contact flow (post-match)
- Stripe checkout integration

---

## 4. ARCHITECTURE

### Auth Flow (4 steps)
1. Email + password
2. Username selection
3. Stripe Identity verification
4. Card on file (payment method)

### Database (Supabase)
Seven tables — schema in `grailiso-vault-schema.sql`:

| Table | Purpose |
|---|---|
| `profiles` | Extends auth.users — holds username, ISO credits |
| `cards` | Master card catalog — mirrors JS CARDS array |
| `vault` | User collections with full provenance metadata |
| `isos` | Active want listings |
| `matches` | ISO × vault cross-reference (auto-populated by triggers) |
| `notifications` | In-app alerts for buyers and sellers |
| `credit_events` | Full credit ledger — every credit in and out |

**Auto-firing triggers:**
- `vault INSERT` → instantly scans all active ISOs for matches
- `iso INSERT` → instantly scans all vault cards for matches
- `auth.users INSERT` → creates profile + logs 5-credit signup bonus

**Row Level Security:** Enabled on all tables.

### Credit Model

| Action | Credits |
|---|---|
| Signup bonus | +5 |
| Upload front scan | +1 |
| Upload front + back | +2 |
| Post an ISO | -1 |
| Respond to a match (seller) | -1 |
| Purchase credits | varies |

---

## 5. CARD CATALOG

**Current state:** 522 cards across 13 sets, 81KB single HTML file.

### Sets in catalog-catalog.html
| # | Set | Year | Sport |
|---|---|---|---|
| 1 | Topps Chrome UEFA Club Competitions | 2025 | Soccer |
| 2 | Topps Finest F1 | 2025 | F1 |
| 3 | Topps Dynasty F1 | 2024 | F1 |
| 4 | Topps Finest MLS | 2024 | Soccer |
| 5 | Topps Chrome Star Wars | 2025 | Star Wars |
| 6 | Topps Chrome SW Galaxy | 2025 | Star Wars |
| 7 | Topps Chrome VeeFriends | 2025 | Entertainment |
| 8 | Topps Chrome Winter Olympics | 2026 | Olympics |
| 9 | Topps Disneyland 70th Anniversary | 2025 | Disney |
| 10 | Topps Chrome McDonald's All-American | 2025 | Basketball |
| 11 | Topps Chrome F1 Sapphire Edition | 2025 | F1 |
| 12 | Topps Chrome Deadpool | 2025 | Marvel |
| 13 | Score Trading Cards | 1988–2024 | Baseball / Football / Hockey |

### Score Discography (Set 13 breakdown)
47 sets, 195 card entries. Covers:
- Score Baseball: 1988–1998
- Score Football: 1989–2024 (Pinnacle era + full Panini revival)
- Score Hockey: 1991–1997
- Key RCs cataloged: Griffey Jr., Barry Sanders, Troy Aikman, Peyton Manning, Randy Moss, Patrick Mahomes, Joe Burrow, Caleb Williams, and more

### Next Priority Sets
1. 2025 Topps Chrome Baseball — flagship, highest ISO demand
2. 2025 Bowman Chrome Baseball — prospect collectors
3. 2025-26 Topps Chrome Basketball
4. 2024 Topps Chrome Football
5. 2025 Topps Chrome UFC

~60+ sets remaining from original PDF checklist list in prior sessions.

### Search Rules (locked)
- Requires BOTH name (2+ chars) AND year to show results
- No autocomplete dropdown — removed
- Clear ✕ button centered vertically in input
- Card ticker at bottom scrolling notable cards

---

## 6. THE VAULT FEATURE

### What it is
A free digital collection manager. Any logged-in user can search the catalog, click a card, and add it to their personal vault. They log:
- Parallel, print run (e.g. 12/50)
- Grade + grading company + cert number
- Where acquired, price paid, date
- Notes
- Front + back card scans

### Why it matters strategically
Most sellers don't know they're sellers until someone waves money in front of them. The vault captures passive supply — people building a collection for fun — and silently runs a match engine against live buyer ISOs. When a match fires, the seller gets a notification they didn't expect: *"Someone wants this card right now."*

### The match engine
- Bidirectional: fires on vault INSERT and on ISO INSERT
- Match score: 100 = exact parallel match, 80 = parallel differs
- Seller sees: buyer username, max price, notes, card details
- Seller responds "I'm Interested" → 1 credit deducted → buyer notified
- Seller can also mark "Not Selling" or ignore

### FOMO hook
"3 people are looking for cards in your collection right now" — shown on vault dashboard even before they click in. Drives return visits.

---

## 7. DESIGN SYSTEM

**Never change these.**

| Token | Value | Usage |
|---|---|---|
| Background | `#0D1F33` | All pages — permanent |
| Blue | `#00AAFF` | ISO = brand blue, links, CTAs |
| Cyan | `#00FFFF` | Laser hover accent |
| White | `#FFFFFF` | GRAIL wordmark |
| Gold | `#FFB800` | Credits, RC badges, warnings |
| Green | `#00E887` | Matches, confirmed, success |
| Red | `#FF3B5C` | Urgent, relic badges, alerts |
| Purple | `#9B59B6` | Soccer sport color |
| Text | `#E8F4FD` | Primary body text |
| Text2 | `#8BA7C7` | Secondary / meta text |

**Fonts:**
- Headlines: `Bebas Neue` — all caps, letter-spacing 2–4px
- UI / Body: `Barlow Condensed` — weights 400, 600, 700

**Hover effect (cards):** Conic-gradient spinning laser border, blue `#00AAFF` → cyan `#00FFFF`. Card lifts `translateY(-4px)`.

---

## 8. FOMO ENGINE RULES

1. **Real data only** — no fake timers, no fabricated urgency
2. **Every signal grounded in actual activity**
3. Buyers: cards are slipping, ISOs are filling, window is closing
4. Sellers: buyers are waiting right now — every hour is money left on the table
5. Vault angle: "X people are looking for cards in your collection"
6. Admin FOMO dashboard planned at `/admin/fomo` — **DO NOT BUILD YET**

---

## 9. DOMAIN PORTFOLIO

| Domain | Status | Priority |
|---|---|---|
| grailiso.com | ✅ OWNED — LIVE | — |
| isodefender.com | 🔲 To purchase | High |
| isobiometrics.com | 🔲 To purchase | Medium |
| grail-iso.com | 🔲 To purchase | Medium |
| isograde.com | 🔲 To purchase (replaces isograding.com — taken) | High |
| grailvault.com | 🔲 To purchase (replaces isovault.com — taken) | High |
| isocollect.com | 🔲 Backup for grailvault.com | Low |

**Buy on:** Namecheap (~$10–14/year per .com)

---

## 10. LEGAL & BUSINESS

| Item | Status |
|---|---|
| GrailISO LLC | Formed |
| Tennessee Foreign LLC registration | ⚠️ REQUIRED — do this week |
| UPS Store mailbox | ⚠️ Not opened — bring 2 IDs, register under GrailISO LLC |
| Attorney consult | ⚠️ Pending — trademark + money transmitter + ID verification policy |
| Trademark filing | Not started |
| Money transmitter license research | Not started |

---

## 11. EMAIL INFRASTRUCTURE

**Platform:** Google Workspace (not yet set up)

**Addresses to create:**
- hello@grailiso.com
- support@grailiso.com
- verify@grailiso.com
- noreply@grailiso.com
- sellers@grailiso.com
- media@grailiso.com

**DNS records needed:** SPF + DMARC (not yet configured)

---

## 12. IMMEDIATE DO NOW — RANKED

| Priority | Task | Blocks |
|---|---|---|
| 🔴 1 | Run `supabase-schema.sql` in Supabase SQL Editor | All user signups |
| 🔴 2 | Run `grailiso-vault-schema.sql` in Supabase SQL Editor | Vault feature |
| 🔴 3 | Tennessee Foreign LLC registration | Legal compliance |
| 🟠 4 | Push `dashboard.html` + `card-catalog.html` to GitHub | Site going stale |
| 🟠 5 | Purchase domains: isograde.com, grailvault.com, isodefender.com | Brand protection |
| 🟠 6 | UPS Store mailbox | Business address |
| 🟡 7 | Attorney consult | Trademark + compliance |
| 🟡 8 | Google Workspace + email addresses | Communications |
| 🟡 9 | SPF + DMARC DNS records | Email deliverability |

---

## 13. NEXT BUILD OPTIONS

### A — Wire Vault into dashboard.html
Vault mockup is standalone. Integrate as a tab in dashboard. Swap Card Library panel's hardcoded CARDS array for live catalog data at the same time.

### B — Wire Vault to Supabase
Schema is written. Connect the UI:
- Add card → `INSERT INTO vault`
- Trigger fires → match row created → notification queued
- Bell icon shows unread count

### C — Add More Card Sets
Next batch (highest demand first):
- 2025 Topps Chrome Baseball
- 2025 Bowman Chrome Baseball
- 2025-26 Topps Chrome Basketball
- 2024 Topps Chrome Football
- 2025 Topps Chrome UFC

### D — Match Notification UI
Build the full notification feed panel and match email template. Bell icon in vault-ui-mockup.html is placeholder — needs real panel.

### E — GitHub Push
```bash
git add .
git commit -m "v1.3.0 — Score sets, vault UI, vault schema, catalog fixes"
git push
```

---

*GrailISO — Built for the collector who knows exactly what they want.*
*PROJECT.md v1.3.0 — March 10, 2026*
