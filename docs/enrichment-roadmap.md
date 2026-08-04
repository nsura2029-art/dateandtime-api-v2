## Enrichment Plan (Saved for Later)

For the 2026-08-04 cleanup, we removed these sources to use Calendarific only:
- nager_date (subset of Calendarific, redundant)
- un_official (UN days — most covered by Calendarific)
- hebcal (Jewish holidays — subset of Calendarific Hebrew type)
- computed_federal_us (derived from rules, Calendarific has them)

Enrichment roadmap (for when we add sources back):
1. **Tier A government sources** for major countries:
   - gov_in (Government of India 2026 gazette list)
   - gov_uk (gov.uk bank holidays)
   - opm_gov (US Office of Personnel Management)
   - service_public_fr (France jours fériés)
   - bundesregierung_de (German federal holidays)
2. **Hebcal** (Jewish calendar) — for more Jewish holiday depth
3. **UN days** (UN observances from un.org)
4. **State-level sources**:
   - 58K US school district calendars (NCES)
   - Indian state government calendars
   - Canadian provincial calendars (13 provinces/territories)

These would be Tier A additions (highest authority) that would override or supplement
Calendarific's Tier D data. The filter assignment logic stays the same — we just
add more sources per holiday occurrence.
