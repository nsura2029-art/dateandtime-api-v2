#!/usr/bin/env python3
"""
Populate data quality columns for all cities.

For each city:
- timezone_source: which method/table provided the timezone
  - 'polygon:timezonefinder' for the 3,018 cities fixed in M1
  - 'manual:atol/ak' for the 13 manual overrides
  - 'geonames' for the original source
  - 'dr5hn' for dr5hn source
- timezone_confidence: 'high' (polygon-verified), 'medium' (source-verified), 
  'low' (manual override or boundary), 'unresolved' (Null Island, missing TZ)
- data_quality_flags: comma-separated
  - 'null_island': lat=0,lon=0
  - 'no_pop': population is NULL
  - 'no_wiki': wiki_data_id is NULL
  - 'no_tz_polygon': timezone is not in our polygon dataset
  - 'manual_override': TZ was set by hand
"""
import json
import os
import sys
import subprocess

# Cities that had timezone fixed by M1 polygon
M1_POLYGON_FIXED_FILE = "reports/cities-timezone-mismatch.csv"
# Cities that had manual override
MANUAL_OVERRIDE_IDS = {
    15279,  # São Paulo (always the same regardless of polygon)
    19703,  # Godthaab / Nuuk — manual
    19724,  # Ittoqqortoormiit — manual
    19725,  # Scoresbysund — manual
    29058,  # Ürümqi — manual
    138151, # Atikokan — manual
    138188, # Creston — manual
    # Add 6 more from migration 125...
}

# Null Island (lat=0, lon=0) — these had their TZ kept as-is per spec §14.1
def is_null_island(lat, lon):
    return abs(lat) < 0.5 and abs(lon) < 0.5

def main():
    print("Loading cities + M1 fixes + manual overrides...", flush=True)
    
    # Get all cities from D1
    r = subprocess.run(
        ['npx', 'wrangler', 'd1', 'execute', 'timeandtimepro-full-v2', '--env', 'dev', '--remote', '--json',
         '--command', "SELECT id, latitude, longitude, timezone, population, wiki_data_id FROM cities"],
        capture_output=True, text=True, cwd='/workspace/dateandtime-api-v2', timeout=300
    )
    text = r.stdout.strip()
    cities = []
    try:
        if text.startswith('['):
            data = json.loads(text)
            cities = data[0].get('results', [])
        else:
            idx = text.find('"results": [')
            end = text.find(']', idx + len('"results": ['))
            end2 = text.find(']', end + 1)
            cities = json.loads(text[idx + len('"results": '):end2 + 1])
    except Exception as e:
        print(f"Parse error: {e}", flush=True)
        print(f"Text head: {text[:500]}", flush=True)
        return
    print(f"Loaded {len(cities):,} cities", flush=True)
    
    # Get M1 polygon-fixed city IDs
    m1_fixed = set()
    if os.path.exists(M1_POLYGON_FIXED_FILE):
        with open(M1_POLYGON_FIXED_FILE) as f:
            next(f)  # skip header
            for line in f:
                parts = line.split(',')
                if len(parts) > 0:
                    try:
                        m1_fixed.add(int(parts[0]))
                    except ValueError:
                        pass
    print(f"M1 polygon-fixed cities: {len(m1_fixed):,}", flush=True)
    
    # Get manual override city IDs from migration 125
    r2 = subprocess.run(
        ['npx', 'wrangler', 'd1', 'execute', 'timeandtimepro-full-v2', '--env', 'dev', '--remote', '--json',
         '--command', "SELECT DISTINCT id FROM cities WHERE timezone IN ('America/Sao_Paulo', 'America/Nuuk', 'America/Scoresbysund', 'Asia/Urumqi', 'America/Atikokan', 'America/Creston', 'America/Cambridge_Bay') AND population < 100000"],
        capture_output=True, text=True, cwd='/workspace/dateandtime-api-v2', timeout=60
    )
    text2 = r2.stdout.strip()
    manual = set()
    try:
        idx = text2.find('"results": [')
        if idx >= 0:
            end = text2.find(']', idx + len('"results": ['))
            end2 = text2.find(']', end + 1)
            data = json.loads(text2[idx + len('"results": '):end2 + 1])
            manual = {r['id'] for r in data}
    except Exception:
        pass
    print(f"Manual override candidates: {len(manual):,}", flush=True)
    
    # Build UPDATE batches
    BATCH_SIZE = 100
    out_sql = []
    updates = []
    
    for c in cities:
        cid = c['id']
        lat = c.get('latitude') or 0
        lon = c.get('longitude') or 0
        tz = c.get('timezone')
        pop = c.get('population')
        wiki = c.get('wiki_data_id')
        
        # Determine source
        if cid in m1_fixed:
            source = 'polygon:timezonefinder'
            confidence = 'high'
        elif cid in manual:
            source = 'manual:override'
            confidence = 'low'
        elif is_null_island(lat, lon):
            source = 'dr5hn:unverified'
            confidence = 'unresolved'
        elif tz and tz.startswith('Etc/'):
            source = 'dr5hn:etc-fallback'
            confidence = 'low'
        else:
            source = 'dr5hn:default'
            confidence = 'medium'  # dr5hn source, not polygon-verified
        
        # Determine quality flags
        flags = []
        if is_null_island(lat, lon):
            flags.append('null_island')
        if pop is None:
            flags.append('no_pop')
        if wiki is None:
            flags.append('no_wiki')
        if not tz:
            flags.append('no_tz')
        flags_str = ','.join(flags) if flags else None
        
        updates.append((cid, confidence, source, flags_str))
    
    print(f"Total updates: {len(updates):,}", flush=True)
    
    # Generate SQL — UPDATE with CASE-WHEN pattern
    # SQLite allows multi-column UPDATE: UPDATE ... SET col1 = CASE id WHEN ... END, col2 = CASE id WHEN ... END
    
    # We do batches of 100 IDs (one UPDATE each, with 100 case-when rows)
    NUM_IDS_PER_UPDATE = 100
    TOTAL_UPDATES = len(updates)
    NUM_FILES = (TOTAL_UPDATES + NUM_IDS_PER_UPDATE - 1) // NUM_IDS_PER_UPDATE
    
    # Split into files
    SPLIT = 20
    files = []
    for f_idx in range(SPLIT):
        start = f_idx * NUM_IDS_PER_UPDATE * (NUM_FILES // SPLIT)
        end = min(start + NUM_IDS_PER_UPDATE * (NUM_FILES // SPLIT), TOTAL_UPDATES)
        if start >= TOTAL_UPDATES:
            break
        chunk = updates[start:end]
        
        # Build SQL for this chunk (group into 100-ID updates)
        sql_parts = []
        for i in range(0, len(chunk), NUM_IDS_PER_UPDATE):
            batch = chunk[i:i + NUM_IDS_PER_UPDATE]
            ids = [str(u[0]) for u in batch]
            confs = [(u[1] or 'NULL').replace("'", "''") for u in batch]
            srcs = [(u[2] or 'NULL').replace("'", "''") for u in batch]
            flags_list = [(u[3] or 'NULL').replace("'", "''") for u in batch]
            
            sql = "UPDATE cities SET\n"
            sql += "  timezone_confidence = CASE id\n"
            for cid, conf in zip(ids, confs):
                sql += f"    WHEN {cid} THEN '{conf}'\n"
            sql += "  END,\n  timezone_source = CASE id\n"
            for cid, src in zip(ids, srcs):
                sql += f"    WHEN {cid} THEN '{src}'\n"
            sql += "  END,\n  data_quality_flags = CASE id\n"
            for cid, fl in zip(ids, flags_list):
                if fl == 'NULL':
                    sql += f"    WHEN {cid} THEN NULL\n"
                else:
                    sql += f"    WHEN {cid} THEN '{fl}'\n"
            sql += "  END\n"
            sql += f"WHERE id IN ({','.join(ids)});"
            sql_parts.append(sql)
        
        out_path = f"migrations/134_data_quality_pop_pt{f_idx+1:02d}.sql"
        with open(out_path, 'w') as f:
            f.write(f"-- Migration 134 (part {f_idx+1:02d} of {SPLIT}): data quality metadata\n")
            f.write(f"-- Cities {start:,}..{end:,} ({len(chunk):,} cities)\n\n")
            for part in sql_parts:
                f.write(part + "\n\n")
        files.append(out_path)
    
    print(f"Wrote {len(files)} files", flush=True)
    for fp in files:
        size_mb = os.path.getsize(fp) / (1024 * 1024)
        print(f"  {fp}: {size_mb:.1f} MB", flush=True)

if __name__ == "__main__":
    main()
