-- ═══════════════════════════════════════════════════════════════
-- Nashville Area + Surrounding Region Card Shops
-- Paste in Supabase SQL Editor
-- ═══════════════════════════════════════════════════════════════

BEGIN;

-- ── Fix Nashville IN → TN misclassifications ──────────────────
UPDATE card_shops SET state = 'TN'
WHERE name = 'Athlon Sports Collectibles'
  AND city = 'Nashville' AND state = 'IN';

UPDATE card_shops SET
  name = 'The Game Cave',
  address = '2710 Old Lebanon Rd Ste 28',
  state = 'TN',
  zip = '37214',
  phone = '(615) 678-5768',
  lat = 36.1905, lng = -86.6156,
  types = '{TCG,Games,Pokemon,MTG,Yu-Gi-Oh}',
  hours = 'Mon-Tue 12pm-10pm; Wed-Fri 12pm-10pm; Sat-Sun 11am-8pm',
  website = 'https://www.thegamecave.store/',
  source = 'manual', active = true
WHERE name LIKE '%thegamecave%'
  AND city = 'Nashville' AND state = 'IN';

-- ── Fix Cranks — deactivate bad Marty's entries, add real Cranks ──
UPDATE card_shops SET active = false
WHERE (name LIKE '%Marty%Trading Card Exchange%'
   OR name LIKE '%Marty%Sports Card Exchange%'
   OR name LIKE '%Cranks TCG%')
  AND state = 'TN';

INSERT INTO card_shops (name,address,city,state,country,zip,phone,lat,lng,region,types,hours,website,notes,source,verified,active) VALUES
('Cranks Sports Trading Gallery','8898 Old Lee Hwy #110','Ooltewah','TN','US','37363','(423) 910-1236',35.0757,-85.0578,'chattanooga','{Sports,Pokemon,MTG,Yu-Gi-Oh,Collectibles,Singles}','Mon-Sat 10am-6pm; Sun 1pm-6pm','https://crankstrading.com','Multi-location brand; eBay store: chattanoogasports; 4.7★ Google (137 reviews); 8.6K FB followers','manual',true,true);

-- ── Nashville proper ──────────────────────────────────────────
INSERT INTO card_shops (name,address,city,state,country,zip,phone,lat,lng,region,types,hours,website,notes,source,verified,active) VALUES
('C&J Cards and Collectibles','3628 Trousdale Dr Ste A','Nashville','TN','US','37204','(615) 600-5956',36.1183,-86.7697,'nashville','{Sports,TCG,Collectibles,Singles}','Tue-Fri 10am-6pm; Sat 10am-5pm; Sun-Mon Closed','https://candjcards.com/','facebook.com/candjcard; Nashville''s favorite trading card & memorabilia store; buys/sells/trades singles, sealed, supplies','manual',true,true),
('Dustemon TCG','634 Wedgewood Ave','Nashville','TN','US','37203','(615) 739-2532',36.1404,-86.7889,'nashville','{TCG,Pokemon,MTG}','','','twitter.com/DustemonTCG','manual',true,true),
('Middle Tennessee Gaming','7648 Hwy 70 S Ste 20','Nashville','TN','US','37221','(629) 292-1046',36.0562,-87.0315,'nashville','{TCG,Games,Pokemon,MTG}','Open daily except Wed 1pm-9pm','https://middletennesseegaming.com/','facebook.com/p/Middle-Tennessee-Gaming-61567309793600; instagram.com/midtngaming; Community focused gaming store','manual',true,true),
('Ready Mark Cards','7041 Highway 70 S Ste 103','Nashville','TN','US','37221','',36.0577,-87.0220,'nashville','{Pokemon,TCG,Singles}','','https://readymark.co/','facebook.com/p/Ready-Mark-Cards-61561535176265; instagram.com/readymarkcards; Pokemon specialist','manual',true,true),
('The Next Level Games','2066 Gallatin Pike N','Madison','TN','US','37115','',36.2614,-86.7060,'nashville','{Pokemon,MTG,Yu-Gi-Oh,Digimon,TCG,Games}','Mon-Thu 11am-7pm; Fri 11am-8pm; Sat 10am-8pm; Sun 12pm-6pm','https://tnlgnashville.com/','facebook.com/TheNextLevelGames; Moved from RiverGate Mall to current location','manual',true,true);

-- ── Mt. Juliet / Brentwood / Nolensville / Franklin ──────────
INSERT INTO card_shops (name,address,city,state,country,zip,phone,lat,lng,region,types,hours,website,notes,source,verified,active) VALUES
('Nashcards Mt. Juliet','300 Pleasant Grove Rd #340','Mt. Juliet','TN','US','37122','(615) 470-5313',36.2001,-86.5186,'nashville','{Sports,TCG,Sealed,Singles}','Daily 11am-6pm','https://nashcards.com/','facebook.com/nashcards; instagram.com/nashcards_nashville; PSA Dealer; Opened 2020; Topps Direct','manual',true,true),
('Nashcards Cool Springs','8105 Moores Ln Ste 400','Brentwood','TN','US','37027','(629) 203-8140',35.9923,-86.7828,'nashville','{Sports,TCG,Sealed,Singles}','Daily 11am-6pm','https://nashcards.com/','instagram.com/nashcards_coolsprings; Second location next to Publix','manual',true,true),
('Dads Dugout Sports Cards and Collectibles','7020 Church St E Ste 9','Brentwood','TN','US','37027','(615) 712-8692',36.0245,-86.7536,'nashville','{Sports,Collectibles,Singles,Autographs}','Tue-Sat 11am-6pm; Sun 12pm-5pm; Mon Closed','https://www.dads-dugout.com/','facebook.com/DadsDugoutSportsCards; instagram.com/dadsdugout; email: contact@dads-dugout.com; eBay: chutesandladders; Topps & Panini Direct; Grading Services','manual',true,true),
('Pretty Cool Cards','7177 Nolensville Rd Ste A3','Nolensville','TN','US','37135','(615) 283-8186',35.9509,-86.6710,'nashville','{Sports,Pokemon,TCG,Singles}','Mon 12pm-7pm; Wed-Sat 12pm-7pm; Sun 12pm-6pm; Tue Closed (by appt)','https://prettycoolcards.com/','facebook.com/p/Pretty-Cool-Cards-Nolensville-61566604351659; instagram.com/prettycoolcardsnolensville; email: prettycoolcards@gmail.com','manual',true,true);

-- ── Hendersonville / Gallatin / Lebanon ──────────────────────
INSERT INTO card_shops (name,address,city,state,country,zip,phone,lat,lng,region,types,hours,website,notes,source,verified,active) VALUES
('Shep''s Cards & Collectibles','102 Glen Oak Blvd Ste 40','Hendersonville','TN','US','37075','(615) 757-3151',36.3145,-86.5895,'nashville','{Sports,TCG,Singles,Sealed}','Tue-Fri 11am-6pm; Sat 10am-5pm; Sun-Mon Closed','https://www.shepscards.com/','facebook.com/shepscollectibles; instagram.com/shepscards; Topps Authorized Direct; Upper Deck Diamond Dealer','manual',true,true),
('Kountry Kards','563 S Water Ave','Gallatin','TN','US','37066','(615) 633-6368',36.3789,-86.4469,'nashville','{TCG,Pokemon,MTG,Games}','Tue-Thu 12pm-7pm; Fri-Sat 12pm-10pm; Sun 2pm-8pm; Mon Closed','https://kountrykards.com/','facebook.com/kountrykards; email: kountrykards@jcuconsulting.org','manual',true,true),
('Sports World Card Shop','535 W Baddour Pkwy','Lebanon','TN','US','37087','(615) 476-9228',36.2038,-86.3056,'nashville','{Sports,TCG,Collectibles}','','https://sportsworldcardshop.com/','facebook.com/sportsworldcardshop; email: sportsworldcardshop@gmail.com','manual',true,true),
('TC Giant','440 Park Ave Ste C','Lebanon','TN','US','37087','',36.2067,-86.2967,'nashville','{TCG,Sports,Singles}','','','facebook.com/tcgiant; Buy and sell trading cards','manual',true,true);

-- ── Murfreesboro / Columbia ──────────────────────────────────
INSERT INTO card_shops (name,address,city,state,country,zip,phone,lat,lng,region,types,hours,website,notes,source,verified,active) VALUES
('Grand Slam Collectibles','1226 NW Broad St','Murfreesboro','TN','US','37129','(615) 809-2362',35.8662,-86.4094,'nashville','{Sports,Pokemon,Collectibles,Singles,Sealed}','Mon-Sat 10am-6:30pm; Sun 10am-4pm','https://onlyatgrandslam.com/','facebook.com/GrandSlamCollectibles615; instagram.com/grandslamcollectibles; Vintage + modern sports, GPK, movie/TV memorabilia','manual',true,true),
('The Dragon''s Hoard','1720 Old Fort Pkwy Unit F105','Murfreesboro','TN','US','37129','(615) 999-0808',35.8426,-86.3767,'nashville','{MTG,Pokemon,Yu-Gi-Oh,Lorcana,Games}','Mon-Sat 10am-9pm','https://www.dragonshoardboro.com/','facebook.com/p/The-Dragons-Hoard-61565529771907; instagram.com/dragons_hoard_boro; FLGS in Stones River Town Center','manual',true,true),
('Grand Adventures Comics & Games','1013 Memorial Blvd','Murfreesboro','TN','US','37129','(615) 867-0838',35.8502,-86.3963,'nashville','{Comics,MTG,Pokemon,Yu-Gi-Oh,Warhammer,Games}','Sun-Mon 12pm-7pm; Tue-Thu 12pm-9pm; Fri 12pm-11pm; Sat 12pm-7pm','https://www.grandadventurescomics.com/','facebook.com/GrandAdventuresComics; Comics, TCG, Warhammer, Gundam, RPGs','manual',true,true),
('Muletown Hobbies and Games','105 E James Campbell Blvd Ste 4','Columbia','TN','US','38401','(931) 922-2668',35.6154,-87.0353,'nashville','{Pokemon,MTG,Games,3D-Printing}','Mon-Thu 10am-7pm; Fri 10am-9pm; Sat 10am-7pm; Sun Closed','https://muletown-hobbies-and-games.square.site/','facebook.com/muletownhobbiesandgames; instagram.com/muletownhobbiesandgames; email: muletownhobbiesandgames@gmail.com','manual',true,true);

-- ── Clarksville ──────────────────────────────────────────────
INSERT INTO card_shops (name,address,city,state,country,zip,phone,lat,lng,region,types,hours,website,notes,source,verified,active) VALUES
('Frontline Games','287 Stonecrossing Dr','Clarksville','TN','US','37042','(931) 896-2722',36.5660,-87.3394,'clarksville','{MTG,Pokemon,Warhammer,Games}','Mon-Thu 10am-10pm; Fri-Sat 10am-12am; Sun 10am-8pm','https://www.frontlinegames.net/','facebook.com/frontlinegamestn; email: support@frontlinegames.net; Veteran owned; Since 2013; Cafe service','manual',true,true),
('Guild Vault Games','2026 Ft Campbell Blvd B','Clarksville','TN','US','37042','(931) 647-9843',36.5420,-87.3570,'clarksville','{MTG,Pokemon,Lorcana,Games,Miniatures}','Daily 12pm-10pm','https://www.guildvaultgames.com/','facebook.com/guildvaultgames; instagram.com/guildvaultgames; email: Joe@guildvaultgames.com','manual',true,true),
('Infinity Game Lounge','1330 College St','Clarksville','TN','US','37040','(931) 271-4573',36.5354,-87.3541,'clarksville','{MTG,Pokemon,Games,RPG,Miniatures,3D-Printing}','Mon-Thu 10am-8pm; Fri-Sat 10am-10pm; Sun 10am-8pm','https://infinitygamelounge.com/','facebook.com/IGLClarksville; Also has location at 2051 Ft Campbell Blvd + 109 Ewing St Guthrie KY','manual',true,true),
('Graceful Gaming','1507B Fort Campbell Blvd','Clarksville','TN','US','37042','(931) 201-9445',36.5430,-87.3560,'clarksville','{Pokemon,MTG,Sports,LEGO,Collectibles}','','https://gracefulgaming.com/','facebook.com/gracefulgaming; email: gracefulgaming@outlook.com; Buy/sell/trade + play','manual',true,true);

-- ── Bowling Green KY / Smiths Grove / Cookeville ─────────────
INSERT INTO card_shops (name,address,city,state,country,zip,phone,lat,lng,region,types,hours,website,notes,source,verified,active) VALUES
('Dreams Sports Cards and Collectibles','1725 Ashley Circle #112','Bowling Green','KY','US','42104','',36.9576,-86.4419,'bowling_green','{Sports,Pokemon,Collectibles,Singles}','','https://www.dreamscardshop.com/','facebook.com/dreamscardshop; Family-friendly; Wide selection sports + Pokemon','manual',true,true),
('Sports Country 2','2625 Scottsville Rd','Bowling Green','KY','US','42104','(270) 315-9881',36.9380,-86.4298,'bowling_green','{Sports,Collectibles}','','https://sports-country.square.site/','facebook.com/sportscountry2; Inside Greenwood Mall; Tri-state''s #1 sports fan store','manual',true,true),
('Hobby Crossing (HobbyTown BG)','2345 Russellville Rd','Bowling Green','KY','US','42101','(270) 904-6100',36.9717,-86.4653,'bowling_green','{TCG,Games,RC,Models}','Sun 12pm-5pm; Mon,Wed 10am-6pm; Tue,Thu-Sat 10am-9pm','https://www.hobbytown.com/bowling-green-ky/l7','facebook.com/HobbyTownBGKY; email: bghobbycrossing@gmail.com; Locally owned HobbyTown franchise','manual',true,true),
('Kentucky Card Vault','108 E 1st St','Smiths Grove','KY','US','42171','(270) 451-5311',37.0590,-86.2020,'bowling_green','{Sports,Pokemon,Collectibles,Singles}','Wed-Sat 10am-6pm; Sun-Tue Closed','https://www.kentuckycardvault.com/','facebook.com/KentuckyCardVault; instagram.com/kentuckycardvault; email: Kentuckycardvault@gmail.com','manual',true,true),
('Knighthood Games','880 W Jackson St Ste A','Cookeville','TN','US','38501','(931) 526-2311',36.1647,-85.5124,'cookeville','{MTG,Pokemon,Yu-Gi-Oh,Games,Warhammer}','','https://knighthoodgames.com/','facebook.com/knighthoodgames; email: info@knighthoodgames.com; Hosts official events','manual',true,true);

COMMIT;
