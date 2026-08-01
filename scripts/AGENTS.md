# scripts/AGENTS.md

> Conventions for seed and helper scripts. Read this BEFORE writing or editing any script.
> Sub-context of root AGENTS.md.

## Types of scripts

1. **Migration generators** (e.g. `102_generate_regions_subs_countries.py`) — produce SQL
   files for `migrations/`. Run on demand, output committed.
2. **Helper scripts** (e.g. `verify-and-run.sh`, `deploy.sh`) — wrap `wrangler` for common
   tasks. Bash, lives at `scripts/` root.
3. **Maintenance scripts** (e.g. `extract-postman.ts` planned) — read DB or OpenAPI spec,
   produce derived artifacts. TypeScript.

## Migration generator patterns

### Required: cross-platform temp dir

```python
import tempfile
from pathlib import Path

TMP_FILE = str(Path(tempfile.gettempdir()) / "filename.json")
# Works on Windows, macOS, Linux
```

**NEVER** hardcode `/tmp/...` — it doesn't exist on Windows.

### Required: NULL handling helper

```python
def sql_num(v):
    """Coerce numeric value to SQL literal. Handles 0 correctly (unlike `or`)."""
    if v is None: return 'NULL'
    if isinstance(v, bool): return '1' if v else '0'
    return str(v)

def escape_sql(s):
    if s is None: return 'NULL'
    return "'" + str(s).replace("'", "''") + "'"
```

**NEVER** use `c.get('field') or 'NULL'` — turns 0 into 'NULL' (since 0 is falsy).

### Required: D1 batch sizing

```python
# Always compute BATCH from column count, never hardcode
N_COLS = 12  # actual column count
BATCH = 8    # 8 × 12 = 96 vars (under D1's 100-var limit)
```

See `migrations/AGENTS.md` for the BATCH table.

### Required: multi-row INSERT structure

```python
# CORRECT: one INSERT per chunk
chunks = [cities[i:i+BATCH] for i in range(0, len(cities), BATCH)]
for chunk in chunks:
    parts.append(
        "INSERT INTO cities (cols) VALUES\n" +
        ",\n".join(rows) + ";"
    )

# WRONG: ; inside a multi-row INSERT
parts.append(",\n".join(rows) + ";")  # for each chunk
# This breaks SQLite's syntax: it sees the first chunk as a complete
# statement, then chokes on the next '(' at offset 4.
```

### Required: download to OS-appropriate temp

```python
import urllib.request
import tempfile
from pathlib import Path

url = "https://example.com/data.json"
out = Path(tempfile.gettempdir()) / "data.json"
if not out.exists():
    print(f"Downloading {url}...")
    urllib.request.urlretrieve(url, str(out))

with open(out) as f:
    data = json.load(f)
```

### Required: parameterized run-all wrapper

```bash
#!/usr/bin/env bash
# Apply per-country seed files. Override DB and remote with env vars.
DB_NAME="${DB_NAME:-timeandtimepro-full}"
if [ "${REMOTE:-0}" = "1" ]; then
  REMOTE_FLAG="--remote"
else
  REMOTE_FLAG=""
fi

npx wrangler d1 execute "$DB_NAME" --env dev $REMOTE_FLAG --file="$1" \
  || { echo "WARNING: $1 failed, continuing"; true; }
```

**NEVER** hardcode the DB name in the wrapper.

### Required: 0-row tolerance

For per-country files, some small countries may have 0 cities in dr5hn. The wrapper
should `|| true` past failures with a warning, not abort.

## Python environment

- **Cross-platform:** Test on Windows, macOS, Linux. The user is on Windows.
- **Python 3.13+:** User's version. Use modern syntax (type hints, dataclasses where useful).
- **No virtualenv required** for these scripts — they have minimal deps (stdlib only).
- **Run with `python3` on *nix, `py` on Windows.** Never rely on `python` (Microsoft Store hijack).

## Bash wrapper patterns

```bash
#!/usr/bin/env bash
set -euo pipefail  # strict mode

# Always check wrangler is available
if ! command -v wrangler &> /dev/null; then
  echo "ERROR: wrangler not found. Install with: npm install -g wrangler"
  exit 1
fi

# Always confirm before prod operations
if [ "$ENV" = "prod" ]; then
  read -p "About to deploy to PROD. Continue? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi
```

## Deploy script (scripts/deploy.sh)

**The deploy script is GATED by "ship it" for prod:**

```bash
ENV="${1:-dev}"

if [ "$ENV" = "prod" ]; then
  echo "About to deploy to PRODUCTION. This will affect live users."
  read -p 'Type "ship it" to confirm: ' confirmation
  if [ "$confirmation" != "ship it" ]; then
    echo "Aborted."
    exit 1
  fi
fi

# Deploy
wrangler deploy --env "$ENV"
echo "Deployed to $ENV."
```

## Verifying a generator

After generating a migration:

1. **Row count** matches expected
2. **No `None` literal** in the output: `grep -c None migrations/XXX_*.sql` (should be 0)
3. **No `0 or NULL` artifacts** (use `sql_num` correctly)
4. **BATCH × N_COLS ≤ 95** vars
5. **Total file size** < 1MB (else split into multiple statements)
6. **Single `;` per statement** (no embedded semicolons in multi-row INSERTs)
7. **Foreign keys** valid (every FK column references a real row)

## Common gotchas

- **dr5hn data quirks:** Some countries (Antarctica, BV, HM) have NULL region_id or subregion_id.
  Fall back to defaults. See `migrations/AGENTS.md`.
- **Unicode in SQL:** `escape_sql` must double single quotes: `"O'Brien"` → `"O''Brien"`.
- **Big files:** For 10MB+ outputs, use `pathlib.Path.write_text` not `open().write()` for atomicity.
- **Network failures:** A truncated download leaves a corrupt file. Use `if not exists` to skip
  re-download — but add a content-length sanity check for large files.
- **JSON nested types:** dr5hn sometimes has `timezones: [{zoneName: "X"}]` (array of objects).
  Always check `isinstance(v, list)` before accessing.

## Adding a new script (checklist)

1. Pick a name following the pattern: `NNN_<description>.<ext>` for generators, plain
   `<verb>.<ext>` for helpers.
2. Add a docstring at the top with: purpose, output, usage, dependencies.
3. Use the NULL handling and BATCH patterns from this file.
4. Test on a small dataset (1 country or 1 timezone) before generating the full set.
5. Run `grep -c None <output>.sql` to verify no `None` literals.
6. Commit on a `feature/*` branch.

## Scripts inventory (current)

| Script | Purpose | Output |
|---|---|---|
| `verify-and-run.sh` | Local dev runner with health checks | (none) |
| `deploy.sh` | Deploy to dev or prod (gated) | (none) |
| `seed/102_generate_regions_subs_countries.py` | Generate 102, 103, 104 | 3 SQL files |
| `seed/105_generate_admin_regions.py` | Generate 105 (admin regions) | 1 SQL file (664 INSERTs) |
| `seed/106_generate_timezones.py` | Generate 106 (time zones) | 1 SQL file (33 INSERTs) |
| `seed/107_generate_cities.py` | Generate per-country city files | 223 SQL files + run-all.sh |
| `seed/missing_tzs.py` | Bootstrap missing IANA timezones | (used for legacy D1) |
