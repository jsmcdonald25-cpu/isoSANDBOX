-- fix_shop_coords.sql
-- Generated from card_shops_import.csv
-- 1255 UPDATE statements
-- Resolution: city=254, state=879, country=121, unresolved=0
-- Only updates shops where lat IS NULL or lat = 0 (safe to re-run)

BEGIN;

-- Exact fix: Underdog Collectibles, Knoxville TN
UPDATE card_shops SET lat = 35.9606, lng = -83.9207 WHERE name = 'UNDERDOG COLLECTIBLES' AND state = 'TN';
UPDATE card_shops SET lat = 52.378134, lng = -110.716631 WHERE name = 'CompuSoft and The Game Store – Electronics store in Red Deer, ABThe Game Store' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: RED DEER, AB
UPDATE card_shops SET lat = 52.378134, lng = -110.716631 WHERE name = 'EB Games Canada' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: RED DEER, AB
UPDATE card_shops SET lat = 49.682809, lng = -112.804236 WHERE name = 'Games Galore and the Billiard Store' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: LETHBRIDGE, AB
UPDATE card_shops SET lat = 52.378134, lng = -110.716631 WHERE name = 'Holmestead Sports Cards & Collectibles Store' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: RED DEER, AB
UPDATE card_shops SET lat = 49.682809, lng = -112.804236 WHERE name = 'LethbridgeBRZ e-Gift Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: LETHBRIDGE, AB
UPDATE card_shops SET lat = 49.682809, lng = -112.804236 WHERE name = 'Showcase Comics & Hobbies Ltd., Comics, Collectibles, RC, Boardgames -...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: LETHBRIDGE, AB
UPDATE card_shops SET lat = 52.378134, lng = -110.716631 WHERE name = 'SportsCards& Memorabilia StoresinRedDeer,AB-AlbertaLocal' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: RED DEER, AB
UPDATE card_shops SET lat = 49.682809, lng = -112.804236 WHERE name = 'Treasure Chest Games – Store in Lethbridge, AB' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: LETHBRIDGE, AB
UPDATE card_shops SET lat = 49.269384, lng = -123.071405 WHERE name = 'AASportscards Hockey Cards Vancouver' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: VANCOUVER, BC
UPDATE card_shops SET lat = 50.184836, lng = -120.182342 WHERE name = 'Comics Scene Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SURREY, BC
UPDATE card_shops SET lat = 50.184836, lng = -120.182342 WHERE name = 'Delaware Sports Card Stores' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NEWARK, BC
UPDATE card_shops SET lat = 50.184836, lng = -120.182342 WHERE name = 'Game Suppliers in Victoria, BC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: VICTORIA, BC
UPDATE card_shops SET lat = 49.269384, lng = -123.071405 WHERE name = 'Godfather Comics Vancouver' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: VANCOUVER, BC
UPDATE card_shops SET lat = 49.222127, lng = -122.993579 WHERE name = 'Metropolis Comics and Toys' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: BURNABY, BC
UPDATE card_shops SET lat = 49.192831, lng = -123.991667 WHERE name = 'Sports Card Alley – Store in Nanaimo, BC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: NANAIMO, BC
UPDATE card_shops SET lat = 49.222127, lng = -122.993579 WHERE name = 'TazmanianComicConnection,BurnabyBC| Ourbis' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: BURNABY, BC
UPDATE card_shops SET lat = 49.269384, lng = -123.071405 WHERE name = 'Vesperia Manga & Comics' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: VANCOUVER, BC
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = '8 Bit of Awesome in Brandon, MB R7A 4G6' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: BRANDON, MB
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'Comic Book Shop in Winnipeg, MB' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: WINNIPEG, MB
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'I Want That Stuff' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: BRANDON, MB
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'Inner Hero Collectibles in Brandon, MB R7B 0T4' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: BRANDON, MB
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'Joe''s Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: BRANDON, MB
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'Joe''s Sports Cards Brandon, 2047299388, Miscellaneous Retail ...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: BRANDON, MB
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'Joe''s Sports Cards Brandon, 2047299388, Miscellaneous Retail Stores ...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: BRANDON, MB
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'THREE STARS SPORTSCARDS (LITTLE CANADA)' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: LITTLE CANADA, MN
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'Battleground Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: FREDERICTON, NB
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'Card Rack' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: FREDERICTON, NB
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'Card Rack in Fredericton, NB E3A 8V4' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: FREDERICTON, NB
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'D&M Sports – DM Sports' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: HALIFAX, NB
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'Game Zilla – Store in Fredericton, NB' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: FREDERICTON, NB
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'GameZilla Fredericton' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: FREDERICTON, NB
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'Heroes'' Beacon Comics & Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: SAINT JOHN, NB
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'Heroes'' Beacon Comics & Games in Saint John, NB E2L 2H3' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: SAINT JOHN, NB
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'Heroes'' Beacon Comics & Games – A retail store in Saint John ...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: SAINT JOHN, NB
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'Moncton Sports Cards Moncton, 5068556661, Miscellaneous ...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: MONCTON, NB
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'Trading Card Warehouse Inc.' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: MONCTON, NB
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'Carlton Cards on Topsail Road' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: ST JOHNS, NL
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'Game Exchange' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: ST JOHNS, NL
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'Maverick Sports & Collectables in St. John''s, NL A1C 1B7' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: ST JOHNS, NL
UPDATE card_shops SET lat = 44.673085, lng = -63.531456 WHERE name = 'D&M Sports' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MONCTON, NS
UPDATE card_shops SET lat = 44.673085, lng = -63.531456 WHERE name = 'East Coast Trading Card Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HALIFAX, NS
UPDATE card_shops SET lat = 44.673085, lng = -63.531456 WHERE name = 'Light The Lamp Sportscards in Sydney, NS B1P 1E1' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SYDNEY, NS
UPDATE card_shops SET lat = 44.673085, lng = -63.531456 WHERE name = 'Strictly Singles Sportscards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HALIFAX, NS
UPDATE card_shops SET lat = 44.673085, lng = -63.531456 WHERE name = 'The Local NPC Games & Comics' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SYDNEY, NS
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = '807 Cards & Collectibles in Thunder Bay, ON P7B 1C4' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: THUNDER BAY, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Action Packed Comics & Games in Kingston, ON K7L 1G2' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: KINGSTON, ON
UPDATE card_shops SET lat = 43.00345, lng = -81.196674 WHERE name = 'Beyond the Pond Sports Cards and Collectables in London, ON N6H 5L6 ...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: LONDON, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Big B Comics in Barrie, ON L4N 3K4' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BARRIE, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Blue Ox Games, LLC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GREENVILLE, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Border City Comics in Windsor, ON N8W 1K6' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WINDSOR, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Burdin''s Comics Hamilton ON' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HAMILTON, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Burlington Mall' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BURLINGTON, ON
UPDATE card_shops SET lat = 43.4593, lng = -80.464566 WHERE name = 'CloutsnChara Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: KITCHENER, ON
UPDATE card_shops SET lat = 43.4593, lng = -80.464566 WHERE name = 'CloutsnChara Sports Cards in Kitchener, ON N2H 5G3' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: KITCHENER, ON
UPDATE card_shops SET lat = 43.730519, lng = -79.790247 WHERE name = 'Comic Warehouse in Brampton, ON L6T 4P7' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: BRAMPTON, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Comics North in Sudbury, ON' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SUDBURY, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Comics North in Sudbury, ON P3C 1T5' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SUDBURY, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Contact Dandy Deals 2nd HandStoreTopekaKS| 785-250-4676' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: TOPEKA, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Cookeville Antique Mall' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: COOKEVILLE, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Custom StationeryCards& Sets' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LARAMIE, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Diadem Cards & Hobbies in Sudbury, ON P3E 1G1' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SUDBURY, ON
UPDATE card_shops SET lat = 43.730519, lng = -79.790247 WHERE name = 'Doe''s Cards in Brampton, ON L7A 0R3' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: BRAMPTON, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Dolly''s Cards & Collectibles Niagara' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ST CATHARINES, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Doug Laurie Sports' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BARRIE, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Doug Laurie Sports in Barrie, ON L4M 5A1' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BARRIE, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Elite Cardboard Gaming' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: DURHAM, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Great Canadian Games & Hobbies' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SUDBURY, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Great Canadian Games & Hobbies in Sudbury, ON P3A 1Z6' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SUDBURY, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Great Canadian Games and Hobbies' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SUDBURY, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Helou’s Sports Card and Collectibles – Downtown Windsor BIA' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WINDSOR, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'High Score Gamez in St. Catharines, ON L2P 1M5' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ST CATHARINES, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'JPL Sports Cards and Collectibles in Burlington, ON L7L 0A3' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BURLINGTON, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Laughing Crow Collectibles (@laughingcrowcollectibles ...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MODESTO, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'MK Cards in Cambridge, ON N3C 2A8' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CAMBRIDGE, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Martin Sports Cards Guelph, 5198363061, Miscellaneous Retail ...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GUELPH, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Mecha Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ST CATHARINES, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Mostly Comics in St. Catharines, ON L2R 3N1' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ST CATHARINES, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Mulligans Trading Cards & Collectibles (@mulliganstcg) • Instagram ...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: RICHMOND, ON
UPDATE card_shops SET lat = 43.00345, lng = -81.196674 WHERE name = 'PLAYERS CARDS AND COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: LONDON, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Paper Heroes' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WINDSOR, ON
UPDATE card_shops SET lat = 43.00345, lng = -81.196674 WHERE name = 'Premium Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: LONDON, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Retro Rocket Comics in Cambridge, ON N1R 1V6' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CAMBRIDGE, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Ryan Kennedy (@arcsportcards) • Instagram photos and videos' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CONCORD, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Store Locations' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: VAUGHAN, ON
UPDATE card_shops SET lat = 43.730519, lng = -79.790247 WHERE name = 'Store Locations:' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: BRAMPTON, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Tampa Card Shop (@tampacardshop) • Instagram photos and videos' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: TAMPA, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'The Comic Doctor' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: OSHAWA, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'The Trading Post in Guelph, ON N1H 3K8' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GUELPH, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Thunder Games & Gifts – Store in Thunder Bay, ON' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: THUNDER BAY, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'University ofTorontoBookstoreThe Review |TorontoReads @ U of...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: TORONTO, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Untouchables Sports Cards & Gaming in Mississauga, ON L5A 3Y1' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MISSISSAUGA, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Upper OakvilleCardShop— GreetingCardsinMississauga, Ontario...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MISSISSAUGA, ON
UPDATE card_shops SET lat = 43.730519, lng = -79.790247 WHERE name = 'We Got Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: BRAMPTON, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Where Is Rainbow on Markham Located' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SASKATOON, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'Woodbridge Heroes Comics' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: VAUGHAN, ON
UPDATE card_shops SET lat = 43.795028, lng = -79.75474 WHERE name = 'poe.com/poeknowledge/1512928000344312' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WINNIPEG, ON
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'Backmandy Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: CHARLOTTETOWN, PE
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'Exor Games in Charlottetown, PE C1A 2V6' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: CHARLOTTETOWN, PE
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'Lighting Bolt Comics Charlottetown, 9028944000, Book Stores, 99 ...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: CHARLOTTETOWN, PE
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'PSA Dealer: Morningside LLC dba Sports Shop' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: NAPERVILLE, PE
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'Sherwood Sports Cards Charlottetown, 9026291842, Miscellaneous Retail ...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: CHARLOTTETOWN, PE
UPDATE card_shops SET lat = 45.65298, lng = -71.19851 WHERE name = 'CAPITAL SPORTS CARDS -' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: QUEBEC CITY, QC
UPDATE card_shops SET lat = 45.65298, lng = -71.19851 WHERE name = 'Carl & Associates Trading Cards in Trois-Rivieres, QC G8Z 4E4' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: TROIS-RIVIERES, QC
UPDATE card_shops SET lat = 45.65298, lng = -71.19851 WHERE name = 'Cartes Sportives De La Mauricie Enr. Trois-Rivieres, 8193723867, Sports ...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: TROIS-RIVIERES, QC
UPDATE card_shops SET lat = 45.65298, lng = -71.19851 WHERE name = 'Cartes Sportives Jumbobear Laval, 4506643446, Gift, 2987 boul de la ...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LAVAL, QC
UPDATE card_shops SET lat = 45.65298, lng = -71.19851 WHERE name = 'EB Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: QUEBEC CITY, QC
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'B J''s Collectors Center Regina, 3067578285, Sports Cards & Memorabilia ...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: REGINA, SK
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'Cowtown e-GiftCards| AnyCardCanada' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: SASKATOON, SK
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'Queen City Sports Cards in Regina, SK S4N 6L4' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: REGINA, SK
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'RAD Cards and Collectibles, A7 3510 8th Street East, Saskatoon, SK' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: SASKATOON, SK
UPDATE card_shops SET lat = 56.1304, lng = -106.3468 WHERE name = 'Re-Play Games – Store in Regina, SK' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: REGINA, SK
UPDATE card_shops SET lat = 60.720292, lng = -135.054726 WHERE name = 'A #1 Cards, Comics and Collectables' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ANCHORAGE, AK
UPDATE card_shops SET lat = 60.720292, lng = -135.054726 WHERE name = 'BOSCO''S' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ANCHORAGE, AK
UPDATE card_shops SET lat = 60.720292, lng = -135.054726 WHERE name = 'Base: Orruk Flesh (12ML) 21-56' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ANCHORAGE, AK
UPDATE card_shops SET lat = 60.720292, lng = -135.054726 WHERE name = 'Collector''s Hideaway' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: JUNEAU, AK
UPDATE card_shops SET lat = 60.720292, lng = -135.054726 WHERE name = 'DON''S SPORTSCARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ANCHORAGE, AK
UPDATE card_shops SET lat = 60.720292, lng = -135.054726 WHERE name = 'KT Collectible Trading Cards & Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ANCHORAGE, AK
UPDATE card_shops SET lat = 60.720292, lng = -135.054726 WHERE name = 'Ork Morkanaut 50-19' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ANCHORAGE, AK
UPDATE card_shops SET lat = 60.720292, lng = -135.054726 WHERE name = 'The ComicShop-Fairbanks,AK| SportsCard-Stores.Com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FAIRBANKS, AK
UPDATE card_shops SET lat = 33.936229, lng = -86.36334 WHERE name = 'Al''s Comic Shop' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: STOCKTON, AL
UPDATE card_shops SET lat = 33.936229, lng = -86.36334 WHERE name = 'BIG HIT SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SPANISH FORT, AL
UPDATE card_shops SET lat = 33.936229, lng = -86.36334 WHERE name = 'CULLMAN SPORTSCARDS & FUN SHOP' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CULLMAN, AL
UPDATE card_shops SET lat = 33.936229, lng = -86.36334 WHERE name = 'Collectible, Video Games, Consoles and More – Play and Talk' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GULFPORT, AL
UPDATE card_shops SET lat = 33.936229, lng = -86.36334 WHERE name = 'Comics and Cards Trading Post' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MONTGOMERY, AL
UPDATE card_shops SET lat = 33.936229, lng = -86.36334 WHERE name = 'Jags Corner Trading Cards & Sports Memorabilia' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MOBILE, AL
UPDATE card_shops SET lat = 33.936229, lng = -86.36334 WHERE name = 'Jags Corner Trading Cards & Sports Memorabilia – Mobile ...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MOBILE, AL
UPDATE card_shops SET lat = 33.936229, lng = -86.36334 WHERE name = 'M and R Ball Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MOBILE, AL
UPDATE card_shops SET lat = 33.936229, lng = -86.36334 WHERE name = 'Oklahoma Sports Card Stores' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: OKLAHOMA CITY, AL
UPDATE card_shops SET lat = 33.936229, lng = -86.36334 WHERE name = 'One Up TCG' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: TUSCALOOSA, AL
UPDATE card_shops SET lat = 33.936229, lng = -86.36334 WHERE name = 'Tennessee' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: OAK RIDGE, AL
UPDATE card_shops SET lat = 33.936229, lng = -86.36334 WHERE name = 'The G.O.A.T. Collectibles & Antiques' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BIRMINGHAM, AL
UPDATE card_shops SET lat = 33.936229, lng = -86.36334 WHERE name = 'UDLR TCG & Gaming' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MOBILE, AL
UPDATE card_shops SET lat = 33.936229, lng = -86.36334 WHERE name = 'Vermont' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BURLINGTON, AL
UPDATE card_shops SET lat = 36.176921, lng = -94.191249 WHERE name = 'CLEVE''S SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SPRINGDALE, AR
UPDATE card_shops SET lat = 36.176921, lng = -94.191249 WHERE name = 'Cleve''s Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SPRINGDALE, AR
UPDATE card_shops SET lat = 36.176921, lng = -94.191249 WHERE name = 'Cleve''s Sports Cards in Springdale, AR 72764' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SPRINGDALE, AR
UPDATE card_shops SET lat = 36.176921, lng = -94.191249 WHERE name = 'Cleve''s Sports Cards, Springdale AR' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SPRINGDALE, AR
UPDATE card_shops SET lat = 35.343279, lng = -94.425968 WHERE name = 'DICK''S SPORTING GOODS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: FORT SMITH, AR
UPDATE card_shops SET lat = 34.744002, lng = -92.406735 WHERE name = 'GAMEDAY SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: LITTLE ROCK, AR
UPDATE card_shops SET lat = 34.744002, lng = -92.406735 WHERE name = 'Hobbytown Usa Little Rock' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: LITTLE ROCK, AR
UPDATE card_shops SET lat = 35.212746, lng = -93.354297 WHERE name = 'Jonesboro Sports Cards and Memorabilia' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: JONESBORO, AR
UPDATE card_shops SET lat = 35.212746, lng = -93.354297 WHERE name = 'Jonesboro Sports Cards and Memorabilia – Jonesboro, Arkansas ...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: JONESBORO, AR
UPDATE card_shops SET lat = 35.212746, lng = -93.354297 WHERE name = 'LEFTY''S SPORTS MEMORABILIA LLC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BURLINGAME, AR
UPDATE card_shops SET lat = 35.212746, lng = -93.354297 WHERE name = 'NorseGoat cards and collectible store' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: JONESBORO, AR
UPDATE card_shops SET lat = 36.176921, lng = -94.191249 WHERE name = 'Storage Unit Auction in Springdale, AR at Springdale Self' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SPRINGDALE, AR
UPDATE card_shops SET lat = 34.744002, lng = -92.406735 WHERE name = '[Arkansas Storage Centers' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: LITTLE ROCK, AR
UPDATE card_shops SET lat = 33.56336, lng = -111.83778 WHERE name = '698 E Route 66 Flagstaff Az 928-774-0035' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FLAGSTAFF, AZ
UPDATE card_shops SET lat = 33.714524, lng = -112.111818 WHERE name = 'AZ SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: PHOENIX, AZ
UPDATE card_shops SET lat = 33.56336, lng = -111.83778 WHERE name = 'Amazing Discoveries' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: TUCSON, AZ
UPDATE card_shops SET lat = 33.714524, lng = -112.111818 WHERE name = 'BOXSEAT COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: PHOENIX, AZ
UPDATE card_shops SET lat = 33.56336, lng = -111.83778 WHERE name = 'CARD KINGS SPORTS CARDS & MEMORABILIA' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: TUCSON, AZ
UPDATE card_shops SET lat = 33.56336, lng = -111.83778 WHERE name = 'Contact' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: TUCSON, AZ
UPDATE card_shops SET lat = 33.714524, lng = -112.111818 WHERE name = 'DNA CARDS & COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: PHOENIX, AZ
UPDATE card_shops SET lat = 33.56336, lng = -111.83778 WHERE name = 'EARTHBOUND TRADING CO.' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SCOTTSDALE, AZ
UPDATE card_shops SET lat = 33.56336, lng = -111.83778 WHERE name = 'FlagstaffBaseballCardShop| SportsCardForum' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FLAGSTAFF, AZ
UPDATE card_shops SET lat = 33.56336, lng = -111.83778 WHERE name = 'HOT CORNER SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MESA, AZ
UPDATE card_shops SET lat = 33.56336, lng = -111.83778 WHERE name = 'IRL Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: TUCSON, AZ
UPDATE card_shops SET lat = 33.714524, lng = -112.111818 WHERE name = 'Let’s Find Pokemon! Special Complete Edition – GBS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: PHOENIX, AZ
UPDATE card_shops SET lat = 33.56336, lng = -111.83778 WHERE name = 'Our Showroom' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FLAGSTAFF, AZ
UPDATE card_shops SET lat = 33.56336, lng = -111.83778 WHERE name = 'PHOENIX SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GLENDALE, AZ
UPDATE card_shops SET lat = 33.56336, lng = -111.83778 WHERE name = 'PSA Dealer: Scottsdale Baseball Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SCOTTSDALE, AZ
UPDATE card_shops SET lat = 33.56336, lng = -111.83778 WHERE name = 'RIP VALLEY' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: , AZ
UPDATE card_shops SET lat = 33.56336, lng = -111.83778 WHERE name = 'SCOTTSDALE TRADING POST' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SCOTTSDALE, AZ
UPDATE card_shops SET lat = 33.56336, lng = -111.83778 WHERE name = 'SHOWTIME' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: TEMPE, AZ
UPDATE card_shops SET lat = 33.56336, lng = -111.83778 WHERE name = 'THE MONSTER CARD SHOP' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: QUEEN CREEK, AZ
UPDATE card_shops SET lat = 33.56336, lng = -111.83778 WHERE name = 'THE TRADING CARD CLUB' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GILBERT, AZ
UPDATE card_shops SET lat = 33.56336, lng = -111.83778 WHERE name = 'VALLEYWIDE SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SCOTTSDALE, AZ
UPDATE card_shops SET lat = 33.714524, lng = -112.111818 WHERE name = 'instagram.com/explore/locations/104733976260235/the-baseball-card...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: PHOENIX, AZ
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'A & N COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SAN DIMAS, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'ALL STAR CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SANTEE, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'Amazing Comics' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LONG BEACH, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'BASEBALL & GAMES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HESPERIA, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'BASEBALL CARDS PLUS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HUNTINGTON BEACH, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'BEST VARIETY SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GLENDORA, CA
UPDATE card_shops SET lat = 34.171935, lng = -118.322135 WHERE name = 'BURBANK SPORTSCARDS LLC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: BURBANK, CA
UPDATE card_shops SET lat = 32.746686, lng = -117.092597 WHERE name = 'Bards & Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SAN DIEGO, CA
UPDATE card_shops SET lat = 32.746686, lng = -117.092597 WHERE name = 'Baseball CardShopsinSanDiego,CA|SportsMemorabiliaStores...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SAN DIEGO, CA
UPDATE card_shops SET lat = 37.674596, lng = -120.958772 WHERE name = 'Baseball Fan-Attic' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: MODESTO, CA
UPDATE card_shops SET lat = 36.797888, lng = -119.810418 WHERE name = 'Bases Loaded' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: FRESNO, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'CALICARDS & MORE' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CLOVIS, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'CARDBOARD LEGENDS, LLC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: , CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'CARDS AND COFFEE' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LOS ANGELES, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'CARDSMITHS SPORT CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ROCKLIN, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'COACH CHRIS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: UPLAND, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'COAST CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HALF MOON BAY, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'Cardboard Hero' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: OSHAWA, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'CollectiblesinLosAngeles| TikTok' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LOS ANGELES, CA
UPDATE card_shops SET lat = 38.561485, lng = -121.343462 WHERE name = 'Contact Us' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SACRAMENTO, CA
UPDATE card_shops SET lat = 38.561485, lng = -121.343462 WHERE name = 'D&P CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SACRAMENTO, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'Empire TCG' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: RIVERSIDE, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'GAMES AND CARDS SUPERSTORE' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: EAGLE ROCK, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'HALL OF FAME BASEBALL CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MONROVIA, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'HONEY HOLE COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: TEMECULA, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'Irvine Spectrum Center' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: IRVINE, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'KCK COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MURPHYS, CA
UPDATE card_shops SET lat = 37.674596, lng = -120.958772 WHERE name = 'Krier''s Cards and Comics' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: MODESTO, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'LIGHT THE LAMP SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SYDNEY, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'Locations' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LOS ANGELES, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'Lower Level Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WINNIPEG, CA
UPDATE card_shops SET lat = 37.674596, lng = -120.958772 WHERE name = 'MAXIMUM SPORTS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: MODESTO, CA
UPDATE card_shops SET lat = 37.323884, lng = -121.995011 WHERE name = 'MOJOBREAK INC.' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SANTA CLARA, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'MONTEREY BAY COLLECTORS LOUNGE' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MONTEREY, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'MVP SPORTSCARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LAGUNA HILLS, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'MVP TRADING CARDS COMPANY' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NORTHRIDGE, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'NEIGHBORHOOD CARD SHOP' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LODI, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'NORCAL SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ROSEVILLE, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'NORTHRIDGE SPORTS COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NORTHRIDGE, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'OMG COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PALM DESERT, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'PAPAJAY CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ROHNERT PARK, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'PENINSULA SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BELMONT, CA
UPDATE card_shops SET lat = 38.561485, lng = -121.343462 WHERE name = 'PSA Dealer: D & P Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SACRAMENTO, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'PSA Dealer: Lazy Trading Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: RICHMOND, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'PSA Dealer: Slabspace Sports Cards/ PTCG' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: IRVINE, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'PSA Dealer: Trading Card Warehouse Inc.' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MONCTON, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'RIZO SPORTS & TCG' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SANTA MONICA, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'RL SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FULLERTON, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'ROSS CARDS & COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ENCINITAS, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'Russo''s Sports Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BAKERSFIELD, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'SD SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: POWAY, CA
UPDATE card_shops SET lat = 33.789844, lng = -118.30929 WHERE name = 'SOUTH BAY BASEBALL CARDS, INC.' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: LOMITA, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'SOUTH BAY SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SUNNYVALE, CA
UPDATE card_shops SET lat = 34.171935, lng = -118.322135 WHERE name = 'SPORTS EMPIRE' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: BURBANK, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'SPORTS SOURCE 2' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: STUDIO CITY, CA
UPDATE card_shops SET lat = 37.327193, lng = -121.947923 WHERE name = 'STEVENS CREEK SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SAN JOSE, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'TEAMMATES SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CARMICHAEL, CA
UPDATE card_shops SET lat = 37.674596, lng = -120.958772 WHERE name = 'TEAMMATES SPORTS CARDS AND COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: MODESTO, CA
UPDATE card_shops SET lat = 36.797888, lng = -119.810418 WHERE name = 'THE CARD BAR' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: FRESNO, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'THREE J''S SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ANAHEIM, CA
UPDATE card_shops SET lat = 37.703779, lng = -121.927489 WHERE name = 'TRADER J''S CARDS & COMICS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: DUBLIN, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'The Comic Hunter' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CHARLOTTETOWN, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'Top Deck Keep' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: RIVERSIDE, CA
UPDATE card_shops SET lat = 36.797888, lng = -119.810418 WHERE name = 'WEBSTER SPORTSCARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: FRESNO, CA
UPDATE card_shops SET lat = 35.572525, lng = -118.788546 WHERE name = 'WHATS ON SECOND SPORTSCARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SAN MATEO, CA
UPDATE card_shops SET lat = 39.72348, lng = -104.98802 WHERE name = 'BILL''S SPORTS, LLC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: DENVER, CO
UPDATE card_shops SET lat = 39.72348, lng = -104.98802 WHERE name = 'Bill''s Sports Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: DENVER, CO
UPDATE card_shops SET lat = 39.500577, lng = -105.2331 WHERE name = 'COURTSIDE COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: THORNTON, CO
UPDATE card_shops SET lat = 38.863673, lng = -104.766733 WHERE name = 'ColoradoSpringsGiftShop| Greeting & BirthdayCards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: COLORADO SPRINGS, CO
UPDATE card_shops SET lat = 38.863673, lng = -104.766733 WHERE name = 'DALEZ KARDZ' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: COLORADO SPRINGS, CO
UPDATE card_shops SET lat = 39.72348, lng = -104.98802 WHERE name = 'Find a Dealer – DecisionTradingCards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: DENVER, CO
UPDATE card_shops SET lat = 39.500577, lng = -105.2331 WHERE name = 'Gulf South Trading Card Co.' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GULFPORT, CO
UPDATE card_shops SET lat = 38.863673, lng = -104.766733 WHERE name = 'IMPACT SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: COLORADO SPRINGS, CO
UPDATE card_shops SET lat = 39.694779, lng = -104.837924 WHERE name = 'MIKE''S STADIUM SPORTSCARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: AURORA, CO
UPDATE card_shops SET lat = 39.500577, lng = -105.2331 WHERE name = 'Old Town Art and Framery' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FORT COLLINS, CO
UPDATE card_shops SET lat = 39.500577, lng = -105.2331 WHERE name = 'Right Card, The' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FORT COLLINS, CO
UPDATE card_shops SET lat = 39.500577, lng = -105.2331 WHERE name = 'Rocky Mountain Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PUEBLO, CO
UPDATE card_shops SET lat = 38.863673, lng = -104.766733 WHERE name = 'THE IRON LION' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: COLORADO SPRINGS, CO
UPDATE card_shops SET lat = 38.863673, lng = -104.766733 WHERE name = 'THE SHOPPE' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: COLORADO SPRINGS, CO
UPDATE card_shops SET lat = 41.425899, lng = -72.926921 WHERE name = 'AV SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FAIRFIELD, CT
UPDATE card_shops SET lat = 41.425899, lng = -72.926921 WHERE name = 'CLUTCH CARDS LLC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BERLIN, CT
UPDATE card_shops SET lat = 41.425899, lng = -72.926921 WHERE name = 'Connecticut Sports Card Stores' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NEW HAVEN, CT
UPDATE card_shops SET lat = 41.425899, lng = -72.926921 WHERE name = 'DJ''S SPORTS COLLECTIBLES & COMICS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NORTH HAVEN, CT
UPDATE card_shops SET lat = 41.425899, lng = -72.926921 WHERE name = 'DUGOUT DREAMS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: DANBURY, CT
UPDATE card_shops SET lat = 41.425899, lng = -72.926921 WHERE name = 'GRAND SLAM VI' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: THOMASTON, CT
UPDATE card_shops SET lat = 41.425899, lng = -72.926921 WHERE name = 'KEN’S CARDS & COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BERLIN, CT
UPDATE card_shops SET lat = 41.425899, lng = -72.926921 WHERE name = 'Local Game Store Waterford, CT' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HARTFORD, CT
UPDATE card_shops SET lat = 41.425899, lng = -72.926921 WHERE name = 'MATT''S SPORTSCARDS AND COMICS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ENFIELD, CT
UPDATE card_shops SET lat = 41.425899, lng = -72.926921 WHERE name = 'Nite & Day Sports Cards and Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: DANBURY, CT
UPDATE card_shops SET lat = 41.425899, lng = -72.926921 WHERE name = 'OMNI COMICS AND CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WETHERSFIELD, CT
UPDATE card_shops SET lat = 41.124989, lng = -73.393337 WHERE name = 'SKYBOX COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: NORWALK, CT
UPDATE card_shops SET lat = 41.425899, lng = -72.926921 WHERE name = 'SierraTradingPostDanburyCT: Hours & Location' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: DANBURY, CT
UPDATE card_shops SET lat = 41.124989, lng = -73.393337 WHERE name = 'SkyBox Trading Cards & Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: NORWALK, CT
UPDATE card_shops SET lat = 41.425899, lng = -72.926921 WHERE name = 'Sparks Trading Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: STOCKTON, CT
UPDATE card_shops SET lat = 41.425899, lng = -72.926921 WHERE name = 'Welcome To Our Game Store' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: COLUMBUS, CT
UPDATE card_shops SET lat = 39.683467, lng = -75.746079 WHERE name = 'COLLECTOR''S BOX INC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: NEWARK, DE
UPDATE card_shops SET lat = 39.683467, lng = -75.746079 WHERE name = 'GAME OF CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: OVIEDO, DE
UPDATE card_shops SET lat = 39.683467, lng = -75.746079 WHERE name = 'Gifts For Guys and Gals' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WILMINGTON, DE
UPDATE card_shops SET lat = 39.683467, lng = -75.746079 WHERE name = 'Stackhouse Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: DOVER, DE
UPDATE card_shops SET lat = 39.683467, lng = -75.746079 WHERE name = 'The Local Card Shop – Wilmington Manor, Delaware' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WILMINGTON, DE
UPDATE card_shops SET lat = 39.683467, lng = -75.746079 WHERE name = 'TnT sports cards & collectables' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: NEWARK, DE
UPDATE card_shops SET lat = 39.683467, lng = -75.746079 WHERE name = 'TnT sports cards & collectables – Newark, Delaware' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: NEWARK, DE
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'AA MINT CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: COOPER CITY, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'ALL STAR CARDS & COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: DAVIE, FL
UPDATE card_shops SET lat = 29.675694, lng = -82.390489 WHERE name = 'All Star Sports Cards & Comics' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: GAINESVILLE, FL
UPDATE card_shops SET lat = 29.675694, lng = -82.390489 WHERE name = 'All Star Sportscards & Comics in Gainesville, FL 32607' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: GAINESVILLE, FL
UPDATE card_shops SET lat = 28.085879, lng = -82.539021 WHERE name = 'BASEBALL CARD CLUBHOUSE' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: TAMPA, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'BEN''S CARD WORLD' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PENSACOLA, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'BIG LEAGUE CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CASSELBERRY, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'BLUE BREAKS SPORTS & HOBBY CARD STORE' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: VENICE, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'BOCA SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BOCA RATON, FL
UPDATE card_shops SET lat = 28.085879, lng = -82.539021 WHERE name = 'Baseball Card Clubhouse in Tampa, FL 33629' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: TAMPA, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'Best Baseball CardShopsinOrlando,FL| Ballcard Genius' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ORLANDO, FL
UPDATE card_shops SET lat = 27.344506, lng = -82.50032 WHERE name = 'Blue Breaks' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SARASOTA, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'COGNIZANT CARDS & COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: POMPANO BEACH, FL
UPDATE card_shops SET lat = 27.344506, lng = -82.50032 WHERE name = 'Catcher''s Mitt' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SARASOTA, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'Coastal Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ST PETERSBURG, FL
UPDATE card_shops SET lat = 30.479245, lng = -84.297465 WHERE name = 'Collector''s Attic Inc.' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: TALLAHASSEE, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'Contact Us –HobbyCardShop' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MOBILE, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'DAN''S SPORTS CARDS & GAMES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: JACKSONVILLE, FL
UPDATE card_shops SET lat = 29.155273, lng = -81.02077 WHERE name = 'DaytonaMagicShop|DaytonaBeach,FL32114' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: DAYTONA BEACH, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'Dick and Jane''s Baseball Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: JACKSONVILLE, FL
UPDATE card_shops SET lat = 26.141859, lng = -81.79648 WHERE name = 'EAST WEST SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: NAPLES, FL
UPDATE card_shops SET lat = 26.141859, lng = -81.79648 WHERE name = 'East West Sports Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: NAPLES, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'EnchantSt.PetersburgGift & GreetingCards- Email, Text or Print...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ST PETERSBURG, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'FAST BREAK TRADINGS CARDS & MEMORABILIA' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SAINT CLOUD, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'FP Trading Card Shop' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ST PETERSBURG, FL
UPDATE card_shops SET lat = 29.155273, lng = -81.02077 WHERE name = 'Finn McCool''s Sports & Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: DAYTONA BEACH, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'Florida Sports Card Stores' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MIAMI, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'GAME TIME CARDZ' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WINTER PARK, FL
UPDATE card_shops SET lat = 29.155273, lng = -81.02077 WHERE name = 'Geek Out Toys and Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: DAYTONA BEACH, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'INSTANT REPLAY SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PANAMA CITY, FL
UPDATE card_shops SET lat = 29.155273, lng = -81.02077 WHERE name = 'John’s Collectibles – Daytona Flea & Farmers Market' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: DAYTONA BEACH, FL
UPDATE card_shops SET lat = 27.918337, lng = -82.760751 WHERE name = 'KK SPORTSCARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: LARGO, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'KNT SPORTS CARDS & MEMORABILIA LLC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ORMOND BEACH, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'LUCKIEST MAN SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ORANGE PARK, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'Lion''s Paw Antiques & Collectables' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ST PETERSBURG, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'M & M Sports Cards & Collectibles in Pensacola, FL 32504' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PENSACOLA, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'MATT''S DUGOUT' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WELLINGTON, FL
UPDATE card_shops SET lat = 27.795849, lng = -80.48162 WHERE name = 'MVP SPORTS CARDS AND COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SEBASTIAN, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'PCB HOBBY' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PANAMA CITY BEACH, FL
UPDATE card_shops SET lat = 27.344506, lng = -82.50032 WHERE name = 'PSA Dealer: Kenmore Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SARASOTA, FL
UPDATE card_shops SET lat = 26.141859, lng = -81.79648 WHERE name = 'PSA Dealer: Steve Novella' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: NAPLES, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'Proco Memorabilia in Fort Lauderdale, FL' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FORT LAUDERDALE, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'SHORTSTOPS SPORTS CARDS & GAMES, LLC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PALM HARBOR, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'SHOWTIME SPORTS CARDS & COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: JACKSONVILLE, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'STRIKE ZONE' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PORT ST LUCIE, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'Shoe & Sneaker Store inStPetersburg| JDSportsat Tyrone Square' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ST PETERSBURG, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'Sports Memorabilia' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: JACKSONVILLE, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'Sportscards & Collectibles Miami' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MIAMI, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'Sportscards Jacksonville Florida Baseball Football Trading Sports ...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: JACKSONVILLE, FL
UPDATE card_shops SET lat = 27.344506, lng = -82.50032 WHERE name = 'Srq cards in Sarasota, FL 34231' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SARASOTA, FL
UPDATE card_shops SET lat = 29.675694, lng = -82.390489 WHERE name = 'THE MEELYPOPS SHOP' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: GAINESVILLE, FL
UPDATE card_shops SET lat = 30.479245, lng = -84.297465 WHERE name = 'Talgov.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: TALLAHASSEE, FL
UPDATE card_shops SET lat = 30.479245, lng = -84.297465 WHERE name = 'Tallahassee Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: TALLAHASSEE, FL
UPDATE card_shops SET lat = 30.479245, lng = -84.297465 WHERE name = 'Tallahassee Sports Cards – Tallahassee, Florida' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: TALLAHASSEE, FL
UPDATE card_shops SET lat = 29.155273, lng = -81.02077 WHERE name = 'The Friendly Confines' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: DAYTONA BEACH, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'The Millennium Group' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ORLANDO, FL
UPDATE card_shops SET lat = 27.344506, lng = -82.50032 WHERE name = 'Trading Cards — Moosehead Toys And Comics' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SARASOTA, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'WONDER WATER SPORTS CARDS COMICS & GAMES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CLEARWATER, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'WORLD CHAMPION SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WEST PALM BEACH, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'WhistlecopterMiamiFL, 33173 – Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MIAMI, FL
UPDATE card_shops SET lat = 28.316544, lng = -81.992295 WHERE name = 'Zean''s Hobby Shop' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FORT LAUDERDALE, FL
UPDATE card_shops SET lat = 34.105437, lng = -83.570509 WHERE name = 'BT COLLECTIBLES LLC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WOODSTOCK, GA
UPDATE card_shops SET lat = 34.105437, lng = -83.570509 WHERE name = 'CARDS HQ' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ATLANTA, GA
UPDATE card_shops SET lat = 33.958324, lng = -84.524521 WHERE name = 'CHAMPION SPORTSCARDS & COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: MARIETTA, GA
UPDATE card_shops SET lat = 34.105437, lng = -83.570509 WHERE name = 'Cardboard Castle Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: AUGUSTA, GA
UPDATE card_shops SET lat = 34.105437, lng = -83.570509 WHERE name = 'Cardboard Castle Games 4015 Columbia Rd, Augusta, GA 30907 ...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: AUGUSTA, GA
UPDATE card_shops SET lat = 34.105437, lng = -83.570509 WHERE name = 'DOWNTOWN SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GAINESVILLE, GA
UPDATE card_shops SET lat = 33.958324, lng = -84.524521 WHERE name = 'DUCKS DUGOUT' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: MARIETTA, GA
UPDATE card_shops SET lat = 34.105437, lng = -83.570509 WHERE name = 'GOT BASEBALL CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LOGANVILLE, GA
UPDATE card_shops SET lat = 34.105437, lng = -83.570509 WHERE name = 'MIDDLE GEORGIA SPORTSCARDS AND COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WARNER ROBINS, GA
UPDATE card_shops SET lat = 34.105437, lng = -83.570509 WHERE name = 'Morningstar Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SAVANNAH, GA
UPDATE card_shops SET lat = 34.105437, lng = -83.570509 WHERE name = 'ON DECK SPORTSCARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LAWRENCEVILLE, GA
UPDATE card_shops SET lat = 34.105437, lng = -83.570509 WHERE name = 'The ChristmasShopSavannahGA- YouTube' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SAVANNAH, GA
UPDATE card_shops SET lat = 34.105437, lng = -83.570509 WHERE name = 'Top Dog Comics' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MARTINEZ, GA
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'AJTK SPORTSCARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: AIEA, HI
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'ALBATROSS, LLC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: , HI
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'MAUI SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: KAHULUI, HI
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Metal Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: HONOLULU, HI
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'TradingCardAttic' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: MAUI, HI
UPDATE card_shops SET lat = 42.015764, lng = -91.633402 WHERE name = 'Castle Sports & Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CEDAR RAPIDS, IA
UPDATE card_shops SET lat = 41.373093, lng = -94.632792 WHERE name = 'Daydream Comics' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: IOWA CITY, IA
UPDATE card_shops SET lat = 41.553675, lng = -93.594821 WHERE name = 'JAY''S CD & HOBBY' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: DES MOINES, IA
UPDATE card_shops SET lat = 42.015764, lng = -91.633402 WHERE name = 'Locker Room Legends' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CEDAR RAPIDS, IA
UPDATE card_shops SET lat = 41.373093, lng = -94.632792 WHERE name = 'MIDWEST COLLECTABLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: DAVENPORT, IA
UPDATE card_shops SET lat = 41.373093, lng = -94.632792 WHERE name = 'RK COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CORALVILLE, IA
UPDATE card_shops SET lat = 41.373093, lng = -94.632792 WHERE name = 'Super Stars and Super Heroes' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: DAVENPORT, IA
UPDATE card_shops SET lat = 41.373093, lng = -94.632792 WHERE name = 'THE ROOKIE' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CLIVE, IA
UPDATE card_shops SET lat = 45.449337, lng = -115.252862 WHERE name = 'Baseball Card in Nampa, ID' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NAMPA, ID
UPDATE card_shops SET lat = 43.612858, lng = -116.222921 WHERE name = 'Boise Card Guys LLC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: BOISE, ID
UPDATE card_shops SET lat = 45.449337, lng = -115.252862 WHERE name = 'Dugout Sports Cards and Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NAMPA, ID
UPDATE card_shops SET lat = 45.449337, lng = -115.252862 WHERE name = 'Game Grid I.F.' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: IDAHO FALLS, ID
UPDATE card_shops SET lat = 43.612858, lng = -116.222921 WHERE name = 'Hobby, Toy, andGameShops|Boise,ID- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: BOISE, ID
UPDATE card_shops SET lat = 43.612858, lng = -116.222921 WHERE name = 'JERRY''S ROOKIE SHOP' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: BOISE, ID
UPDATE card_shops SET lat = 45.449337, lng = -115.252862 WHERE name = 'Jewelry & Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: IDAHO FALLS, ID
UPDATE card_shops SET lat = 45.449337, lng = -115.252862 WHERE name = 'SILVER SLUGGER COINS & CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: AMMON, ID
UPDATE card_shops SET lat = 45.449337, lng = -115.252862 WHERE name = 'ShoppingIdahoFallsIDIdaho+ Outlet Mall' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: IDAHO FALLS, ID
UPDATE card_shops SET lat = 45.449337, lng = -115.252862 WHERE name = 'SportingGoods inNampa,Idaho' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NAMPA, ID
UPDATE card_shops SET lat = 45.449337, lng = -115.252862 WHERE name = 'bestbuy.com/site/electronics/black-friday/pcmcat225600050002.c?id...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GREEN BAY, ID
UPDATE card_shops SET lat = 39.761484, lng = -89.639213 WHERE name = '217 Comics Cards & Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SPRINGFIELD, IL
UPDATE card_shops SET lat = 40.917045, lng = -88.385432 WHERE name = 'BASEBALL CARD CITY' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PEORIA, IL
UPDATE card_shops SET lat = 40.917045, lng = -88.385432 WHERE name = 'BASELINE SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SCHAUMBURG, IL
UPDATE card_shops SET lat = 40.917045, lng = -88.385432 WHERE name = 'BERGIE''S SPORTS CARD DUGOUT INC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HIGHLAND PARK, IL
UPDATE card_shops SET lat = 40.917045, lng = -88.385432 WHERE name = 'BRICKS AND IVY SPORTS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HOOPESTON, IL
UPDATE card_shops SET lat = 41.927054, lng = -87.693798 WHERE name = 'BRIDGEPORT HOBBY' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CHICAGO, IL
UPDATE card_shops SET lat = 40.917045, lng = -88.385432 WHERE name = 'Baseball Card City in Peoria, IL 61614' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PEORIA, IL
UPDATE card_shops SET lat = 40.113292, lng = -88.260732 WHERE name = 'Box Seat Cards And Collectibles CU' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CHAMPAIGN, IL
UPDATE card_shops SET lat = 41.501688, lng = -88.167982 WHERE name = 'CARD POP USA' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: JOLIET, IL
UPDATE card_shops SET lat = 40.917045, lng = -88.385432 WHERE name = 'CHICAGOLAND SPORTS CARDS & MEMORABILIA' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BUFFALO GROVE, IL
UPDATE card_shops SET lat = 41.927054, lng = -87.693798 WHERE name = 'Central Collectables' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CHICAGO, IL
UPDATE card_shops SET lat = 41.927054, lng = -87.693798 WHERE name = 'Chicago Toy Hunting.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CHICAGO, IL
UPDATE card_shops SET lat = 41.927054, lng = -87.693798 WHERE name = 'ELITE SPORTS CARDS AND COMIC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CHICAGO, IL
UPDATE card_shops SET lat = 40.917045, lng = -88.385432 WHERE name = 'HEROES, INC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NORTH RIVERSIDE, IL
UPDATE card_shops SET lat = 40.917045, lng = -88.385432 WHERE name = 'JIM & STEVE''S SPORTSCARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WAUKEGAN, IL
UPDATE card_shops SET lat = 40.917045, lng = -88.385432 WHERE name = 'Johnny O Sports' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ROCKFORD, IL
UPDATE card_shops SET lat = 40.917045, lng = -88.385432 WHERE name = 'MINT MEMORABILIA' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LAKE ZURICH, IL
UPDATE card_shops SET lat = 40.917045, lng = -88.385432 WHERE name = 'One for All Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PEORIA, IL
UPDATE card_shops SET lat = 40.917045, lng = -88.385432 WHERE name = 'Pokemon' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PEORIA, IL
UPDATE card_shops SET lat = 40.917045, lng = -88.385432 WHERE name = 'Royal Hobby Shop' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ROCKFORD, IL
UPDATE card_shops SET lat = 40.917045, lng = -88.385432 WHERE name = 'SHOEBOX-MEMORABILIA, INC.' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SOUTH ELGIN, IL
UPDATE card_shops SET lat = 40.113292, lng = -88.260732 WHERE name = 'Specialty Stamp & Coin' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CHAMPAIGN, IL
UPDATE card_shops SET lat = 40.917045, lng = -88.385432 WHERE name = 'THE BASEBALL CARD KING #1' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PLAINFIELD, IL
UPDATE card_shops SET lat = 40.917045, lng = -88.385432 WHERE name = 'THE BASEBALL CARD KING #2' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: OAK LAWN, IL
UPDATE card_shops SET lat = 41.794958, lng = -88.009904 WHERE name = 'THE BASEBALL CARD KING #3' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: DOWNERS GROVE, IL
UPDATE card_shops SET lat = 40.917045, lng = -88.385432 WHERE name = 'THE SANDLOT SPORTS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GLEN ELLYN, IL
UPDATE card_shops SET lat = 40.917045, lng = -88.385432 WHERE name = 'THE SPORTS CARD ZONE' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SHOREWOOD, IL
UPDATE card_shops SET lat = 42.028458, lng = -88.29837 WHERE name = 'TOP SHELF SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: ELGIN, IL
UPDATE card_shops SET lat = 41.927054, lng = -87.693798 WHERE name = 'Tim''s BaseballCardShop-Chicago,IL| SportsCard-Stores.Com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CHICAGO, IL
UPDATE card_shops SET lat = 39.761484, lng = -89.639213 WHERE name = 'UNDERDOG Sports, Memorabilia & Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SPRINGFIELD, IL
UPDATE card_shops SET lat = 40.917045, lng = -88.385432 WHERE name = 'Wendy''s Creative Collections & Coins' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PEORIA, IL
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = '2 Guys Sports Cards in Springfield, IL 62702' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SPRINGFIELD, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = '7th Inning Stretch LLC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WILMINGTON, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'A walk in time' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CHARLESTON, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'A&M Hobby Shop' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NEW BERN, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'AA CARDS & COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: KOKOMO, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'AAA Games Arena' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SPRINGFIELD, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'AJ Collectables Kenosha in Kenosha, WI 53142' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: KENOSHA, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'AMS Sports Cards in Tempe, AZ 85281' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: TEMPE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'ARC Sportcards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CONCORD, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'About' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: OMAHA, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Action Cards & Comics' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GREAT FALLS, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'All Things Sports SUX in Sioux City, IA 51103' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SIOUX CITY, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'AllSports Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MIAMI, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Amazing Fantasy Red Deer''s Comic Book Store' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: RED DEER, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Ann Arbor Sports Memorabilia Shop' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ANN ARBOR, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Annapolis Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ANNAPOLIS, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Anubis Games and Hobby' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LAFAYETTE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Apponaug Hobby Shop' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WARWICK, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Arc SportsCards in Concord, NH 03301' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CONCORD, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Athlon Sports Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NASHVILLE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'B&B Cards and Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: VIRGINIA BEACH, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'BASEBALL CARD EXCHANGE, INC.' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SCHERERVILLE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'BEST CARD SHOP' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PLAINFIELD, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Balena and Abrams Sports Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: IOWA CITY, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Ball Hogs Sports Cards, Collectibles & More in Reno, NV 89502' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: RENO, IN
UPDATE card_shops SET lat = 39.748808, lng = -86.14001 WHERE name = 'Baseball Card Exchange' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: INDIANAPOLIS, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Baseball Cards 4-U Co' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MACON, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'BaseballSportsCardsand Memorabilia |Florida- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MIAMI, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Best 10 Pokemon Card Buy Sell Trade in Collierville, TN with Reviews' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MEMPHIS, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Best 12 Comic Books in Memphis, TN with Reviews' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MEMPHIS, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Best 2SportsCardsMemorabilia in Longview,TXwith Reviews' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: DALLAS, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Best 9 Sports Cards Memorabilia in Memphis, TN with Reviews' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MEMPHIS, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Best BaseballCardShops&SportsMemorabilia StoresinDenver,CO' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: DENVER, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Best Deals LocalSportsShop|Cranston& Wakefield,RI' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CRANSTON, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Best of the Best in Sportscards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PEARL CITY, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Beverly Hills Baseball Cards in Los Angeles, CA 90035' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LOS ANGELES, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Beyond the Pond Sports Cards and Collectables' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LONDON, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Big B Comics Barrie in Barrie, Ontario, Canada' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BARRIE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Bill''s Sports Collectibles in Denver, CO 80210' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: DENVER, IN
UPDATE card_shops SET lat = 41.694632, lng = -86.224124 WHERE name = 'Bitgo Hobby in South Bend, IN 46628' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SOUTH BEND, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Bluff City Memorabilia in Southaven, MS 38672' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SOUTHAVEN, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Boise Card Guys LLC in Boise, ID 83704' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BOISE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Bozeman Sports Cards in Bozeman, MT 59718' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BOZEMAN, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Breaking Bad Sports Cards LLC in Topeka, KS 66606' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: TOPEKA, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'CARD ADDICTION' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ANAHEIM, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Card Stop Sports Collectables' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: VICTORIA, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Cards At The Cages Greensboro NC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GREENSBORO, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Cards At the Cages Inc' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GREENSBORO, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Cards Games and More' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BISMARCK, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Cards and Comics Central' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SAN FRANCISCO, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Carta Magica Ottawa in Ottawa, ON K1K 3B7' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: OTTAWA, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Catan: On the Road' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NORFOLK, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Centre City Sports Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SAN DIEGO, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Champs Sports in 1510 West Empire MallSiouxFalls,SouthDakota' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SIOUX FALLS, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Champs Sports in 6401 Bluebonnet BlvdBatonRouge,Louisiana' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BATON ROUGE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Clean Out and Cash Out with Annapolis Consignment Shops' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ANNAPOLIS, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Cobra Cards in Dothan, AL 36303' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: DOTHAN, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Collector''s Corner NW (@collectorscornernw) • Instagram ...Local Card Shops' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BELLEVUE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Collectors Choice' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: KNOXVILLE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Columbia Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: COLUMBIA, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Columbia Collectibles in Columbia, TN 38401' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: COLUMBIA, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Cosmic Card Shop in Salem, OR 97301' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SALEM, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Creative Antiques' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WORCESTER, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Dauby''sSportCenterSiouxFallsSD, 57105 – Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SIOUX FALLS, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Deans Dugout' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NAPERVILLE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Don''s Sports Card Center in Portland, ME 04102' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PORTLAND, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Don''s Sports Card Center on Brighton Ave in Portland, ME' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PORTLAND, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Double Midnight Comics' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CONCORD, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Duncan’s Sports Cards in Jonesboro, AR 72401' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: JONESBORO, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'E J Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FLINT, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'ENC Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NEW BERN, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Elite Memorabilia & Collection in Norwalk, CT 06851' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NORWALK, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Elwood Sports Cards in Medford, OR 97501' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MEDFORD, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Exclusive Sports memorabilia & collectibles in Manchester, NH 03102 ...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MANCHESTER, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Fable Hobby in Portland, OR 97225' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PORTLAND, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Family Treasures Antique Mall' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BROKEN ARROW, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Flagstaff Sports Cards & Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FLAGSTAFF, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Free Game' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: QUEBEC CITY, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Freedom Hobby and Gaming' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CANTON, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'GG Cards & Breaks in Syracuse, NY 13208' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SYRACUSE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'GPS Sports Gallery' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CLEVELAND, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Gaenic Memorabilia in Sudbury, Ontario, Canada' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SUDBURY, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Game Knight' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: COLUMBIA, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'GameStop' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NANAIMO, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Gameday Little Rock' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LITTLE ROCK, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Get DIRECTV in Collierville, TN' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: COLLIERVILLE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Get DIRECTV in High Point, NC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HIGH POINT, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Get DIRECTV in Huntersville, NC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HUNTERSVILLE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Gift, Novelty, and SouvenirShops|Southaven,MS- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SOUTHAVEN, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'GiftShops|TomsRiver,NJ- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: TOMS RIVER, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Golden Eagle Comics & Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: READING, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Grand Slam Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: JACKSONVILLE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Grand Slam Sports Cards in Nampa, ID 83651' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NAMPA, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'GreetingCardStores|Evansville,IN- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: EVANSVILLE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Grubbmasters Card Shop in Bowling Green, KY 42101' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BOWLING GREEN, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Guild Gaming' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: JACKSONVILLE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'H & H Baseball Cards Plus in Bakersfield, CA 93309' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BAKERSFIELD, IN
UPDATE card_shops SET lat = 39.16454, lng = -86.495159 WHERE name = 'HI5 CARDS AND COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: BLOOMINGTON, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'HOMETOWN HOBBIES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HUNTINGTON, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Have Fun Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: DAVENPORT, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Hero Source Toys & Collectibles in Sanford, NC 27330' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SANFORD, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Heroes & Legends Sports Cards and Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: COOKEVILLE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Heroes Magic & Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: RAPID CITY, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Heroes Magic & Sports Cards in Rapid City, SD 57701' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: RAPID CITY, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Hickory Cards, Games & Comics in Hickory, NC 28602' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HICKORY, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Hobby Hole' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MONTGOMERY, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Hobby Shops In Anchorage, AK' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ANCHORAGE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Hobby Stop West on Sylvania Ave in Toledo, OH' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: TOLEDO, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Hobby shop in Springfield, Illinois' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SPRINGFIELD, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Hobby, Toy, andGameShops|Bellevue,WA- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BELLEVUE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Hobby, Toy, andGameShops|Dothan,AL- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: DOTHAN, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Hobby, Toy, andGameShops|Huntington,WV- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HUNTINGTON, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Hobby, Toy, andGameShops|Jonesboro,AR- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: JONESBORO, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Hobby, Toy, andGameShops|Madison,WI- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MADISON, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Hobby, Toy, andGameShops|Providence,RI- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PROVIDENCE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Hobby, Toy, andGameShops|Stockton,CA- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: STOCKTON, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Hometown Hobbies in Huntington, WV 25701' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HUNTINGTON, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Hometown Sports Collectables' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: DOVER, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Hometown sports collectables in Dover, DE 19904' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: DOVER, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Hoody''s Collectibles (Bend) in Bend, OR 97702' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BEND, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'INDIANA SPORTSCARD GUYS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MILFORD, IN
UPDATE card_shops SET lat = 39.748808, lng = -86.14001 WHERE name = 'INDY CARD EXCHANGE' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: INDIANAPOLIS, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Iconic games&hobbies in Mesa, AZ 85213' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MESA, IN
UPDATE card_shops SET lat = 39.748808, lng = -86.14001 WHERE name = 'Indiana Card Shops' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: INDIANAPOLIS, IN
UPDATE card_shops SET lat = 39.748808, lng = -86.14001 WHERE name = 'Indiana Sports Card Stores' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: INDIANAPOLIS, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Infinite TCG' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FORT WAYNE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Infinite TCG – Fort Wayne, Indiana' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FORT WAYNE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Instagram' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: JUNEAU, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'JR''s Sports cards plus + in Savannah, GA 31404' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SAVANNAH, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Jackson''s Card Shop' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: JACKSON, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Jonesboro Sports Cards & Memorabilia' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: JONESBORO, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'K&L CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GREEENWOOD, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'KAB SPORTS CARDS & COLLECTABLES in Billings, MT 59102' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BILLINGS, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Kaleido TCG' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: JERSEY CITY, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Kilby''s Extreme RC Hobby Shop in Kingsport, TN' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: KINGSPORT, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Lone Star Sports Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LUBBOCK, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Lucky''s Card Shop in Greensboro, NC 27407' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GREENSBORO, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'M & M SPORTSCARDS & COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: COLUMBUS, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'MADISON SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MADISON, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'MICHIANA SPORTSCARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GRANGER, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Magic City Sportscards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: AKRON, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Maine Sports Card Stores' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PORTLAND, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Major Art & Hobby Co.' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: DAVENPORT, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Map and Directions to The Cardsmiths in New Haven, CT 06512' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NEW HAVEN, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Marty''s Sportscard Exchange Superstore in Chattanooga, TN 37421' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CHATTANOOGA, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Maui Sports Cards in Kahului, HI 96732' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MAUI, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Mike Moyer Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ALLENTOWN, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Mopigs collectibles and custom paint' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WICHITA, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Murdoch''s Ranch & Home Supply, 3773 E Lincolnway,CheyenneWy...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CHEYENNE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'NICODEMUS CARDS & GAMES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WARSAW, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'North Valley Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MESA, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'NorthDakotaGameStores' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MINOT, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Nostalgia Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: EUGENE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'One Up TCG in Tuscaloosa, AL 35401' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: TUSCALOOSA, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Orlando Sportscards South in Orlando, FL 32837' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ORLANDO, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Our Retail Store in Bangor, ME' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BANGOR, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Outer Limits Boro' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MURFREESBORO, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Owensboro.cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: OWENSBORO, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'PJ Sports Cards in Milwaukee, WI 53219' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MILWAUKEE, IN
UPDATE card_shops SET lat = 41.694632, lng = -86.224124 WHERE name = 'Paul''s Coins and Postcards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SOUTH BEND, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Phantom Cards & Collectibles in Los Angeles, CA 90012' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LOS ANGELES, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Platinum Sports and Music Memorabilia' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PROVO, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Port City Sports Collectibles in Wilmington, NC 28403' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WILMINGTON, IN
UPDATE card_shops SET lat = 39.748808, lng = -86.14001 WHERE name = 'Posts' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: INDIANAPOLIS, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Quinn’s Trading Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MANCHESTER, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Rdsportstopeka' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: TOPEKA, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Rescue Gaming' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PROVIDENCE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Retrofix Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MISSOULA, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Rick''s Cards and Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CLARKSVILLE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Robin''s Nest' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ROCKFORD, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Rock Solid Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BRIDGEPORT, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Rogue Games and Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: COLUMBIA, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Rutland Collectibles in Rutland, VT 05701' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: RUTLAND, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Rutland''s Baseball Cards in Rutland, Vermont 05701' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: RUTLAND, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'SPORT SPOT INC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FORT WAYNE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'SPORTS HEROES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CRANSTON, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'SPORTS KINGS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SCOTTSBURG, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Scott''s Collectibles in Kannapolis, NC 28083' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: KANNAPOLIS, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Shep''s Cards & Collectibles in Hendersonville, TN 37075' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HENDERSONVILLE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Shoe & Sneaker StoreinStPetersburg| JDSportsat Tyrone Square' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ST PETERSBURG, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Shopping Retail Games Gauntlet' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LARAMIE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Shopping|SiouxFalls,SD- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SIOUX FALLS, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Spokane Valley Sportscards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SPOKANE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Sport Spot Inc in Fort Wayne, IN 46805' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FORT WAYNE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'SportStuff Cards & Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CORPUS CHRISTI, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Sports Archives in Canton, OH 44709' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CANTON, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Sports Heroes in Cranston, RI 02920' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CRANSTON, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Sports Memorabilia of Ct in Hartford, CT 06106' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HARTFORD, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Sports Zone' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ALBANY, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Steeplegate Mall' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CONCORD, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Storage Unit Auction in Chattanooga, TN at Scenic City Self' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CHATTANOOGA, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Storage Unit Auction in Cookeville , TN at Cookeville Self' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: COOKEVILLE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Storage Unit Auction in Gastonia, NC at River Rock Storage ends' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GASTONIA, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Storage Unit Auction in Hendersonville, TN at New Shackle Self' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HENDERSONVILLE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Storage Unit Auction in Kingsport, TN at 24 Hr Self Storage -' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: KINGSPORT, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Storage Unit Auction in Memphis, TN at Fairgrounds Self Storage' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MEMPHIS, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Storage Unit Auction in Memphis, TN at Lucky Self Storage ends' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MEMPHIS, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Storage Unit Auction in Murfreesboro, TN at Northboro Storage' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MURFREESBORO, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'TCG House of Cards in Worcester, MA 01605' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WORCESTER, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'TNC Sports' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BARTLETT, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'TNT Antiques and Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MODESTO, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'The 20 Best Hobby Shops – Cleveland, OH (United States)Immortals Inc' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CLEVELAND, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'The Card District' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: OWENSBORO, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'The Card Shop Evansville' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: EVANSVILLE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'The Card Shop NC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WINSTON-SALEM, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'The Card Shop NC in Winston Salem, NC 27103' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WINSTON-SALEM, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'The Card Shop in Evansville, IN 47715' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: EVANSVILLE, IN
UPDATE card_shops SET lat = 39.16454, lng = -86.495159 WHERE name = 'The Coin Shop Inc.' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: BLOOMINGTON, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'The Great Escape' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BOWLING GREEN, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'The Hobby Den' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: EVANSVILLE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'The Hobby Shop in Sanford, NC 27330' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SANFORD, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'The Right Card in Fort Collins, CO 80524' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FORT COLLINS, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'The Tennessee Card Co. #3' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BARTLETT, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Third Eye Games & Hobbies' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ANNAPOLIS, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Triangle Area Trading Cards in Raleigh, NC 27606' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: RALEIGH, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Triple Play Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SIOUX FALLS, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Triple Play Sports Cards, Inc.' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SIOUX FALLS, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Triumph TCG in Fresno, CA 93727' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FRESNO, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'UNDERGROUND CASE BREAKS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HOBART, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Upcoming WNY Card Shows' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BUFFALO, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Vancity CJ Trading Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: RICHMOND, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Visit Us: Discover Card & Coin at Green Bay, WI' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GREEN BAY, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Wally''s Pro Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: VANCOUVER, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Warwick Gift Shop' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WARWICK, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Welcome to Kevin Savage Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: TOLEDO, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'Yorkshire Rose Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ANNAPOLIS, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'baseballcards in Milwaukee, WI' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MILWAUKEE, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'baseballcards in Worcester, MA' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WORCESTER, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'marticards in High Point, NC 27262' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HIGH POINT, IN
UPDATE card_shops SET lat = 39.85712, lng = -86.145363 WHERE name = 'thegamecave.tcgplayerpro.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NASHVILLE, IN
UPDATE card_shops SET lat = 38.754169, lng = -95.694807 WHERE name = 'Amy''s HallmarkShop-Olathe,KS66062' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: OLATHE, KS
UPDATE card_shops SET lat = 38.754169, lng = -95.694807 WHERE name = 'COLLECTOR''S CACHE' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LENEXA, KS
UPDATE card_shops SET lat = 37.668704, lng = -97.350359 WHERE name = 'Mopig''s collectibles and custom paint – Wichita, Kansas' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: WICHITA, KS
UPDATE card_shops SET lat = 38.968328, lng = -94.675079 WHERE name = 'PSA Dealer: The Baseball Card Store LLC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: OVERLAND PARK, KS
UPDATE card_shops SET lat = 39.036305, lng = -95.738099 WHERE name = 'R & D COLLECTIBLES LLC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: TOPEKA, KS
UPDATE card_shops SET lat = 39.036305, lng = -95.738099 WHERE name = 'R and D Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: TOPEKA, KS
UPDATE card_shops SET lat = 37.668704, lng = -97.350359 WHERE name = 'ROCK’S DUGOUT' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: WICHITA, KS
UPDATE card_shops SET lat = 37.668704, lng = -97.350359 WHERE name = 'Rocks Dugout Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: WICHITA, KS
UPDATE card_shops SET lat = 37.668704, lng = -97.350359 WHERE name = 'SportingGoods |Wichita,KS- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: WICHITA, KS
UPDATE card_shops SET lat = 38.94953, lng = -95.255565 WHERE name = 'Sports Dome' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: LAWRENCE, KS
UPDATE card_shops SET lat = 38.754169, lng = -95.694807 WHERE name = 'THE ART OF SPORTS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LEAWOOD, KS
UPDATE card_shops SET lat = 38.968328, lng = -94.675079 WHERE name = 'THE BASEBALL CARD STORE LLC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: OVERLAND PARK, KS
UPDATE card_shops SET lat = 38.754169, lng = -95.694807 WHERE name = 'UNOPENEDPACKMAN SPORTSCARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: OLATHE, KS
UPDATE card_shops SET lat = 38.754169, lng = -95.694807 WHERE name = 'Unopenedpackman Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: OLATHE, KS
UPDATE card_shops SET lat = 38.754169, lng = -95.694807 WHERE name = 'Used MerchandiseStores|Olathe,KS- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: OLATHE, KS
UPDATE card_shops SET lat = 39.036305, lng = -95.738099 WHERE name = 'Wheatland Antique Mall' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: TOPEKA, KS
UPDATE card_shops SET lat = 37.904055, lng = -84.252709 WHERE name = 'Grubbmasters Card Shop' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BOWLING GREEN, KY
UPDATE card_shops SET lat = 37.904055, lng = -84.252709 WHERE name = 'HIT SEEKERS SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FT MITCHELL, KY
UPDATE card_shops SET lat = 37.904055, lng = -84.252709 WHERE name = 'KENTUCKY CARD VAULT' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SMITHS GROVE, KY
UPDATE card_shops SET lat = 38.019782, lng = -84.528522 WHERE name = 'KENTUCKY ROADSHOW SHOP' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: LEXINGTON, KY
UPDATE card_shops SET lat = 37.904055, lng = -84.252709 WHERE name = 'LOUISVILLE SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LOUISVILLE, KY
UPDATE card_shops SET lat = 38.019782, lng = -84.528522 WHERE name = 'SEARCH AND RESCUE CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: LEXINGTON, KY
UPDATE card_shops SET lat = 37.904055, lng = -84.252709 WHERE name = 'Sports-Country' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: OWENSBORO, KY
UPDATE card_shops SET lat = 37.904055, lng = -84.252709 WHERE name = 'Steve''s Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BOWLING GREEN, KY
UPDATE card_shops SET lat = 37.904055, lng = -84.252709 WHERE name = 'THROUGH THE DECADES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LOUISVILLE, KY
UPDATE card_shops SET lat = 37.904055, lng = -84.252709 WHERE name = 'WINCITY SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WINCHESTER, KY
UPDATE card_shops SET lat = 31.05099, lng = -91.02906 WHERE name = 'AJ''S SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BATON ROUGE, LA
UPDATE card_shops SET lat = 31.05099, lng = -91.02906 WHERE name = 'AJ''s Sports Cards in Baton Rouge, LA 70809' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BATON ROUGE, LA
UPDATE card_shops SET lat = 29.946034, lng = -90.132592 WHERE name = 'About Us' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: NEW ORLEANS, LA
UPDATE card_shops SET lat = 31.05099, lng = -91.02906 WHERE name = 'Anubis Games & Hobby' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LAFAYETTE, LA
UPDATE card_shops SET lat = 31.05099, lng = -91.02906 WHERE name = 'CARDS AND CULTURE' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BATON ROUGE, LA
UPDATE card_shops SET lat = 31.05099, lng = -91.02906 WHERE name = 'Cajun Gamer in Lafayette, LA 70507' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LAFAYETTE, LA
UPDATE card_shops SET lat = 31.05099, lng = -91.02906 WHERE name = 'Jerry''s RookieShop-Boise,IdahoOxford Book Haven' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BOISE, LA
UPDATE card_shops SET lat = 32.55916, lng = -93.781143 WHERE name = 'Legends on Jewella Ave in Shreveport, LA' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SHREVEPORT, LA
UPDATE card_shops SET lat = 30.007587, lng = -90.161165 WHERE name = 'MARKMAN SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: METAIRIE, LA
UPDATE card_shops SET lat = 29.946034, lng = -90.132592 WHERE name = 'Media Men Cards & Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: NEW ORLEANS, LA
UPDATE card_shops SET lat = 29.946034, lng = -90.132592 WHERE name = 'PSA Dealer: House of Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: NEW ORLEANS, LA
UPDATE card_shops SET lat = 29.946034, lng = -90.132592 WHERE name = 'PokéNOLA Collectibles in Metairie, LA 70003' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: NEW ORLEANS, LA
UPDATE card_shops SET lat = 32.55916, lng = -93.781143 WHERE name = 'SPORTSCARDS - LOUISIANA' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SHREVEPORT, LA
UPDATE card_shops SET lat = 31.05099, lng = -91.02906 WHERE name = 'Southeast Cards & Comics' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BATON ROUGE, LA
UPDATE card_shops SET lat = 32.55916, lng = -93.781143 WHERE name = 'SportsCards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SHREVEPORT, LA
UPDATE card_shops SET lat = 42.366049, lng = -71.105584 WHERE name = 'AMAYA BROS COMICS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CAMBRIDGE, MA
UPDATE card_shops SET lat = 42.339966, lng = -71.440532 WHERE name = 'Bob''s Hobbies & Collectibles, Springfield' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SPRINGFIELD, MA
UPDATE card_shops SET lat = 42.339966, lng = -71.440532 WHERE name = 'CardVault by Tom Brady' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BOSTON, MA
UPDATE card_shops SET lat = 42.339966, lng = -71.440532 WHERE name = 'Coin Exchange Inc.' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SPRINGFIELD, MA
UPDATE card_shops SET lat = 42.339966, lng = -71.440532 WHERE name = 'Dinn Bros Trophies Coupon Codes' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SPRINGFIELD, MA
UPDATE card_shops SET lat = 42.339966, lng = -71.440532 WHERE name = 'Gabriella Collectibles store – Worcester, Massachusetts' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WORCESTER, MA
UPDATE card_shops SET lat = 42.366049, lng = -71.105584 WHERE name = 'MarathonSports-Cambridge02138' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CAMBRIDGE, MA
UPDATE card_shops SET lat = 42.339966, lng = -71.440532 WHERE name = 'Massachusetts Sports Card Stores' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BOSTON, MA
UPDATE card_shops SET lat = 42.339966, lng = -71.440532 WHERE name = 'TCG House of Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WORCESTER, MA
UPDATE card_shops SET lat = 42.339966, lng = -71.440532 WHERE name = 'The Wizards Duel' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BOSTON, MA
UPDATE card_shops SET lat = 39.294305, lng = -76.615131 WHERE name = 'BASEBALL CARD OUTLET' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: BALTIMORE, MD
UPDATE card_shops SET lat = 39.556733, lng = -76.272679 WHERE name = 'BEL AIR SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: BEL AIR, MD
UPDATE card_shops SET lat = 39.294305, lng = -76.615131 WHERE name = 'Dave''s Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: BALTIMORE, MD
UPDATE card_shops SET lat = 39.056374, lng = -76.971087 WHERE name = 'HALL OF FAME CARDS INC.' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: POTOMAC, MD
UPDATE card_shops SET lat = 39.056374, lng = -76.971087 WHERE name = 'Hobby Works #2' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ROCKVILLE, MD
UPDATE card_shops SET lat = 39.294305, lng = -76.615131 WHERE name = 'Maryland' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: BALTIMORE, MD
UPDATE card_shops SET lat = 39.056374, lng = -76.971087 WHERE name = 'POPS SPORTS CARDS & GAMING' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ESSEX, MD
UPDATE card_shops SET lat = 39.056374, lng = -76.971087 WHERE name = 'PRIMETIME SPORTS COLLECTIBES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FREDERICK, MD
UPDATE card_shops SET lat = 39.056374, lng = -76.971087 WHERE name = 'Primetime Sports Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FREDERICK, MD
UPDATE card_shops SET lat = 39.556733, lng = -76.272679 WHERE name = 'SIMMS SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: BEL AIR, MD
UPDATE card_shops SET lat = 39.056374, lng = -76.971087 WHERE name = 'Star Hobby' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ANNAPOLIS, MD
UPDATE card_shops SET lat = 39.056374, lng = -76.971087 WHERE name = 'Tournament City Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FREDERICK, MD
UPDATE card_shops SET lat = 44.060566, lng = -69.703057 WHERE name = 'All Star Sportscards & Comics' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GAINESVILLE, ME
UPDATE card_shops SET lat = 44.060566, lng = -69.703057 WHERE name = 'Bangor Sports Collectables' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BANGOR, ME
UPDATE card_shops SET lat = 44.060566, lng = -69.703057 WHERE name = 'Bangor Sports Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BANGOR, ME
UPDATE card_shops SET lat = 44.060566, lng = -69.703057 WHERE name = 'Don Hontz' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PORTLAND, ME
UPDATE card_shops SET lat = 44.060566, lng = -69.703057 WHERE name = 'Don''s Sports Card Center' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PORTLAND, ME
UPDATE card_shops SET lat = 44.060566, lng = -69.703057 WHERE name = 'J&R Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BRUNSWICK, ME
UPDATE card_shops SET lat = 44.060566, lng = -69.703057 WHERE name = 'Maine' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BANGOR, ME
UPDATE card_shops SET lat = 44.060566, lng = -69.703057 WHERE name = 'Sports Cards & Collectibles Show' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WILMINGTON, ME
UPDATE card_shops SET lat = 43.624297, lng = -85.977049 WHERE name = 'ACE SPORTS & TRADING CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HOLLAND, MI
UPDATE card_shops SET lat = 43.624297, lng = -85.977049 WHERE name = 'ALL STAR SPORTS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WYOMING, MI
UPDATE card_shops SET lat = 43.624297, lng = -85.977049 WHERE name = 'All-Star Sportscards Apparel & Memorabilia' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GRAND RAPIDS, MI
UPDATE card_shops SET lat = 43.624297, lng = -85.977049 WHERE name = 'CURVEBALL COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SAGINAW, MI
UPDATE card_shops SET lat = 43.624297, lng = -85.977049 WHERE name = 'ChampsSportsin 3175 28th St. SE.GrandRapids,Michigan' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GRAND RAPIDS, MI
UPDATE card_shops SET lat = 43.624297, lng = -85.977049 WHERE name = 'FANFARE' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: KALAMAZOO, MI
UPDATE card_shops SET lat = 43.624297, lng = -85.977049 WHERE name = 'GRAND SLAM SPORTS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: STERLING HEIGHTS, MI
UPDATE card_shops SET lat = 43.624297, lng = -85.977049 WHERE name = 'HIDDEN GEMS CARD SHOP' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SHELBY TOWNSHIP, MI
UPDATE card_shops SET lat = 43.624297, lng = -85.977049 WHERE name = 'Higbee Enterprises' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LANSING, MI
UPDATE card_shops SET lat = 42.625863, lng = -83.033685 WHERE name = 'JAWBREAKERS CARD SHOP' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: UTICA, MI
UPDATE card_shops SET lat = 43.624297, lng = -85.977049 WHERE name = 'L.T.''s Hobbies & Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FLINT, MI
UPDATE card_shops SET lat = 43.624297, lng = -85.977049 WHERE name = 'LEGENDS SPORTS & GAMES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GRAND RAPIDS, MI
UPDATE card_shops SET lat = 43.624297, lng = -85.977049 WHERE name = 'LES''S SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BIRCH RUN, MI
UPDATE card_shops SET lat = 43.624297, lng = -85.977049 WHERE name = 'LEWTON''S SPORTS CARDS & COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CLAWSON, MI
UPDATE card_shops SET lat = 43.624297, lng = -85.977049 WHERE name = 'LEWTON''S SPORTS CARDS AND COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CLAWSON, MI
UPDATE card_shops SET lat = 43.624297, lng = -85.977049 WHERE name = 'Legends Fan Shop' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GRAND RAPIDS, MI
UPDATE card_shops SET lat = 43.624297, lng = -85.977049 WHERE name = 'Legends Sports and Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LANSING, MI
UPDATE card_shops SET lat = 43.624297, lng = -85.977049 WHERE name = 'MY EXTRA CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HARRISON, MI
UPDATE card_shops SET lat = 43.624297, lng = -85.977049 WHERE name = 'Michigan Sports Card Stores' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LANSING, MI
UPDATE card_shops SET lat = 43.624297, lng = -85.977049 WHERE name = 'ROCHESTER SPORTS CARDS & MEMORABILIA' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ROCHESTER, MI
UPDATE card_shops SET lat = 42.258617, lng = -83.660609 WHERE name = 'STADIUM CARDS AND COMICS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: YPSILANTI, MI
UPDATE card_shops SET lat = 43.624297, lng = -85.977049 WHERE name = 'THE SPORTS CARD SHOP AT MOCO' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NEW BUFFALO, MI
UPDATE card_shops SET lat = 43.624297, lng = -85.977049 WHERE name = 'THE STADIUM' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BAY CITY, MI
UPDATE card_shops SET lat = 43.624297, lng = -85.977049 WHERE name = 'The Locker Room' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: KALAMAZOO, MI
UPDATE card_shops SET lat = 43.624297, lng = -85.977049 WHERE name = 'UP NORTH COLLECTORS SPORTS CARDS & MORE' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MANISTEE, MI
UPDATE card_shops SET lat = 43.624297, lng = -85.977049 WHERE name = 'flint for sale "baseball cards"' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FLINT, MI
UPDATE card_shops SET lat = 45.070145, lng = -93.376507 WHERE name = 'ABSOLUTE SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SAVAGE, MN
UPDATE card_shops SET lat = 45.070145, lng = -93.376507 WHERE name = 'BrightonCollectiblesAmphora Drops Necklace at Mall of America® in...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BLOOMINGTON, MN
UPDATE card_shops SET lat = 45.070145, lng = -93.376507 WHERE name = 'CARDBOARD VAULT' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FARIBAULT, MN
UPDATE card_shops SET lat = 46.804574, lng = -92.160256 WHERE name = 'COLLECTOR''S CONNECTION DULUTH' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: DULUTH, MN
UPDATE card_shops SET lat = 45.070145, lng = -93.376507 WHERE name = 'COULEE CARDS & GAMING - ROCHESTER' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ROCHESTER, MN
UPDATE card_shops SET lat = 46.804574, lng = -92.160256 WHERE name = 'Carr''s Hobby Shop on Superior St in Duluth, MN' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: DULUTH, MN
UPDATE card_shops SET lat = 46.804574, lng = -92.160256 WHERE name = 'Collector''s Connection Ii' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: DULUTH, MN
UPDATE card_shops SET lat = 45.070145, lng = -93.376507 WHERE name = 'Coulee Cards & Gaming' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ROCHESTER, MN
UPDATE card_shops SET lat = 45.070145, lng = -93.376507 WHERE name = 'Coulee Cards & Gaming in Rochester, MN 55901' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ROCHESTER, MN
UPDATE card_shops SET lat = 46.804574, lng = -92.160256 WHERE name = 'Duluth Trading Company' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: DULUTH, MN
UPDATE card_shops SET lat = 45.070145, lng = -93.376507 WHERE name = 'Field of Dreams' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BLOOMINGTON, MN
UPDATE card_shops SET lat = 44.927596, lng = -93.247373 WHERE name = 'Hot Comics and Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: MINNEAPOLIS, MN
UPDATE card_shops SET lat = 45.070145, lng = -93.376507 WHERE name = 'MN SPORTSCARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MONTICELLO, MN
UPDATE card_shops SET lat = 44.927596, lng = -93.247373 WHERE name = 'Pat''s Old House of Antiques 612-926-1811' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: MINNEAPOLIS, MN
UPDATE card_shops SET lat = 45.070145, lng = -93.376507 WHERE name = 'REAL SPORTSCARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CHAMPLIN, MN
UPDATE card_shops SET lat = 45.070145, lng = -93.376507 WHERE name = 'THE FANZONE' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WILLMAR, MN
UPDATE card_shops SET lat = 45.070145, lng = -93.376507 WHERE name = 'THREE STARS SPORTSCARDS (BLOOMINGTON)' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BLOOMINGTON, MN
UPDATE card_shops SET lat = 45.070145, lng = -93.376507 WHERE name = 'TRIPLE DIAMOND SPORTS CARDS AND COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: EAGAN, MN
UPDATE card_shops SET lat = 45.070145, lng = -93.376507 WHERE name = 'Three Stars Sportscards, 8806 Lyndale Avenue S, Bloomington, MN' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BLOOMINGTON, MN
UPDATE card_shops SET lat = 45.070145, lng = -93.376507 WHERE name = 'Triple B Collectibles in Saint Paul, MN 55102' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ST PAUL, MN
UPDATE card_shops SET lat = 38.70836, lng = -92.907738 WHERE name = '5C Gaming / The Card Shop' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SPRINGFIELD, MO
UPDATE card_shops SET lat = 38.70836, lng = -92.907738 WHERE name = 'Action Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: KANSAS CITY, MO
UPDATE card_shops SET lat = 38.70836, lng = -92.907738 WHERE name = 'BASEBALL PLUS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SAINT PETERS, MO
UPDATE card_shops SET lat = 38.70836, lng = -92.907738 WHERE name = 'COLLECTOR STORE LLC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ST. CHARLES, MO
UPDATE card_shops SET lat = 38.70836, lng = -92.907738 WHERE name = 'ELITE COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: IMPERIAL, MO
UPDATE card_shops SET lat = 38.70836, lng = -92.907738 WHERE name = 'ENDLESS COMICS, GAMES & CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FLORISSANT, MO
UPDATE card_shops SET lat = 38.70836, lng = -92.907738 WHERE name = 'ENDLESS COMICS, GAMES & CARDS #2' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SAINT PETERS, MO
UPDATE card_shops SET lat = 38.70836, lng = -92.907738 WHERE name = 'Gift Shops |SaintLouis,MO- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ST LOUIS, MO
UPDATE card_shops SET lat = 38.70836, lng = -92.907738 WHERE name = 'GiftShops|SaintLouis,MO- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ST LOUIS, MO
UPDATE card_shops SET lat = 38.70836, lng = -92.907738 WHERE name = 'Hobby, Toy, andGameShops|Springfield,MO- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SPRINGFIELD, MO
UPDATE card_shops SET lat = 38.966927, lng = -92.376409 WHERE name = 'Hobbytown Usa on Peachtree Dr in Columbia, MO' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: COLUMBIA, MO
UPDATE card_shops SET lat = 38.70836, lng = -92.907738 WHERE name = 'KC''S FINEST SPORTS CARDS AND MEMORABILIA LLC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LIBERTY, MO
UPDATE card_shops SET lat = 38.70836, lng = -92.907738 WHERE name = 'KC''S FINEST SPORTS CARDS AND MEMORABILIA LLC 002' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BLUE SPRINGS, MO
UPDATE card_shops SET lat = 38.70836, lng = -92.907738 WHERE name = 'M & S SPORTSCARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BLUE SPRINGS, MO
UPDATE card_shops SET lat = 38.70836, lng = -92.907738 WHERE name = 'RESTLESSCRAFT BREAKERS SPORTS AND GAMING' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SAINT PETERS, MO
UPDATE card_shops SET lat = 38.70836, lng = -92.907738 WHERE name = 'RIGHT OFF THE BAT CARDS & COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WEST PLAINS, MO
UPDATE card_shops SET lat = 38.70836, lng = -92.907738 WHERE name = 'Sets' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SPRINGFIELD, MO
UPDATE card_shops SET lat = 38.70836, lng = -92.907738 WHERE name = 'Southern Hobby St Louis' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ST LOUIS, MO
UPDATE card_shops SET lat = 38.70836, lng = -92.907738 WHERE name = 'Sports Card Dugout in Saint Louis, MO 63119' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ST LOUIS, MO
UPDATE card_shops SET lat = 38.966927, lng = -92.376409 WHERE name = 'TM Memorabilia in Columbia, MO 65203' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: COLUMBIA, MO
UPDATE card_shops SET lat = 38.70836, lng = -92.907738 WHERE name = 'TRADING CARD MARKET' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MANCHESTER, MO
UPDATE card_shops SET lat = 38.966927, lng = -92.376409 WHERE name = 'The Dugout' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: COLUMBIA, MO
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'BLUFF CITY MEMORABILIA' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: SOUTHAVEN, MS
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Bluff City Cards & Sports Memorabilia' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: SOUTHAVEN, MS
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Hobby, Toy, andGameShops|Hattiesburg,MS- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: HATTIESBURG, MS
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'KwikShop-Southaven,MS38671' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: SOUTHAVEN, MS
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Mississippi' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: GULFPORT, MS
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Mississippi Hobby Shops' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: JACKSON, MS
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'One Up TCG Hattiesburg' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: HATTIESBURG, MS
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'P&T Trading Cards & Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: GULFPORT, MS
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'P&T Trading Cards & Collectibles – Gulfport, Mississippi ...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: GULFPORT, MS
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Play And Talk Gulfport Outlet Mall' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: GULFPORT, MS
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Shopping|Southaven,MS- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: SOUTHAVEN, MS
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Sportscards International Jackson MS, 39216' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: JACKSON, MS
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Van''s Comics, Cards and Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: JACKSON, MS
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Action Cards and Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: GREAT FALLS, MT
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Action Cards and Collectibles – Great Falls, Montana' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: GREAT FALLS, MT
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Bozeman Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: BOZEMAN, MT
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'GET EXCITED Cards & Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: BILLINGS, MT
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'GET EXCITED Cards & Collectibles – Billings, Montana' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: BILLINGS, MT
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'His and Hers Coins' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: GREAT FALLS, MT
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Kab Sports Cards & Collectables' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: BILLINGS, MT
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'MILLER SPORTS CARDS & COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: , MT
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Mt. Penn Sports Cards We Serve Memories Every Day – Reading ...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: READING, MT
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'My WordPress' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: MISSOULA, MT
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'NASHCARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: STE 340, MT
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Trading Card Shop' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: BILLINGS, MT
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'ZOOTOWN SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: MISSOULA, MT
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'sports cards and memorabilia Great Falls, MT 59401' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: GREAT FALLS, MT
UPDATE card_shops SET lat = 35.706149, lng = -80.035883 WHERE name = 'AAA Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MATTHEWS, NC
UPDATE card_shops SET lat = 35.706149, lng = -80.035883 WHERE name = 'Amusement Services |Salisbury,NC- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SALISBURY, NC
UPDATE card_shops SET lat = 35.706149, lng = -80.035883 WHERE name = 'Batters Up Trading Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NEW BERN, NC
UPDATE card_shops SET lat = 35.706149, lng = -80.035883 WHERE name = 'Buy & Sell Sports Cards Eastern NC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GREENVILLE, NC
UPDATE card_shops SET lat = 35.706149, lng = -80.035883 WHERE name = 'CARDIACS OF KANNAPOLIS LLC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: KANNAPOLIS, NC
UPDATE card_shops SET lat = 35.706149, lng = -80.035883 WHERE name = 'CARDIACS Sports & Memorabilia' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: KANNAPOLIS, NC
UPDATE card_shops SET lat = 36.053294, lng = -79.891092 WHERE name = 'CARDS AT THE CAGES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: GREENSBORO, NC
UPDATE card_shops SET lat = 35.213923, lng = -79.509431 WHERE name = 'CARDSINFINITY' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: WEST END, NC
UPDATE card_shops SET lat = 36.053294, lng = -79.891092 WHERE name = 'CURRY’S COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: GREENSBORO, NC
UPDATE card_shops SET lat = 35.706149, lng = -80.035883 WHERE name = 'Carolina Card Connection' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: STATESVILLE, NC
UPDATE card_shops SET lat = 35.706149, lng = -80.035883 WHERE name = 'Catch Em Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HUNTERSVILLE, NC
UPDATE card_shops SET lat = 35.706149, lng = -80.035883 WHERE name = 'Charlotte Sports Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CHARLOTTE, NC
UPDATE card_shops SET lat = 35.706149, lng = -80.035883 WHERE name = 'Collectors World' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GASTONIA, NC
UPDATE card_shops SET lat = 35.610953, lng = -82.55465 WHERE name = 'Fan-Tastic Cards & Comics' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: ASHEVILLE, NC
UPDATE card_shops SET lat = 35.706149, lng = -80.035883 WHERE name = 'Ford''s Cards & Coins' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CHARLOTTE, NC
UPDATE card_shops SET lat = 35.706149, lng = -80.035883 WHERE name = 'Gamers Alley' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GASTONIA, NC
UPDATE card_shops SET lat = 36.053294, lng = -79.891092 WHERE name = 'Greensboro''s Original Since 1983: This Week’s Comics' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: GREENSBORO, NC
UPDATE card_shops SET lat = 35.706149, lng = -80.035883 WHERE name = 'Home' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: JACKSONVILLE, NC
UPDATE card_shops SET lat = 35.706149, lng = -80.035883 WHERE name = 'IGNITION SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WILMINGTON, NC
UPDATE card_shops SET lat = 35.480475, lng = -80.858274 WHERE name = 'LUCKY BOX SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CORNELIUS, NC
UPDATE card_shops SET lat = 35.706149, lng = -80.035883 WHERE name = 'MIKE''S COINS AND COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GASTONIA, NC
UPDATE card_shops SET lat = 35.706149, lng = -80.035883 WHERE name = 'One Stop Sports' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CHARLOTTE, NC
UPDATE card_shops SET lat = 35.706149, lng = -80.035883 WHERE name = 'Palmetto Collectables' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CHARLOTTE, NC
UPDATE card_shops SET lat = 35.480475, lng = -80.858274 WHERE name = 'Parker Banner Kent & Wayne' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CORNELIUS, NC
UPDATE card_shops SET lat = 35.392988, lng = -80.653126 WHERE name = 'Pokemon Singles – Page 3' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CONCORD, NC
UPDATE card_shops SET lat = 35.171359, lng = -80.657083 WHERE name = 'Rally Squirrel Cards & Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: MINT HILL, NC
UPDATE card_shops SET lat = 35.706149, lng = -80.035883 WHERE name = 'Replay Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CHARLOTTE, NC
UPDATE card_shops SET lat = 35.706149, lng = -80.035883 WHERE name = 'SCORE MORE SPORTS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WINSTON SALEM, NC
UPDATE card_shops SET lat = 35.706149, lng = -80.035883 WHERE name = 'SCOTT''S COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: KANNAPOLIS, NC
UPDATE card_shops SET lat = 35.706149, lng = -80.035883 WHERE name = 'SPORTS COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SYLVA, NC
UPDATE card_shops SET lat = 35.706149, lng = -80.035883 WHERE name = 'Score More Sports Salisbury' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SALISBURY, NC
UPDATE card_shops SET lat = 36.053294, lng = -79.891092 WHERE name = 'Shop' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: GREENSBORO, NC
UPDATE card_shops SET lat = 35.706149, lng = -80.035883 WHERE name = 'ShoppingGastoniaNCNorthCarolina+ Outlet Mall' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GASTONIA, NC
UPDATE card_shops SET lat = 35.706149, lng = -80.035883 WHERE name = 'The Card Shop NC – Winston-Salem, North Carolina' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WINSTON-SALEM, NC
UPDATE card_shops SET lat = 35.706149, lng = -80.035883 WHERE name = 'Valentino Card Shop' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CHARLOTTE, NC
UPDATE card_shops SET lat = 35.706149, lng = -80.035883 WHERE name = 'YouthSportsin theWinston-SalemArea' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WINSTON-SALEM, NC
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Big Nick''s Sportscards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: FARGO, ND
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'DAKOTA GAMING SUPPLY, INC.' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: BISMARCK, ND
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Force of Habit HobbyShop-Minot,ND| Wargames.Com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: MINOT, ND
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Force of HabitHobbyShop-Minot,ND| Wargames.Com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: MINOT, ND
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Grand Slam Sportscards and Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: MINOT, ND
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'JWW Sports Cards & Gaming' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: FARGO, ND
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Map and Directions to Grand Cities Games in Grand Forks, ND 58203' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: GRAND FORKS, ND
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Paradox Comics-N-Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: FARGO, ND
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Sports Cards Memorabilia in Minot, ND' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: MINOT, ND
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'THE SPORTS CAVE' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: BISMARCK, ND
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'THE SPORTS SHAQ' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: MINOT, ND
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'The Sports Cave in Bismarck, ND 58504' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: BISMARCK, ND
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Triple Diamond Sports Cards & Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: FARGO, ND
UPDATE card_shops SET lat = 41.803817, lng = -97.046565 WHERE name = 'Baseballcardstore|OmahaSportsCards| United States' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: OMAHA, NE
UPDATE card_shops SET lat = 41.803817, lng = -97.046565 WHERE name = 'CMON' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: OMAHA, NE
UPDATE card_shops SET lat = 41.803817, lng = -97.046565 WHERE name = 'Castle Sports and Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CEDAR RAPIDS, NE
UPDATE card_shops SET lat = 41.803817, lng = -97.046565 WHERE name = 'Columbia Hobby' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: VANCOUVER, NE
UPDATE card_shops SET lat = 41.803817, lng = -97.046565 WHERE name = 'Football Card Store' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: OMAHA, NE
UPDATE card_shops SET lat = 41.803817, lng = -97.046565 WHERE name = 'GI Card Shop' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GRAND ISLAND, NE
UPDATE card_shops SET lat = 41.803817, lng = -97.046565 WHERE name = 'GI Card Shop in Grand Island, NE 68803' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GRAND ISLAND, NE
UPDATE card_shops SET lat = 41.803817, lng = -97.046565 WHERE name = 'Johnny Ford Sports Cards & Memorabilia' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GRAND RAPIDS, NE
UPDATE card_shops SET lat = 41.803817, lng = -97.046565 WHERE name = 'Local Card Shops' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SEATTLE, NE
UPDATE card_shops SET lat = 41.803817, lng = -97.046565 WHERE name = 'OMAHA SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: OMAHA, NE
UPDATE card_shops SET lat = 41.803817, lng = -97.046565 WHERE name = 'Omaha Sports Cards in Omaha, NE 68137' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: OMAHA, NE
UPDATE card_shops SET lat = 41.803817, lng = -97.046565 WHERE name = 'PREP 2 PRO SPORTS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NORFOLK, NE
UPDATE card_shops SET lat = 40.737698, lng = -96.700462 WHERE name = 'SPORTS FANtastic' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: LINCOLN, NE
UPDATE card_shops SET lat = 41.803817, lng = -97.046565 WHERE name = 'Super Sports Cards and More' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: VANCOUVER, NE
UPDATE card_shops SET lat = 41.803817, lng = -97.046565 WHERE name = 'Super Sports Cards in Vancouver, WA 98661' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: VANCOUVER, NE
UPDATE card_shops SET lat = 40.737698, lng = -96.700462 WHERE name = 'Tap Into The Best Source for Magic!' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: LINCOLN, NE
UPDATE card_shops SET lat = 41.803817, lng = -97.046565 WHERE name = 'The Card Shop' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: OMAHA, NE
UPDATE card_shops SET lat = 41.803817, lng = -97.046565 WHERE name = 'The Card Shop in Omaha, NE 68137' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: OMAHA, NE
UPDATE card_shops SET lat = 42.991565, lng = -71.462696 WHERE name = 'Collector''s Heaven' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: MANCHESTER, NH
UPDATE card_shops SET lat = 43.91693, lng = -71.863672 WHERE name = 'NHSportsMemorabilia' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PHOENIX, NH
UPDATE card_shops SET lat = 42.991565, lng = -71.462696 WHERE name = 'New Hampshire Sports Card Stores' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: MANCHESTER, NH
UPDATE card_shops SET lat = 42.991565, lng = -71.462696 WHERE name = 'Quinns Trading Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: MANCHESTER, NH
UPDATE card_shops SET lat = 42.991565, lng = -71.462696 WHERE name = 'Quinns Trading Cards in Manchester, NH 03103' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: MANCHESTER, NH
UPDATE card_shops SET lat = 42.991565, lng = -71.462696 WHERE name = 'VisitCardCzar Your LocalCardShopInManchesterNH' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: MANCHESTER, NH
UPDATE card_shops SET lat = 42.991565, lng = -71.462696 WHERE name = 'VisitCardCzar YourLocalCardShopInManchesterNH' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: MANCHESTER, NH
UPDATE card_shops SET lat = 40.450074, lng = -74.722936 WHERE name = 'ACTION VIDEO & SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MANTUA, NJ
UPDATE card_shops SET lat = 40.450074, lng = -74.722936 WHERE name = 'BANKER BILLS COLLECTABLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HILLSBOROUGH, NJ
UPDATE card_shops SET lat = 40.450074, lng = -74.722936 WHERE name = 'BERGEN COUNTY SPORTS CARDS (D/B/A)' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BERGENFIELD, NJ
UPDATE card_shops SET lat = 40.450074, lng = -74.722936 WHERE name = 'BOB BECK SPORTS COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LIVINGSTON, NJ
UPDATE card_shops SET lat = 40.450074, lng = -74.722936 WHERE name = 'BOB''S SPORTS CARDS & MEMORABILIA' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HOWELL, NJ
UPDATE card_shops SET lat = 40.450074, lng = -74.722936 WHERE name = 'BaseballCardStoreInc' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BEND, NJ
UPDATE card_shops SET lat = 39.94213, lng = -75.150575 WHERE name = 'Bill''s Sports Cards & Memorabilia' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: PHILADELPHIA, NJ
UPDATE card_shops SET lat = 40.450074, lng = -74.722936 WHERE name = 'Bodega Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: JERSEY CITY, NJ
UPDATE card_shops SET lat = 40.450074, lng = -74.722936 WHERE name = 'CARD CAVE CENTRAL' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: UNION, NJ
UPDATE card_shops SET lat = 40.450074, lng = -74.722936 WHERE name = 'CENTURY JEWELERS & LOAN' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LAKEWOOD, NJ
UPDATE card_shops SET lat = 40.450074, lng = -74.722936 WHERE name = 'Card-O-Rama Shop in Newark, NJ 07102' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NEWARK, NJ
UPDATE card_shops SET lat = 40.450074, lng = -74.722936 WHERE name = 'EAST COAST CONNECTION LLC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LYNDHURST, NJ
UPDATE card_shops SET lat = 40.450074, lng = -74.722936 WHERE name = 'Elaines Fine Art andSportsMemorabiliainNewYork.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: JERSEY CITY, NJ
UPDATE card_shops SET lat = 40.852892, lng = -74.827992 WHERE name = 'HIDDEN GEM SPORTS COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: HACKETTSTOWN, NJ
UPDATE card_shops SET lat = 40.450074, lng = -74.722936 WHERE name = 'Hobby, Toy, andGameShops|Edison,NJ- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: EDISON, NJ
UPDATE card_shops SET lat = 40.450074, lng = -74.722936 WHERE name = 'JerseyFraming' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: EDISON, NJ
UPDATE card_shops SET lat = 40.450074, lng = -74.722936 WHERE name = 'Market Place At Garden State Park' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CHERRY HILL, NJ
UPDATE card_shops SET lat = 40.450074, lng = -74.722936 WHERE name = 'Monmouth Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: STAMFORD, NJ
UPDATE card_shops SET lat = 40.450074, lng = -74.722936 WHERE name = 'NEW CONCEPT SPORTS CARD AND HOBBY' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MEDFORD, NJ
UPDATE card_shops SET lat = 40.450074, lng = -74.722936 WHERE name = 'PSA Dealer: SportsCardLink.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HOBOKEN, NJ
UPDATE card_shops SET lat = 40.450074, lng = -74.722936 WHERE name = 'PT Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: EDISON, NJ
UPDATE card_shops SET lat = 40.450074, lng = -74.722936 WHERE name = 'RP SPECIALTY SPORTSCARDS UNLIMITED' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ROCKAWAY, NJ
UPDATE card_shops SET lat = 40.450074, lng = -74.722936 WHERE name = 'SANTIAGO SPORTS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MATAWAN, NJ
UPDATE card_shops SET lat = 40.450074, lng = -74.722936 WHERE name = 'THE BASEBALL CARD STORE,INC.' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MIDLAND PARK, NJ
UPDATE card_shops SET lat = 40.450074, lng = -74.722936 WHERE name = 'THE CARD CAPITAL' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: COLLINGSWOOD, NJ
UPDATE card_shops SET lat = 40.450074, lng = -74.722936 WHERE name = 'The Backstop' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: TOMS RIVER, NJ
UPDATE card_shops SET lat = 40.450074, lng = -74.722936 WHERE name = 'WOW SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: RANDOLPH, NJ
UPDATE card_shops SET lat = 35.662627, lng = -105.976393 WHERE name = 'Best 1 Sports Cards Memorabilia in Santa Fe, NM' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SANTA FE, NM
UPDATE card_shops SET lat = 35.662627, lng = -105.976393 WHERE name = 'Big Adventure Comics' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SANTA FE, NM
UPDATE card_shops SET lat = 35.276042, lng = -106.371569 WHERE name = 'Buckskins Trading Post' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LAS CRUCES, NM
UPDATE card_shops SET lat = 35.276042, lng = -106.371569 WHERE name = 'Ladies Used Clothing Boutique -LaTienda de Jardin inLasCruces' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LAS CRUCES, NM
UPDATE card_shops SET lat = 35.662627, lng = -105.976393 WHERE name = 'Marcy Street Card Shop' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SANTA FE, NM
UPDATE card_shops SET lat = 35.662627, lng = -105.976393 WHERE name = 'PokemonSnorlax Starry Night Van Gogh Beautiful Moon ACG...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SANTA FE, NM
UPDATE card_shops SET lat = 35.082749, lng = -106.569157 WHERE name = 'The Old Town Card Shop on Old Town Rd in Albuquerque, NM' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: ALBUQUERQUE, NM
UPDATE card_shops SET lat = 35.276042, lng = -106.371569 WHERE name = 'Zia Comics' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LAS CRUCES, NM
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Aloha Card Shop' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: LAS VEGAS, NV
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Gameday Sports Cards in Henderson, NV 89052' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: HENDERSON, NV
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'LEGACY SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: LAS VEGAS, NV
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'My 4 Sons Comics Cards & Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: HENDERSON, NV
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'PARADISE CARD BREAKS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: LAS VEGAS, NV
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'PSA Dealer: Card Shop Live' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: HENDERSON, NV
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'PSA Dealer: Gameday Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: HENDERSON, NV
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'THE AWESOME CARD SHOP' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: LAS VEGAS, NV
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'The Blez -LasVegas,NV| about.me' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: LAS VEGAS, NV
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'A&S SPORTS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WESTBURY, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'AAN COLLECT' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NEW HARTFORD, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'ALEX''S MVP CARDS AND COMICS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NEW YORK, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'AMERICAN LEGENDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SCARSDALE, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'All Sport Collectors Gallery' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SYRACUSE, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'BASEBALL CARDS SHOWCASE' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WANTAGH, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'BASES LOADED SPORTS COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WEST SENECA, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'BLEECKER TRADING' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NEW YORK, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'BP SPORTS CARDS AND MEMORABILIA, INC.' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FLORIDA, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'CARD SHACK' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LYNBROOK, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'CHAMPION CARD COLLECTOR' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: POUGHKEEPSIE, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'COOPERSTOWN CONNECTION' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SYRACUSE, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'Collector Cave' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: YONKERS, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'DIAMOND CLUB CARDS AND COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PHELPS, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'DOC D''S TRADING CARDS LLC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BELLMORE, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'E AND J BOUTIQUE' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BROOKLYN, NY
UPDATE card_shops SET lat = 43.132104, lng = -77.547357 WHERE name = 'Fumbles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: ROCHESTER, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'GALAXY OF STARS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LIVERPOOL, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'GG Cards and Breaks' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SYRACUSE, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'Gift, Novelty, and SouvenirShops|Yonkers,NY- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: YONKERS, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'Great American' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: YONKERS, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'Hobby, Toy, andGameShops|Buffalo,NY- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BUFFALO, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'LONG ISLAND SPORTS CARDS INC.' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ALBERTSON, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'MAJOR SPORTS CARDS & MEMORABILIA' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MINEOLA, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'MLB FLAGSHIP STORE' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NEW YORK, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'MONTASY COMICS NYC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NEW YORK, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'NATIONAL BASEBALL HALL OF FAME' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: COOPERSTOWN, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'NEW YORK ROADSHOW SHOP' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BRONXVILLE, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'ORIGINAL COOPERSTOWN CONNECTION' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NEW HARTFORD, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'Official NBA Memorabilia' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NEW YORK CITY, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'PIECE OF THE GAME' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WAPPINGERS FALLS, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'THE VALLEY SPORTSCARDS & COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HERKIMER, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'TOYWIZ COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NANUET, NY
UPDATE card_shops SET lat = 43.132104, lng = -77.547357 WHERE name = 'WETHEHOBBY' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: ROCHESTER, NY
UPDATE card_shops SET lat = 42.600331, lng = -76.557344 WHERE name = 'YASTRZEMSKI SPORTS INC.' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: COOPERSTOWN, NY
UPDATE card_shops SET lat = 43.132104, lng = -77.547357 WHERE name = 'Yankee Clipper House of Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: ROCHESTER, NY
UPDATE card_shops SET lat = 41.13042, lng = -81.50786 WHERE name = 'ALL-PRO SPORTSCARDS LLC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CUYAHOGA FALLS, OH
UPDATE card_shops SET lat = 39.770869, lng = -84.106772 WHERE name = 'All American Trading Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: DAYTON, OH
UPDATE card_shops SET lat = 40.732033, lng = -82.301575 WHERE name = 'B&B SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FAIRVIEW PARK, OH
UPDATE card_shops SET lat = 40.732033, lng = -82.301575 WHERE name = 'CARD STOCKS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LIBERTY TOWNSHIP, OH
UPDATE card_shops SET lat = 40.732033, lng = -82.301575 WHERE name = 'CARDCOLLECTOR2 SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GROVE CITY, OH
UPDATE card_shops SET lat = 40.732033, lng = -82.301575 WHERE name = 'CHAMPION CITY VIDEO GAMES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SPRINGFIELD, OH
UPDATE card_shops SET lat = 40.732033, lng = -82.301575 WHERE name = 'Channel -TCGShop' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ROCHESTER, OH
UPDATE card_shops SET lat = 40.732033, lng = -82.301575 WHERE name = 'Checkmate Games and Hobbies' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: TOLEDO, OH
UPDATE card_shops SET lat = 40.732033, lng = -82.301575 WHERE name = 'D & P Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SACRAMENTO, OH
UPDATE card_shops SET lat = 40.732033, lng = -82.301575 WHERE name = 'ENC Sports Cards, 112 S Business Plaza, New Bern, NC (2026)Home' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NEW BERN, OH
UPDATE card_shops SET lat = 39.770869, lng = -84.106772 WHERE name = 'Epic Loot Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: DAYTON, OH
UPDATE card_shops SET lat = 40.732033, lng = -82.301575 WHERE name = 'FATHER-SON SPORTS CARDS & COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: POWELL, OH
UPDATE card_shops SET lat = 40.732033, lng = -82.301575 WHERE name = 'Freedom Hobby & Gaming' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CANTON, OH
UPDATE card_shops SET lat = 40.732033, lng = -82.301575 WHERE name = 'GAME TIME SPORTS COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CIRCLVILLE, OH
UPDATE card_shops SET lat = 40.732033, lng = -82.301575 WHERE name = 'GEM CITY COLLECTS SPORTS CARDS & MEMORABILA' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FAIRBORN, OH
UPDATE card_shops SET lat = 40.732033, lng = -82.301575 WHERE name = 'HIT KINGS SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CINCINNATI, OH
UPDATE card_shops SET lat = 40.732033, lng = -82.301575 WHERE name = 'HOOTERVILLE SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FAIRFIELD, OH
UPDATE card_shops SET lat = 39.770869, lng = -84.106772 WHERE name = 'HobbyShop(Dayton) Jan 24th 40K Tournament' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: DAYTON, OH
UPDATE card_shops SET lat = 40.732033, lng = -82.301575 WHERE name = 'JUMBO''S SPORTS COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LIMA, OH
UPDATE card_shops SET lat = 40.732033, lng = -82.301575 WHERE name = 'LEBANON CANDY AND SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LEBANON, OH
UPDATE card_shops SET lat = 40.732033, lng = -82.301575 WHERE name = 'MEDINA SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MEDINA, OH
UPDATE card_shops SET lat = 40.732033, lng = -82.301575 WHERE name = 'MOMMA TRIED SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SANDUSKY, OH
UPDATE card_shops SET lat = 41.059861, lng = -81.529422 WHERE name = 'Magic City Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: AKRON, OH
UPDATE card_shops SET lat = 40.732033, lng = -82.301575 WHERE name = 'NEUHART CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: DELAWARE, OH
UPDATE card_shops SET lat = 40.732033, lng = -82.301575 WHERE name = 'OHIO CARD EXCHANGE' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CENTERVILLE, OH
UPDATE card_shops SET lat = 41.406477, lng = -81.734274 WHERE name = 'OHIO ESTATES COIN LLC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: PARMA, OH
UPDATE card_shops SET lat = 40.732033, lng = -82.301575 WHERE name = 'OVER THE FENCE' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: EASTLAKE, OH
UPDATE card_shops SET lat = 40.732033, lng = -82.301575 WHERE name = 'Rick''s Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CANTON, OH
UPDATE card_shops SET lat = 40.732033, lng = -82.301575 WHERE name = 'SHELBY COUNTY COLLECTIBLES INC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PIQUA, OH
UPDATE card_shops SET lat = 39.770869, lng = -84.106772 WHERE name = 'Schumer''s Cards and Comics' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: DAYTON, OH
UPDATE card_shops SET lat = 40.732033, lng = -82.301575 WHERE name = 'Sports Archives' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CANTON, OH
UPDATE card_shops SET lat = 40.001037, lng = -82.930195 WHERE name = 'Sports Card Shop' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: COLUMBUS, OH
UPDATE card_shops SET lat = 40.732033, lng = -82.301575 WHERE name = 'Sports Cards and Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: TOLEDO, OH
UPDATE card_shops SET lat = 39.770869, lng = -84.106772 WHERE name = 'TCI SPORTS FAN' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: DAYTON, OH
UPDATE card_shops SET lat = 40.732033, lng = -82.301575 WHERE name = 'TRIPLE PLAY SPORTS CARDS & MEMORABILIA' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WESTERVILLE, OH
UPDATE card_shops SET lat = 35.379982, lng = -99.007526 WHERE name = 'Azlin''s Sports Cards & Technologies in Norman, OK 73072' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NORMAN, OK
UPDATE card_shops SET lat = 35.379982, lng = -99.007526 WHERE name = 'Hobby, Toy, andGameShops|BrokenArrow,OK- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BROKEN ARROW, OK
UPDATE card_shops SET lat = 35.379982, lng = -99.007526 WHERE name = 'KardboardInk Sports cards & Memorabilia' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BROKEN ARROW, OK
UPDATE card_shops SET lat = 35.322623, lng = -97.485996 WHERE name = 'MM7 SPORTSCARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: MOORE, OK
UPDATE card_shops SET lat = 35.379982, lng = -99.007526 WHERE name = 'MTECH CAVE' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: STILWELL, OK
UPDATE card_shops SET lat = 35.52462, lng = -97.600924 WHERE name = 'On Deck' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: OKLAHOMA CITY, OK
UPDATE card_shops SET lat = 35.379982, lng = -99.007526 WHERE name = 'S + S Sportscards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BROKEN ARROW, OK
UPDATE card_shops SET lat = 35.379982, lng = -99.007526 WHERE name = 'Starbase 21' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: TULSA, OK
UPDATE card_shops SET lat = 35.379982, lng = -99.007526 WHERE name = 'The Dugout Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NORMAN, OK
UPDATE card_shops SET lat = 35.379982, lng = -99.007526 WHERE name = 'Vintage Stock' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: TULSA, OK
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = '314 Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ST LOUIS, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = '931sportscards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: COOKEVILLE, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'A & J SPORTS CARDS, LLC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: EUGENE, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'Athlon Sports' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NASHVILLE, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'Best 4SportsCardsMemorabiliainEugene...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: EUGENE, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'Bonfire Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: TAMPA, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'Buy One Get One Free' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NAMPA, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'Buy Sell Old Vintage Baseball Cards Football Cards Basketball Cards ...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SAN DIEGO, OR
UPDATE card_shops SET lat = 45.491939, lng = -122.831372 WHERE name = 'CARDS N HOBBY' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: BEAVERTON, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'CardPop Up!' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ROCKFORD, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'Cardhalla' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LARAMIE, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'Casino Nova Scotia -Halifax& Sydney' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HALIFAX, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'Contact — Cardhalla' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LARAMIE, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'Cosmic Card Shop' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SALEM, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'First State Coin' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: DOVER, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'FortWorthTXDesigner Greeting/BirthdayCardsFor Friends And...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FORT WORTH, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'Friends open comic,sportsmemorabiliashopinWaco, say people...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WACO, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'Game Vault El Paso' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: EL PASO, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'Gazelle SportsKalamazoo' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: KALAMAZOO, OR
UPDATE card_shops SET lat = 44.066446, lng = -121.309454 WHERE name = 'HOODY''S COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: BEND, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'HOOKERS SPORTSCARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: EUGENE, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'MK Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CAMBRIDGE, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'Magic The Gathering Singles And Sealed – Fact Or Fiction Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: DARTMOUTH, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'Marty''s Sports Card Exchange Superstore' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CHATTANOOGA, OR
UPDATE card_shops SET lat = 42.344007, lng = -122.871642 WHERE name = 'Mvp Sports Cards and Memorabilia' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: MEDFORD, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'Olympic Sports Cards and Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CALGARY, OR
UPDATE card_shops SET lat = 45.516131, lng = -122.618067 WHERE name = 'Oregon Sports Card Stores' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: PORTLAND, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'PULLING THE PROS SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NEWPORT, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'Pokémon TCG Sealed Product & Singles @ Most Wanted Dartmouth' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: DARTMOUTH, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'RON''S COINS & COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CEDAR RAPIDS, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'Shoe & Sneaker StoreinBatonRouge| JDSportsat Mall ofLouisiana' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BATON ROUGE, OR
UPDATE card_shops SET lat = 45.491939, lng = -122.831372 WHERE name = 'SportingGoods Stores and BicycleShops|Beaverton...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: BEAVERTON, OR
UPDATE card_shops SET lat = 45.516131, lng = -122.618067 WHERE name = 'SportsMemorabilia& AutographedSportsCollectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: PORTLAND, OR
UPDATE card_shops SET lat = 44.066446, lng = -121.309454 WHERE name = 'Spot It' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: BEND, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'Stores' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MEMPHIS, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'Stuart''s Hollywood Collectibles, Salem OR (503) 375-6109' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SALEM, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'The Barn on Country Club: Great Selection ofCollectiblesfor Home or...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WINSTON-SALEM, OR
UPDATE card_shops SET lat = 45.042234, lng = -122.840462 WHERE name = 'Trading Cards: Baseball or Other Sports, Entertainment, Etc.' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CHARLESTON, OR
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'BASEBALL CARD CASTLE INC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: , PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'Baseball CardShopsinPhiladelphia,PA|SportsMemorabilia...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PHILADELPHIA, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'BaseballCardShopsinPhiladelphia,PA|SportsMemorabilia...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PHILADELPHIA, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'CARD COLLECTING MAIA' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HAMBURG, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'CARD STADIUM' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HARRISBURG, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'CHALFONT SPORTS CONNECTION' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NEW BRITAIN, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'DGN SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ORWIGSBURG, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'East Side Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ALLENTOWN, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'GARDEN OF EARTHLY DELIGHTS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PHILADELPHIA, PA
UPDATE card_shops SET lat = 40.423355, lng = -79.98786 WHERE name = 'GREENTREE SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: PITTSBURGH, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'JUNIATA CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ALTOONA, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'KEL''S SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BRIDGEVILLE, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'KERMS CARD SHOP' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GREENCASTLE, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'KINEMS SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ERIE, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'LOGANS SPORTS COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: EASTON, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'Lou''s Baseball Card Dugout' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PHILADELPHIA, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'MACE MERCHANDISE CARD & COIN' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SCRANTON, PA
UPDATE card_shops SET lat = 40.038711, lng = -76.30658 WHERE name = 'MVP SPORTS & GAMES CO' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: LANCASTER, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'Mace Merchandise Card and Coin' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SCRANTON, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'NASHCARDS PHILADELPHIA' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: TRAPPE, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'Pennsylvania' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ALLENTOWN, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'Philly TCG' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PHILADELPHIA, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'RANDY''S SPORTCARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: QUAKERTOWN, PA
UPDATE card_shops SET lat = 40.038711, lng = -76.30658 WHERE name = 'RED ROSE SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: LANCASTER, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'S&B SPORTS COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: NORTH WALES, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'SCG HOBBY - ALTOONA' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ALTOONA, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'SCG HOBBY - INDIANA' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: INDIANA, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'SPORTS CARD CORNER' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FREELAND, PA
UPDATE card_shops SET lat = 40.423355, lng = -79.98786 WHERE name = 'SPORTS CARD JUNCTION LLC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: PITTSBURGH, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'SPORTS CONNECTION' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: DOYLESTOWN, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'SPORTS ZONE TOYS & COMICS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SUNBURY, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'SPORTSAMERICA SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MECHANICSBURG, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'SPORTSCARDS ETC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MC KEES ROCKS, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'STEEL CITY COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WHITE OAK, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'STODY LLC DBA/ SCG HOBBY - LATROBE' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LATROBE, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'THE BASEBALL CARD SHOP' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HERMITAGE, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'TJT SPORTS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LEBANON, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'Turn 2 Sports Cards & Collectibles in Erie, PA 16506' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ERIE, PA
UPDATE card_shops SET lat = 40.038711, lng = -76.30658 WHERE name = 'VSM SPORTS CARD OUTLET' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: LANCASTER, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'WHEELHOUSE CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WAYNE, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'WOW PA SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: HARRISBURG, PA
UPDATE card_shops SET lat = 40.291567, lng = -78.150234 WHERE name = 'YAREM ENTERPRISES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SCRANTON, PA
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Card Stores' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: WARWICK, RI
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Now & Then Sports Cards and Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: WARWICK, RI
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Now & Then Sports Cards and Collectibles – Warwick, Rhode ...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: WARWICK, RI
UPDATE card_shops SET lat = 32.907861, lng = -79.974182 WHERE name = 'Baseball CardShopsinGreenville,SC|SportsMemorabiliaStores...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GREENVILLE, SC
UPDATE card_shops SET lat = 32.907861, lng = -79.974182 WHERE name = 'BaseballCardShopsinGreenville,SC| Sports Memorabilia Stores...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GREENVILLE, SC
UPDATE card_shops SET lat = 32.907861, lng = -79.974182 WHERE name = 'BaseballCardShopsinGreenville,SC|SportsMemorabilia Stores...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GREENVILLE, SC
UPDATE card_shops SET lat = 32.907861, lng = -79.974182 WHERE name = 'COLLECTOR''S CORNER' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CHARLESTON, SC
UPDATE card_shops SET lat = 32.907861, lng = -79.974182 WHERE name = 'Cheerful TCG LLC in Spartanburg, SC 29301' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SPARTANBURG, SC
UPDATE card_shops SET lat = 32.907861, lng = -79.974182 WHERE name = 'Collecting Problems' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FORT MILL, SC
UPDATE card_shops SET lat = 32.907861, lng = -79.974182 WHERE name = 'Dad''s Gallery of Stars' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: COLUMBIA, SC
UPDATE card_shops SET lat = 32.907861, lng = -79.974182 WHERE name = 'Grand Slam Cards & Comics' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ROCK HILL, SC
UPDATE card_shops SET lat = 32.907861, lng = -79.974182 WHERE name = 'MEELYPOPS SC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SPARTANBURG, SC
UPDATE card_shops SET lat = 32.907861, lng = -79.974182 WHERE name = 'PSA Dealer: Bryan Sports Cards & More' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GREENVILLE, SC
UPDATE card_shops SET lat = 32.907861, lng = -79.974182 WHERE name = 'R & R Collectibles, Myrtle Beach, SC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MYRTLE BEACH, SC
UPDATE card_shops SET lat = 32.907861, lng = -79.974182 WHERE name = 'R&R Collectables' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MYRTLE BEACH, SC
UPDATE card_shops SET lat = 32.907861, lng = -79.974182 WHERE name = 'Spring Valley Trading Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: COLUMBIA, SC
UPDATE card_shops SET lat = 32.907861, lng = -79.974182 WHERE name = 'Spring Valley Trading Cards – Columbia, South Carolina' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: COLUMBIA, SC
UPDATE card_shops SET lat = 32.907861, lng = -79.974182 WHERE name = 'The 10th Inning Sportsworld' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SPARTANBURG, SC
UPDATE card_shops SET lat = 32.907861, lng = -79.974182 WHERE name = 'Upstate Card Show' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SPARTANBURG, SC
UPDATE card_shops SET lat = 44.291642, lng = -103.543482 WHERE name = 'Rainbow Comics, Cards & Collectibles – Sioux Falls, South ...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SIOUX FALLS, SD
UPDATE card_shops SET lat = 44.291642, lng = -103.543482 WHERE name = 'TRIPLE PLAY SPORTS CARDS INC.' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SIOUX FALLS, SD
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = '28 The mountains are calling... ideas' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SEVIERVILLE, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = '931 Sports Cards & Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: COOKEVILLE, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = '931 Sports Cards & Collectibles – Cookeville, Tennessee' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: COOKEVILLE, TN
UPDATE card_shops SET lat = 35.012353, lng = -85.211023 WHERE name = 'ALL STAR SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CHATTANOOGA, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'Academy Sports + Outdoors' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: COLLIERVILLE, TN
UPDATE card_shops SET lat = 35.012353, lng = -85.211023 WHERE name = 'All Star Case Breaks' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CHATTANOOGA, TN
UPDATE card_shops SET lat = 35.012353, lng = -85.211023 WHERE name = 'All Star Sports Cards / Case Breaks' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CHATTANOOGA, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'Antiques FurnitureStoresMaryvilleTn' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MARYVILLE, TN
UPDATE card_shops SET lat = 35.18958, lng = -84.865366 WHERE name = 'Bargy''s Cards and Board Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CLEVELAND, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'Best 9SportsCardsMemorabiliainBartlett,TNwith Reviews' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BARTLETT, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'Big D''s Baseball Cards and Comic' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: COOKEVILLE, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'Card Shops' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FRANKLIN, TN
UPDATE card_shops SET lat = 36.071595, lng = -86.637944 WHERE name = 'Cards R Fun' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: NASHVILLE, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'Collector''s Choice of Knoxville' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: KNOXVILLE, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'DC SPORTS CARDS & COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PARSONS, TN
UPDATE card_shops SET lat = 35.012353, lng = -85.211023 WHERE name = 'Epikos Comics Cards & Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CHATTANOOGA, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'FOW' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: KINGSPORT, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'GRAND SLAM COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MURFREESBORO, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'HBZ Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: KINGSPORT, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'HBZ Sports Cards – Kingsport, Tennessee' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: KINGSPORT, TN
UPDATE card_shops SET lat = 35.012353, lng = -85.211023 WHERE name = 'Infinity Flux' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CHATTANOOGA, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'JD''s Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MEMPHIS, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'Jackson''sCardShop-Jackson,TN| SportsCard-Stores.Com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: JACKSON, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'JewelryStores|Maryville,TN- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MARYVILLE, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'LocalCardShops| The Bench' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BARTLETT, TN
UPDATE card_shops SET lat = 35.012353, lng = -85.211023 WHERE name = 'Marty''s Sports Card Exchange' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CHATTANOOGA, TN
UPDATE card_shops SET lat = 35.012353, lng = -85.211023 WHERE name = 'Marty''s Trading Card Exchange' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CHATTANOOGA, TN
UPDATE card_shops SET lat = 35.012353, lng = -85.211023 WHERE name = 'Marty''s Trading Card Exchange (Cranks TCG) – Chattanooga ...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CHATTANOOGA, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'NASHCARDS MEMPHIS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: LAKELAND, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'PSA Dealer: 931 Sports Cards & Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: COOKEVILLE, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'Play To Win Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: KNOXVILLE, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'SPORTS TREASURES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: KNOXVILLE, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'Services' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: JACKSON, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'ShoppingCookevilleTNTennessee+ Outlet Mall' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: COOKEVILLE, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'Smokey Mountin Sports Card and Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SEVIERVILLE, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'Sport Card Investments' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: KNOXVILLE, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'Sports Cards, Memorabilia, Autographs, Hobby Boxes' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: COLLIERVILLE, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'Sports Memorabilia & Autographed Sports Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: JOHNSON CITY, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'TNC SPORTS/TENNESSEE CARD' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: BARTLETT, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'TRIPLE CROWN SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GERMANTOWN, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'TargetKingsportStore,Kingsport,TN' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: KINGSPORT, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'Tennessee Sports Card Stores' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: KNOXVILLE, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'The Sports Authority' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MEMPHIS, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'The Supply Place' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: JACKSON, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = 'UNDERDOG COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: KNOXVILLE, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = '[24 Hr Self Storage' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: KINGSPORT, TN
UPDATE card_shops SET lat = 35.424509, lng = -85.571444 WHERE name = '[Suitable Self Storage' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: JACKSON, TN
UPDATE card_shops SET lat = 30.657968, lng = -97.410293 WHERE name = 'BANKSTON''S COMICS & SPORTSCARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WACO, TX
UPDATE card_shops SET lat = 30.657968, lng = -97.410293 WHERE name = 'BEAST SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PLANO, TX
UPDATE card_shops SET lat = 29.481735, lng = -98.575016 WHERE name = 'BOOMTOWN SPORTS CARDS & COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SAN ANTONIO, TX
UPDATE card_shops SET lat = 29.481735, lng = -98.575016 WHERE name = 'Baseball CardShopsinSanAntonio,TX|SportsMemorabilia...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SAN ANTONIO, TX
UPDATE card_shops SET lat = 30.657968, lng = -97.410293 WHERE name = 'CARDS IN A BOX' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FRISCO, TX
UPDATE card_shops SET lat = 27.706719, lng = -97.360786 WHERE name = 'Capt. John''s Sports Cards and Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CORPUS CHRISTI, TX
UPDATE card_shops SET lat = 30.364875, lng = -97.738443 WHERE name = 'Card Traders of Austin' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: AUSTIN, TX
UPDATE card_shops SET lat = 32.92909, lng = -97.288906 WHERE name = 'Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: FORT WORTH, TX
UPDATE card_shops SET lat = 27.706719, lng = -97.360786 WHERE name = 'Cottens Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CORPUS CHRISTI, TX
UPDATE card_shops SET lat = 30.657968, lng = -97.410293 WHERE name = 'DOC''s Unique Collectibles LLC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: EL PASO, TX
UPDATE card_shops SET lat = 33.580963, lng = -101.845445 WHERE name = 'Faust Stamp and Coin Co.' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: LUBBOCK, TX
UPDATE card_shops SET lat = 32.92909, lng = -97.288906 WHERE name = 'Fine Arts Artists |FortWorth,TX- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: FORT WORTH, TX
UPDATE card_shops SET lat = 32.92909, lng = -97.288906 WHERE name = 'Get Unique Baby Shower GreetingCardsWith ThisFortWorthGift...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: FORT WORTH, TX
UPDATE card_shops SET lat = 29.728883, lng = -95.450638 WHERE name = 'HOUSTON SPORTS CONNECTION' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: HOUSTON, TX
UPDATE card_shops SET lat = 27.706719, lng = -97.360786 WHERE name = 'Hobby Shops in Corpus Christi, TX' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CORPUS CHRISTI, TX
UPDATE card_shops SET lat = 30.657968, lng = -97.410293 WHERE name = 'J & M SPORTS CARDS AND TOY COLLECTIBLES in El Paso, TX 79936' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: EL PASO, TX
UPDATE card_shops SET lat = 30.657968, lng = -97.410293 WHERE name = 'J and M Sportscards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: EL PASO, TX
UPDATE card_shops SET lat = 30.364875, lng = -97.738443 WHERE name = 'LUCKY 7 CARDS AND COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: AUSTIN, TX
UPDATE card_shops SET lat = 33.580963, lng = -101.845445 WHERE name = 'Lone Star Sports Collectibles in Lubbock, TX 79410' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: LUBBOCK, TX
UPDATE card_shops SET lat = 30.657968, lng = -97.410293 WHERE name = 'RJ DUKE SPORTS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MCKINNEY, TX
UPDATE card_shops SET lat = 30.657968, lng = -97.410293 WHERE name = 'SAPPY''S SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CARROLTON, TX
UPDATE card_shops SET lat = 30.657968, lng = -97.410293 WHERE name = 'SMP SPORTSCARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GRAPEVINE, TX
UPDATE card_shops SET lat = 30.657968, lng = -97.410293 WHERE name = 'SOUTHWEST CARD WORLD' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: COLLEGE STATION, TX
UPDATE card_shops SET lat = 29.481735, lng = -98.575016 WHERE name = 'SPORTS CARDS PLUS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SAN ANTONIO, TX
UPDATE card_shops SET lat = 27.706719, lng = -97.360786 WHERE name = 'SportStuff Cards & Collectibles in Corpus Christi, TX 78418' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CORPUS CHRISTI, TX
UPDATE card_shops SET lat = 30.657968, lng = -97.410293 WHERE name = 'Superiorsportsinvestments.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ARLINGTON, TX
UPDATE card_shops SET lat = 30.657968, lng = -97.410293 WHERE name = 'TCG Battleground in El Paso, TX 79936' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: EL PASO, TX
UPDATE card_shops SET lat = 30.657968, lng = -97.410293 WHERE name = 'TEXAS ROADSHOW SHOP' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MANSFIELD, TX
UPDATE card_shops SET lat = 30.657968, lng = -97.410293 WHERE name = 'TEXAS SPORTS CARDS AND MEMORABILIA' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ARGYLE, TX
UPDATE card_shops SET lat = 30.657968, lng = -97.410293 WHERE name = 'THE ADVENTURE STADIUM' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CONROE, TX
UPDATE card_shops SET lat = 30.657968, lng = -97.410293 WHERE name = 'TRIPLE CARDS AND COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PLANO, TX
UPDATE card_shops SET lat = 30.657968, lng = -97.410293 WHERE name = 'The Card House Trading Cards and Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ARLINGTON, TX
UPDATE card_shops SET lat = 27.706719, lng = -97.360786 WHERE name = 'The Card Vault' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CORPUS CHRISTI, TX
UPDATE card_shops SET lat = 27.706719, lng = -97.360786 WHERE name = 'Trading Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: CORPUS CHRISTI, TX
UPDATE card_shops SET lat = 30.657968, lng = -97.410293 WHERE name = 'WIRTH COLLECTING' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WAXAHACHIE, TX
UPDATE card_shops SET lat = 40.328072, lng = -112.05573 WHERE name = 'Beehive Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: OGDEN, UT
UPDATE card_shops SET lat = 40.328072, lng = -112.05573 WHERE name = 'CRAVE COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MIDVALE, UT
UPDATE card_shops SET lat = 40.328072, lng = -112.05573 WHERE name = 'Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ST GEORGE, UT
UPDATE card_shops SET lat = 40.328072, lng = -112.05573 WHERE name = 'Deseret Collectables' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: OGDEN, UT
UPDATE card_shops SET lat = 40.328072, lng = -112.05573 WHERE name = 'Game Haven St. George' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ST GEORGE, UT
UPDATE card_shops SET lat = 40.328072, lng = -112.05573 WHERE name = 'It''s Time To Duel!' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ST GEORGE, UT
UPDATE card_shops SET lat = 40.328072, lng = -112.05573 WHERE name = 'MR. E''S SPORTS CARDS & COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: OREM, UT
UPDATE card_shops SET lat = 40.711825, lng = -111.879429 WHERE name = 'PSA Dealer: Overtime Cards and Collectibles, Inc.' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SALT LAKE CITY, UT
UPDATE card_shops SET lat = 40.328072, lng = -112.05573 WHERE name = 'Platinum Sports and Music Memorabilia, Provo UT (801) 691-1827 ...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: PROVO, UT
UPDATE card_shops SET lat = 36.846159, lng = -76.110933 WHERE name = 'B and B Cards and Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: VIRGINIA BEACH, VA
UPDATE card_shops SET lat = 37.272306, lng = -79.949692 WHERE name = 'C and M Trading Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: ROANOKE, VA
UPDATE card_shops SET lat = 37.362937, lng = -77.791895 WHERE name = 'COLLECTOR''S WORLD' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FALLS CHURCH, VA
UPDATE card_shops SET lat = 37.362937, lng = -77.791895 WHERE name = 'Hobby, Toy, andGameShops|Arlington,VA- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ARLINGTON, VA
UPDATE card_shops SET lat = 37.362937, lng = -77.791895 WHERE name = 'KOLLECTIBLE KINGS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WINCHESTER, VA
UPDATE card_shops SET lat = 36.846159, lng = -76.110933 WHERE name = 'Kaboom' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: VIRGINIA BEACH, VA
UPDATE card_shops SET lat = 37.362937, lng = -77.791895 WHERE name = 'LAB 20 SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: ST. PAUL, VA
UPDATE card_shops SET lat = 36.846159, lng = -76.110933 WHERE name = 'PSA Dealer: B&B Cards and Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: VIRGINIA BEACH, VA
UPDATE card_shops SET lat = 37.272306, lng = -79.949692 WHERE name = 'Roanoke VA Toy Store, Hobby Shop, Comic Books & Sports Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: ROANOKE, VA
UPDATE card_shops SET lat = 37.272306, lng = -79.949692 WHERE name = 'Sports Haven' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: ROANOKE, VA
UPDATE card_shops SET lat = 37.362937, lng = -77.791895 WHERE name = 'THE CARD CELLAR' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: FREDERICKSBURG, VA
UPDATE card_shops SET lat = 36.846159, lng = -76.110933 WHERE name = 'The Booster Box: Trading Card Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: VIRGINIA BEACH, VA
UPDATE card_shops SET lat = 36.846159, lng = -76.110933 WHERE name = 'Virginia' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: VIRGINIA BEACH, VA
UPDATE card_shops SET lat = 37.272306, lng = -79.949692 WHERE name = 'Virginia Sports Card Stores' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: ROANOKE, VA
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'GREEN MOUNTAIN SPORTS CARDS & GAMING' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: ESSEX JUNCTION, VT
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'JIM''S SPORTS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: SOUTH BURLINGTON, VT
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Quarterstaff Games' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: BURLINGTON, VT
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Vermont Gaming Academy Rutland' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: RUTLAND, VT
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Vermont Toy and Hobby, Inc.' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: BURLINGTON, VT
UPDATE card_shops SET lat = 47.830983, lng = -122.336125 WHERE name = 'A WORLD OF COLLECTIONS GAMES, COMICS & CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: EDMONDS, WA
UPDATE card_shops SET lat = 47.622686, lng = -122.162601 WHERE name = 'Andy''s Sports Cards in Bellevue, WA 98008' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: BELLEVUE, WA
UPDATE card_shops SET lat = 47.800014, lng = -121.886423 WHERE name = 'BIG NATES TRADING CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: GIG HARBOR, WA
UPDATE card_shops SET lat = 47.638584, lng = -122.357101 WHERE name = 'CARD EXCHANGE' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SEATTLE, WA
UPDATE card_shops SET lat = 47.638584, lng = -122.357101 WHERE name = 'Card Exchange Sports' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: SEATTLE, WA
UPDATE card_shops SET lat = 47.622686, lng = -122.162601 WHERE name = 'Collector''s Corner NW' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: BELLEVUE, WA
UPDATE card_shops SET lat = 47.800014, lng = -121.886423 WHERE name = 'Collector''s Zone' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SPOKANE, WA
UPDATE card_shops SET lat = 47.800014, lng = -121.886423 WHERE name = 'DIGITAL HEROES LLC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: WALLA WALLA, WA
UPDATE card_shops SET lat = 47.800014, lng = -121.886423 WHERE name = 'GAS BREAKS SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: OLYMPIA, WA
UPDATE card_shops SET lat = 47.255165, lng = -122.510931 WHERE name = 'Knutsen''s Northwest Sportscards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: TACOMA, WA
UPDATE card_shops SET lat = 47.800014, lng = -121.886423 WHERE name = 'LUCKY BREAKS SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: VANCOUVER, WA
UPDATE card_shops SET lat = 47.800014, lng = -121.886423 WHERE name = 'MILL CREEK SPORTS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: MILL CREEK, WA
UPDATE card_shops SET lat = 47.800014, lng = -121.886423 WHERE name = 'NORTH TOWN CARD VAULT' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: UNION GAP, WA
UPDATE card_shops SET lat = 47.800014, lng = -121.886423 WHERE name = 'Reckless Hobbies & Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: VANCOUVER, WA
UPDATE card_shops SET lat = 47.359563, lng = -122.169021 WHERE name = 'STAGG''S INC.' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: KENT, WA
UPDATE card_shops SET lat = 47.800014, lng = -121.886423 WHERE name = 'Sportscards Northwest' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: SPOKANE, WA
UPDATE card_shops SET lat = 47.255165, lng = -122.510931 WHERE name = 'The Game Matrix' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: TACOMA, WA
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'AJ COLLECTABLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: GREENFIELD, WI
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'All Pro Sport Cards' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: KENOSHA, WI
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'BADGER SPORTS SHOP' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: ONALASKA, WI
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'BREW TOWN TRADING CO' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: GREENFIELD, WI
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'CARDBOARD LEGACY' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: OSHKOSH, WI
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'CB HOBBY' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: KAUKAUNA, WI
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'COULEE CARDS & GAMING - EAU CLAIRE' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: EAU CLAIRE, WI
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'COULEE CARDS AND GAMING' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: ONALASKA, WI
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Find Us' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: MADISON, WI
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'GREEN BAY CITY CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: GREEN BAY, WI
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Jim''s Card Korner' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: MADISON, WI
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'LAKE COUNTRY CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: OCONOMOWOC, WI
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'MITCH''S SPORTS CARDS AND COLLECTIBLES' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: MEQUON, WI
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'REAL SPORTSCARDS, WISCONSIN' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: WAUPUN, WI
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'THE HAWKE''S NEST SPORTS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: WOODRUFF, WI
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Treasure Hunters Buy & Sell Comics, Cards, Collectibles & More' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: APPLETON, WI
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'ULTIMATE AUTHENTICS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: EAU CLAIRE, WI
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'BACK IN THE GAME SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: RANSON, WV
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Baseball Cards and More' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: HUNTINGTON, WV
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'CWV' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: CHARLESTON, WV
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Donna''s Unique Gifts and Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: MORGANTOWN, WV
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'E AND K SPORTS CARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: MOUNDSVILLE, WV
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'FOAMCITY SPORTSCARDS' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: CHARLES TOWN, WV
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Freeman''s Sports Cards & Collectibles – Huntington, West ...' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: HUNTINGTON, WV
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'MAMBA COLLECTIBLES LLC' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: MARTINSBURG, WV
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'One More TCG & Collectibles' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: HUNTINGTON, WV
UPDATE card_shops SET lat = 39.8283, lng = -98.5795 WHERE name = 'Select Cards & Collectables in South Charleston, WV 25303' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- country: CHARLESTON, WV
UPDATE card_shops SET lat = 41.308779, lng = -105.565976 WHERE name = 'Crossroad Collectibles in Cheyenne, WY 82009' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CHEYENNE, WY
UPDATE card_shops SET lat = 41.308779, lng = -105.565976 WHERE name = 'Gotta Catch ''Em All?' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CHEYENNE, WY
UPDATE card_shops SET lat = 41.308779, lng = -105.565976 WHERE name = 'SportingGoods Stores and BicycleShops|Laramie,WY- Manta.com' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: LARAMIE, WY
UPDATE card_shops SET lat = 41.308779, lng = -105.565976 WHERE name = 'Sportscards and More' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- state: CHEYENNE, WY
UPDATE card_shops SET lat = 41.308779, lng = -105.565976 WHERE name = 'Wyoming Sports Card Stores' AND (lat IS NULL OR lat = 0) AND (lng IS NULL OR lng = 0);  -- city: LARAMIE, WY

COMMIT;
