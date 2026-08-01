"""
Generate migration 111: seed place_names with GeoNames alt names.

Source: https://download.geonames.org/export/dump/alternateNamesV2.txt (~200MB zipped, 19M records)
Matching: GeoNames cities1000.txt → our cities (152K) by name+country.

Output: migrations/111_seed_alt_names.sql (~43MB, 50K INSERTs of 9 rows each)

Usage:
    python scripts/seed/alt_names.py

Then apply:
    wrangler d1 execute timeandtimepro-full-v2 --env dev --remote --file=migrations/111_seed_alt_names.sql
    wrangler d1 execute timeandtimepro-full-v2 --env dev --remote --command="INSERT INTO place_names_fts(place_names_fts) VALUES('rebuild');"
"""
import json
import os
import re
import sys
import unicodedata
import urllib.request
import zipfile
from collections import defaultdict

WORKDIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ALTNAMES_URL = "https://download.geonames.org/export/dump/alternateNamesV2.zip"
CITIES1000_URL = "https://download.geonames.org/export/dump/cities1000.zip"
GEONAMES_DIR = os.path.join(os.path.expanduser("~"), ".cache", "geonames")

def download_if_missing(url, dest):
    if os.path.exists(dest):
        return
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    print(f"Downloading {url} -> {dest}")
    urllib.request.urlretrieve(url, dest)

def extract_if_missing(zip_path, member, out_path):
    if os.path.exists(out_path):
        return
    with zipfile.ZipFile(zip_path) as zf:
        with zf.open(member) as src, open(out_path, "wb") as dst:
            dst.write(src.read())

def normalize_name(s: str) -> str:
    if not s:
        return ""
    nfkd = unicodedata.normalize("NFKD", s)
    s = "".join(c for c in nfkd if not unicodedata.combining(c))
    s = s.lower()
    s = re.sub(r"[^a-z0-9]+", "", s)
    return s

def normalize_lang(lang: str) -> str:
    if not lang:
        return None
    return lang.split("-")[0].lower()

def get_script(name: str) -> str:
    if not name:
        return "Latn"
    for c in name:
        cp = ord(c)
        if 0x4E00 <= cp <= 0x9FFF: return "Hans"
        if 0x3040 <= cp <= 0x309F: return "Hira"
        if 0x30A0 <= cp <= 0x30FF: return "Kana"
        if 0x0400 <= cp <= 0x04FF: return "Cyrl"
        if 0x0600 <= cp <= 0x06FF: return "Arab"
        if 0x0590 <= cp <= 0x05FF: return "Hebr"
        if 0x0900 <= cp <= 0x097F: return "Deva"
        if 0x0E00 <= cp <= 0x0E7F: return "Thai"
        if 0xAC00 <= cp <= 0xD7AF: return "Kore"
    return "Latn"

def get_name_type(is_pref, is_short, is_coll, is_hist):
    if is_hist == "1":
        return "historical"
    if is_pref == "1":
        return "official"
    if is_short == "1":
        return "abbreviation"
    if is_coll == "1":
        return "colloquial"
    return "alternate"

def get_valid_iso_codes(iso_file):
    codes = set()
    with open(iso_file) as f:
        for line in f:
            parts = line.split("\t")
            for p in parts[:3]:
                p = p.strip()
                if p and len(p) <= 3:
                    codes.add(p.lower())
    return codes

def build_dr5hn_to_geoname(cities_file, our_cities_lookup):
    """Match GeoNames cities1000 to our cities by name + country."""
    mapping = {}
    with open(cities_file) as f:
        for line in f:
            parts = line.split("\t")
            if len(parts) < 9:
                continue
            gid, name, ascii_name, country = parts[0], parts[1], parts[2], parts[8]
            for try_name in (name, ascii_name):
                if not try_name:
                    continue
                key = (try_name.lower().strip(), country)
                if key in our_cities_lookup:
                    for cid in our_cities_lookup[key]:
                        mapping[cid] = int(gid)
                    break
    return mapping

def main():
    # Setup
    altnames_zip = os.path.join(GEONAMES_DIR, "alternateNamesV2.zip")
    altnames_txt = os.path.join(GEONAMES_DIR, "alternateNamesV2.txt")
    iso_file = os.path.join(GEONAMES_DIR, "iso-languagecodes.txt")
    cities_zip = os.path.join(GEONAMES_DIR, "cities1000.zip")
    cities_txt = os.path.join(GEONAMES_DIR, "cities1000.txt")
    
    print("Downloading GeoNames data if needed...")
    download_if_missing(ALTNAMES_URL, altnames_zip)
    download_if_missing(CITIES1000_URL, cities_zip)
    extract_if_missing(altnames_zip, "alternateNamesV2.txt", altnames_txt)
    extract_if_missing(altnames_zip, "iso-languagecodes.txt", iso_file)
    extract_if_missing(cities_zip, "cities1000.txt", cities_txt)
    
    # Get our cities from D1 (or accept via arg)
    print("Loading our cities from D1...")
    our_cities_file = os.path.join(GEONAMES_DIR, "our_cities.json")
    if not os.path.exists(our_cities_file):
        import subprocess
        result = subprocess.run([
            "npx", "wrangler", "d1", "execute", "timeandtimepro-full-v2",
            "--env", "dev", "--remote", "--json",
            "--command", "SELECT c.id, c.name, co.cca2 FROM cities c JOIN countries co ON co.id = c.country_id;"
        ], capture_output=True, text=True, cwd=WORKDIR)
        if result.returncode != 0:
            print("Failed to load cities from D1")
            sys.exit(1)
        cities_data = json.loads(result.stdout)[0]['results']
        with open(our_cities_file, 'w') as f:
            json.dump(cities_data, f)
        our_cities = cities_data
    else:
        with open(our_cities_file) as f:
            our_cities = json.load(f)
    print(f"  {len(our_cities):,} cities")
    
    # Build lookup
    our_lookup = {}
    for c in our_cities:
        our_lookup.setdefault((c['name'].lower().strip(), c['cca2']), []).append(c['id'])
    
    # Build geonameId → dr5hn_id mapping
    print("Matching cities1000 → dr5hn cities...")
    dr5hn_to_geoname = build_dr5hn_to_geoname(cities_txt, our_lookup)
    print(f"  Matched: {len(dr5hn_to_geoname):,} ({len(dr5hn_to_geoname)/len(our_cities)*100:.1f}%)")
    
    # Reverse: geonameId → dr5hn_id
    geoname_to_dr5hn = {v: k for k, v in dr5hn_to_geoname.items()}
    target_gids = set(geoname_to_dr5hn.keys())
    
    # Get valid ISO codes
    valid_codes = get_valid_iso_codes(iso_file)
    print(f"  Valid ISO codes: {len(valid_codes):,}")
    
    # Stream alt names, build SQL
    print("Processing alt names...")
    START_ID = 200000
    current_id = START_ID
    seen = set()  # dedup (city_id, name, lang)
    out_path = os.path.join(WORKDIR, 'migrations', '111_seed_alt_names.sql')
    
    with open(out_path, 'w') as out:
        out.write(f"""-- Migration 111: Seed place_names with GeoNames alternate names
-- Source: https://download.geonames.org/export/dump/alternateNamesV2.txt
-- Matched: dr5hn city_id → geonameId via cities1000.txt (name+country)
-- Filtered to: real ISO 639 language codes
-- Apply then rebuild FTS5: INSERT INTO place_names_fts(place_names_fts) VALUES('rebuild');

""")
        
        BATCH = 9
        batch_buf = []
        matched = 0
        skipped = 0
        stats = defaultdict(int)
        
        def flush_batch():
            if not batch_buf:
                return
            out.write("INSERT INTO place_names (id, canonical_place_id, name, normalized_name, language_code, script, name_type, is_preferred, is_historical, source) VALUES\n")
            out.write(",\n".join(batch_buf))
            out.write(";\n")
            batch_buf.clear()
        
        with open(altnames_txt) as f:
            for line in f:
                parts = line.rstrip("\n").split("\t")
                if len(parts) < 4:
                    continue
                alt_id, geoname_id, isolang, alt_name = parts[0], parts[1], parts[2], parts[3]
                is_pref = parts[4] if len(parts) > 4 else '0'
                is_short = parts[5] if len(parts) > 5 else '0'
                is_coll = parts[6] if len(parts) > 6 else '0'
                is_hist = parts[7] if len(parts) > 7 else '0'
                
                if geoname_id not in target_gids:
                    skipped += 1
                    continue
                if not alt_name or len(alt_name) > 200:
                    skipped += 1
                    continue
                lang = normalize_lang(isolang)
                if not lang or lang not in valid_codes:
                    skipped += 1
                    continue
                
                dr5hn_id = geoname_to_dr5hn[geoname_id]
                key = (dr5hn_id, alt_name, lang)
                if key in seen:
                    continue
                seen.add(key)
                
                norm = normalize_name(alt_name)
                script = get_script(alt_name)
                name_type = get_name_type(is_pref, is_short, is_coll, is_hist)
                
                esc_name = alt_name.replace("'", "''")
                esc_norm = norm
                batch_buf.append(
                    f"({current_id},{dr5hn_id},'{esc_name}','{esc_norm}',"
                    f"'{lang}','{script}','{name_type}',"
                    f"{1 if is_pref == '1' else 0},{1 if is_hist == '1' else 0},'geonames')"
                )
                current_id += 1
                matched += 1
                stats[lang] += 1
                
                if len(batch_buf) >= BATCH:
                    flush_batch()
                
                if matched % 100000 == 0:
                    print(f"  matched: {matched:,}, skipped: {skipped:,}", flush=True)
        
        flush_batch()
        
        # Append language stats
        out.write(f"\n-- {matched:,} total alt names, {len(stats)} languages\n")
        out.write(f"-- Top 20: " + ", ".join(f"{l}={c}" for l, c in sorted(stats.items(), key=lambda x: -x[1])[:20]) + "\n")
    
    print(f"\nDone. Wrote {out_path}")
    print(f"  matched: {matched:,}")
    print(f"  skipped: {skipped:,}")
    print(f"  languages: {len(stats)}")

if __name__ == "__main__":
    main()
