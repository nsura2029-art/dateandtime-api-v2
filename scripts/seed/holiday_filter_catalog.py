#!/usr/bin/env python3
"""
scripts/seed/holiday_filter_catalog.py

M13: Seed the holiday_filter catalog with the 18 US filters from the spec
+ country_filter_policy for US and NL (the variance).

US (per the screenshot) shows 18 filters.
NL shows 4 (Federal/National, Important Observances, Common Observances, Seasons).

The catalog is global; per-country applicability is in country_filter_policy.
"""
import os
import time
import json
import urllib.request

ACCOUNT = "f0de6c4b68becd81e60507ecf9410199"
DB_ID = "ab54b1d7-6791-4d29-a94c-c95e6a560b7e"
TOKEN = os.environ.get("CLOUDFLARE_API_TOKEN", "")
HEADERS = {"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"}


def http_query(sql: str, params: list = None) -> dict:
    body = {"sql": sql}
    if params:
        body["params"] = params
    payload = json.dumps(body).encode()
    req = urllib.request.Request(
        f"https://api.cloudflare.com/client/v4/accounts/{ACCOUNT}/d1/database/{DB_ID}/query",
        data=payload, method="POST",
        headers=HEADERS,
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            resp = json.loads(r.read().decode())
            inner = (resp.get("result") or [{}])[0]
            return {
                "ok": resp.get("success") and inner.get("success", False),
                "data": inner.get("results", []),
                "error": (inner.get("errors", [{}])[0].get("message", "") if not inner.get("success") else ""),
            }
    except Exception as e:
        return {"ok": False, "data": [], "error": str(e)}


# The 18 filters visible on Timeanddate US + spec additions
# Maps to atomic dimensions from spec section 4
FILTERS = [
    # (code, label, atomic_legal_status, atomic_scope_level, atomic_observance_rank,
    #  atomic_tradition, atomic_event_domain, atomic_op_effect, default_state, default_selected, display_order)
    ("PUBLIC_NATIONAL",   "Federal/National Holidays",   "public",     "country",     None, None,           "civil",      "work_off",      "unsupported", 1, 10),
    ("PUBLIC_COMMON_LOCAL", "Common Local Holidays",     "public",     "subdivision", None, None,           "civil",      "work_off",      "unsupported", 0, 20),
    ("PUBLIC_LOCAL",      "Local Holidays",              "public",     "subdivision", None, None,           "civil",      "work_off",      "unsupported", 1, 30),
    ("DE_FACTO_HOLIDAY",  "De Facto Holidays",           "de_facto",   "country",     None, None,           "civil",      "work_off",      "unsupported", 0, 40),
    ("OPTIONAL_HOLIDAY",  "Optional/Restricted Holidays", "optional",  "country",     None, None,           "civil",      None,            "unsupported", 0, 50),
    ("HALF_DAY_HOLIDAY",  "Half-Day Holidays",           "half_day",   "country",     None, None,           "civil",      "work_off",      "unsupported", 0, 60),
    ("SPECIAL_WORKING_DAY", "Special Weekend Working Days", "working_day_override", "country", None, None, "civil", None, "unsupported", 0, 70),
    ("FLAG_DAY",          "Flag Day(s)",                 "observance", "country",     None, None,           "civil",      None,            "unsupported", 0, 80),
    ("BANK_CLOSURE",      "Bank and Payment Closures",   "public",     "country",     None, None,           "finance",    "bank_closed",   "unsupported", 0, 90),
    ("GOVERNMENT_CLOSURE", "Government Office Closures",  "public",     "country",     None, None,           "civil",      "authority_closed", "unsupported", 0, 100),
    ("MARKET_CLOSURE",    "Financial Market Closures",   "public",     "country",     None, None,           "finance",    "market_closed", "unsupported", 0, 110),
    ("SCHOOL_HOLIDAY",    "School Holidays",             "public",     "subdivision", None, None,           "school",     "school_closed", "unsupported", 0, 120),
    ("OBS_IMPORTANT",     "Important Observances",       "observance", "country",     "important", None,     "civil",      None,            "unsupported", 1, 200),
    ("OBS_COMMON",        "Common Observances",          "observance", "country",     "common",    None,     "civil",      None,            "unsupported", 1, 210),
    ("OBS_OTHER",         "Other Observances",           "observance", "country",     "other",     None,     "civil",      None,            "unsupported", 0, 220),
    ("OBS_LOCAL",         "Local Observances",           "observance", "subdivision", "local",     None,     "civil",      None,            "unsupported", 0, 230),
    ("ELECTION_EVENT",    "Elections and Civic Events",  "observance", "country",     None, None,           "election",   None,            "unsupported", 0, 240),
    ("AWARENESS_PERIOD",  "Awareness Days and Weeks",    "observance", "global",      None, None,           "civil",      None,            "unsupported", 0, 250),
    ("FUN_HOLIDAY",       "Fun and Trivial Holidays",    "observance", "global",      None, None,           "civil",      None,            "unsupported", 0, 260),
    ("UN_OBSERVANCE",     "United Nations Observances",  "observance", "global",      None, None,           "UN",         None,            "unsupported", 0, 300),
    ("WORLD_OBSERVANCE",  "Worldwide Observances",       "observance", "global",      None, None,           "worldwide",  None,            "unsupported", 0, 310),
    ("SEASON",            "Seasons",                     "observance", "global",      None, None,           "astronomical", None,        "unsupported", 1, 320),
    ("CLOCK_CHANGE",      "Clock Change Dates",          "observance", "global",      None, None,           "time_zone",  None,            "unsupported", 1, 330),
    ("SPORTING_EVENT",    "Sporting Events",             "observance", "country",     None, None,           "sports",     None,            "unsupported", 0, 340),
    ("CHRISTIAN_MAJOR",   "Major Christian",             "observance", "country",     "important", "christian", "religious",   None,            "unsupported", 1, 400),
    ("CHRISTIAN_MORE",    "More Christian",              "observance", "country",     "other",     "christian", "religious",   None,            "unsupported", 0, 410),
    ("JEWISH_MAJOR",      "Major Jewish",                "observance", "country",     "important", "jewish",    "religious",   None,            "unsupported", 0, 420),
    ("JEWISH_MORE",       "More Jewish",                 "observance", "country",     "other",     "jewish",    "religious",   None,            "unsupported", 0, 430),
    ("MUSLIM_MAJOR",      "Major Muslim",                "observance", "country",     "important", "muslim",    "religious",   None,            "unsupported", 0, 440),
    ("MUSLIM_MORE",       "More Muslim",                 "observance", "country",     "other",     "muslim",    "religious",   None,            "unsupported", 0, 450),
    ("HINDU_MAJOR",       "Major Hindu",                 "observance", "country",     "important", "hindu",     "religious",   None,            "unsupported", 0, 460),
    ("HINDU_MORE",        "More Hindu",                  "observance", "country",     "other",     "hindu",     "religious",   None,            "unsupported", 0, 470),
    ("ORTHODOX_MAJOR",    "Major Orthodox",              "observance", "country",     "important", "orthodox",  "religious",   None,            "unsupported", 0, 480),
    ("ORTHODOX_MORE",     "More Orthodox",               "observance", "country",     "other",     "orthodox",  "religious",   None,            "unsupported", 0, 490),
    ("BUDDHIST",          "Buddhist Holidays",           "observance", "country",     None,        "buddhist",  "religious",   None,            "unsupported", 0, 500),
    ("OTHER_RELIGION",    "Other Religious Observances", "observance", "country",     None,        "other_religion", "religious", None,       "unsupported", 0, 510),
]


# US policy — 18 filters visible in screenshot
US_POLICY = [
    # (filter_code, state, default_selected, display_order)
    ("PUBLIC_NATIONAL",      "available", 1, 10),
    ("PUBLIC_LOCAL",         "available", 1, 20),
    ("OBS_IMPORTANT",        "available", 1, 200),
    ("OBS_COMMON",           "available", 1, 210),
    ("OBS_OTHER",            "available", 0, 220),
    ("OBS_LOCAL",            "available", 0, 230),
    ("SEASON",               "available", 1, 320),
    ("CLOCK_CHANGE",         "available", 1, 330),
    ("WORLD_OBSERVANCE",     "available", 0, 310),
    ("UN_OBSERVANCE",        "available", 0, 300),
    ("CHRISTIAN_MAJOR",      "available", 1, 400),
    ("CHRISTIAN_MORE",       "available", 0, 410),
    ("JEWISH_MAJOR",         "supported_empty", 0, 420),
    ("JEWISH_MORE",          "supported_empty", 0, 430),
    ("MUSLIM_MAJOR",         "available", 0, 440),
    ("HINDU_MAJOR",          "available", 0, 460),
    ("ORTHODOX_MAJOR",       "supported_empty", 0, 480),
    ("SPORTING_EVENT",       "supported_empty", 0, 340),
]

# NL policy — 4 filters per spec section 6.4
NL_POLICY = [
    ("PUBLIC_NATIONAL", "available", 1, 10),
    ("OBS_IMPORTANT",   "available", 1, 200),
    ("OBS_COMMON",      "available", 1, 210),
    ("SEASON",          "available", 1, 320),
]


def main():
    if not TOKEN:
        print("ERROR: CLOUDFLARE_API_TOKEN not set")
        return

    now_ms = int(time.time() * 1000)

    print("Step 1: Seed holiday_filter catalog ...")
    rows = []
    for code, label, ls, scope, rank, trad, domain, op, default_state, def_sel, order in FILTERS:
        label_escaped = label.replace("'", "''")
        def q(v):
            return f"'{v}'" if v else "NULL"
        rows.append(
            f"('{code}', '{label_escaped}', {q(ls)}, {q(scope)}, {q(rank)}, "
            f"{q(trad)}, {q(domain)}, {q(op)}, '{default_state}', {def_sel}, {order}, {now_ms})"
        )

    # Write to SQL file
    sql_path = "tmp/holiday_filter_catalog.sql"
    os.makedirs("tmp", exist_ok=True)
    # 11 cols × 9 rows = 99 vars
    BATCH = 9
    with open(sql_path, "w") as f:
        f.write("DELETE FROM holiday_filter;\n")
        for i in range(0, len(rows), BATCH):
            chunk = rows[i:i + BATCH]
            placeholders = ",".join(["(?,?,?,?,?,?,?,?,?,?,?,?)"] * len(chunk))
            f.write(f"INSERT OR REPLACE INTO holiday_filter "
                    f"(code, label_en, atomic_legal_status, atomic_scope_level, atomic_observance_rank, "
                    f"atomic_tradition, atomic_event_domain, atomic_op_effect, default_state, default_selected, "
                    f"display_order, created_at) "
                    f"VALUES {','.join(chunk)};\n")
    print(f"  Wrote {sql_path} ({len(rows)} rows)")

    print("\nStep 2: Seed country_filter_policy for US + NL ...")
    policy_rows = []
    for code, state, sel, order in US_POLICY:
        policy_rows.append(f"('US', '{code}', '{state}', {sel}, {order}, {now_ms})")
    for code, state, sel, order in NL_POLICY:
        policy_rows.append(f"('NL', '{code}', '{state}', {sel}, {order}, {now_ms})")

    policy_path = "tmp/country_filter_policy.sql"
    with open(policy_path, "w") as f:
        f.write("DELETE FROM country_filter_policy WHERE country_code IN ('US', 'NL');\n")
        # 6 cols × 16 rows = 96 vars
        BATCH = 16
        for i in range(0, len(policy_rows), BATCH):
            chunk = policy_rows[i:i + BATCH]
            placeholders = ",".join(["(?,?,?,?,?,?)"] * len(chunk))
            f.write(f"INSERT OR REPLACE INTO country_filter_policy "
                    f"(country_code, filter_code, state, default_selected, display_order, updated_at) "
                    f"VALUES {','.join(chunk)};\n")
    print(f"  Wrote {policy_path} ({len(policy_rows)} rows)")

    print("\n=== NEXT STEPS ===")
    print(f"  1. npx wrangler d1 execute timeandtimepro-full-v2 --file={sql_path} --env dev --remote")
    print(f"  2. npx wrangler d1 execute timeandtimepro-full-v2 --file={policy_path} --env dev --remote")


if __name__ == "__main__":
    main()
