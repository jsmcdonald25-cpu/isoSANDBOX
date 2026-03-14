# PROJECT.md — ISOVault / GrailISO
> Current state as of thread cutoff. Paste alongside SPRINGBOARD.md in every new thread.

---

## 🏗️ WHAT'S BEEN BUILT

### ✅ Locked & Complete
- **15 sport/entertainment categories** — finalized
- **Navigation hierarchy:** Sport → Manufacturer → Year → Set → Cards
- **Two vault paths:**
  - No catalog pic → upload required (front + back photo both mandatory before submit unlocks)
  - Has pic → data entry only
- **Price paid is required on both paths** (feeds market value tracking)
- **Card detail prototype** (`isovault-card-detail`) built with:
  - 3D card rotation mechanic
  - Mojo variation pills
  - Shimmer effect
  - Market / FOMO block
  - Dual-path modal
- **3D Card Viewer** — built and live at grailiso.com (separate file, do not merge destructively)
- **`card-viewer.html`** — ⛔ NEVER MODIFY

---

## 🗄️ DATABASE SCHEMA DECISION (LOCKED)

- **One row per base card** in the `cards` table
- **Variations** (e.g. Purple Mojo /299, Teal /199, Blue /150) = linked table or JSON array attached to the base card
- Search returns one result for "Ichiro Mojo" → user drills into the variation list from there

---

## 🎨 DESIGN DECISIONS (LOCKED)

| Decision | Answer |
|---|---|
| Card placeholder art | **Blank** — user uploads their own image. No generated placeholders. |
| Back navigation | **Back goes to ISOVault grid** (not one level up) |
| Player search | **Search box at top of every view** — searches by player name |
| Variation schema | **One base card row + linked/JSON variations** (see above) |

---

## 🔜 WHERE WE ARE HEADING

### Immediate Next Steps
1. Merge the **grailiso.com 3D card viewer** rotation mechanic into the ISOVault card detail
2. Wire the card detail prototype into **`dashboard.html`**
3. Player search box — implement at top of card listing views

### Pending / Not Started
- `/admin/fomo` FOMO admin dashboard — **DO NOT BUILD YET**
- Full database wiring (schema above is decided, implementation pending)

---

## 📁 KEY FILES

| File | Status | Notes |
|---|---|---|
| `card-viewer.html` | ⛔ LOCKED | Never modify |
| `isovault-card-detail` | ✅ Built | Needs 3D viewer merged in |
| `dashboard.html` | 🔜 Next | Card detail wires into this |
| grailiso.com 3D viewer | ✅ Live | Source to be posted by user |

---

## 🔒 PERMANENT RULES (repeat from SPRINGBOARD)
- Background: `#0D1F33` always
- GRAIL = `#FFFFFF` | ISO = `#00AAFF`
- Fonts: Bebas Neue (headlines) / Barlow Condensed (UI) — never swap
- Real data only in FOMO engine — no fake timers, no fabricated urgency
- At 190,000 tokens → STOP, generate SPRINGBOARD.md + PROJECT.md, new thread
