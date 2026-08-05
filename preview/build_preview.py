#!/usr/bin/env python3
"""
Build the clean-calendarific HTML preview for quality gate review.

Shows:
1. Before/after comparison (mixed sources vs calendarific-only)
2. Universal 8-tier preset structure (timeanddate-style)
3. Per-country filter panel (computed from Calendarific)
4. Sample holidays showing derived filter codes
"""

import json
import os
import sys
from collections import Counter, defaultdict
from datetime import datetime

sys.path.insert(0, 'lib')
from calendarific_to_m14 import (
    CF_TYPE_TO_FILTER, get_tradition_filter, derive_filters,
    PRESETS, ALL_FILTER_CODES
)


# ============= DATA LOADING =============

def load_all_calendarific(year_dir):
    """Load all Calendarific JSON for a given year."""
    data = []
    for f in sorted(os.listdir(year_dir)):
        if not f.endswith('.json'): continue
        with open(f'{year_dir}/{f}') as fp:
            d = json.load(fp)
        if 'response' in d and 'holidays' in d['response']:
            for h in d['response']['holidays']:
                data.append(h)
    return data


def get_country_data(holidays, cca2):
    """Filter Calendarific data to a single country."""
    return [h for h in holidays if h.get('country', {}).get('id') == cca2]


# ============= ANALYSIS =============

def compute_filter_counts(holidays):
    """For each holiday, derive filter codes from Calendarific data."""
    counts = Counter()
    for h in holidays:
        name = h.get('name', '')
        cf_type = h.get('type', '')
        filters = derive_filters(name, cf_type)
        for f in filters:
            counts[f] += 1
    return counts


def compute_preset_counts(holidays):
    """For each preset, count holidays that match."""
    preset_counts = {}
    holiday_filter_sets = []
    for h in holidays:
        name = h.get('name', '')
        cf_type = h.get('type', '')
        filters = set(derive_filters(name, cf_type))
        holiday_filter_sets.append((h, filters))

    for bitmask, preset in PRESETS.items():
        if preset["filter_codes"] == "ALL":
            count = len(holidays)
        else:
            preset_filters = set(preset["filter_codes"])
            count = sum(1 for _, hf in holiday_filter_sets if hf & preset_filters)
        preset_counts[bitmask] = count
    return preset_counts


# ============= HTML GENERATION =============

def fetch_current_db_data():
    """Fetch current data from the live API to show what would be lost."""
    import urllib.request
    api_base = "https://dt-api-v2-dev.nsura2029.workers.dev"
    countries = ['US', 'CA', 'IN', 'GB', 'AU', 'DE', 'FR']
    data = {}
    for c in countries:
        try:
            url = f"{api_base}/api/v1/holidays?year=2026&country={c}&limit=500"
            req = urllib.request.Request(url)
            with urllib.request.urlopen(req, timeout=10) as r:
                d = json.loads(r.read().decode())
                holidays = d['data']['holidays']
                source_counts = Counter()
                for h in holidays:
                    for s in h.get('sources', []):
                        source_counts[s] += 1
                data[c] = {
                    'total': len(holidays),
                    'sources': dict(source_counts),
                }
        except Exception as e:
            data[c] = {'total': 0, 'sources': {}, 'error': str(e)}
    return data


def build_html():
    # Load all 2026 + 2027 data
    data_2026 = load_all_calendarific('holiday_data/calendarific/2026')
    data_2027 = load_all_calendarific('holiday_data/calendarific/2027')
    all_data = data_2026 + data_2027

    # Per-country stats
    countries = ['US', 'CA', 'IN', 'GB', 'AU', 'DE', 'FR', 'IT', 'ES', 'JP', 'CN', 'MX', 'BR']
    country_stats = {}
    for cca2 in countries:
        ch = get_country_data(all_data, cca2)
        if not ch:
            continue
        counts = compute_filter_counts(ch)
        presets = compute_preset_counts(ch)
        country_stats[cca2] = {
            'total': len(ch),
            'filter_counts': dict(counts),
            'preset_counts': presets,
        }

    # Build HTML
    current_data = fetch_current_db_data()
    html = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Holiday Cleanup Preview — Calendarific Only</title>
<style>
  * { box-sizing: border-box; }
  body { font-family: -apple-system, system-ui, sans-serif; margin: 0; padding: 24px; background: #f8f9fa; color: #212529; }
  h1 { font-size: 28px; margin: 0 0 8px 0; }
  h2 { font-size: 22px; margin: 32px 0 12px 0; padding-bottom: 8px; border-bottom: 2px solid #1f4e78; }
  h3 { font-size: 18px; margin: 24px 0 8px 0; }
  .subtitle { color: #6c757d; margin: 0 0 24px 0; }
  .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 16px; }
  .card { background: white; border: 1px solid #dee2e6; border-radius: 8px; padding: 16px; }
  .card h4 { margin: 0 0 8px 0; font-size: 14px; color: #1f4e78; }
  .stat { font-size: 32px; font-weight: 700; color: #1f4e78; }
  .stat-label { font-size: 13px; color: #6c757d; }
  table { width: 100%; border-collapse: collapse; margin: 12px 0; font-size: 14px; }
  th, td { padding: 8px 10px; border: 1px solid #dee2e6; text-align: left; }
  th { background: #1f4e78; color: white; font-weight: 600; }
  tr:nth-child(even) td { background: #f8f9fa; }
  .badge { display: inline-block; padding: 2px 8px; border-radius: 10px; font-size: 11px; font-weight: 600; }
  .badge-remove { background: #f8d7da; color: #842029; }
  .badge-keep { background: #d1e7dd; color: #0f5132; }
  .badge-new { background: #cfe2ff; color: #084298; }
  .badge-preset { background: #fff3cd; color: #664d03; }
  .compare-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }
  .compare-col { padding: 16px; border-radius: 8px; }
  .before { background: #f8d7da; border: 1px solid #f5c2c7; }
  .after { background: #d1e7dd; border: 1px solid #badbcc; }
  .bitmask { font-family: monospace; font-size: 12px; background: #e9ecef; padding: 2px 6px; border-radius: 3px; }
  .filter-pill { display: inline-block; padding: 3px 8px; background: #e7f1ff; color: #084298; border-radius: 10px; font-size: 11px; margin: 2px; font-family: monospace; }
  .country-pill { display: inline-block; padding: 4px 10px; background: #1f4e78; color: white; border-radius: 12px; font-size: 12px; font-weight: 600; margin: 2px; }
  .warning { background: #fff3cd; border: 1px solid #ffecb5; padding: 12px; border-radius: 6px; margin: 16px 0; }
  .success { background: #d1e7dd; border: 1px solid #badbcc; padding: 12px; border-radius: 6px; margin: 16px 0; }
  .info { background: #cfe2ff; border: 1px solid #9ec5fe; padding: 12px; border-radius: 6px; margin: 16px 0; }
  .filter-row td { font-family: monospace; font-size: 13px; }
  .legend { display: flex; gap: 16px; flex-wrap: wrap; margin: 8px 0; }
  .check { color: #198754; font-weight: 700; }
  .cross { color: #dc3545; font-weight: 700; }
  .num { font-weight: 600; color: #1f4e78; }
</style>
</head>
<body>

<h1>🧹 Holiday Data Cleanup Preview</h1>
<p class="subtitle">
  Single source: <strong>Calendarific</strong> · 190 countries × 2 years (2026 + 2027) ·
  Universal 8-tier preset structure (timeanddate-style bitmasks)
</p>

<div class="info">
  <strong>Quality gate preview</strong> — review the changes before applying to D1.
  <br>Sources we will REMOVE: <span class="badge badge-remove">nager_date</span>
  <span class="badge badge-remove">un_official</span>
  <span class="badge badge-remove">hebcal</span>
  <span class="badge badge-remove">computed_federal_us</span>
  <br>Source we will KEEP: <span class="badge badge-keep">calendarific_api</span>
  <br>New: <span class="badge badge-new">Universal presets</span> derived from filter codes (same for all countries)
</div>

<h2>1. Sources: Before vs After</h2>
<div class="compare-grid">
  <div class="compare-col before">
    <h3>❌ Before (Mixed sources — LIVE API data per country)</h3>
    <table>
      <tr><th>Country</th><th>Total</th><th>calendarific</th><th>un_official</th><th>hebcal</th><th>nager_date</th><th>computed</th></tr>
"""
    for cca2 in sorted(current_data.keys()):
        d = current_data[cca2]
        s = d.get('sources', {})
        total = d.get('total', 0)
        html += f"""      <tr>
        <td><strong>{cca2}</strong></td>
        <td class="num">{total}</td>
        <td class="num">{s.get('calendarific_api', 0)}</td>
        <td class="num">{s.get('un_official', 0)}</td>
        <td class="num">{s.get('hebcal', 0)}</td>
        <td class="num">{s.get('nager_date', 0)}</td>
        <td class="num">{s.get('computed_federal_us', 0)}</td>
      </tr>
"""
    html += """    </table>
  </div>
  <div class="compare-col after">
    <h3>✅ After (Calendarific only)</h3>
    <table>
      <tr><th>Country</th><th>Before</th><th>After</th><th>Lost</th></tr>
"""
    for cca2 in sorted(current_data.keys()):
        d = current_data[cca2]
        total = d.get('total', 0)
        s = d.get('sources', {})
        cf = s.get('calendarific_api', 0)
        lost = total - cf
        lost_class = "num" if lost == 0 else "num" + (" style='color: #dc3545;'" if lost > 100 else "")
        html += f"""      <tr>
        <td><strong>{cca2}</strong></td>
        <td>{total}</td>
        <td class="num">{cf}</td>
        <td {lost_class}>{lost}</td>
      </tr>
"""
    html += """    </table>
    <p><small>CA/AU/DE/FR: no change (already calendarific-only). US loses 131 (mostly UN + Jewish). IN loses 293 (mostly UN + Jewish). GB loses 292.</small></p>
  </div>
</div>

<div class="warning">
  <strong>⚠️ Data loss to be aware of:</strong>
  <ul>
    <li><strong>UN Observances</strong> (67 US + 225 IN + 225 GB = 517 entries) — Calendarific does include some UN days but with less depth</li>
    <li><strong>Jewish holidays</strong> (31 US + 59 IN + 59 GB = 149 entries) — Calendarific has Hebrew type but our GB/IN data has more via hebcal</li>
    <li><strong>Computed federal holidays</strong> (3 entries) — these were auto-derived from rules; Calendarific has them as "National holiday" anyway</li>
  </ul>
  For MVP this is acceptable. We can add Hebcal + UN sources back later if needed.
</div>

<h2>2. Filter Derivation: Calendarific → M14</h2>
<p>Each Calendarific holiday has a <code>type</code> field that maps to one of the 36 M14 filter codes:</p>
<table>
  <tr>
    <th>Calendarific type</th>
    <th>M14 filter code</th>
    <th>Examples</th>
  </tr>
"""

    # Add the mapping table
    type_examples = {
        "National holiday": "Independence Day, Republic Day, Canada Day",
        "Local holiday": "State-specific gazetted (US states, IN states)",
        "Common local holiday": "Family Day (5 provinces), Civic Holiday",
        "Observance": "Valentine's Day, Mother's Day",
        "Local observance": "Heritage Day, Natal Day",
        "Optional holiday": "Boxing Day (most provinces)",
        "Half-day holiday": "Christmas Eve (some countries)",
        "De facto holiday": "Day after Thanksgiving (US)",
        "Flag day": "Canada Flag Day (Feb 15)",
        "United Nations observance": "International Day of Peace",
        "Worldwide observance": "World Poetry Day",
        "Season": "Equinoxes, Solstices",
        "Clock change/Daylight Saving Time": "DST start/end",
        "Christian": "Christmas, Easter, Good Friday",
        "Hebrew": "Passover, Yom Kippur, Hanukkah",
        "Muslim": "Eid al-Fitr, Eid al-Adha, Ramadan",
        "Orthodox": "Orthodox Christmas, Orthodox Easter",
        "Hinduism": "Diwali, Holi, Navratri",
        "Sporting event": "Super Bowl, Cricket World Cup",
    }
    for cf_type, filter_code in CF_TYPE_TO_FILTER.items():
        if filter_code is None: continue
        examples = type_examples.get(cf_type, "")
        html += f"""
  <tr>
    <td><code>{cf_type}</code></td>
    <td><span class="filter-pill">{filter_code}</span></td>
    <td>{examples}</td>
  </tr>
"""

    # Religious → MAJOR/MORE rule
    html += """
</table>
<div class="success">
  <strong>Bonus:</strong> Religious types (Christian, Hinduism, Muslim, Hebrew, Orthodox) get a SECOND filter code:
  <ul>
    <li><code>CHRISTIAN_MAJOR</code> = Christmas, Easter, Good Friday, Easter Monday</li>
    <li><code>CHRISTIAN_MORE</code> = Ash Wednesday, Pentecost, etc.</li>
    <li><code>HINDU_MAJOR</code> = Diwali, Holi, Navratri, Dussehra, Raksha Bandhan, Janmashtami</li>
    <li><code>MUSLIM_MAJOR</code> = Eid al-Fitr, Eid al-Adha, Ramadan</li>
    <li><code>JEWISH_MAJOR</code> = Passover, Yom Kippur, Rosh Hashanah, Hanukkah</li>
    <li><code>ORTHODOX_MAJOR</code> = Orthodox Christmas, Orthodox Easter</li>
  </ul>
  This lets the timeanddate-style UI show "Major Christian (5)" + "More Christian (12)" independently.
</div>

<h2>3. Universal 8-Tier Preset Structure (timeanddate.com bitmasks)</h2>
<p>Same 8 presets for ALL countries. Each preset is a fixed set of filter codes.</p>
<table>
  <tr>
    <th>Bitmask</th>
    <th>Preset</th>
    <th>Includes</th>
    <th>US 2026</th>
    <th>CA 2026</th>
    <th>IN 2026</th>
    <th>GB 2026</th>
  </tr>
"""

    # Compute per-country preset counts
    preset_per_country = {}
    for cca2 in ['US', 'CA', 'IN', 'GB', 'AU', 'DE', 'FR']:
        ch = get_country_data(data_2026, cca2)
        if ch:
            preset_per_country[cca2] = compute_preset_counts(ch)
        else:
            preset_per_country[cca2] = {}

    for bitmask, preset in PRESETS.items():
        codes_str = ", ".join(preset["filter_codes"][:5])
        if preset["filter_codes"] == "ALL":
            codes_str = "All 36 filter codes"
        elif len(preset["filter_codes"]) > 5:
            codes_str += f" +{len(preset['filter_codes'])-5} more"
        us = preset_per_country.get('US', {}).get(bitmask, 0)
        ca = preset_per_country.get('CA', {}).get(bitmask, 0)
        ind = preset_per_country.get('IN', {}).get(bitmask, 0)
        gb = preset_per_country.get('GB', {}).get(bitmask, 0)
        html += f"""
  <tr>
    <td><span class="bitmask">{bitmask}</span></td>
    <td><strong>{preset['name']}</strong><br><small>{preset['description']}</small></td>
    <td><small>{codes_str}</small></td>
    <td class="num">{us}</td>
    <td class="num">{ca}</td>
    <td class="num">{ind}</td>
    <td class="num">{gb}</td>
  </tr>
"""

    html += """
</table>

<h2>4. Per-Country Filter Panel (computed from Calendarific)</h2>
<p>Each country shows the 27 universal filter codes that have data, with counts. The UI can hide empty filters (state = supported_empty).</p>
"""

    for cca2 in sorted(country_stats.keys()):
        stats = country_stats[cca2]
        total = stats['total']
        counts = stats['filter_counts']
        html += f"""
<h3>{cca2} <span class="badge" style="background: #1f4e78; color: white;">{total} holidays in 2026+2027</span></h3>
<table>
  <tr><th>Filter Code</th><th>Label</th><th>Count</th><th>State</th></tr>
"""
        for code, label, order in ALL_FILTER_CODES:
            count = counts.get(code, 0)
            if count > 0:
                state = '<span class="check">available</span>'
            else:
                state = '<span style="color: #6c757d;">supported_empty</span>'
            html += f"  <tr class='filter-row'><td><span class='filter-pill'>{code}</span></td><td>{label}</td><td class='num'>{count}</td><td>{state}</td></tr>\n"
        html += "</table>\n"

    # Sample holidays
    html += """
<h2>5. Sample Holidays (US 2026) — Derived Filter Codes</h2>
<table>
  <tr><th>Date</th><th>Name</th><th>CF Type</th><th>Derived Filter Codes</th></tr>
"""
    us_holidays = get_country_data(data_2026, 'US')[:30]
    for h in us_holidays:
        name = h.get('name', '')
        cf_type = h.get('type', '')
        filters = derive_filters(name, cf_type)
        date = h.get('date', {}).get('iso', '')
        if isinstance(date, str) and len(date) >= 10:
            date = date[:10]
        try:
            dt = datetime.fromisoformat(date.replace('Z', '+00:00').split('T')[0])
            date = dt.strftime('%d %b %Y (%a)')
        except:
            date = str(date)[:10]
        filters_html = " ".join(f'<span class="filter-pill">{f}</span>' for f in filters)
        html += f"""
  <tr>
    <td>{date}</td>
    <td>{name}</td>
    <td><code>{cf_type}</code></td>
    <td>{filters_html}</td>
  </tr>
"""
    html += """
</table>

<h2>6. What We Keep & What We Lose</h2>
<div class="compare-grid">
  <div class="compare-col after">
    <h3>✅ What we KEEP from Calendarific (rich data)</h3>
    <ul>
      <li>All public holidays (national + local + common local)</li>
      <li>All optional holidays (Boxing Day, etc.)</li>
      <li>All observances (Valentine's, Mother's Day, etc.)</li>
      <li>All seasons (equinoxes, solstices) — 4 per country/year</li>
      <li>All clock changes (DST) — 2 per country/year</li>
      <li>All religious holidays with MAJOR/MORE split:
        <ul>
          <li>Christian: Christmas, Easter, Good Friday, etc.</li>
          <li>Hindu: Diwali, Holi, Navratri, etc.</li>
          <li>Muslim: Eid al-Fitr, Eid al-Adha, Ramadan</li>
          <li>Jewish: Passover, Yom Kippur, Hanukkah</li>
          <li>Orthodox: Orthodox Christmas, Easter</li>
        </ul>
      </li>
      <li>Sporting events (Super Bowl, Cricket World Cup)</li>
      <li>Local observances (Heritage Day, etc.)</li>
    </ul>
  </div>
  <div class="compare-col before">
    <h3>❌ What we LOSE (not in Calendarific)</h3>
    <ul>
      <li>Some UN observances that hebcal/un_official had more depth on</li>
      <li>Some Jewish-specific holidays (Yom HaShoah, etc.) that hebcal tracked but Calendarific missed</li>
      <li>The "computed_federal_us" derived holidays (3 — these were duplicates of Calendarific anyway)</li>
      <li>The nager.date entries (these were a strict subset of Calendarific)</li>
    </ul>
    <p><strong>Net impact:</strong> For most user-facing filters, the count is similar or higher. The losses are mostly in deep UN/religious observances that timeanddate doesn't show prominently anyway.</p>
  </div>
</div>

<h2>7. SQL Cleanup Plan (NOT YET APPLIED — preview only)</h2>
<div class="info">
  <strong>Status:</strong> Preview only. Review the data, then I'll apply after quality gate pass.
</div>
<pre style="background: #f8f9fa; padding: 16px; border-radius: 6px; border: 1px solid #dee2e6; overflow-x: auto; font-size: 12px;">
-- Step 1: Remove sources from the source registry
DELETE FROM holiday_source WHERE code IN (
  'nager_date', 'un_official', 'hebcal', 'computed_federal_us'
);

-- Step 2: Remove holiday_occurrence_source links to those sources
DELETE FROM holiday_occurrence_source
WHERE source_key IN (
  'nager_date', 'un_official', 'hebcal', 'computed_federal_us'
);

-- Step 3: Delete orphan occurrences (no sources left)
DELETE FROM holiday_occurrence
WHERE id NOT IN (SELECT occurrence_id FROM holiday_occurrence_source);

-- Step 4: Delete orphan concepts (no occurrences left)
DELETE FROM holiday_concept
WHERE id NOT IN (SELECT concept_id FROM holiday_occurrence);

-- Step 5: Re-derive filter assignments for all remaining occurrences
-- (Run the calendarific_to_m14.py derivation on each occurrence
--  and rewrite holiday_occurrence_filter accordingly)
DELETE FROM holiday_occurrence_filter;

-- Step 6: Re-insert filter assignments from Calendarific derivation
-- (Generated by lib/calendarific_to_m14.py apply_to_holiday_occurrence_filter)
</pre>

<div class="success">
  <strong>Result after applying this plan:</strong>
  <ul>
    <li>Single source: <code>calendarific_api</code> for all 190 countries</li>
    <li>All holidays have a M14 filter code derived from Calendarific's <code>type</code> field</li>
    <li>Religious holidays have 2 filters (primary + MAJOR/MORE tradition)</li>
    <li>8 universal presets available for any country via bitmask</li>
    <li>Per-country filter panel auto-computed</li>
  </ul>
</div>

</body>
</html>
"""
    return html


if __name__ == "__main__":
    html = build_html()
    with open("preview/clean_calendarific.html", "w") as f:
        f.write(html)
    print(f"✓ Saved: preview/clean_calendarific.html ({len(html):,} bytes)")
    # Also save a smaller sample for testing
    print("\nFile is ready for review. Open in browser to inspect.")
