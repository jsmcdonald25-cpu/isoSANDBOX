# GrailISO Scam Catalog
_Defensive threat intelligence for the grail2.0 Scam Prevention Wizard_

**Version:** 2026-04-20
**Sources:** `research/fraud/` scraper output + public 2025–2026 news, court records, police advisories, collector community reports
**Purpose:** Catalog known scams, decompose each into reusable atomic components, then mix-and-match atoms to predict novel scams before they happen. Feeds the wizard's decision tree + recovery-playbook data layer.

## Catalog Principles

1. **Techniques, not people.** Cases reference method + date + jurisdiction. No defendant names. The method matters; the individual does not.
2. **Atomic decomposition.** Every case breaks into reusable atoms (actor / venue / platform / payment / method / victim-role / dollar-tier / legal-outcome) so the wizard can narrow user input to one scam.
3. **Mix-and-match is defense, not blueprint.** Predicting "what if atom X meets atom Y" lets users watch for novel combinations. Descriptive, never instructional.
4. **grail2.0 defense mapping uses identity/provenance language only.** Never "grade" or "score" — per pivot rules.

---

## TABLE OF CONTENTS

- **Part 1** — Known Cases by Category _(30+ documented 2025–2026 patterns)_
- **Part 2** — Atomic Component Library _(the reusable atoms)_
- **Part 3** — Mix-and-Match Threat Model _(predicted novel scams)_
- **Part 4** — Active Watch List _(user-facing alerts)_
- **Appendix A** — Wizard Data Flow
- **Appendix B** — Source Verification & Disclaimer Protocol

---

# PART 1 — KNOWN CASES BY CATEGORY

Every case uses this shape:
- **Where / when / scale**
- **Method summary** (1–3 lines)
- **Atoms** (tags for mix-and-match)
- **grail2.0 defense** (identity/provenance control that neutralizes it)

---

## 1.A — Counterfeit Production & Distribution

### A1 — Multi-state fake-slab forgery conspiracy
- **Where / when:** Federal conviction SDNY, Jan 2026. Multi-year operation.
- **Scale:** $2M+ defrauded nationwide.
- **Method:** Forged PSA-style labels on sports + Pokemon cards. Lower-value or fully counterfeit cards placed into fake slabs. Distributed via online listings, auctions, card shows. One operator posed as legitimate dealer; co-conspirator took plea.
- **Atoms:** `network` `counterfeit-slab-manufacture` `label-forgery` `multi-venue-distribution` `persona-of-legitimacy` `national-scale` `federal-wire-fraud`
- **grail2.0 defense:** DL-verified identity (one account per real human, no persona-of-legitimacy); pre-encapsulation biometric enrollment means forged labels cannot claim identity without matching substrate signature.

### A2 — Local home counterfeit production
- **Where / when:** Utah, Feb 2026 arrest (2nd or 3rd arrest for same activity).
- **Scale:** Sales $1,500–$4,500 each to local collectors.
- **Method:** Home production of counterfeit Pokemon cards sold directly to local collectors.
- **Charges:** 25 felonies including possession of forging devices.
- **Atoms:** `solo` `home-production` `local-direct-sale` `repeat-offender` `possession-of-forging-devices-as-charge`
- **grail2.0 defense:** Cards offered for sale on platform must have biometric identity enrollment; home-printed counterfeits have no enrollment record and cannot be listed.

### A3 — European resealed-slab ring
- **Where / when:** Europe, 2026 collector reports.
- **Method:** Crack genuine mid-grade slab; insert lower-grade or counterfeit card; reseal in replica case that includes UV-compliant fake watermarks and silver label. Some cases copy cert data from older higher-grade labels.
- **Distribution:** Regional European markets, potentially moving to US auction houses.
- **Atoms:** `network` `real-slab-harvest` `counterfeit-replica-case` `UV-feature-mimicry` `cert-data-harvesting` `regional-operation`
- **grail2.0 defense:** Biometric enrollment happens pre-encapsulation against the card's inherent substrate. Any post-enrollment swap fails biometric match at next verification stage.

### A4 — Acetone-strip label tampering
- **Where / when:** Publicly discussed via r/PokeGrading, Mar 2026.
- **Method:** Acetone solution strips ink from a real grader label while preserving UV / security features. Original card swapped out, counterfeit inserted, label re-applied.
- **Tell:** Inner card-holder brackets on fake slab show sharper angular edges than authentic brackets.
- **Severity:** Described by grader as "one of the best counterfeit slabs they've ever seen" — still caught on internal review.
- **Atoms:** `solo-or-small` `real-slab-harvest` `chemical-label-strip` `feature-preservation` `edge-geometry-tell`
- **grail2.0 defense:** Biometric identity is tied to the card, not the holder. No label-based chain of trust to strip.

### A5 — Thermal-label fake sealed cases
- **Where / when:** Early 2026 community video documentation.
- **Method:** Reprint thermal label for a high-demand sealed booster case; apply to cardboard-box-with-stop-tape over low-value or empty contents. Mimics factory seal.
- **Product:** Example: "Evolving Skies" label applied over "Journey Together" case.
- **Reproducibility:** Community demonstrated method is easily repeated.
- **Atoms:** `manufacturing-tier` `thermal-label-reprint` `factory-seal-mimicry` `high-value-product-targeting`
- **grail2.0 defense:** Sealed product outside scope of V1 biometric enrollment; but hub-custody model for any unsealed derivative requires pre-sale verification.

### A6 — Historical-provenance forgery recall
- **Where / when:** Early 2025 → 2026 fallout at a major grader.
- **Scale:** 1,500+ "prototype / playtest" cards recalled after forensic analysis showed they were printed in 2024, not the 1990s vintage represented. Some had sold at auction for >$1M.
- **Method:** Fabricate historical narrative; authenticate through legitimate grader; launder through major auction.
- **Atoms:** `manufacturing-tier` `authenticated-through-real-grader` `historical-provenance-fabrication` `auction-laundering` `grader-post-mortem`
- **grail2.0 defense:** Biometric identity at enrollment + first-known-enrollment-date timestamp creates an auditable origin point. "Newly discovered vintage" with no enrollment history is inherently lower-trust.

### A7 — New-set crossover counterfeit surge
- **Where / when:** MTG Final Fantasy crossover, 2025–2026.
- **Method:** Counterfeit singles flood marketplaces immediately after set release. Straight counterfeits attempt official foil stamp; some fakes mixed with disclosed proxies to create plausible deniability.
- **Channels:** eBay, TikTok.
- **Atoms:** `manufacturing-tier` `hype-cycle-timing` `new-set-exploit` `authenticity-marker-forgery` `mixed-with-proxies`
- **grail2.0 defense:** Duplicate-serial / duplicate-identity detection at enrollment; hype-cycle listings without biometric record flag as higher risk.

---

## 1.B — Fake Graded Slab Schemes (individual sale level)

### B1 — Platform authentication bypass
- **Where / when:** Documented 2026 case against eBay Authenticity Guarantee.
- **Loss:** Buyer paid ~$1,500; platform check initially passed the fake; buyer confirmed counterfeit via grader submission after receipt.
- **Atoms:** `individual` `platform-auth-exploit` `post-sale-confirmation-gap` `high-value-target`
- **grail2.0 defense:** Biometric verification happens at Hub intake (HAC stage) on every transfer — not a one-time listing check. Counterfeits halt at Tier 5 auto-rejection.

### B2 — In-person meetup fake slabs
- **Where / when:** Multiple 2026 community warnings across US metros.
- **Venue:** Local meetups, Instagram/Facebook arranged deals.
- **Method:** Cash sales of "high-grade" counterfeit slabs. Example loss: $210 for a fake VMAX "10".
- **Atoms:** `individual` `in-person-trust-exploit` `cash-payment` `unverified-cert`
- **grail2.0 defense:** Hub-only transaction model — no direct cash peer-to-peer on platform.

### B3 — Card-show high-value buyer loss
- **Where / when:** 2025–2026 reported incidents.
- **Scale:** One reported $28,000 loss at a card show on fake graded slabs.
- **Atoms:** `individual` `card-show-venue` `high-value-single-buyer` `cash-or-quick-payment`
- **grail2.0 defense:** Hub routing for any card-show-originated transaction; biometric enrollment before buyer receives.

---

## 1.C — Online Transaction Fraud (buyer victim)

### C1 — Pre-order ghost-seller wave
- **Where / when:** SE Asia (among others), late 2025 ongoing into 2026.
- **Platforms:** Messaging + P2P marketplace apps with weak buyer protection.
- **Scale:** 600+ reports in one national market; $800K+ USD-equivalent reported losses.
- **Method:** Scammer accepts deposits for upcoming TCG releases via bank transfer / P2P apps; goes unreachable around release date.
- **Atoms:** `individual-or-small` `pre-order-exploit` `hype-cycle-timing` `p2p-payment` `communication-ghosting`
- **grail2.0 defense:** Escrow via Stripe Connect — funds held until hub confirms physical receipt + biometric match.

### C2 — Fake "job / commission" crypto funnel
- **Where / when:** Jan 2026 documented wave.
- **Pretext:** Victim offered commission for completing "digital Pokemon trading tasks."
- **Mechanism:** Victim directed to deposit cryptocurrency on fraudulent exchange.
- **Scale:** S$51,600 across 7 reported cases in one month.
- **Atoms:** `network` `pretext-employment-scam` `crypto-payment-funnel` `tcg-branding-as-legitimacy`
- **grail2.0 defense:** grail2.0 does not use crypto, commissions, or digital-task flows. Any pretext branding as "grail2.0 work" is identifiable through DL-verified-only account creation.

### C3 — Non-delivery fraud against small business
- **Where / when:** UK, Feb 2026. Suspended sentence after private prosecution.
- **Loss:** ~£60K (~$75K USD) to single B2B victim over multiple orders.
- **Atoms:** `individual` `b2b-target` `trust-based-repeat-order` `no-delivery`
- **grail2.0 defense:** Every order escrow-backed regardless of repeat-buyer relationship.

### C4 — Legitimate-service impersonation via SEO
- **Where / when:** MTG, Mar 2026.
- **Method:** Scammer created listing impersonating a real TCG vending service; surfaced via search engine results; advertised high-demand booster product at plausible price.
- **Atoms:** `individual` `legit-service-impersonation` `seo-placement` `high-demand-product`
- **grail2.0 defense:** grail2.0 transactions happen on the platform, not via external SEO clicks. Verified-identity badge on platform is the only authentic seller signal.

### C5 — Influencer coordinated non-delivery
- **Where / when:** Late 2025 "pokedrama" wave.
- **Actors:** Multiple TCG influencers / content groups accused of coordinated non-delivery to audience-trust buyers.
- **Scale:** $100K+ combined losses.
- **Outcome:** Community reputation damage; few formal criminal cases.
- **Atoms:** `network` `influencer-trust-exploit` `coordinated-across-accounts` `social-audience-funnel`
- **grail2.0 defense:** Platform reputation shows verified transaction counts only, not content-platform follower counts. Influencer social trust has no privilege on grail2.0.

### C6 — Layered fall-guy operation
- **Where / when:** Reddit reports, SE Asia, early 2026.
- **Structure:** Operator A collects / processes payments, keeps 5% cut; mastermind B receives 95% and stays insulated. If A gets arrested, B retains resources to run operation with a new A.
- **Atoms:** `network` `compartmentalized-roles` `legal-insulation` `income-split-architecture`
- **grail2.0 defense:** DL-verified identity + Stripe Connect forces real payout account to real human. Compartmentalization collapses when funds flow requires verified identity.

### C7 — Rip-and-Ship event rigging
- **Where / when:** Mid-2025 hype-cycle around new releases.
- **Format:** Live or in-person pack rip events; buyers pay $10–20/pack well above MSRP.
- **Fraud variants:** Pre-opened packs; rigged pull order; no delivery.
- **Per-victim loss:** Typically $50–$100.
- **Atoms:** `individual-or-small` `live-event-format` `hype-cycle-timing` `retail-premium` `rigged-randomization`
- **grail2.0 defense:** grail2.0 does not host pack-rip randomized events; any post-rip single sold on grail2.0 requires hub intake and enrollment.

---

## 1.D — In-Person Transaction Fraud (buyer or seller victim)

### D1 — Fake money bundle heist
- **Where / when:** Japan, Mar 2026. 3-person team.
- **Target:** Seller of rare cards valued $300K+.
- **Method:** Real currency bill on top of bundle, filler underneath. Counted during arranged face-to-face exchange; seller defrauded.
- **Atoms:** `small-team` `in-person-exchange` `physical-cash-deception` `high-value-single-target`
- **grail2.0 defense:** No face-to-face cash exchanges on platform. Hub routes physical card; Stripe Connect routes payment.

### D2 — Cashier POS manipulation
- **Where / when:** NYC SoHo, 2025. Retail card store victim.
- **Method:** Suspect manipulated credit-card transaction so cashier mis-read a decline as a completed sale. Pre-reconned store via multiple visits same day.
- **Loss:** ~$10K in Pokemon + baseball cards.
- **Atoms:** `individual` `retail-store-target` `pos-exploit` `multi-visit-recon`
- **grail2.0 defense:** N/A for physical retail operations; advisory content for card-shop partners integrated into Card Shops feature.

### D3 — Low-dollar shakedown with refund
- **Where / when:** Oregon, Mar 2026 police log.
- **Pattern:** Buyer purchases counterfeit deck at market; complains to seller; seller returns money. No charges filed.
- **Significance:** Captures common pattern where scammers test targets at low dollar amounts; only proceed at scale with those who don't complain.
- **Atoms:** `individual` `market-venue` `low-dollar` `no-enforcement-outcome`

---

## 1.E — Retail & Shop Theft

### E1 — Big-box barcode-swap retail-theft ring
- **Where / when:** Florida, Jul 2025 – Feb 2026. ~75 separate thefts across counties.
- **Method:** Scammer applies 99¢ barcode sticker (hidden inside unrelated product packet) to high-value sealed TCG box at self-checkout. Pays the low price, walks out.
- **Fence:** Resold on major online marketplace for ~$40K total.
- **Charges:** Organized retail theft, dealing in stolen property, money laundering.
- **Atoms:** `solo` `big-box-retail` `self-checkout-exploit` `barcode-sticker-swap` `ebay-fence` `high-repeat-volume`
- **grail2.0 defense:** Sealed product enrollment with retailer-side SKU / timestamp anchor flags suspicious pricing at listing.

### E2 — Shop break-in (team)
- **Where / when:** Anaheim CA, early 2026. 3-suspect team.
- **Loss:** Tens of thousands in sealed + single-card inventory.
- **Atoms:** `small-team` `after-hours-burglary` `shop-target`

### E3 — Regional shop-burglary wave
- **Where / when:** Southern California, late 2025 – 2026. 4 burglary suspects arrested in one clustered case.
- **Pattern:** Multiple brazen thefts; some single heists six-figure; some involving violence.
- **Atoms:** `network` `regional-operation` `escalating-violence` `shop-clustering`

### E4 — Distract-and-grab at LCS
- **Where / when:** Tampa area FL, Mar 2026. 2-person team.
- **Method:** One suspect distracts clerk; partner steals high-value card from display.
- **Repeat:** Linked to similar earlier theft in adjacent metro.
- **Atoms:** `pair` `distract-and-grab` `LCS-target` `regional-repeat`

### E5 — International store burglary
- **Where / when:** Canberra AU, Mar 2026. Solo 33-year-old.
- **Loss:** Thousands in cards; some Pokemon unrecovered.
- **Atoms:** `solo` `store-burglary` `international` `cards-as-theft-target`

### E6 — Social-media-recon residential theft
- **Where / when:** Chicago, 2025–2026. Felony charges filed.
- **Method:** Used social media to identify individual collectors; stole cards through targeted approach.
- **Atoms:** `individual` `social-media-recon` `targeted-theft`

### E7 — Residential collection theft
- **Where / when:** Pittsburgh area, 2025–2026.
- **Loss:** $13K+ in trading cards from residence.
- **Atoms:** `individual` `residential-target` `high-value-collection`

### E8 — Stolen-financial-instrument card purchase
- **Where / when:** Roswell GA, Dec 2025.
- **Method:** Stolen credit card used to purchase Pokemon card.
- **Secondary victim:** Merchant who accepted the card eats chargeback loss when cardholder reports fraud.
- **Atoms:** `individual` `stolen-financial-instrument` `merchant-as-second-victim`
- **grail2.0 defense:** DL-verified identity tied to Stripe Connect account blocks disposable-CC-to-cards pattern; any stolen-CC chargeback is defended by cryptographic provenance chain.

---

## 1.F — Armed Robbery / Meetup Ambush

### F1 — Chemical-irritant Facebook Marketplace ambush ring
- **Where / when:** Vancouver BC, Mar 2026.
- **Method:** Scammer arranges purchase of valuable cards through Facebook Marketplace; robs seller with bear spray at meetup.
- **Scale:** 5+ similar incidents over days before police sting arrested suspect.
- **Atoms:** `solo` `facebook-marketplace-bait` `chemical-irritant-weapon` `pre-arranged-meetup` `seller-as-victim`
- **grail2.0 defense:** No seller → buyer meetups on platform. Hub model removes physical exchange entirely.

### F2 — Violent in-store robbery
- **Where / when:** Wilmington NC, Jan 2026. Game store victim.
- **Loss:** ~$20K across graded slabs, raw singles, sealed product.
- **Method:** Employee restrained + threatened during robbery.
- **Atoms:** `individual` `game-store` `employee-physical-coercion` `mixed-product-theft`

### F3 — Gas-station armed robbery (low-dollar, violent)
- **Where / when:** California, Apr 2025 incident → Feb 2026 sentencing.
- **Loss:** $1,000 in Pokemon cards.
- **Method:** Verbal threats during confrontation.
- **Sentence:** 4 years state prison for 2nd-degree robbery.
- **Atoms:** `individual` `gas-station` `low-dollar-but-violent` `prosecuted-aggressively`

### F4 — Card-show follow-and-rob (pattern)
- **Where / when:** Multi-location 2025–2026 pattern.
- **Method:** Thief identifies high-value buyer or seller at card show; follows to parking lot or vehicle; robs.
- **Atoms:** `individual-or-pair` `surveillance-at-event` `post-venue-isolation-attack`

---

## 1.G — Chargeback & Reverse-Side Fraud (seller victim)

### G1 — Fake-ID in-person chargeback
- **Where / when:** New Jersey card shops, Mar 2026.
- **Method:** High-value in-person credit-card purchase using fake driver's license under assumed name. ~30 days later, buyer files chargeback claiming non-receipt or fraud. Shop loses both cards and money.
- **Scale:** Multiple shops reporting thousands in losses.
- **Atoms:** `individual` `brick-and-mortar-target` `fake-ID` `credit-card-chargeback` `cards-and-cash-double-loss`
- **grail2.0 defense:** DL-verified identity tied to real human; cryptographically signed provenance chain submitted as chargeback-dispute evidence.

### G2 — AI-fabricated damage claim
- **Where / when:** General pattern, online sellers, early 2026.
- **Method:** Buyer receives intact product. Uses AI image-editing to fabricate damage photos. Files refund or damage claim on platform that defaults to buyer in disputes.
- **Atoms:** `individual` `online-seller-target` `AI-fabricated-evidence` `post-delivery-false-claim`
- **grail2.0 defense:** Biometric enrollment captures card state at CPC. Post-delivery re-verification captures delivered state. Any fabricated damage claim fails biometric comparison.

### G3 — Authentication-pipeline swap
- **Where / when:** 2026 collector reports.
- **Flow:** Seller ships genuine cards to platform or grader authentication. Package intercepted or swapped en route. Seller receives counterfeit slabs back claiming "that's what you sent."
- **Atoms:** `network-or-insider` `shipping-pipeline` `in-transit-substitution` `authentication-as-cover`
- **grail2.0 defense:** 5-scan transfer cycle: pre-ship capture by seller + hub-arrival capture are independent biometric records. Swap in transit fails hub-arrival match.

---

## 1.H — Platform / Grader System Exploits

### H1 — Grader internal cert-flip buyback
- **Where / when:** Major grader, Dec 2025 – Mar 2026.
- **Pattern:** Collector submits identical modern cards → graded mostly "9" → accepts grader buyback at 9 value → cert numbers subsequently upgraded to "10" silently by senior reviewer during internal QC. Grader captures the upgrade delta.
- **Evidence basis:** Multiple community reports of identical cert-number-after-buyback patterns.
- **Atoms:** `insider` `grader-internal-exploit` `buyback-arbitrage` `silent-post-hoc-upgrade` `submitter-financial-harm`
- **grail2.0 defense:** grail2.0 doesn't grade or score. Verification is identity, not condition. No incentive exists to flip an identity record.

### H2 — Auction-house shill-bidding
- **Where / when:** Major sports-card auction platform, suit filed Apr 2025, ongoing 2026.
- **Claim:** Years-long internal + external coordinated shill-bidding inflating auction hammer prices. Damages sought $13.7M+.
- **Atoms:** `network` `auction-house-insider` `coordinated-fake-bidding` `fiduciary-breach`
- **grail2.0 defense:** No auction format. Fixed-price / ISO-post / offer model; nothing to shill-inflate.

### H3 — Manufacturer false-scarcity advertising
- **Where / when:** Major sealed-product line, 2025–26 season. Class action filed Mar 2026.
- **Claim:** Product marketed as containing exclusive chase cards. Manufacturer later admitted (internal email leaked) zero boxes contained the advertised chase. Buyers paid premium based on advertised chase.
- **Atoms:** `manufacturer` `false-scarcity-advertising` `premium-pricing-misrepresentation`

### H4 — Manufacturer overprinting securities fraud
- **Where / when:** Major TCG, shareholder suit filed Jan 30, 2026.
- **Claim:** Deliberate overprinting to offset revenue shortfalls; devalued secondary market; misled investors.
- **Atoms:** `manufacturer` `supply-side-manipulation` `secondary-market-impact` `securities-angle`

---

## 1.I — Adjacent / Laundering

### I1 — Crypto-theft-to-cards laundering
- **Where / when:** Maryland indictment, Mar 30, 2026.
- **Predicate:** $50M+ crypto exchange hack.
- **Laundering route:** Stolen funds used to purchase genuine high-end cards — Black Lotus (~$500K), sealed Alpha boosters (~$1.5M), sealed Pokemon sets.
- **Direction:** Scammer is the BUYER. Sellers face potential clawback risk if funds traced.
- **Atoms:** `individual-fraudster` `real-card-as-asset-class` `stolen-funds-laundering` `seller-clawback-risk`
- **grail2.0 defense:** DL-verified identity + Stripe Connect creates KYC trail on both sides; high-value transactions flagged for additional identity verification.

### I2 — Employee embezzlement → card purchases
- **Where / when:** SD Iowa, sentenced Aug 2025.
- **Predicate:** Employee used employer's credit cards to buy ~$140–146K in Pokemon + gaming items + gift cards.
- **Cover:** Falsified expense reports.
- **Atoms:** `individual` `employer-funds-diversion` `cards-as-laundering-asset`

---

# PART 2 — ATOMIC COMPONENT LIBRARY

Every atom below is a tag that can attach to a known case OR combine with others to generate novel scam predictions.

## 2.1 — Actor Archetype
- `solo` — single individual
- `pair` — two-person coordination (distract + grab)
- `small-team` — 3–5 coordinated actors
- `network` — organized multi-actor with distinct roles
- `insider` — employee of grader / platform / retailer
- `influencer-fronted` — operator leverages audience trust
- `persona-of-legitimacy` — operator poses as legit dealer / service
- `manufacturer` — corporate-tier actor
- `fall-guy-mastermind` — compartmentalized A/B structure

## 2.2 — Victim Role
- `buyer-online` · `buyer-in-person` · `buyer-institutional`
- `seller-online` · `seller-in-person` · `seller-small-business`
- `shop-storefront` · `shop-inventory` · `shop-employee`
- `grader-as-conduit` · `platform-as-conduit`
- `auction-bidder` · `shareholder-investor`
- `merchant-second-victim` (stolen-CC chargeback fallout)

## 2.3 — Venue / Platform
- `ebay` · `mercari` · `whatnot` · `fanatics-collect` · `pwcc` · `tcgplayer`
- `facebook-marketplace` · `instagram-dm` · `tiktok-live` · `discord` · `telegram` · `carousell`
- `big-box-retail` (Target / Walmart / GameStop) · `self-checkout-exploit`
- `LCS` (local card shop) · `card-show` · `private-meetup` · `gas-station` · `parking-lot`
- `google-seo-listing` · `cloned-vendor-url`
- `authentication-pipeline` (in-transit to / from grader)
- `residential-target`

## 2.4 — Payment Method
- `credit-card-on-platform` · `credit-card-in-person`
- `paypal-gs` · `paypal-ff` · `venmo-standard` · `venmo-gs`
- `zelle` · `cashapp` · `wire-transfer` · `bank-transfer` · `paynow`
- `crypto-deposit` · `crypto-as-laundering`
- `cash-in-person` · `fake-cash-bundle`
- `stolen-financial-instrument` · `fake-ID-credit-card`
- `gift-card` · `check-moneyorder`

## 2.5 — Physical Method (card alteration)
- `counterfeit-print` · `counterfeit-slab-manufacture` · `replica-case-manufacture`
- `card-trimming` · `card-pressing` · `card-cleaning` · `card-whitening` · `card-recoloring`
- `card-doctoring` · `surface-smoothing` · `edge-touch-up`

## 2.6 — Packaging Method
- `pack-reseal` · `pack-weighing-cherry-pick`
- `box-reseal` · `thermal-label-reprint` · `factory-seal-mimicry`
- `slab-crack-and-insert` · `chemical-label-strip` · `cert-data-harvesting`
- `UV-feature-mimicry` · `hologram-replication`

## 2.7 — Transaction Method
- `pre-order-exploit` · `hype-cycle-timing` · `new-set-exploit`
- `bait-and-switch` · `empty-package-send` · `fake-tracking`
- `address-switch-after-payment` · `ghosting-post-payment`
- `rigged-randomization` (pack rip, live rip) · `live-event-format`
- `return-swap` (buyer sends different item back)
- `post-delivery-false-claim` · `AI-fabricated-evidence`
- `credit-card-chargeback` · `90-day-reversal`
- `shill-bidding` · `buyback-arbitrage`

## 2.8 — Violence / Theft Method
- `after-hours-burglary` · `smash-and-grab`
- `distract-and-grab` · `multi-visit-recon`
- `pre-arranged-meetup-ambush` · `chemical-irritant-weapon` · `firearm`
- `employee-physical-coercion` · `surveillance-at-event` · `post-venue-isolation-attack`
- `porch-pirate` · `mail-theft` · `in-transit-substitution`

## 2.9 — Retail / POS Method
- `barcode-sticker-swap` · `SKU-substitution` · `self-checkout-exploit`
- `pos-exploit` · `decline-misread` · `cashier-distraction`
- `stolen-financial-instrument`

## 2.10 — System-Exploit / Corporate Method
- `platform-auth-exploit` · `post-sale-confirmation-gap`
- `grader-internal-exploit` · `silent-post-hoc-upgrade`
- `auction-house-insider` · `coordinated-fake-bidding`
- `false-scarcity-advertising` · `supply-side-manipulation`
- `authenticated-through-real-grader` · `historical-provenance-fabrication`

## 2.11 — Social-Engineering / Trust Method
- `legit-service-impersonation` · `seo-placement` · `cloned-vendor-url`
- `influencer-trust-exploit` · `coordinated-across-accounts` · `social-audience-funnel`
- `pretext-employment-scam` · `tcg-branding-as-legitimacy`
- `social-media-recon` · `trust-based-repeat-order` · `in-person-trust-exploit`
- `persona-of-legitimacy`

## 2.12 — Structural / Operational Method
- `compartmentalized-roles` · `legal-insulation` · `income-split-architecture`
- `regional-operation` · `national-scale` · `international`
- `shop-clustering` · `escalating-violence`
- `high-repeat-volume` · `auction-laundering`

## 2.13 — Dollar Tier
- `petty` ($10–100) · `small` ($100–1K) · `medium` ($1K–10K)
- `large` ($10K–100K) · `major` ($100K–1M) · `catastrophic` ($1M+)

## 2.14 — Legal Outcome Seen
- `civil-only` · `platform-ban-only` · `local-police-arrest` · `state-felony-charge`
- `federal-indictment` · `federal-conviction` · `class-action` · `shareholder-suit` · `private-prosecution`
- `no-charges-filed` · `suspended-sentence` · `prison-sentence`

---

# PART 3 — MIX-AND-MATCH THREAT MODEL

Novel scam combinations — not yet documented but structurally plausible. Each prediction combines atoms from real cases. These feed the wizard's "watch list" and grail2.0 defense roadmap.

## P1 — AI-damage × live-stream rip
- **Atoms:** `G2` `live-event-format` `seller-as-victim`
- **Scenario:** Buyer purchases pulled card from live-rip stream; after delivery, generates AI-fabricated crease/surface damage photos; files platform refund. Streamer has no intake-state proof of the card they shipped.
- **Why plausible:** AI damage-fab (G2) is proven; live-rip ecosystem adds a new seller cohort with no pre-ship baseline scan.
- **Watch for:** Buyers filing damage claims within 48h of delivery on live-stream pulls.

## P2 — Bear-spray ambush migrates to eBay local-pickup
- **Atoms:** `F1` `pre-arranged-meetup-ambush` `chemical-irritant-weapon`
- **Scenario:** Method originally on Facebook Marketplace expands to eBay local-pickup listings where seller doesn't verify identity prior to meeting.
- **Watch for:** Local-pickup-only listings at extreme discount with buyer pushing first-meetup on urgent timeline.

## P3 — Fake-ID chargeback at card shows
- **Atoms:** `G1` `card-show-venue` `fake-ID` `credit-card-chargeback`
- **Scenario:** NJ-shop pattern migrates to card-show vendors who accept credit cards via mobile readers. Scammer pays with fake-ID-linked CC, disputes 30 days later.
- **Watch for:** Card-show vendors receiving large CC payments from out-of-state IDs; vendors should keep HD video of every transaction.

## P4 — Acetone-strip method applied to other graders
- **Atoms:** `A4` `chemical-label-strip` `cert-data-harvesting`
- **Scenario:** Acetone method proven against one major grader diffuses to others (BGS / SGC / TAG) whose labels use comparable substrates.
- **Watch for:** Sudden appearance of high-grade fakes from non-PSA graders where the volume was previously low.

## P5 — Pack-weighing migrates to modern sets
- **Atoms:** `pack-weighing-cherry-pick` `new-set-exploit`
- **Scenario:** Weighing was historically vintage-only; modern hit-vs-bulk weight differentials (autos, relics) make select modern sets weighable. Store employees or distributor insiders cherry-pick heavy packs.
- **Watch for:** Retail boxes with consistent bulk-only outcomes; weigh-to-detect becomes a buyer check.

## P6 — Thermal-label seal fraud expands to sports sealed
- **Atoms:** `A5` `thermal-label-reprint` `hype-cycle-timing`
- **Scenario:** Method proven on Pokemon sealed cases expands to sports hobby boxes (Stadium Club, Chrome, Prizm Premium) where per-case value exceeds $500.
- **Watch for:** Sealed hobby case listings on secondary markets with slight factory-seal inconsistency; demand sealed product come from authorized distributor with chain-of-custody.

## P7 — grail2.0 platform itself becomes laundering target
- **Atoms:** `I1` `stolen-funds-laundering` `real-card-as-asset-class`
- **Scenario:** As grail2.0 accumulates verified-identity real-card inventory, bad actors attempt to acquire cards with laundered funds. Risk is on the seller side if funds are clawed back post-sale.
- **Mitigation:** KYC escalation above transaction dollar thresholds; Stripe Connect + DL-verification creates AML trail from day one.

## P8 — Grader cert-flip pattern at other graders
- **Atoms:** `H1` `insider` `silent-post-hoc-upgrade` `buyback-arbitrage`
- **Scenario:** Any grader with a buyback program creates the same arbitrage — submit identical cards, buy back at low grade, silently upgrade, keep delta.
- **Watch for:** Grader transparency policies on cert-change audit logs. Absence of published audit trail = plausible deniability.

## P9 — Influencer non-delivery on live platforms
- **Atoms:** `C5` `live-event-format` `influencer-trust-exploit`
- **Scenario:** Non-delivery pattern from late-2025 Instagram/YouTube migrates to live-stream platforms where audience-video "proof" of packaging creates fake trust.
- **Watch for:** Streamers who film packaging but don't show tracking upload or shipping drop-off; ask for end-to-end USPS Informed Delivery scan.

## P10 — Bot-scale stolen-CC sniping
- **Atoms:** `E8` `stolen-financial-instrument` `high-repeat-volume`
- **Scenario:** Automated sniping bots run stolen-CC purchases on marketplace listings; items shipped to mule addresses; stolen CC reported days later, merchant eats chargeback.
- **Watch for:** Instant purchases from new accounts; address mismatch between billing and ship-to; rapid-fire same-IP account creation.

## P11 — Fake-job crypto scam rebranded to MTG
- **Atoms:** `C2` `pretext-employment-scam` `tcg-branding-as-legitimacy`
- **Scenario:** Pokemon-branded fake-job crypto pattern rebrands for MTG community which has equivalent collector interest.
- **Watch for:** MTG-themed "commission" job offers, especially to recently-active finance-sub Reddit users.

## P12 — Barcode swap at LCS consignment displays
- **Atoms:** `E1` `barcode-sticker-swap` `LCS`
- **Scenario:** Self-checkout barcode trick adapted to LCS consignment displays where shop's SKU-on-sticker is handwritten / less secure than big-box.
- **Watch for:** LCS shops should verify every consignment SKU against POS lookup at checkout, not just scan.

## P13 — Follow-and-rob at hobby meetups (non-card-show venues)
- **Atoms:** `F4` `surveillance-at-event` `post-venue-isolation-attack`
- **Scenario:** Card-show pattern extends to regional informal meetups (coffee shops, mall atriums, parking lots) where no venue security exists.
- **Watch for:** "Meet here instead" flips; offered meetup at a place other than buyer-specified.

## P14 — Replica-case rings reach major auction houses
- **Atoms:** `A3` `UV-feature-mimicry` `auction-laundering`
- **Scenario:** European replica-case rings route high-quality fakes through traditional vintage auction houses whose authentication relies on label appearance, not pre-encapsulation substrate check.
- **Watch for:** Vintage slabs of "newly discovered" provenance from European consignors; require substrate analysis in addition to label UV check.

## P15 — AI voice-clone coordinated disputes
- **Atoms:** `G2` `social-engineering` `coordinated-fake-bidding`
- **Scenario:** AI voice-clones of known high-feedback buyer accounts used to coordinate dispute-filing campaigns against specific sellers.
- **Watch for:** Sudden cluster of disputes from otherwise-trusted accounts against one seller; platform fraud teams should cross-check voice-AI flag on support calls.

## P16 — Pre-order ghost migrates to "storefront" accounts on large platforms
- **Atoms:** `C1` `pre-order-exploit` `persona-of-legitimacy`
- **Scenario:** Individual-ghost pre-order pattern moves behind fake "storefront" accounts on Fanatics Collect / Topps Vault / Whatnot shops, exploiting platform trust halo.
- **Watch for:** New-storefront accounts listing pre-orders for products 6+ months from release.

## P17 — Rip-and-Ship migrates to TikTok Live
- **Atoms:** `C7` `live-event-format` `rigged-randomization` `tiktok-live`
- **Scenario:** Rig a rip by having off-camera confederate swap cards when stream cuts or during "technical difficulty."
- **Watch for:** Streams with frequent cuts, audio dropouts, camera angle changes mid-rip.

## P18 — Employee-funds-diversion on e-commerce buyer accounts
- **Atoms:** `I2` `employer-funds-diversion` `cards-as-laundering-asset`
- **Scenario:** Embezzler uses corporate Amazon/eBay/Whatnot buyer account to funnel cards to personal reseller address. Escalation beyond the 2025 Iowa case's gift-card pattern.
- **Watch for:** Sudden spike in business-account purchases of high-value sealed product shipping to residential addresses.

---

# PART 4 — ACTIVE WATCH LIST (user-facing)

Short, punchy alerts. Each = one sentence symptom + one sentence consequence + action. These feed the wizard result screens and the public grailiso.com scam-awareness page.

| # | If you see… | Because… | Action |
|---|-------------|----------|--------|
| 1 | Seller asking for Venmo, Zelle, CashApp, or PayPal F&F | Zero buyer protection — you cannot recover if it goes bad | Refuse; use only escrowed platforms |
| 2 | Facebook Marketplace local-pickup at extreme discount, urgent meetup push | Meetup-ambush robberies are documented and active | Meet only at a police-station "safe exchange zone" or cancel |
| 3 | Graded slab you can't verify on the grader's cert lookup | No matching cert = counterfeit label | Do not buy; report listing |
| 4 | Slab label shows weak or patchy UV watermark under 395nm | UV-feature mimicry is the tell | Reject; cross-check with grader |
| 5 | Slab's inner card brackets are sharp-angled not slightly rounded | Indicates acetone-strip reseal tampering | Do not buy even if label looks perfect |
| 6 | Seller films packaging but won't show carrier drop-off | Coordinated non-delivery pattern | Require carrier-side scan (USPS Informed Delivery) |
| 7 | Sealed booster case with off-color or thickness-inconsistent thermal label | Thermal-label reprint is a documented method | Inspect factory seal at seam; buy only from authorized distributor |
| 8 | "Rip and ship" event without serial code verification or buyer choice of pack | Rigged-pull fraud is common in this format | Walk |
| 9 | Influencer offers pre-sale for unreleased set via DM / Venmo | Pre-order ghost wave is active at scale | Pay only via platform with chargeback-able credit card |
| 10 | Out-of-state buyer paying cash-on-credit in person at card show | Fake-ID chargeback scam actively targeting shops | Record HD video of transaction + ID; keep records 90+ days |
| 11 | "Private listing" or blurred cert numbers on auction | Auction-house shill-bidding pattern | Skip the listing |
| 12 | Vending-service URL that doesn't match their known social-media-linked domain | Legitimate-service impersonation via SEO | Verify via known social account before payment |
| 13 | Buyer offers discount for wire / crypto | Non-reversible payment is the scammer's goal | Do not accept — use credit-card-on-platform only |
| 14 | Pack-rip video cuts or skips frames before reveal | Rigged-pull concealment | Treat all pulls as unverified |
| 15 | Cert number returns "retired" or "invalid" on grader site | Label is forged or data harvested from old cert | Do not buy |
| 16 | Meetup venue flips from buyer's choice to seller's choice last-minute | Isolation tactic for ambush | Cancel and report |
| 17 | Seller account is <30 days old listing multiple 4-figure cards | New-account high-value pattern matches fraud wave | Wait, avoid, or require extreme escrow |
| 18 | Sealed box weight differs meaningfully from spec | Possible pre-opened / pack-weighed | Request weigh before purchase |
| 19 | Instant purchase from new account, billing-ship address mismatch | Stolen-CC sniping bot pattern | Sellers: require manual review above $500 |
| 20 | Cluster of disputes from multiple high-feedback accounts against one seller in 24h | AI-voice-clone coordinated dispute flag | Sellers: escalate to platform fraud team immediately |
| 21 | Buyer requests split payment (part platform, part Venmo) | Circumventing buyer protection to enable off-platform scam | Refuse entire transaction |
| 22 | Cashier doesn't show receipt listing your specific SKU | Barcode-swap or decline-misread happening to you | Do not leave until SKU matches |
| 23 | "Newly discovered vintage" slab with no enrollment history + European consignor | Replica-case laundering via auction houses | Require substrate-level re-authentication |
| 24 | Business-account purchases of sealed product shipping to a residential address | Employee funds-diversion pattern | Finance teams: flag for expense-report audit |
| 25 | Any grader offering "buyback" without published cert-change audit log | Internal cert-flip arbitrage is structurally possible | Prefer graders with transparent audit trails |

---

# APPENDIX A — Wizard Data Flow

1. **User enters the wizard.** Q1 branches on payment state (money-moved yes/no) and role (buyer/seller).
2. **Each answer prunes scam candidates** by matching atoms. Wizard keeps a running "possible-scams" set.
3. **When the set narrows to 1 (or a small tied group), wizard declares the identified scam.**
4. **Wizard pulls the matching Recovery Playbook cell** keyed by scam × platform × payment × days-since-discovery.
5. **Result screen shows:**
   - The identified scam (from Part 1 entry)
   - Next-48-hour recovery steps (cited, dated)
   - Evidence checklist to preserve
   - Reporting agencies to contact (platform, payment processor, IC3/USPIS/FTC/state AG)
   - "How grail2.0 would have prevented this" (identity/provenance mapping)
6. **Share button** emits an Open Graph card summarizing the scam type for Reddit/Twitter — grassroots distribution.

---

# APPENDIX B — Source Verification & Disclaimer Protocol

**Required before any recovery-playbook content ships to public:**
- Each recovery cell cites the source URL + "last verified YYYY-MM-DD."
- Every cited platform policy is re-verified quarterly (platforms change terms silently).
- Legal disclaimer: "General guidance compiled from public sources. Platforms change policy; deadlines may differ. This is not legal advice; consult an attorney for high-dollar losses."
- Content warning on sensitive content: no step-by-step replication of scam methods; descriptive only.

**This catalog's sourcing:**
- Fraud-scraper corpus at `research/fraud/results/`
- Public 2025–2026 news, DOJ releases, court records, police advisories, collector community reports
- Case references anonymized per the "techniques not people" principle — no defendant names used

**Catalog update protocol:**
- Re-run fraud scraper monthly with refreshed queries (add RECOVERY / DISPUTE PATHS block)
- Add new cases to Part 1 preserving atom tagging
- Mix-and-match (Part 3) reviewed after each case batch — new atoms may unlock new predictions
- Active Watch List (Part 4) rotated quarterly; retire items that have been platform-remediated

---

_End of catalog v2026-04-20._
