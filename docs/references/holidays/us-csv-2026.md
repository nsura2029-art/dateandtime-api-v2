# US 2026 Holidays — Authoritative List

**Source:** User-provided CSV (`/workspace/attachments/e3285d38__a55b27aa-b719-4250-88c3-da2e11b5ccfc.csv`)
**Original upstream:** timeanddate.com (per spec, no scraping — this is the user's snapshot)
**Tier:** F (community-aggregated)
**Captured:** 2026-08-03
**Format:** CSV

## Coverage Summary

| Category | Count |
|----------|------:|
| United Nations Observance | 178 |
| State Holiday | 85 |
| Observance | 85 |
| State Observance | 53 |
| Worldwide Observance | 46 |
| Christian | 23 |
| Jewish holiday | 18 |
| Local Observance | 16 |
| Federal Holiday | 12 |
| State Legal Holiday | 12 |
| Annual Monthly Observance | 10 |
| Muslim | 8 |
| Hindu Holiday | 8 |
| Sporting Event | 8 |
| Orthodox | 6 |
| Season | 4 |
| Clock Change/Daylight Saving Time | 2 |
| Local Holiday | 1 |
| Jewish commemoration | 1 |
| **TOTAL** | **571** |

## Federal Holidays (12 entries — actual + observed)

| Date | Day | Name |
|------|-----|------|
| Jan 1 | Thursday | New Year's Day |
| Jan 19 | Monday | Martin Luther King Jr. Day |
| Feb 16 | Monday | Presidents' Day |
| May 25 | Monday | Memorial Day |
| Jun 19 | Friday | Juneteenth |
| Jul 3 | Friday | Independence Day (substitute for Sat Jul 4) |
| Jul 4 | Saturday | Independence Day |
| Sep 7 | Monday | Labor Day |
| Oct 12 | Monday | Columbus Day |
| Nov 11 | Wednesday | Veterans Day |
| Nov 26 | Thursday | Thanksgiving Day |
| Dec 25 | Friday | Christmas Day |

## Seasons (4)

| Date | Day | Name |
|------|-----|------|
| Mar 20 | Friday | March Equinox |
| Jun 21 | Sunday | June Solstice |
| Sep 22 | Tuesday | September Equinox |
| Dec 21 | Monday | December Solstice |

## Clock Changes (2)

| Date | Day | Name |
|------|-----|------|
| Mar 8 | Sunday | Daylight Saving Time starts |
| Nov 1 | Sunday | Daylight Saving Time ends |

## Key State-Specific Holidays

| Date | State(s) | Holiday |
|------|----------|---------|
| Feb 12 | CA, CT, IL, IN, KY, MI, MO, NY | Lincoln's Birthday |
| Apr 3 | CT, DE, HI, IN, KY, LA, NC, ND, NJ, TN, TX | Good Friday |
| May 8 | MO | Truman Day |
| Jun 1 | AL | Jefferson Davis' Birthday |
| Jun 11 | HI | Kamehameha Day |
| Jun 16 | MS (Jefferson Davis) | Jefferson Davis' Birthday |
| Jun 19 | TX | Emancipation Day |
| Jul 24 | UT | Pioneer Day |
| Aug 10 | RI | Victory Day |
| Aug 16 | AZ | National Navajo Code Talkers Day |
| Aug 21 | HI | Hawaii Statehood Day |
| Aug 27 | TX | Lyndon Baines Johnson Day |
| Oct 5 | CO | Frances Xavier Cabrini Day |
| Oct 18 | AK | Alaska Day |
| Oct 19 | AK | Alaska Day observed |
| Oct 30 | NV | Nevada Day |
| Nov 27 | GA, IN, MD, NM, WA + 22 other states | Day After Thanksgiving |
| Dec 24 | AR, KS, KY, MI, NC, ND, OK, SC, TX, VA, WI | Christmas Eve |
| Dec 31 | MI, WI | New Year's Eve |
| Mar 26 | HI | Prince Jonah Kuhio Kalanianaole Day |
| Mar 31 | CA, CO, NM, TX, AZ | César Chávez Day |
| Sep 25 | CA, NV | Native American Day |
| Nov 8 | CA, PA | Diwali/Deepavali (State Legal Holiday) |
| Sep 12 | TX | Rosh Hashana (State Holiday) |
| Sep 21 | TX | Yom Kippur (State Holiday) |

## What we had vs. what we have now (after M14 enrichment)

| | Pre-M14 (Nager.Date) | Post-M14 (computed + Hebcal + UN) |
|---|---:|---:|
| Federal holidays | 11 | 11 ✓ + 1 observed (Jul 3) = 12 |
| US state holidays | ~12 | 40+ (Lincoln × 8, Good Friday × 12, etc.) |
| Columbus Day/Indigenous | 53 | 53 ✓ (with both names per state) |
| Seasons | 0 | 4 |
| DST changes | 0 | 2 |
| Jewish holidays (US) | 0 | 18 (Hebcal) |
| Christian holidays (US) | 1 (Christmas) | 8 (Christmas, Easter Sun, Good Fri, etc.) |
| UN observances (US) | 0 | ~178 (one per UN day, US-default) |
| Worldwide observances (US) | 0 | ~46 (Valentine's, Mother's Day, etc.) |
| Hindu holidays (US) | 0 | 8 (Diwali × 3 statuses, etc.) |
| Muslim holidays (US) | 0 | 8 (Eid, Ramadan, etc.) |
| Sporting events (US) | 0 | 8 (Kentucky Derby, etc.) |
| **Total US 2026** | **84** | **400-500** |

## Cross-Reference with Nager.Date

Nager.Date for US 2026:
- ✓ Federal holidays: 11
- ✓ Lincoln's Birthday × 8 states
- ✓ Good Friday × 12 states
- ✓ Truman Day, César Chávez, Columbus Day variants, etc.
- ❌ No observances
- ❌ No seasons
- ❌ No Christian (other than Christmas)
- ❌ No Jewish
- ❌ No UN days
- ❌ No Hindu
- ❌ No Muslim
- ❌ No sporting events
- ❌ No DST

**Nager.Date has only the "public" subset. M14 enrichment adds the rest.**
