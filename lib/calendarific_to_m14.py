#!/usr/bin/env python3
"""
calendarific_to_m14.py

Derive M14 filter codes from Calendarific's data fields.
Single source: Calendarific API (no nager.date, hebcal, un_official, computed).

Calendarific "type" field → M14 filter_code (primary):
  - National holiday        → PUBLIC_NATIONAL
  - Local holiday           → PUBLIC_LOCAL
  - Common local holiday    → PUBLIC_COMMON_LOCAL
  - Observance              → OBS_COMMON
  - Local observance        → OBS_LOCAL
  - Optional holiday        → OPTIONAL_HOLIDAY
  - Half-day holiday        → HALF_DAY_HOLIDAY
  - De facto holiday        → DE_FACTO_HOLIDAY
  - Flag day                → FLAG_DAY
  - United Nations observ.  → UN_OBSERVANCE
  - Worldwide observance    → WORLD_OBSERVANCE
  - Season                  → SEASON
  - Clock change/Daylight   → CLOCK_CHANGE
  - Christian               → CHRISTIAN_MAJOR
  - Hebrew                  → JEWISH_MAJOR
  - Muslim                  → MUSLIM_MAJOR
  - Orthodox                → ORTHODOX_MAJOR
  - Hinduism                → HINDU_MAJOR
  - Sporting event          → SPORTING_EVENT
  - Weekend                 → (excluded — not a holiday)

MAJOR vs MORE classification (for tradition codes):
  - Christian: Christmas, Easter, Good Friday, Easter Monday → MAJOR; rest → MORE
  - Hindu: Diwali, Holi, Navratri → MAJOR; rest → MORE
  - Muslim: Eid al-Fitr, Eid al-Adha → MAJOR; rest → MORE
  - Jewish: Passover, Yom Kippur (if present) → MAJOR; rest → MORE
  - Orthodox: Christmas, Easter → MAJOR; rest → MORE

Universal 8-tier preset (timeanddate.com bitmask):
  1                  → Public holidays (PUBLIC_NATIONAL, DE_FACTO_HOLIDAY)
  134217729          → + OPTIONAL, PUBLIC_LOCAL, PUBLIC_COMMON_LOCAL, HALF_DAY
  134217737          → + SPECIAL_WORKING_DAY
  134217753          → + OBS_IMPORTANT
  138412057          → + OBS_COMMON
  138412059          → + OBS_LOCAL, OBS_OTHER, FLAG_DAY
  134218041          → + UN_OBSERVANCE, WORLD_OBSERVANCE
  146928447          → All 36 codes (incl. all religious MAJOR/MORE)
"""

# Calendarific type → M14 primary filter
CF_TYPE_TO_FILTER = {
    "National holiday":                  "PUBLIC_NATIONAL",
    "Local holiday":                     "PUBLIC_LOCAL",
    "Common local holiday":              "PUBLIC_COMMON_LOCAL",
    "Observance":                        "OBS_COMMON",
    "Local observance":                  "OBS_LOCAL",
    "Optional holiday":                  "OPTIONAL_HOLIDAY",
    "Half-day holiday":                  "HALF_DAY_HOLIDAY",
    "De facto holiday":                  "DE_FACTO_HOLIDAY",
    "Flag day":                          "FLAG_DAY",
    "United Nations observance":         "UN_OBSERVANCE",
    "Worldwide observance":              "WORLD_OBSERVANCE",
    "Season":                            "SEASON",
    "Clock change/Daylight Saving Time": "CLOCK_CHANGE",
    "Christian":                         "CHRISTIAN_MAJOR",
    "Hebrew":                            "JEWISH_MAJOR",
    "Muslim":                            "MUSLIM_MAJOR",
    "Orthodox":                          "ORTHODOX_MAJOR",
    "Hinduism":                          "HINDU_MAJOR",
    "Sporting event":                    "SPORTING_EVENT",
    "Weekend":                           None,  # exclude
}

# MAJOR vs MORE (per tradition) — keys are M14 tradition codes (uppercase)
TRADITION_MAJOR = {
    "CHRISTIAN": {"Christmas", "Christmas Day", "Easter", "Easter Sunday", "Good Friday", "Easter Monday"},
    "HINDU":     {"Diwali", "Holi", "Navratri", "Dussehra", "Maha Shivaratri", "Raksha Bandhan", "Janmashtami"},
    "MUSLIM":    {"Eid al-Fitr", "Eid al-Adha", "Ramadan", "Eid", "Bakrid"},
    "JEWISH":    {"Passover", "Yom Kippur", "Rosh Hashanah", "Hanukkah"},
    "ORTHODOX":  {"Orthodox Christmas", "Orthodox Easter", "Orthodox Christmas Day", "Orthodox Easter Sunday"},
}

# Map Calendarific type → M14 tradition code
CF_TYPE_TO_TRADITION = {
    "Christian": "CHRISTIAN",
    "Hinduism":  "HINDU",
    "Muslim":    "MUSLIM",
    "Hebrew":    "JEWISH",
    "Orthodox":  "ORTHODOX",
}


def get_tradition_filter(name: str, cf_type: str) -> str:
    """
    Given a holiday name and Calendarific type, return the tradition filter (MAJOR or MORE).
    Returns None if not a tradition type.
    """
    tradition = CF_TYPE_TO_TRADITION.get(cf_type)
    if not tradition:
        return None
    # Check if name is in MAJOR list
    for major_name in TRADITION_MAJOR.get(tradition, set()):
        if major_name.lower() in name.lower() or name.lower() in major_name.lower():
            return f"{tradition}_MAJOR"
    return f"{tradition}_MORE"


def derive_filters(name: str, cf_type: str) -> list:
    """
    Return list of M14 filter codes for a holiday.
    Always includes the primary filter from type.
    For religious types, also includes MAJOR/MORE tradition.
    """
    filters = []
    primary = CF_TYPE_TO_FILTER.get(cf_type)
    if primary:
        filters.append(primary)
    # If religious type, also add MAJOR/MORE
    if cf_type in TRADITION_MAJOR:
        trad_filter = get_tradition_filter(name, cf_type)
        if trad_filter:
            filters.append(trad_filter)
    return filters


# Universal 8-tier preset (timeanddate.com bitmask)
# These are GLOBAL — same for every country
PRESETS = {
    1: {
        "name": "Public holidays",
        "description": "Federal/national gazetted holidays only",
        "filter_codes": ["PUBLIC_NATIONAL", "DE_FACTO_HOLIDAY"],
    },
    134217729: {
        "name": "Public and optional holidays",
        "description": "Public + optional + local + common local",
        "filter_codes": ["PUBLIC_NATIONAL", "DE_FACTO_HOLIDAY", "OPTIONAL_HOLIDAY",
                         "PUBLIC_LOCAL", "PUBLIC_COMMON_LOCAL", "HALF_DAY_HOLIDAY"],
    },
    134217737: {
        "name": "Public holidays and non-working days",
        "description": "Above + special working day overrides",
        "filter_codes": ["PUBLIC_NATIONAL", "DE_FACTO_HOLIDAY", "OPTIONAL_HOLIDAY",
                         "PUBLIC_LOCAL", "PUBLIC_COMMON_LOCAL", "HALF_DAY_HOLIDAY",
                         "SPECIAL_WORKING_DAY"],
    },
    134217753: {
        "name": "Holidays and some observances",
        "description": "Above + important observances",
        "filter_codes": ["PUBLIC_NATIONAL", "DE_FACTO_HOLIDAY", "OPTIONAL_HOLIDAY",
                         "PUBLIC_LOCAL", "PUBLIC_COMMON_LOCAL", "HALF_DAY_HOLIDAY",
                         "SPECIAL_WORKING_DAY", "OBS_IMPORTANT"],
    },
    138412057: {
        "name": "Holidays (incl. some local) and observances",
        "description": "Above + common observances",
        "filter_codes": ["PUBLIC_NATIONAL", "DE_FACTO_HOLIDAY", "OPTIONAL_HOLIDAY",
                         "PUBLIC_LOCAL", "PUBLIC_COMMON_LOCAL", "HALF_DAY_HOLIDAY",
                         "SPECIAL_WORKING_DAY", "OBS_IMPORTANT", "OBS_COMMON"],
    },
    138412059: {
        "name": "Holidays (incl. all local) and observances",
        "description": "Above + local + other observances + flag day",
        "filter_codes": ["PUBLIC_NATIONAL", "DE_FACTO_HOLIDAY", "OPTIONAL_HOLIDAY",
                         "PUBLIC_LOCAL", "PUBLIC_COMMON_LOCAL", "HALF_DAY_HOLIDAY",
                         "SPECIAL_WORKING_DAY", "OBS_IMPORTANT", "OBS_COMMON",
                         "OBS_LOCAL", "OBS_OTHER", "FLAG_DAY"],
    },
    134218041: {
        "name": "Holidays and many observances",
        "description": "Above + UN + worldwide observances",
        "filter_codes": ["PUBLIC_NATIONAL", "DE_FACTO_HOLIDAY", "OPTIONAL_HOLIDAY",
                         "PUBLIC_LOCAL", "PUBLIC_COMMON_LOCAL", "HALF_DAY_HOLIDAY",
                         "SPECIAL_WORKING_DAY", "OBS_IMPORTANT", "OBS_COMMON",
                         "OBS_LOCAL", "OBS_OTHER", "FLAG_DAY",
                         "UN_OBSERVANCE", "WORLD_OBSERVANCE"],
    },
    146928447: {
        "name": "All holidays/observances/religious events",
        "description": "Everything: all 36 codes (incl. all religious traditions, sports, seasons)",
        "filter_codes": "ALL",  # All 36 codes
    },
}


# Country filter policy (universal — same for all countries)
# Each country uses 7-22 of these depending on cultural relevance
# M14 has 36 codes; here are the ones in the timeanddate UI structure
ALL_FILTER_CODES = [
    # Type axis (Federal/National → Optional)
    ("PUBLIC_NATIONAL",     "Federal/National Holidays", 10),
    ("PUBLIC_LOCAL",        "Local Holidays",            20),
    ("PUBLIC_COMMON_LOCAL", "Common Local Holidays",     30),
    ("DE_FACTO_HOLIDAY",    "De Facto Holidays",         40),
    ("OPTIONAL_HOLIDAY",    "Optional Holidays",         50),
    ("HALF_DAY_HOLIDAY",    "Half-Day Holidays",         60),
    ("SPECIAL_WORKING_DAY", "Special Working Days",      70),
    ("FLAG_DAY",            "Flag Day",                  80),
    # Observance axis
    ("OBS_IMPORTANT",       "Important Observances",     200),
    ("OBS_COMMON",          "Common Observances",        210),
    ("OBS_OTHER",           "Other Observances",         220),
    ("OBS_LOCAL",           "Local Observances",         230),
    # Worldwide
    ("UN_OBSERVANCE",       "UN Observances",            300),
    ("WORLD_OBSERVANCE",    "Worldwide Observances",     310),
    # Astronomical
    ("SEASON",              "Seasons",                   320),
    ("CLOCK_CHANGE",        "Clock Change Dates",        330),
    # Sporting
    ("SPORTING_EVENT",      "Sporting Events",           340),
    # Religion
    ("CHRISTIAN_MAJOR",     "Major Christian",           400),
    ("CHRISTIAN_MORE",      "More Christian",            410),
    ("JEWISH_MAJOR",        "Major Jewish",              420),
    ("JEWISH_MORE",         "More Jewish",               430),
    ("MUSLIM_MAJOR",        "Major Muslim",              440),
    ("MUSLIM_MORE",         "More Muslim",               450),
    ("HINDU_MAJOR",         "Major Hindu",               460),
    ("HINDU_MORE",          "More Hindu",                470),
    ("ORTHODOX_MAJOR",      "Major Orthodox",            480),
    ("ORTHODOX_MORE",       "More Orthodox",             490),
    ("BUDDHIST",            "Buddhist Holidays",         500),
    ("OTHER_RELIGION",      "Other Religious",           510),
]


if __name__ == "__main__":
    # Test
    test_cases = [
        ("Christmas Day", "Christian"),
        ("Easter Sunday", "Christian"),
        ("Ash Wednesday", "Christian"),
        ("Diwali", "Hinduism"),
        ("Holi", "Hinduism"),
        ("Eid al-Fitr", "Muslim"),
        ("Passover", "Hebrew"),
        ("Orthodox Christmas", "Orthodox"),
        ("New Year's Day", "National holiday"),
        ("Valentine's Day", "Observance"),
    ]
    print("Test derivation:")
    for name, cf_type in test_cases:
        filters = derive_filters(name, cf_type)
        print(f"  {name:25} ({cf_type:25}) → {filters}")
