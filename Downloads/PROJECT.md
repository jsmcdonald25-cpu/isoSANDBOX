# GrailISO — Master Project Document
**Version:** 1.6.0
**Last Updated:** March 12, 2026
**Status:** 🟡 Pre-Launch — Active Development

---

## CATCHPHRASE
**Stop Searching. Start Demanding. Find Your Grail.**

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
| Sandbox site | isosandbox.com (Netlify — LIVE) |
| Sandbox repo | github.com/jsmcdonald25-cpu/isoSANDBOX |
| Production site | grailiso.com (Netlify — LIVE) |
| Production repo | github.com/jsmcdonald25-cpu/grailiso-web |
| Sandbox Supabase URL | https://jyfaegmnzkarlcximxjo.supabase.co |
| Sandbox anon key | sb_publishable_-JI4Y3ImXzqRVkwx1yIL1g_rVJVx5bn |
| Stripe publishable key | pk_test_51T8cf1PfZc4go68Jp0FKkZS3SOG9h14p4m7CeUKRN7eoD6Cq3yMKXZS3SOG9h14... |
| Password gate | grail2026 |
| Auth provider | Supabase Auth |
| Payments | Stripe (Identity + card on file) |

---

## 3. SANDBOX FILE INVENTORY

| File | Description | Status |
|---|---|---|
| `index.html` | Root redirect → dashboard.html | ✅ Live |
| `auth.html` | 5-step onboarding — sandbox keys active | ✅ Fixed this session |
| `dashboard.html` | Main user dashboard | ✅ Fixed this session |
| `card-catalog.html` | 522 cards, 13 sets | ✅ Live |
| `card-viewer.html` | Card viewer — NEVER MODIFY | ✅ Live |
| `vault-ui-mockup.html` | Vault UI mockup | ✅ Static demo |
| `grailiso-vault-schema.sql` | Schema — 8 tables | ✅ Deployed to sandbox |
| `netlify.toml` | Routing, redirects, headers | ✅ Live |
| `netlify/functions/` | 4 serverless functions | ✅ Deployed, not tested |
| `PROJECT.md` | This file | ✅ Current |
| `SPRINGBOARD.md` | Session resume file | ✅ Current |

---

## 4. FIXES COMPLETED THIS SESSION (March 12, 2026)

| Fix | Detail |
|---|---|
| Auth redirect | "Go to Dashboard" now goes to `dashboard.html` not `index.html` |
| Password gate | `sessionStorage.setItem('grailiso_preview','1')` set on redirect so gate doesn't block |
| Nav duplicate labels | "Market" and "Account" section labels removed — were rendering as extra nav items |
| Card ticker | Portfolio ticker moved into topbar below page title. Shows card name · grade · price · % change. Falls back to slow GRAILISO scroll if no cards |
| Portfolio bar removed | Old "PORTFOLIO / Loading portfolio..." bar deleted |

---

## 5. SUPABASE SCHEMA — ALL TABLES LIVE

```sql
-- Run in sandbox SQL Editor if missing:
CREATE TABLE IF NOT EXISTS public.seller_preferences (
  id           BIGSERIAL PRIMARY KEY,
  user_id      UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  sports       TEXT[] NOT NULL DEFAULT '{}',
  card_types   TEXT[] NOT NULL DEFAULT '{}',
  notify_email BOOLEAN NOT NULL DEFAULT true,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.seller_preferences ENABLE ROW LEVEL SECURITY;
CREATE POLICY "seller_prefs_own" ON public.seller_preferences FOR ALL USING (auth.uid() = user_id);
```

**Confirmed profiles columns:**
id, username, display_name, avatar_url, iso_credits, created_at, updated_at, identity_session_id, stripe_customer_id, bio, favorite_player, favorite_team, favorite_sport, first_name, last_name, role

**All 8 tables live:** cards, credit_events, isos, matches, notifications, profiles, seller_preferences, vault

---

## 6. ARCHITECTURE

### Auth Flow (5 steps)
1. Email + password
2. Username + name + role + sport/card preferences → writes to profiles + seller_preferences
3. Stripe Identity verification
4. Card on file (Stripe payment method)
5. Ready screen → GO TO DASHBOARD

### Key Auth Rules
- `handle_new_user` trigger creates profile row but does NOT write first_name, last_name, role — Step 2 writes these
- Email confirmation: OFF in sandbox
- Session retry: 5 attempts × 700ms covers fresh signup race condition
- Only redirects to auth.html on explicit SIGNED_OUT event — not on every load

### Credit Model
| Action | Credits |
|---|---|
| Signup bonus | +5 |
| Upload front scan | +1 |
| Upload front + back | +2 |
| Post an ISO | -1 |
| Respond to a match (seller) | -1 |
| Partner referral signup bonus | +3–5 (GrailISO funded) |

---

## 7. DESIGN SYSTEM — PERMANENT, NEVER CHANGE

| Token | Value | Usage |
|---|---|---|
| Background | `#0D1F33` | All pages |
| Blue | `#00AAFF` | ISO brand blue, links, CTAs |
| White | `#FFFFFF` | GRAIL wordmark |
| Gold | `#FFB800` | Credits, RC badges |
| Green | `#00E887` | Matches, success |
| Red | `#FF3B5C` | Urgent, alerts |
| Fonts | Bebas Neue + Barlow Condensed | Headlines + UI |

**card-viewer.html — NEVER MODIFY**
**FOMO admin dashboard `/admin/fomo` — DO NOT BUILD YET**

---

## 8. CARD CATALOG

522 cards across 13 sets. Next priority sets:
1. 2025 Topps Chrome Baseball
2. 2025 Bowman Chrome Baseball
3. 2025-26 Topps Chrome Basketball
4. 2024 Topps Chrome Football
5. 2025 Topps Chrome UFC

---

## 9. IMMEDIATE DO NOW — RANKED

| Priority | Task |
|---|---|
| 🔴 1 | Push auth.html + dashboard.html to isoSANDBOX repo |
| 🔴 2 | Tennessee Foreign LLC registration |
| 🟠 3 | Purchase domains: isograde.com, grailvault.com, isodefender.com |
| 🟠 4 | UPS Store mailbox (2 IDs, register under GrailISO LLC) |
| 🟠 5 | BallDontLie API key — sign up at balldontlie.io for scores/schedule |
| 🟡 6 | Attorney consult — trademark + money transmitter + ID verification |
| 🟡 7 | Google Workspace + email addresses |
| 🟡 8 | SPF + DMARC DNS records |
| 🟡 9 | Stripe secret key + Supabase service key in Netlify env vars |

---

## 10. NEXT BUILD — IN ORDER

### Fix 1 — Scores/Schedule bar (needs BallDontLie API key)
Wire real MLB scores + schedule into dashboard Market panel. Currently demo data only.

### Fix 2 — Wire card catalog to Supabase
Export 522 cards to CSV → bulk import into `cards` table → rewrite catalog to fetch live.

### Fix 3 — Wire dashboard ISO posting to Supabase
Connect Post ISO panel to `isos` table. Connect vault panel to `vault` table.

### Fix 4 — Match notification UI
Build real notification feed panel. Bell icon is placeholder.

### Fix 5 — Stripe backend
Add STRIPE_SECRET_KEY + SUPABASE_SERVICE_KEY to Netlify env vars. Test card-on-file flow.

---

## 11. DOMAIN PORTFOLIO

| Domain | Status |
|---|---|
| grailiso.com | ✅ OWNED — LIVE |
| isosandbox.com | ✅ OWNED — LIVE |
| isograde.com | 🔲 Purchase |
| grailvault.com | 🔲 Purchase |
| isodefender.com | 🔲 Purchase |
| isobiometrics.com | 🔲 Purchase |
| grail-iso.com | 🔲 Purchase |

---

## 12. LEGAL & BUSINESS

| Item | Status |
|---|---|
| GrailISO LLC | ✅ Formed (Delaware) |
| Tennessee Foreign LLC | ⚠️ REQUIRED — do this week |
| UPS Store mailbox | ⚠️ Not opened |
| Attorney consult | ⚠️ Pending |
| Trademark filing | Not started |

---

## 13. NETLIFY FUNCTIONS (in repo, not yet tested)

- `create-setup-intent.js` — Stripe payment setup
- `create-verification-session.js` — Stripe Identity
- `grant-iso-credits.js` — credit system backend
- `notify-matching-sellers.js` — match notification engine

Needs: STRIPE_SECRET_KEY + SUPABASE_SERVICE_KEY in Netlify env vars.

---

## 14. ROADMAP — FUTURE FEATURES

### 🏪 GRAIL Partner Program (post-launch)
Paid verified directory for local card shops. $49–99/month flat fee. Referral link per partner. Referred signups get 5 + bonus ISO credits (GrailISO funded). Monthly leaderboard with tier badges.

### 📊 ISO Rankings (post-launch)
Public leaderboard — most active buyers, most wanted cards, top sellers, trending sets. Social follow layer. FOMO hook on dashboard.

### 💬 Discord Community (do now)
Create GrailISO Discord server. Channels per sport. Link from dashboard. Use as pre-launch community hub and market research feed. In-platform embed post-launch.

---

*GrailISO — Stop Searching. Start Demanding. Find Your Grail.*
*PROJECT.md v1.6.0 — March 12, 2026*
