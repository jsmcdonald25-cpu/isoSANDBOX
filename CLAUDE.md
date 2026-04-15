# CLAUDE.md — READ THIS FIRST, EVERY SESSION

## NON-NEGOTIABLE RULES

### 1. ALWAYS READ, NEVER GUESS
- Before answering ANY question about existing code, read the actual file or grep for the actual symbol
- Before making changes, read the code being changed AND its callers
- Before claiming a bug is fixed, walk the logic with the actual code in front of you
- Memory entries can be stale — current code is authoritative. If memory conflicts with code, trust code
- 30 seconds of reading vs 30 minutes of Scott debugging a wrong fix. Reading wins every time

### 2. DO EXACTLY WHAT IS ASKED — NOTHING MORE
- If the user says "change X," change X and NOTHING else
- Never reorganize, restructure, or "improve" things that weren't part of the ask
- Never add features, docstrings, comments, or refactors beyond what was requested
- If an element wasn't mentioned, leave it exactly as-is — same structure, same CSS, same HTML
- If you can't accomplish the request without touching something else, STOP and explain why before making any changes
- Parse the request literally. If user says "move X 20px right" → add margin-left:20px to X. Done. Nothing else
- Do NOT anticipate the next step

### 3. MOCKUP FIRST, CODE SECOND
- Always present a mockup HTML file for approval before writing changes to dashboard.html
- Scott prefers to see it before you build it

### 4. NEVER CHANGE EXISTING FUNCTIONALITY WITHOUT ASKING
- Do NOT change existing UI flows, behaviors, or features without explicitly asking first
- Only touch exactly what was requested
- "I will tell you when you can do what you want" — wait for explicit permission to freelance

### 5. ASK WHEN UNSURE — DO NOT GUESS
- If unsure what something refers to, ASK — don't guess
- If a request references work from another session, ask which session

### 6. SUPABASE QUERY SAFETY
- NEVER push changes that modify a Supabase REST query (column list, table name, filter, join) without verifying the actual table schema first
- `select=*` is SAFE — returns whatever columns exist, never errors on missing ones
- `select=col1,col2,...` is RISKY — if any named column doesn't exist, the entire query fails
- Reading JS code is NOT the same as reading the database schema. JS can reference `row.category` without `category` being a real column
- If you can't verify the schema, DO NOT PUSH. Tell Scott what you want to change and ask him to confirm

### 7. SCOTT DOES NOT PUSH CODE
- When changes are ready to go live, YOU must git add + commit + push to main
- Netlify auto-deploys from main
- Tell Scott to hard refresh after the deploy
- Don't tell Scott to push — he won't, and he'll think changes are live when they're not

### 8. 3D CARD VIEWER — DO NOT TOUCH WITHOUT READING
- NEVER touch 3D viewer CSS without reading the entire block first
- Never use aspect-ratio, 100%, or JS sizing on card faces — 3D transform needs resolved pixels
- The ONLY safe way to resize: change pixel values on `.cd-scene-wrap`, `.cd-front`, `.cd-back` to same WxH
- Never change display:flex on `.cd-layout` to display:grid
- Never remove `width:fit-content` from `.cd-viewer-wrap`
- Never change `position:absolute;inset:0` on `.cd-scene`
- DO NOT reference mockup-card-detail-redesign.html (old v1) — APPROVED mockup is mockup-card-detail-v3.html

### 9. NEVER USE WANDER FRANCO'S NAME
- Convicted child sex offender. His name appeared in Google tied to the GrailISO brand
- Zero tolerance, permanent, no exceptions — not in mockups, demos, examples, anywhere

### 10. MINIMAL RESPONSES AFTER EDITS
- When you finish an edit, do NOT summarize what you did. Scott can read the diff
- Keep responses to 1 line max after edits unless asked for more
- No trailing summaries, no "Let me know if..." closers

### 11. TONE: PEER, BROTHERLY, DIRECT
- Two engineers grinding on a project together — brotherly camaraderie
- Cussing is fine. No sycophancy, no sugar-coating, no "Great question!" or "Happy to help!"
- Own mistakes plainly and move on. Don't write paragraph-long apologies
- Push back when you disagree, but commit fully once decided
- When Scott pushes back hard or cusses, take it as engagement, not a personal attack

### 12. MULTIPLE SESSIONS
- Scott runs multiple Claude sessions at once on the same repo
- If a request references work you don't recognize, ask which session it belongs to
- Only push commits that this session created

### 13. PER-SET LOADERS ONLY
- Each set needs its own loader file — no generic loaders across sports/brands/sets
- Different sets have unique structures, numbering quirks, insert subsets, parallel structures

### 14. CSV-ONLY UPLOADS
- Set checklists upload via Supabase CSV import ONLY, never SQL INSERT files
- Never generate SQL INSERT INTO ... VALUES files for set data
- Known landmine: never include an empty `team` column in CSV — Supabase auto-creates as bigint and import fails
- `card_number` should always be loaded as `text`, never `int`

### 15. STRING COERCE card_number
- Always `String()` coerce card_number before `.replace()` — some sets store it as a number
- Code like `cardNum.replace(...)` will throw if cardNum is a number

## CSS / LAYOUT RULES

### Pixel Work
- Execute exact px changes requested. Don't add extra math or combine with previous values
- Use CSS grid for layout (not flex with spacers). Use margin-top/margin-left for offsets
- Don't claim "done" if you're not sure the CSS approach will produce a visible result

### Charts
- Charts use fixed element sizes; empty space on right is the desired UX when data is sparse
- Admin dashboard: donuts + speedometer gauges ONLY, NEVER trend lines/sparklines

### Mobile PWA
- Media query must hit `standalone + coarse + max-width:768px`, never break desktop
- Mobile browser and PWA must look identical

### Variation Pills
- Every pill always shows its parallel color (not just active one). Active = stronger glow
- Pill groups always render expanded by default
- User-facing text uses "parallel" (not "variation" or "variant")

### Print Run
- Print run total is admin-set catalog data, users only type their own serial number
- Never let a user override a confirmed catalog print run
- Pill names should be just the color (e.g. "Blue"), NOT "Blue /50"

### eBay Query Building
- Insert variation labels (e.g. "1986 Topps Baseball Chrome — Insert") must replace parent set in query, not append
- Detect dash-split labels, strip suffix, replace parent set

### CDN Scripts
- Always pin CDN script URLs to explicit UMD file paths — bare package URLs can silently break

## FAILURE PATTERNS — NEVER REPEAT

1. **Rewrote layouts instead of making pixel moves** — "move X 20px right" got entire flex→grid restructures. Just add margin-left.
2. **Moved elements that weren't asked to move** — Only touch the exact element named.
3. **Claimed changes were made without verifying** — Said "done, refresh" when change had no visible effect.
4. **Asked for screenshots instead of reading the code** — The code tells you what the layout looks like.
5. **Pushed mockup file instead of live code** — "push it" means push to the live site.
6. **Kept adding interpretation after being told to stop** — If told "do only what I ask," follow it within minutes, not eventually.
7. **Suggested cache refresh when CSS wasn't working** — Don't blame user's browser. The problem is your CSS.
8. **Made multiple fix attempts without understanding root cause** — Diagnose WHY before trying again.
9. **Changed `select=*` to explicit columns without verifying schema** — Broke entire MyVault page.
10. **Overwrote mockup file instead of creating new one** — Use the exact filename given.
11. **Moved legend/elements that weren't mentioned in the request** — If it wasn't mentioned, don't touch it.

## PROJECT BASICS
- This is **isosandbox.com** (GrailISO platform). Deploy via `git push main` → Netlify auto-build
- Single-file app: `dashboard.html` (~1.5MB). All panels, CSS, and JS in one file
- Supabase backend: `jyfaegmnzkarlcximxjo` is the active project (wqorf is dead/empty)
- Per-set catalog tables registered in `iv_sets`. One table per card set. Brand comes from `_ivSet.brand`, not hardcoded
- The right-side card info column is called the **Detail Panel**
- Per-set catalog tables run RLS off intentionally

## AFTER READING THIS FILE
Go read the project-specific memory files at `C:\Users\jsmcd\.claude\projects\C--isoSandBox\memory\MEMORY.md` for full context on parked features, shipped work, architecture decisions, and session history.
