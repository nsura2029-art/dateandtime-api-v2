-- Migration 103: Seed sub-regions (22 rows from dr5hn)
-- Source: https://github.com/dr5hn/countries-states-cities-database/blob/master/json/subregions.json

INSERT INTO subregions (id, code, name, region_id) VALUES
  (19, '053', 'Australia and New Zealand', 5),
  (7, '029', 'Caribbean', 2),
  (9, '013', 'Central America', 2),
  (10, '143', 'Central Asia', 3),
  (4, '014', 'Eastern Africa', 1),
  (12, '009', 'Eastern Asia', 3),
  (15, '039', 'Eastern Europe', 4),
  (20, '145', 'Melanesia', 5),
  (21, '021', 'Micronesia', 5),
  (2, '011', 'Middle Africa', 1),
  (1, NULL, 'Northern Africa', 1),
  (6, '017', 'Northern America', 2),
  (18, '034', 'Northern Europe', 4),
  (22, '127', 'Polynesia', 5),
  (8, '005', 'South America', 2),
  (13, '154', 'South-Eastern Asia', 3),
  (5, '015', 'Southern Africa', 1),
  (14, '034', 'Southern Asia', 3),
  (16, '035', 'Southern Europe', 4),
  (3, '155', 'Western Africa', 1),
  (11, '005', 'Western Asia', 3),
  (17, '151', 'Western Europe', 4);
