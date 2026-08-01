-- Migration 107: Add 71 missing IANA timezones referenced by dr5hn cities
-- but missing from the IANA tzdb-2026c seed (migration 106).
--
-- Root cause: dr5hn cites more IANA IDs than our seed (likely older aliases
-- and current-vs-historical timezone names). Cities referencing these IDs
-- failed FK constraint on cities.timezone, so 97 country files silently
-- failed to apply. This migration closes the gap.
--
-- Generated: 2026-08-01 from city tz analysis
-- Total: 71 timezones, 11 INSERT batches of 7 rows

INSERT OR IGNORE INTO time_zones (id, canonical_id, region, subregion, city, country_codes, countries, latitude, longitude, current_offset, current_abbreviation, is_dst, description) VALUES
('Africa/Accra', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'GH', NULL, NULL, NULL, 0, 'GMT', 0, NULL),
('Africa/Addis_Ababa', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'ET', NULL, NULL, NULL, 180, 'EAT', 0, NULL),
('Africa/Asmara', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'ER', NULL, NULL, NULL, 180, 'EAT', 0, NULL),
('Africa/Bamako', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'ML', NULL, NULL, NULL, 0, 'GMT', 0, NULL),
('Africa/Bangui', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'CF', NULL, NULL, NULL, 60, 'WAT', 0, NULL),
('Africa/Banjul', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'GM', NULL, NULL, NULL, 0, 'GMT', 0, NULL),
('Africa/Blantyre', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'MW', NULL, NULL, NULL, 120, 'CAT', 0, NULL);

INSERT OR IGNORE INTO time_zones (id, canonical_id, region, subregion, city, country_codes, countries, latitude, longitude, current_offset, current_abbreviation, is_dst, description) VALUES
('Africa/Brazzaville', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'CG', NULL, NULL, NULL, 60, 'WAT', 0, NULL),
('Africa/Bujumbura', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'BI', NULL, NULL, NULL, 120, 'CAT', 0, NULL),
('Africa/Conakry', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'GN', NULL, NULL, NULL, 0, 'GMT', 0, NULL),
('Africa/Dakar', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'SN', NULL, NULL, NULL, 0, 'GMT', 0, NULL),
('Africa/Dar_es_Salaam', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'TZ', NULL, NULL, NULL, 180, 'EAT', 0, NULL),
('Africa/Djibouti', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'DJ', NULL, NULL, NULL, 180, 'EAT', 0, NULL),
('Africa/Douala', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'CM', NULL, NULL, NULL, 60, 'WAT', 0, NULL);

INSERT OR IGNORE INTO time_zones (id, canonical_id, region, subregion, city, country_codes, countries, latitude, longitude, current_offset, current_abbreviation, is_dst, description) VALUES
('Africa/Freetown', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'SL', NULL, NULL, NULL, 0, 'GMT', 0, NULL),
('Africa/Gaborone', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'BW', NULL, NULL, NULL, 120, 'CAT', 0, NULL),
('Africa/Harare', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'ZW', NULL, NULL, NULL, 120, 'CAT', 0, NULL),
('Africa/Kampala', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'UG', NULL, NULL, NULL, 180, 'EAT', 0, NULL),
('Africa/Kigali', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'RW', NULL, NULL, NULL, 120, 'CAT', 0, NULL),
('Africa/Kinshasa', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'CD', NULL, NULL, NULL, 60, 'WAT', 0, NULL),
('Africa/Libreville', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'GA', NULL, NULL, NULL, 60, 'WAT', 0, NULL);

INSERT OR IGNORE INTO time_zones (id, canonical_id, region, subregion, city, country_codes, countries, latitude, longitude, current_offset, current_abbreviation, is_dst, description) VALUES
('Africa/Lome', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'TG', NULL, NULL, NULL, 0, 'GMT', 0, NULL),
('Africa/Luanda', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'AO', NULL, NULL, NULL, 60, 'WAT', 0, NULL),
('Africa/Lubumbashi', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'CD', NULL, NULL, NULL, 120, 'CAT', 0, NULL),
('Africa/Lusaka', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'ZM', NULL, NULL, NULL, 120, 'CAT', 0, NULL),
('Africa/Malabo', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'GQ', NULL, NULL, NULL, 60, 'WAT', 0, NULL),
('Africa/Mogadishu', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'SO', NULL, NULL, NULL, 180, 'EAT', 0, NULL),
('Africa/Niamey', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'NE', NULL, NULL, NULL, 60, 'WAT', 0, NULL);

INSERT OR IGNORE INTO time_zones (id, canonical_id, region, subregion, city, country_codes, countries, latitude, longitude, current_offset, current_abbreviation, is_dst, description) VALUES
('Africa/Nouakchott', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'MR', NULL, NULL, NULL, 0, 'GMT', 0, NULL),
('Africa/Ouagadougou', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'BF', NULL, NULL, NULL, 0, 'GMT', 0, NULL),
('Africa/Porto-Novo', NULL, 'Africa', 'Sub-Saharan Africa', NULL, 'BJ', NULL, NULL, NULL, 60, 'WAT', 0, NULL),
('America/Cayman', NULL, 'Americas', 'Northern America', NULL, 'KY', NULL, NULL, NULL, -300, 'EST', 0, NULL),
('America/Nassau', NULL, 'Americas', 'Northern America', NULL, 'BS', NULL, NULL, NULL, -240, 'EDT', 1, NULL),
('Asia/Aden', NULL, 'Asia', 'Eastern Asia', NULL, 'YE', NULL, NULL, NULL, 180, '+03', 0, NULL),
('Asia/Bahrain', NULL, 'Asia', 'Eastern Asia', NULL, 'BH', NULL, NULL, NULL, 180, '+03', 0, NULL);

INSERT OR IGNORE INTO time_zones (id, canonical_id, region, subregion, city, country_codes, countries, latitude, longitude, current_offset, current_abbreviation, is_dst, description) VALUES
('Asia/Brunei', NULL, 'Asia', 'Eastern Asia', NULL, 'BN', NULL, NULL, NULL, 480, '+08', 0, NULL),
('Asia/Kuala_Lumpur', NULL, 'Asia', 'Eastern Asia', NULL, 'MY', NULL, NULL, NULL, 480, '+08', 0, NULL),
('Asia/Kuwait', NULL, 'Asia', 'Eastern Asia', NULL, 'KW', NULL, NULL, NULL, 180, '+03', 0, NULL),
('Asia/Muscat', NULL, 'Asia', 'Eastern Asia', NULL, 'OM', NULL, NULL, NULL, 240, '+04', 0, NULL),
('Asia/Phnom_Penh', NULL, 'Asia', 'Eastern Asia', NULL, 'KH', NULL, NULL, NULL, 420, '+07', 0, NULL),
('Asia/Vientiane', NULL, 'Asia', 'Eastern Asia', NULL, 'LA', NULL, NULL, NULL, 420, '+07', 0, NULL),
('Atlantic/Reykjavik', NULL, 'Africa', 'Western Africa', NULL, 'IS', NULL, NULL, NULL, 0, 'GMT', 0, NULL);

INSERT OR IGNORE INTO time_zones (id, canonical_id, region, subregion, city, country_codes, countries, latitude, longitude, current_offset, current_abbreviation, is_dst, description) VALUES
('Europe/Amsterdam', NULL, 'Europe', 'Western Europe', NULL, 'NL', NULL, NULL, NULL, 120, 'CEST', 1, NULL),
('Europe/Bratislava', NULL, 'Europe', 'Western Europe', NULL, 'SK', NULL, NULL, NULL, 120, 'CEST', 1, NULL),
('Europe/Busingen', NULL, 'Europe', 'Western Europe', NULL, 'DE', NULL, NULL, NULL, 120, 'CEST', 1, NULL),
('Europe/Copenhagen', NULL, 'Europe', 'Western Europe', NULL, 'DK', NULL, NULL, NULL, 120, 'CEST', 1, NULL),
('Europe/Guernsey', NULL, 'Europe', 'Western Europe', NULL, 'GG', NULL, NULL, NULL, 60, 'BST', 1, NULL),
('Europe/Isle_of_Man', NULL, 'Europe', 'Western Europe', NULL, 'IM', NULL, NULL, NULL, 60, 'BST', 1, NULL),
('Europe/Jersey', NULL, 'Europe', 'Western Europe', NULL, 'JE', NULL, NULL, NULL, 60, 'BST', 1, NULL);

INSERT OR IGNORE INTO time_zones (id, canonical_id, region, subregion, city, country_codes, countries, latitude, longitude, current_offset, current_abbreviation, is_dst, description) VALUES
('Europe/Ljubljana', NULL, 'Europe', 'Western Europe', NULL, 'SI', NULL, NULL, NULL, 120, 'CEST', 1, NULL),
('Europe/Luxembourg', NULL, 'Europe', 'Western Europe', NULL, 'LU', NULL, NULL, NULL, 120, 'CEST', 1, NULL),
('Europe/Mariehamn', NULL, 'Europe', 'Western Europe', NULL, 'AX', NULL, NULL, NULL, 180, 'EEST', 1, NULL),
('Europe/Monaco', NULL, 'Europe', 'Western Europe', NULL, 'MC', NULL, NULL, NULL, 120, 'CEST', 1, NULL),
('Europe/Oslo', NULL, 'Europe', 'Western Europe', NULL, 'NO', NULL, NULL, NULL, 120, 'CEST', 1, NULL),
('Europe/Podgorica', NULL, 'Europe', 'Western Europe', NULL, 'ME', NULL, NULL, NULL, 120, 'CEST', 1, NULL),
('Europe/San_Marino', NULL, 'Europe', 'Western Europe', NULL, 'SM', NULL, NULL, NULL, 120, 'CEST', 1, NULL);

INSERT OR IGNORE INTO time_zones (id, canonical_id, region, subregion, city, country_codes, countries, latitude, longitude, current_offset, current_abbreviation, is_dst, description) VALUES
('Europe/Sarajevo', NULL, 'Europe', 'Western Europe', NULL, 'BA', NULL, NULL, NULL, 120, 'CEST', 1, NULL),
('Europe/Skopje', NULL, 'Europe', 'Western Europe', NULL, 'MK', NULL, NULL, NULL, 120, 'CEST', 1, NULL),
('Europe/Stockholm', NULL, 'Europe', 'Western Europe', NULL, 'SE', NULL, NULL, NULL, 120, 'CEST', 1, NULL),
('Europe/Vaduz', NULL, 'Europe', 'Western Europe', NULL, 'LI', NULL, NULL, NULL, 120, 'CEST', 1, NULL),
('Europe/Zagreb', NULL, 'Europe', 'Western Europe', NULL, 'HR', NULL, NULL, NULL, 120, 'CEST', 1, NULL),
('Indian/Antananarivo', NULL, 'Africa', 'Eastern Africa', NULL, 'MG', NULL, NULL, NULL, 180, 'EAT', 0, NULL),
('Indian/Comoro', NULL, 'Africa', 'Eastern Africa', NULL, 'KM', NULL, NULL, NULL, 180, 'EAT', 0, NULL);

INSERT OR IGNORE INTO time_zones (id, canonical_id, region, subregion, city, country_codes, countries, latitude, longitude, current_offset, current_abbreviation, is_dst, description) VALUES
('Indian/Kerguelen', NULL, 'Africa', 'Eastern Africa', NULL, 'TF', NULL, NULL, NULL, 300, '+05', 0, NULL),
('Indian/Mahe', NULL, 'Africa', 'Eastern Africa', NULL, 'SC', NULL, NULL, NULL, 240, '+04', 0, NULL),
('Indian/Mayotte', NULL, 'Africa', 'Eastern Africa', NULL, 'YT', NULL, NULL, NULL, 180, 'EAT', 0, NULL),
('Indian/Reunion', NULL, 'Africa', 'Eastern Africa', NULL, 'RE', NULL, NULL, NULL, 240, '+04', 0, NULL),
('Pacific/Enderbury', NULL, 'Oceania', 'Melanesia', NULL, 'KI', NULL, NULL, NULL, 780, '+13', 0, NULL),
('Pacific/Funafuti', NULL, 'Oceania', 'Melanesia', NULL, 'TV', NULL, NULL, NULL, 720, '+12', 0, NULL),
('Pacific/Majuro', NULL, 'Oceania', 'Melanesia', NULL, 'MH', NULL, NULL, NULL, 720, '+12', 0, NULL);

INSERT OR IGNORE INTO time_zones (id, canonical_id, region, subregion, city, country_codes, countries, latitude, longitude, current_offset, current_abbreviation, is_dst, description) VALUES
('Pacific/Wallis', NULL, 'Oceania', 'Melanesia', NULL, 'WF', NULL, NULL, NULL, 720, '+12', 0, NULL);

