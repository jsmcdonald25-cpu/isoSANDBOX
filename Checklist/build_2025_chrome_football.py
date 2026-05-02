"""Build 2025 Topps Chrome Football import CSV from raw checklist text.

Source: Checklist/2025_Chrome_Football_Checklist.txt
Output: Checklist/2025_topps_chrome_football_import.csv

Matches table `2025_topps_chrome_football` columns:
  card_number, player, team, category, insert_name, is_rookie
(year/sport/set_name use table defaults.)
"""
import csv
import re
from pathlib import Path

SRC = Path(__file__).parent / "2025_Chrome_Football_Checklist.txt"
OUT = Path(__file__).parent / "2025_topps_chrome_football_import.csv"

# Top-level section -> category column value
SECTION_TO_CATEGORY = {
    "BASE": "Base",
    "INSERT": "Insert",
    "AUTOGRAPH": "Auto",
    "RELIC": "Relic",
    "AUTOGRAPH RELIC": "Auto Relic",
}

# Subcategories that are pure base (no insert_name needed)
PURE_BASE_SUBCATS = {"BASE CARDS", "ROOKIES"}

# Map source ALL-CAPS subcategory -> insert_name (title case, Topps-friendly)
INSERT_NAME_OVERRIDES = {
    "BASE CARDS TEAM CAMO VARIATION": "Team Camo Variation",
    "ROOKIES TEAM CAMO VARIATION": "Team Camo Variation",
    "BASE CARDS LIGHTBOARD LOGO VARIATION": "Lightboard Logo Variation",
    "BASE CARDS IMAGE VARIATION": "Image Variation",
    "ROOKIES IMAGE VARIATION": "Image Variation",
    "CHROME BASE ETCH VARIATION": "Chrome Etch Variation",
    "CHROME ROOKIES ETCH VARIATION": "Chrome Etch Variation",
    "BASE CARDS AUTOGRAPH VARIATION": "Base Autograph",
    "ROOKIES AUTOGRAPH VARIATION": "Rookie Autograph",
    "ROOKIE AUTOGRAPHS VARIATION": "Rookie Autograph Variation",
    "1975 TOPPS": "1975 Topps",
    "1990 TOPPS FOOTBALL AUTOGRAPHS": "1990 Topps Football Autographs",
    "FUTURE STARS": "Future Stars",
    "POWER PLAYERS": "Power Players",
    "LEGENDS OF THE GRIDIRON": "Legends of the Gridiron",
    "FORTUNE 15": "Fortune 15",
    "ALL CHROME TEAM": "All Chrome Team",
    "CHROME RADIATING ROOKIES": "Chrome Radiating Rookies",
    "URBAN LEGENDS": "Urban Legends",
    "HELIX": "Helix",
    "SHADOW ETCH": "Shadow Etch",
    "GAME GENIES": "Game Genies",
    "KAIJU": "Kaiju",
    "LETS GO": "Let's Go",
    "ULTRA VIOLET": "Ultra Violet",
    "LIGHTNING LEADERS": "Lightning Leaders",
    "FANATICAL": "Fanatical",
    "TECMO": "Tecmo",
    "DUAL AUTOGRAPHS": "Dual Autographs",
    "FUTURE STARS AUTOGRAPHS": "Future Stars Autographs",
    "CHROMOGRAPHS": "Chromographs",
    "CHROME LEGENDS AUTOGRAPHS": "Chrome Legends Autographs",
    "HALL OF CHROME AUTOGRAPHS": "Hall of Chrome Autographs",
    "TECMO AUTOGRAPHS": "Tecmo Autographs",
    "TOPPS CHROME ROOKIE RELICS": "Topps Chrome Rookie Relics",
    "FIRST YEAR FABRIC": "First Year Fabric",
    "NFL HONORS GOLD SHIELD RELICS": "NFL Honors Gold Shield Relics",
    "FANATICS AUTHENTICS REDEMPTION CARDS": "Fanatics Authentics Redemption",
    "TOPPS CHROME ROOKIE PATCH AUTOGRAPHS": "Topps Chrome Rookie Patch Autographs",
    "ROOKIE PREM1ERE PATCH AUTOGRAPHS": "Rookie Premiere Patch Autographs",
    "NFL HONORS GOLD SHIELD AUTOGRAPHS": "NFL Honors Gold Shield Autographs",
}

# All category headers in the source. Used to detect which lines are headers vs cards.
CATEGORIES = {
    "BASE CARDS",
    "ROOKIES",
    "BASE CARDS TEAM CAMO VARIATION",
    "ROOKIES TEAM CAMO VARIATION",
    "BASE CARDS LIGHTBOARD LOGO VARIATION",
    "FUTURE STARS",
    "1975 TOPPS",
    "POWER PLAYERS",
    "LEGENDS OF THE GRIDIRON",
    "FORTUNE 15",
    "ALL CHROME TEAM",
    "CHROME RADIATING ROOKIES",
    "URBAN LEGENDS",
    "HELIX",
    "CHROME BASE ETCH VARIATION",
    "CHROME ROOKIES ETCH VARIATION",
    "BASE CARDS IMAGE VARIATION",
    "ROOKIES IMAGE VARIATION",
    "SHADOW ETCH",
    "GAME GENIES",
    "KAIJU",
    "LETS GO",
    "ULTRA VIOLET",
    "LIGHTNING LEADERS",
    "FANATICAL",
    "TECMO",
    "BASE CARDS AUTOGRAPH VARIATION",
    "ROOKIES AUTOGRAPH VARIATION",
    "1990 TOPPS FOOTBALL AUTOGRAPHS",
    "DUAL AUTOGRAPHS",
    "FUTURE STARS AUTOGRAPHS",
    "CHROMOGRAPHS",
    "CHROME LEGENDS AUTOGRAPHS",
    "HALL OF CHROME AUTOGRAPHS",
    "ROOKIE AUTOGRAPHS VARIATION",
    "TECMO AUTOGRAPHS",
    "TOPPS CHROME ROOKIE RELICS",
    "FIRST YEAR FABRIC",
    "NFL HONORS GOLD SHIELD RELICS",
    "FANATICS AUTHENTICS REDEMPTION CARDS",
    "TOPPS CHROME ROOKIE PATCH AUTOGRAPHS",
    "ROOKIE PREM1ERE PATCH AUTOGRAPHS",
    "NFL HONORS GOLD SHIELD AUTOGRAPHS",
}

# Greedy-match teams from end of line. Includes historical teams that appear in Legends section.
TEAMS = [
    "Arizona Cardinals", "Atlanta Falcons", "Baltimore Ravens", "Buffalo Bills",
    "Carolina Panthers", "Chicago Bears", "Cincinnati Bengals", "Cleveland Browns",
    "Dallas Cowboys", "Denver Broncos", "Detroit Lions", "Green Bay Packers",
    "Houston Texans", "Indianapolis Colts", "Jacksonville Jaguars", "Kansas City Chiefs",
    "Las Vegas Raiders", "Los Angeles Chargers", "Los Angeles Rams", "Miami Dolphins",
    "Minnesota Vikings", "New England Patriots", "New Orleans Saints", "New York Giants",
    "New York Jets", "Philadelphia Eagles", "Pittsburgh Steelers", "San Francisco 49ers",
    "Seattle Seahawks", "Tampa Bay Buccaneers", "Tennessee Titans", "Washington Commanders",
    # Historical / Legends
    "Houston Oilers", "Los Angeles Raiders", "Oakland Raiders", "San Diego Chargers",
    "St. Louis Rams", "Washington Redskins",
]

# Card-number pattern: starts a line, no spaces, like "1", "300", "FS-1", "1975-12", "RPPA-MGRE"
CARD_NUM_RE = re.compile(r"^([A-Za-z0-9]+(?:-[A-Za-z0-9]+)?)\s+(.+)$")

DISCLAIMER_TOKENS = ("Checklists provided by Topps", "product at the time of production")


def split_player_team(rest: str):
    """Given 'Player Name Team Name [Rookie]' return (player, team)."""
    s = rest.strip()
    is_rookie = s.endswith(" Rookie")
    if is_rookie:
        s = s[: -len(" Rookie")].rstrip()
    for team in TEAMS:
        suffix = " " + team
        if s.endswith(suffix):
            player = s[: -len(suffix)].strip()
            return player, team
        if s == team:
            return "", team
    return s, ""


def main():
    rows = []
    current_section = None     # BASE / INSERT / AUTOGRAPH / RELIC / AUTOGRAPH RELIC
    current_subcat = None      # e.g., BASE CARDS, FUTURE STARS, etc.
    fanatics_counter = 0

    with SRC.open("r", encoding="utf-8") as f:
        for raw in f:
            line = raw.strip()
            if not line:
                continue
            if any(tok in line for tok in DISCLAIMER_TOKENS):
                continue
            if line == SRC.stem:
                continue
            if line in SECTION_TO_CATEGORY:
                current_section = line
                continue
            if line in CATEGORIES:
                current_subcat = line
                fanatics_counter = 0
                continue
            if current_subcat is None:
                continue

            category = SECTION_TO_CATEGORY.get(current_section, "Base")
            if current_subcat in PURE_BASE_SUBCATS:
                insert_name = ""
            else:
                insert_name = INSERT_NAME_OVERRIDES.get(current_subcat, current_subcat.title())
            is_rookie = "true" if "Rookie" in line.split() else "false"

            # Fanatics redemption rows have no card number prefix
            if current_subcat == "FANATICS AUTHENTICS REDEMPTION CARDS":
                fanatics_counter += 1
                player, team = split_player_team(line)
                rows.append({
                    "card_number": f"FA-{fanatics_counter}",
                    "player": player,
                    "team": team,
                    "category": category,
                    "insert_name": insert_name,
                    "is_rookie": is_rookie,
                })
                continue

            m = CARD_NUM_RE.match(line)
            if not m:
                print(f"SKIP (no card#): [{current_subcat}] {line}")
                continue
            card_num, rest = m.group(1), m.group(2)
            player, team = split_player_team(rest)
            if not team:
                print(f"WARN (no team): [{current_subcat}] {line}")
            rows.append({
                "card_number": card_num,
                "player": player,
                "team": team,
                "category": category,
                "insert_name": insert_name,
                "is_rookie": is_rookie,
            })

    fields = ["card_number", "player", "team", "category", "insert_name", "is_rookie"]
    with OUT.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fields)
        w.writeheader()
        for r in rows:
            w.writerow(r)

    print(f"\nWrote {len(rows)} rows -> {OUT}")
    cats = {}
    for r in rows:
        key = (r["category"], r["insert_name"] or "(base)")
        cats[key] = cats.get(key, 0) + 1
    print("\nRow counts per category / insert_name:")
    for (cat, ins), v in sorted(cats.items()):
        print(f"  {v:>4}  {cat:<10} {ins}")


if __name__ == "__main__":
    main()
