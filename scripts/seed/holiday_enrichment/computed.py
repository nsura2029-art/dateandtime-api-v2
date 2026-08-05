"""
holiday_enrichment/computed.py
Computes holiday dates from rules (no external API needed).
Returns a list of dicts ready for insertion into holiday_occurrence.
"""
import calendar
import time
from datetime import date, datetime, timedelta

# =============================================================================
# Date utility functions
# =============================================================================

def nth_weekday(year, month, weekday, n):
    """Get the nth occurrence of a weekday in a month (1-indexed, weekday 0=Mon)."""
    first = date(year, month, 1)
    # Find first weekday
    days_ahead = (weekday - first.weekday()) % 7
    first_weekday = first + timedelta(days=days_ahead)
    return first_weekday + timedelta(weeks=n-1)


def last_weekday(year, month, weekday):
    """Get the last occurrence of a weekday in a month."""
    last_day = calendar.monthrange(year, month)[1]
    last = date(year, month, last_day)
    days_back = (last.weekday() - weekday) % 7
    return last - timedelta(days=days_back)


def easter_sunday(year):
    """Gregorian Computus (Anonymous Gregorian algorithm)."""
    a = year % 19
    b = year // 100
    c = year % 100
    d = b // 4
    e = b % 4
    f = (b + 8) // 25
    g = (b - f + 1) // 3
    h = (19*a + b - d - g + 15) % 30
    i = c // 4
    k = c % 4
    l = (32 + 2*e + 2*i - h - k) % 7
    m = (a + 11*h + 22*l) // 451
    month = (h + l - 7*m + 114) // 31
    day = ((h + l - 7*m + 114) % 31) + 1
    return date(year, month, day)


def observed_shift(year, month, day):
    """If a fixed-date holiday falls on Sat/Sun, shift per US OPM rule.
    Saturday → preceding Friday
    Sunday → following Monday
    """
    d = date(year, month, day)
    if d.weekday() == 5:  # Saturday → Friday
        return d - timedelta(days=1)
    if d.weekday() == 6:  # Sunday → Monday
        return d + timedelta(days=1)
    return d


def spring_equinox(year):
    """March equinox (vernal). Uses Meeus high-precision algorithm (Astronomical Algorithms, Ch. 27).
    Accurate to within ~1 minute for years 1000-3000.
    """
    # Meeus 27.A (March equinox)
    y = (year - 2000) / 1000.0
    jde0 = 2451623.80984 + 365242.37404 * y + 0.05169 * y**2 - 0.00411 * y**3 - 0.00057 * y**4
    # Add periodic terms (Meeus Table 27.A)
    t = (jde0 - 2451545.0) / 36525
    w = 35999.373 * t - 2.47
    d = 1.0 + 0.50000 * t
    s = 1.0 + 0.50000 * t  # simplified
    delta = (0.00001 * (
        485 * _cos_deg(324.96 + 1934.136 * t) +
        203 * _cos_deg(337.23 + 32964.467 * t) +
        199 * _cos_deg(342.08 + 20.186 * t) +
        182 * _cos_deg(27.85 + 445267.112 * t) +
        156 * _cos_deg(73.14 + 45036.886 * t) +
        136 * _cos_deg(171.52 + 22518.443 * t) +
        77 * _cos_deg(222.54 + 65928.934 * t) +
        74 * _cos_deg(296.72 + 3034.906 * t) +
        70 * _cos_deg(243.58 + 9037.513 * t) +
        58 * _cos_deg(119.81 + 33718.147 * t) +
        52 * _cos_deg(297.17 + 150.678 * t) +
        50 * _cos_deg(21.02 + 2281.226 * t) +
        45 * _cos_deg(247.54 + 29929.562 * t) +
        44 * _cos_deg(325.15 + 31555.956 * t) +
        29 * _cos_deg(60.93 + 4443.417 * t) +
        18 * _cos_deg(155.12 + 67555.328 * t) +
        17 * _cos_deg(288.79 + 4562.452 * t) +
        16 * _cos_deg(198.04 + 62894.029 * t) +
        14 * _cos_deg(199.76 + 31436.921 * t) +
        12 * _cos_deg(95.39 + 14577.848 * t) +
        12 * _cos_deg(287.11 + 31931.756 * t) +
        12 * _cos_deg(320.81 + 34777.259 * t) +
        9 * _cos_deg(227.73 + 1222.114 * t) +
        8 * _cos_deg(15.45 + 16859.074 * t)
    ))
    jde = jde0 + delta
    return _jde_to_date(jde)


def summer_solstice(year):
    """June solstice (Meeus 27.B)."""
    y = (year - 2000) / 1000.0
    jde0 = 2451716.56767 + 365241.62603 * y + 0.00325 * y**2 + 0.00888 * y**3 - 0.00030 * y**4
    t = (jde0 - 2451545.0) / 36525
    delta = (0.00001 * (
        485 * _cos_deg(324.96 + 1934.136 * t) +
        203 * _cos_deg(337.23 + 32964.467 * t) +
        199 * _cos_deg(342.08 + 20.186 * t) +
        182 * _cos_deg(27.85 + 445267.112 * t) +
        156 * _cos_deg(73.14 + 45036.886 * t) +
        136 * _cos_deg(171.52 + 22518.443 * t) +
        77 * _cos_deg(222.54 + 65928.934 * t) +
        74 * _cos_deg(296.72 + 3034.906 * t) +
        70 * _cos_deg(243.58 + 9037.513 * t) +
        58 * _cos_deg(119.81 + 33718.147 * t) +
        52 * _cos_deg(297.17 + 150.678 * t) +
        50 * _cos_deg(21.02 + 2281.226 * t) +
        45 * _cos_deg(247.54 + 29929.562 * t) +
        44 * _cos_deg(325.15 + 31555.956 * t) +
        29 * _cos_deg(60.93 + 4443.417 * t) +
        18 * _cos_deg(155.12 + 67555.328 * t) +
        17 * _cos_deg(288.79 + 4562.452 * t) +
        16 * _cos_deg(198.04 + 62894.029 * t) +
        14 * _cos_deg(199.76 + 31436.921 * t) +
        12 * _cos_deg(95.39 + 14577.848 * t) +
        12 * _cos_deg(287.11 + 31931.756 * t) +
        12 * _cos_deg(320.81 + 34777.259 * t) +
        9 * _cos_deg(227.73 + 1222.114 * t) +
        8 * _cos_deg(15.45 + 16859.074 * t)
    ))
    jde = jde0 + delta
    return _jde_to_date(jde)


def autumn_equinox(year):
    """September equinox (Meeus 27.C)."""
    y = (year - 2000) / 1000.0
    jde0 = 2451810.21715 + 365242.01767 * y - 0.11575 * y**2 + 0.00337 * y**3 + 0.00078 * y**4
    t = (jde0 - 2451545.0) / 36525
    delta = (0.00001 * (
        485 * _cos_deg(324.96 + 1934.136 * t) +
        203 * _cos_deg(337.23 + 32964.467 * t) +
        199 * _cos_deg(342.08 + 20.186 * t) +
        182 * _cos_deg(27.85 + 445267.112 * t) +
        156 * _cos_deg(73.14 + 45036.886 * t) +
        136 * _cos_deg(171.52 + 22518.443 * t) +
        77 * _cos_deg(222.54 + 65928.934 * t) +
        74 * _cos_deg(296.72 + 3034.906 * t) +
        70 * _cos_deg(243.58 + 9037.513 * t) +
        58 * _cos_deg(119.81 + 33718.147 * t) +
        52 * _cos_deg(297.17 + 150.678 * t) +
        50 * _cos_deg(21.02 + 2281.226 * t) +
        45 * _cos_deg(247.54 + 29929.562 * t) +
        44 * _cos_deg(325.15 + 31555.956 * t) +
        29 * _cos_deg(60.93 + 4443.417 * t) +
        18 * _cos_deg(155.12 + 67555.328 * t) +
        17 * _cos_deg(288.79 + 4562.452 * t) +
        16 * _cos_deg(198.04 + 62894.029 * t) +
        14 * _cos_deg(199.76 + 31436.921 * t) +
        12 * _cos_deg(95.39 + 14577.848 * t) +
        12 * _cos_deg(287.11 + 31931.756 * t) +
        12 * _cos_deg(320.81 + 34777.259 * t) +
        9 * _cos_deg(227.73 + 1222.114 * t) +
        8 * _cos_deg(15.45 + 16859.074 * t)
    ))
    jde = jde0 + delta
    return _jde_to_date(jde)


def winter_solstice(year):
    """December solstice (Meeus 27.D)."""
    y = (year - 2000) / 1000.0
    jde0 = 2451900.05952 + 365242.74049 * y - 0.06223 * y**2 - 0.00823 * y**3 + 0.00032 * y**4
    t = (jde0 - 2451545.0) / 36525
    delta = (0.00001 * (
        485 * _cos_deg(324.96 + 1934.136 * t) +
        203 * _cos_deg(337.23 + 32964.467 * t) +
        199 * _cos_deg(342.08 + 20.186 * t) +
        182 * _cos_deg(27.85 + 445267.112 * t) +
        156 * _cos_deg(73.14 + 45036.886 * t) +
        136 * _cos_deg(171.52 + 22518.443 * t) +
        77 * _cos_deg(222.54 + 65928.934 * t) +
        74 * _cos_deg(296.72 + 3034.906 * t) +
        70 * _cos_deg(243.58 + 9037.513 * t) +
        58 * _cos_deg(119.81 + 33718.147 * t) +
        52 * _cos_deg(297.17 + 150.678 * t) +
        50 * _cos_deg(21.02 + 2281.226 * t) +
        45 * _cos_deg(247.54 + 29929.562 * t) +
        44 * _cos_deg(325.15 + 31555.956 * t) +
        29 * _cos_deg(60.93 + 4443.417 * t) +
        18 * _cos_deg(155.12 + 67555.328 * t) +
        17 * _cos_deg(288.79 + 4562.452 * t) +
        16 * _cos_deg(198.04 + 62894.029 * t) +
        14 * _cos_deg(199.76 + 31436.921 * t) +
        12 * _cos_deg(95.39 + 14577.848 * t) +
        12 * _cos_deg(287.11 + 31931.756 * t) +
        12 * _cos_deg(320.81 + 34777.259 * t) +
        9 * _cos_deg(227.73 + 1222.114 * t) +
        8 * _cos_deg(15.45 + 16859.074 * t)
    ))
    jde = jde0 + delta
    return _jde_to_date(jde)


def _cos_deg(angle_deg):
    """Cosine of angle in degrees."""
    import math
    return math.cos(math.radians(angle_deg))


def _jde_to_date(jde):
    """Convert Julian Day Ephemeris to Python date (UTC)."""
    import math
    # JDE to Julian Day (TT ≈ UTC for our purposes)
    jd = jde + 0.5
    # Algorithm from Meeus Ch. 7
    z = int(jd)
    f = jd - z
    if z < 2299161:
        a = z
    else:
        alpha = int((z - 1867216.25) / 36524.25)
        a = z + 1 + alpha - int(alpha / 4)
    b = a + 1524
    c = int((b - 122.1) / 365.25)
    d = int(365.25 * c)
    e = int((b - d) / 30.6001)
    day = b - d - int(30.6001 * e) + f
    day_int = int(day)
    if e < 14:
        month = e - 1
    else:
        month = e - 13
    if month > 2:
        year = c - 4716
    else:
        year = c - 4715
    return date(year, month, day_int)


def dst_transitions_us(year):
    """US DST: starts 2nd Sun March, ends 1st Sun November."""
    return {
        "start": nth_weekday(year, 3, 6, 2),  # 2nd Sunday of March
        "end": nth_weekday(year, 11, 6, 1),   # 1st Sunday of November
    }


# =============================================================================
# Holiday generators per country
# =============================================================================

def generate_us_federal(year, us_country_id):
    """Generate US federal holidays (5 U.S.C. § 6103).
    Returns list of dicts ready for D1 insertion.
    """
    holidays = []

    def add(name_en, d, tradition='civic', concept_origin='computed_federal_us', category='public_holiday', scope_level='country', event_domain=None, observed_date=None, **extra):
        return {
            "concept_name": name_en,
            "concept_tradition": tradition,
            "concept_origin": concept_origin,
            "country_id": us_country_id,
            "subdivision_code": None,
            "start_date": d.isoformat(),
            "observed_date": observed_date,
            "date_role": "actual",
            "legal_status": "public",
            "scope_level": scope_level,
            "event_domain": event_domain or ("civil" if tradition == "civic" else "religious"),
            "prominence": "major",
            "date_status": "confirmed",
            "origin": concept_origin,
            "category": category,
            "filters": extra.pop("filters", ["PUBLIC_NATIONAL", "GOVERNMENT_CLOSURE"]),
            **extra,
        }

    # New Year's Day — Jan 1, observed Monday
    actual = date(year, 1, 1)
    observed = observed_shift(year, 1, 1)
    holidays.append(add("New Year's Day", actual, observed_date=observed.isoformat() if observed != actual else None))

    # MLK Day — 3rd Monday of January
    d = nth_weekday(year, 1, 0, 3)
    holidays.append(add("Martin Luther King Jr. Day", d, tradition='civic'))

    # Presidents' Day — 3rd Monday of February
    d = nth_weekday(year, 2, 0, 3)
    holidays.append(add("Presidents' Day", d, tradition='civic'))

    # Memorial Day — last Monday of May
    d = last_weekday(year, 5, 0)
    holidays.append(add("Memorial Day", d, tradition='civic'))

    # Juneteenth — Jun 19
    actual = date(year, 6, 19)
    observed = observed_shift(year, 6, 19)
    holidays.append(add("Juneteenth National Independence Day", actual, observed_date=observed.isoformat() if observed != actual else None))

    # Independence Day — Jul 4
    actual = date(year, 7, 4)
    observed = observed_shift(year, 7, 4)
    holidays.append(add("Independence Day", actual, observed_date=observed.isoformat() if observed != actual else None))

    # Labor Day — 1st Monday of September
    d = nth_weekday(year, 9, 0, 1)
    holidays.append(add("Labor Day", d, tradition='civic'))

    # Columbus Day — 2nd Monday of October
    d = nth_weekday(year, 10, 0, 2)
    holidays.append(add("Columbus Day", d, tradition='civic'))

    # Veterans Day — Nov 11
    actual = date(year, 11, 11)
    observed = observed_shift(year, 11, 11)
    holidays.append(add("Veterans Day", actual, observed_date=observed.isoformat() if observed != actual else None))

    # Thanksgiving — 4th Thursday of November
    d = nth_weekday(year, 11, 3, 4)
    holidays.append(add("Thanksgiving Day", d, tradition='civic'))

    # Christmas — Dec 25
    actual = date(year, 12, 25)
    observed = observed_shift(year, 12, 25)
    holidays.append(add("Christmas Day", actual, tradition='christian', observed_date=observed.isoformat() if observed != actual else None))

    return holidays


def generate_us_observances(year, us_country_id):
    """Generate US rule-based observances (Mother's Day, Father's Day, etc.)"""
    holidays = []

    def add(name_en, d, tradition='civic', category='observance', filters=None, event_domain='civil'):
        return {
            "concept_name": name_en,
            "concept_tradition": tradition,
            "concept_origin": 'computed_federal_us',
            "country_id": us_country_id,
            "subdivision_code": None,
            "start_date": d.isoformat(),
            "date_role": "actual",
            "legal_status": "observance",
            "scope_level": "country",
            "event_domain": event_domain,
            "prominence": "common",
            "date_status": "confirmed",
            "origin": 'computed_federal_us',
            "category": category,
            "filters": filters or ["OBS_COMMON"],
        }

    # Mother's Day — 2nd Sunday of May
    holidays.append(add("Mother's Day", nth_weekday(year, 5, 6, 2), category='observance'))

    # Father's Day — 3rd Sunday of June
    holidays.append(add("Father's Day", nth_weekday(year, 6, 6, 3), category='observance'))

    # Valentine's Day — Feb 14
    holidays.append(add("Valentine's Day", date(year, 2, 14), category='observance'))

    # Halloween — Oct 31
    holidays.append(add("Halloween", date(year, 10, 31), category='observance'))

    # Christmas Eve — Dec 24
    holidays.append(add("Christmas Eve", date(year, 12, 24), tradition='christian', category='observance'))

    # New Year's Eve — Dec 31
    holidays.append(add("New Year's Eve", date(year, 12, 31), category='observance'))

    return holidays


def generate_seasons(year, world_country_id=None):
    """Generate 4 seasons. country_id=NULL means worldwide.
    For MVP we use US as the canonical country (seasons are global anyway).
    """
    # Use a placeholder country_id for US; we'll mark worldwide=1
    holidays = []

    def add(name_en, d, tradition='astronomical', filters=None):
        return {
            "concept_name": name_en,
            "concept_tradition": tradition,
            "concept_origin": 'computed_season',
            "concept_worldwide": 1,
            "country_id": world_country_id,
            "subdivision_code": None,
            "start_date": d.isoformat(),
            "date_role": "actual",
            "legal_status": "observance",
            "scope_level": "global" if world_country_id is None else "country",
            "event_domain": "astronomical",
            "prominence": "common",
            "date_status": "calculated",
            "origin": 'computed_season',
            "category": "season",
            "worldwide": 1,
            "filters": filters or ["SEASON"],
        }

    holidays.append(add("March Equinox", spring_equinox(year)))
    holidays.append(add("June Solstice", summer_solstice(year)))
    holidays.append(add("September Equinox", autumn_equinox(year)))
    holidays.append(add("December Solstice", winter_solstice(year)))

    return holidays


def generate_dst_us(year, us_country_id):
    """US DST clock changes (per zoneinfo-derived from M11.6.1).
    Currently approximated for continental US.
    """
    transitions = dst_transitions_us(year)
    holidays = []

    def add(name_en, d, tradition='civic'):
        return {
            "concept_name": name_en,
            "concept_tradition": tradition,
            "concept_origin": 'computed_dst',
            "country_id": us_country_id,
            "subdivision_code": None,
            "start_date": d.isoformat(),
            "date_role": "actual",
            "legal_status": "observance",
            "scope_level": "country",
            "event_domain": "time_zone",
            "prominence": "common",
            "date_status": "calculated",
            "origin": 'computed_dst',
            "category": "clock_change",
            "filters": ["CLOCK_CHANGE"],
        }

    holidays.append(add("Daylight Saving Time starts", transitions["start"]))
    holidays.append(add("Daylight Saving Time ends", transitions["end"]))

    return holidays


def generate_us_easter_based(year, us_country_id):
    """Easter-related holidays for US."""
    easter = easter_sunday(year)
    holidays = []

    def add(name_en, d, tradition='christian', category='public_holiday', filters=None, scope_level='country'):
        return {
            "concept_name": name_en,
            "concept_tradition": tradition,
            "concept_origin": 'computed_easter',
            "country_id": us_country_id,
            "subdivision_code": None,
            "start_date": d.isoformat(),
            "date_role": "actual",
            "legal_status": "public" if category == 'public_holiday' else "observance",
            "scope_level": scope_level,
            "event_domain": "religious",
            "prominence": "major" if category == 'public_holiday' else "common",
            "date_status": "calculated",
            "origin": 'computed_easter',
            "category": category,
            "filters": filters or ["CHRISTIAN_MAJOR" if category == 'public_holiday' else "CHRISTIAN_MORE"],
        }

    # Good Friday — Easter - 2
    holidays.append(add("Good Friday", easter - timedelta(days=2), category='observance', filters=["CHRISTIAN_MAJOR", "OBS_IMPORTANT"]))
    # Holy Saturday
    holidays.append(add("Holy Saturday", easter - timedelta(days=1), category='observance', filters=["CHRISTIAN_MORE", "OBS_COMMON"]))
    # Easter Sunday
    holidays.append(add("Easter Sunday", easter, category='observance', filters=["CHRISTIAN_MAJOR", "OBS_IMPORTANT"]))
    # Easter Monday
    holidays.append(add("Easter Monday", easter + timedelta(days=1), category='observance', filters=["CHRISTIAN_MORE", "OBS_COMMON"]))
    # Ascension Day — Easter + 39
    holidays.append(add("Ascension Day", easter + timedelta(days=39), category='observance', filters=["CHRISTIAN_MORE", "OBS_COMMON"]))
    # Pentecost — Easter + 49
    holidays.append(add("Pentecost", easter + timedelta(days=49), category='observance', filters=["CHRISTIAN_MORE", "OBS_COMMON"]))
    # Ash Wednesday — Easter - 46
    holidays.append(add("Ash Wednesday", easter - timedelta(days=46), category='observance', filters=["CHRISTIAN_MORE", "OBS_COMMON"]))
    # Mardi Gras — Easter - 47
    holidays.append(add("Mardi Gras", easter - timedelta(days=47), category='observance', filters=["CHRISTIAN_MORE", "OBS_COMMON"]))

    return holidays


def generate_in_national(year, in_country_id):
    """India national gazetted holidays + important observances.
    Source: Nager.Date (cross-checked) + Indian national calendar.
    """
    holidays = []

    def add(name_en, d, tradition='civic', category='public_holiday', filters=None, scope_level='country', event_domain='civil', prominence='major'):
        return {
            "concept_name": name_en,
            "concept_tradition": tradition,
            "concept_origin": 'nager_date',
            "country_id": in_country_id,
            "subdivision_code": None,
            "start_date": d.isoformat(),
            "date_role": "actual",
            "legal_status": "public" if category == 'public_holiday' else "observance",
            "scope_level": scope_level,
            "event_domain": event_domain,
            "prominence": prominence,
            "date_status": "confirmed",
            "origin": 'nager_date',
            "category": category,
            "filters": filters or ["PUBLIC_NATIONAL"],
        }

    # Fixed national holidays
    holidays.append(add("Republic Day", date(year, 1, 26), tradition='civic'))
    holidays.append(add("Independence Day", date(year, 8, 15), tradition='civic'))
    holidays.append(add("Gandhi Jayanti", date(year, 10, 2), tradition='civic'))
    holidays.append(add("Mahatma Gandhi Jayanti", date(year, 10, 2), tradition='civic'))  # alias
    holidays.append(add("Christmas Day", date(year, 12, 25), tradition='christian', event_domain='religious'))
    holidays.append(add("Good Friday", easter_sunday(year) - timedelta(days=2), tradition='christian', event_domain='religious', filters=["CHRISTIAN_MAJOR", "PUBLIC_NATIONAL"]))
    holidays.append(add("Buddha Purnima", date(year, 5, 31), tradition='buddhist', event_domain='religious', filters=["BUDDHIST", "PUBLIC_NATIONAL"]))
    holidays.append(add("Mahavir Jayanti", date(year, 4, 1), tradition='jain', event_domain='religious', filters=["OTHER_RELIGION", "PUBLIC_NATIONAL"]))
    holidays.append(add("Guru Nanak Jayanti", date(year, 11, 24), tradition='sikh', event_domain='religious', filters=["OTHER_RELIGION", "PUBLIC_NATIONAL"]))

    return holidays


def generate_nl_easter_based(year, nl_country_id):
    """Netherlands Easter-related holidays."""
    easter = easter_sunday(year)
    holidays = []

    def add(name_en, d, tradition='christian', category='public_holiday', filters=None):
        return {
            "concept_name": name_en,
            "concept_tradition": tradition,
            "concept_origin": 'computed_easter',
            "country_id": nl_country_id,
            "subdivision_code": None,
            "start_date": d.isoformat(),
            "date_role": "actual",
            "legal_status": "public" if category == 'public_holiday' else "observance",
            "scope_level": "country",
            "event_domain": "religious",
            "prominence": "major" if category == 'public_holiday' else "common",
            "date_status": "calculated",
            "origin": 'computed_easter',
            "category": category,
            "filters": filters or ["CHRISTIAN_MAJOR" if category == 'public_holiday' else "CHRISTIAN_MORE"],
        }

    # NL has Good Friday and Easter Monday as public holidays
    holidays.append(add("Good Friday", easter - timedelta(days=2), filters=["CHRISTIAN_MAJOR", "PUBLIC_NATIONAL"]))
    holidays.append(add("Easter Sunday", easter, category='observance', filters=["CHRISTIAN_MAJOR", "OBS_IMPORTANT"]))
    holidays.append(add("Easter Monday", easter + timedelta(days=1), filters=["CHRISTIAN_MAJOR", "PUBLIC_NATIONAL"]))
    holidays.append(add("Ascension Day", easter + timedelta(days=39), filters=["CHRISTIAN_MAJOR", "PUBLIC_NATIONAL"]))
    holidays.append(add("Whit Sunday", easter + timedelta(days=49), category='observance', filters=["CHRISTIAN_MORE", "OBS_COMMON"]))
    holidays.append(add("Whit Monday", easter + timedelta(days=50), filters=["CHRISTIAN_MAJOR", "PUBLIC_NATIONAL"]))

    return holidays


def generate_gb_bank_holidays(year, gb_country_id):
    """UK Bank Holidays. Per Banking and Financial Dealings Act 1971, modified by Royal Proclamation.
    England&Wales, Scotland, Northern Ireland have separate calendars.
    We use the main England&Wales calendar as default.
    """
    holidays = []

    def add(name_en, d, tradition='civic', category='public_holiday', filters=None, scope_level='country', event_domain='civil', subdivision=None, observed_date=None):
        return {
            "concept_name": name_en,
            "concept_tradition": tradition,
            "concept_origin": 'computed_gb',
            "country_id": gb_country_id,
            "subdivision_code": subdivision,
            "start_date": d.isoformat(),
            "observed_date": observed_date,
            "date_role": "actual",
            "legal_status": "public",
            "scope_level": scope_level,
            "event_domain": event_domain,
            "prominence": "major",
            "date_status": "calculated",
            "origin": 'computed_gb',
            "category": category,
            "filters": filters or ["PUBLIC_NATIONAL", "BANK_CLOSURE"],
        }

    # New Year's Day — Jan 1 (or substitute Monday)
    actual = date(year, 1, 1)
    observed = observed_shift(year, 1, 1)
    obs_str = observed.isoformat() if observed != actual else None
    holidays.append(add("New Year's Day", actual, observed_date=obs_str))

    # Good Friday — Easter - 2
    easter = easter_sunday(year)
    holidays.append(add("Good Friday", easter - timedelta(days=2), tradition='christian', event_domain='religious',
                       filters=["CHRISTIAN_MAJOR", "PUBLIC_NATIONAL", "BANK_CLOSURE"]))

    # Easter Monday — Easter + 1
    holidays.append(add("Easter Monday", easter + timedelta(days=1), tradition='christian', event_domain='religious',
                       filters=["CHRISTIAN_MAJOR", "PUBLIC_NATIONAL", "BANK_CLOSURE"]))

    # Early May Bank Holiday — 1st Monday of May
    holidays.append(add("Early May Bank Holiday", nth_weekday(year, 5, 0, 1)))

    # Spring Bank Holiday — last Monday of May
    holidays.append(add("Spring Bank Holiday", last_weekday(year, 5, 0)))

    # Summer Bank Holiday — last Monday of August
    holidays.append(add("Summer Bank Holiday", last_weekday(year, 8, 0)))

    # Christmas Day — Dec 25
    actual = date(year, 12, 25)
    observed = observed_shift(year, 12, 25)
    obs_str = observed.isoformat() if observed != actual else None
    holidays.append(add("Christmas Day", actual, tradition='christian', event_domain='religious',
                       observed_date=obs_str))

    # Boxing Day — Dec 26
    actual = date(year, 12, 26)
    observed = observed_shift(year, 12, 26)
    obs_str = observed.isoformat() if observed != actual else None
    holidays.append(add("Boxing Day", actual, tradition='civic', observed_date=obs_str))

    return holidays
