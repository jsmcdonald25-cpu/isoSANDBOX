-- ============================================================
-- ISOsnipe Targets — Seed with the existing 26 hardcoded targets
-- ============================================================
-- Run ONCE, after migration_004_targets.sql, to migrate the
-- TARGETS array from snipe.js into the new table. Skips rows
-- where (player, card, parallel) already exists.

insert into isosnipe_targets (player, card, parallel, market_avg, correct_searches, misspellings)
select v.player, v.card, v.parallel, v.market_avg, v.correct, v.misspellings
from (values
  -- KEN GRIFFEY JR
  ('Ken Griffey Jr',  '1989 Upper Deck #1 Rookie',           'Base',      45::numeric,
   array['1989 Upper Deck Ken Griffey Jr rookie #1','Griffey Jr 1989 UD rookie'],
   array['1989 upper deck ken griffy jr','Griffy Jr 1989 rookie','Ken Griffee Jr upper deck 1989','1989 UD Griffey rooky','Griffey Jr upperdeck rookie']),
  ('Ken Griffey Jr',  '1989 Topps Traded #41T',              'Base',      20::numeric,
   array['1989 Topps Traded Griffey Jr 41T','Griffey Jr Topps Traded rookie'],
   array['1989 topps traded griffy jr','Griffey topps tradded 41T','Ken Griffy topps traded','Griffey 1989 tops traded']),

  -- ICHIRO SUZUKI
  ('Ichiro Suzuki',   '2001 Topps #726 RC',                  'Base',      25::numeric,
   array['2001 Topps Ichiro 726 rookie','Ichiro Suzuki 2001 Topps RC'],
   array['2001 topps ichero 726','Ichiro Suzki 2001 topps','2001 tops ichiro rookie','Ichiro Susuki topps 726','Ichero Suzuki rookie card']),
  ('Ichiro Suzuki',   '2001 Topps Chrome Traded #T266',      'Base',      55::numeric,
   array['2001 Topps Chrome Traded Ichiro T266','Ichiro Chrome Traded rookie'],
   array['2001 topps crome traded ichiro','Ichiro chrome tradded T266','Ichiro topps crome rookie','2001 topps chrome ichero traded','Ichiro Suzki chrome traded']),
  ('Ichiro Suzuki',   '2001 Bowman Chrome',                  'Base',      70::numeric,
   array['2001 Bowman Chrome Ichiro rookie','Ichiro Bowman Chrome RC'],
   array['2001 bowmen chrome ichiro','Ichiro bowman crome rookie','Ichero bowman chrome','2001 bowmen crome ichiro','Ichiro Suzki bowman chrome']),

  -- SHOHEI OHTANI
  ('Shohei Ohtani',   '2018 Topps Update RC',                'Base',      30::numeric,
   array['2018 Topps Update Ohtani rookie','Ohtani 2018 Topps RC'],
   array['2018 topps update otani rookie','Ohtani 2018 tops update','Shoehei Ohtani 2018 topps','2018 topps ohtni rookie','Shohei Otahni 2018 topps']),
  ('Shohei Ohtani',   '2018 Topps Chrome RC',                'Base',      45::numeric,
   array['2018 Topps Chrome Ohtani rookie','Ohtani Chrome RC 2018'],
   array['2018 topps crome ohtani','Otani 2018 chrome rookie','Ohtani 2018 tops crome','Shoehei Ohtani chrome 2018','2018 topps crome otahni']),

  -- SAL STEWART
  ('Sal Stewart',     '1st Bowman',                          'Base',      18::numeric,
   array['Sal Stewart 1st Bowman','Sal Stewart Bowman 1st'],
   array['Sal Stuart 1st bowman','Sal Steward bowman','Sal Stewart 1st bowmen','Sal Stewert bowman','Sal Stuart 1st bowmen']),
  ('Sal Stewart',     '1st Bowman Chrome',                   'Chrome',    30::numeric,
   array['Sal Stewart 1st Bowman Chrome','Sal Stewart Bowman Chrome'],
   array['Sal Stuart bowman chrome','Sal Stewart bowmen crome','Sal Steward 1st bowman chrome','Sal Stewart 1st bowmen crome','Sal Stewert chrome']),
  ('Sal Stewart',     'Bowman Refractor',                    'Refractor', 50::numeric,
   array['Sal Stewart Bowman refractor','Sal Stewart 1st Bowman refractor'],
   array['Sal Stewart refactor','Sal Stuart refractor','Sal Steward refractor','Sal Stewart bowmen refactor','Sal Stewart refracter']),

  -- DANIEL SUSAC
  ('Daniel Susac',    '1st Bowman',                          'Base',      15::numeric,
   array['Daniel Susac 1st Bowman','Daniel Susac Bowman'],
   array['Daniel Susak bowman','Daniel Sussac 1st bowman','Danial Susac bowman','Daniel Susac 1st bowmen','Susac bowmen 1st']),
  ('Daniel Susac',    '1st Bowman Chrome',                   'Chrome',    25::numeric,
   array['Daniel Susac 1st Bowman Chrome','Daniel Susac Bowman Chrome'],
   array['Daniel Susak bowman chrome','Daniel Sussac chrome','Danial Susac bowman crome','Daniel Susac bowmen crome','Susac 1st bowmen chrome']),
  ('Daniel Susac',    'Bowman Refractor',                    'Refractor', 45::numeric,
   array['Daniel Susac refractor','Susac Bowman refractor'],
   array['Daniel Susac refactor','Susac refracter','Daniel Susak refractor','Danial Susac refractor','Sussac refactor']),

  -- MOISES BALLESTEROS
  ('Moises Ballesteros', '1st Bowman',                       'Base',      12::numeric,
   array['Moises Ballesteros 1st Bowman','Ballesteros Bowman 1st'],
   array['Moises Balesteros bowman','Ballesteros 1st bowmen','Moses Ballesteros bowman','Moises Bayesteros 1st','Balesteros bowman chrome']),
  ('Moises Ballesteros', '1st Bowman Chrome',                'Chrome',    22::numeric,
   array['Moises Ballesteros Bowman Chrome','Ballesteros 1st Chrome'],
   array['Ballesteros bowman crome','Moises Balesteros chrome','Moses Ballesteros crome','Ballesteros bowmen chrome']),

  -- GEORGE VALERA
  ('George Valera',   '1st Bowman',                          'Base',      10::numeric,
   array['George Valera 1st Bowman','Valera Bowman 1st'],
   array['George Valera bowmen','Georg Valera bowman','George Valerra bowman','Valera 1st bowmen']),
  ('George Valera',   '1st Bowman Chrome',                   'Chrome',    18::numeric,
   array['George Valera Bowman Chrome','Valera 1st Chrome'],
   array['Valera bowman crome','George Valerra chrome','Georg Valera crome','Valera bowmen chrome']),

  -- KEVIN MCGONIGLE
  ('Kevin McGonigle', '1st Bowman',                          'Base',       8::numeric,
   array['Kevin McGonigle 1st Bowman','McGonigle Bowman 1st'],
   array['Kevin McGonigle bowmen','McGonigal bowman','Kevin McGoniggal bowman','McGongle 1st bowman']),
  ('Kevin McGonigle', '1st Bowman Chrome',                   'Chrome',    15::numeric,
   array['Kevin McGonigle Bowman Chrome','McGonigle Chrome 1st'],
   array['McGonigle bowman crome','Kevin McGonigal chrome','McGoniggal bowman crome','McGongle chrome']),

  -- CHASE DELAUTER
  ('Chase DeLauter',  '1st Bowman',                          'Base',      15::numeric,
   array['Chase DeLauter 1st Bowman','DeLauter Bowman 1st'],
   array['Chase Delauter bowmen','Chase De Lauter bowman','Chase DeLaughter bowman','Delauter 1st bowmen','Chase Delaughter bowman']),
  ('Chase DeLauter',  '1st Bowman Chrome',                   'Chrome',    28::numeric,
   array['Chase DeLauter Bowman Chrome','DeLauter Chrome 1st'],
   array['DeLauter bowman crome','Chase Delauter crome','De Lauter bowman chrome','DeLaughter crome']),

  -- JJ WETHERHOLT
  ('JJ Wetherholt',   '1st Bowman',                          'Base',      25::numeric,
   array['JJ Wetherholt 1st Bowman','Wetherholt Bowman 1st'],
   array['JJ Wetherholt bowmen','JJ Weatherholt bowman','Wetherholt 1st bowmen','JJ Wetherhold bowman','JJ Wetherhalt bowman']),
  ('JJ Wetherholt',   '1st Bowman Chrome',                   'Chrome',    45::numeric,
   array['JJ Wetherholt Bowman Chrome','Wetherholt Chrome 1st'],
   array['Wetherholt bowman crome','JJ Weatherholt chrome','Wetherhold crome','JJ Wetherhalt bowman chrome']),

  -- JUSTIN CRAWFORD
  ('Justin Crawford', '1st Bowman',                          'Base',      12::numeric,
   array['Justin Crawford 1st Bowman','Crawford Bowman 1st'],
   array['Justin Crawfrod bowman','Justin Crowford bowman','Crawford bowmen 1st','Justin Craford bowman']),
  ('Justin Crawford', '1st Bowman Chrome',                   'Chrome',    22::numeric,
   array['Justin Crawford Bowman Chrome','Crawford Chrome 1st'],
   array['Crawford bowman crome','Justin Crawfrod chrome','Crowford crome','Justin Craford chrome']),

  -- TANNER MURRAY
  ('Tanner Murray',   '1st Bowman',                          'Base',       8::numeric,
   array['Tanner Murray 1st Bowman','Murray Bowman 1st'],
   array['Tanner Murry bowman','Tanner Murray bowmen','Taner Murray bowman','Murray 1st bowmen'])
) as v(player, card, parallel, market_avg, correct, misspellings)
where not exists (
  select 1 from isosnipe_targets t
  where t.player = v.player and t.card = v.card and t.parallel = v.parallel
);
