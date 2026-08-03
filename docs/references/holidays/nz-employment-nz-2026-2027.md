# NZ Employment New Zealand — 2026 + 2027 Holiday Data

**Source:** https://www.employment.govt.nz/leave-and-holidays/public-holidays/public-holidays-and-anniversary-dates
**Tier:** A (controlling truth per spec section 11)
**Captured:** 2026-08-03
**Format:** HTML tables

## 2026 Public Holidays (National)

| Holiday | Actual | Observed |
|---------|--------|----------|
| New Year's Day | 1 January | Thursday 1 January |
| Day after New Year's Day | 2 January | Friday 2 January |
| Waitangi Day | 6 February | Friday 6 February |
| Good Friday | Varies (3 April 2026) | Friday 3 April |
| Easter Monday | Varies (6 April 2026) | Monday 6 April |
| Anzac Day | 25 April | Monday 27 April |
| King's Birthday | 1st Monday in June | Monday 1 June |
| Matariki | Varies (10 July 2026) | Friday 10 July |
| Labour Day | 4th Monday in October | Monday 26 October |
| Christmas Day | 25 December | Friday 25 December |
| Boxing Day | 26 December | Monday 28 December |

## 2026 Regional Anniversary Days

| Province | Actual | Observed |
|----------|--------|----------|
| Auckland | 29 January | Monday 26 January |
| Taranaki | 31 March | Monday 9 March |
| Hawke's Bay | 1 November | Friday 23 October |
| Wellington | 22 January | Monday 19 January |
| Marlborough | 1 November | Monday 2 November |
| Nelson | 1 February | Monday 2 February |
| Canterbury | 16 December | Friday 13 November |
| Canterbury (South) | 16 December | Monday 28 September |
| Westland | 1 December | Monday 30 November |
| Otago | 23 March | Monday 23 March |
| Southland | 17 January | Tuesday 7 April |
| Chatham Islands | 30 November | Monday 30 November |

## 2027 Public Holidays (National)

| Holiday | Actual | Observed |
|---------|--------|----------|
| New Year's Day | 1 January | Friday 1 January |
| Day after New Year's Day | 2 January | Monday 4 January |
| Waitangi Day | 6 February | Monday 8 February |
| Good Friday | 26 March | Friday 26 March |
| Easter Monday | 29 March | Monday 29 March |
| ANZAC Day | 25 April | Monday 26 April |
| King's Birthday | 1st Monday in June | Monday 7 June |
| Matariki | Varies (25 June 2027) | Friday 25 June |
| Labour Day | 4th Monday in October | Monday 25 October |
| Christmas Day | 25 December | Monday 27 December |
| Boxing Day | 26 December | Tuesday 28 December |

## 2027 Regional Anniversary Days

| Province | Actual | Observed |
|----------|--------|----------|
| Auckland | 29 January | Monday 1 February |
| Taranaki | 31 March | Monday 8 March |
| Hawke's Bay | 1 November | Friday 22 October |
| Wellington | 22 January | Monday 25 January |
| Marlborough | 1 November | Monday 1 November |
| Nelson | 1 February | Monday 1 February |
| Canterbury | 16 December | Friday 12 November |
| Canterbury (South) | 16 December | Monday 27 September |
| Westland | 1 December | Monday 29 November |
| Otago | 23 March | Monday 22 March |
| Southland | 17 January | Tuesday 30 March |
| Chatham Islands | 30 November | Monday 29 November |

## Notes

- This data is **superior to the user's CSV** which only had observed Mondays
- ANZAC Day 2026: actual is Saturday Apr 25, observed Monday Apr 27 — both should be loaded
- Boxing Day 2026: actual is Saturday Dec 26, observed Monday Dec 28 — both should be loaded
- ANZAC Day 2027: actual is Sunday Apr 25, observed Monday Apr 26 — both should be loaded
- Boxing Day 2027: actual is Sunday Dec 26, observed Tuesday Dec 28 — both should be loaded
- 12 regional anniversaries for each year, with rule-based actual dates

## Comparison with Nager.Date

Nager.Date has 23 NZ 2026 entries:
- 12 national public holidays ✓
- 11 of 12 regional anniversaries (missing Northland — combined with Auckland)
- **Missing** the "actual" date for ANZAC Day and Boxing Day (only has observed)
