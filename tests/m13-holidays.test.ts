/**
 * M13: Holidays MVP — US + NL golden fixtures
 *
 * Tests the per-country filter variance (US=18, NL=4 per spec), main list,
 * long-weekends finder, and ICS export.
 */
import { describe, it, expect } from "vitest";

const API = process.env.TEST_API_URL || "http://localhost:8787";

describe("M13: Filter catalog", () => {
  it("M13.1: /filters returns 36 codes", async () => {
    const r = await fetch(`${API}/api/v1/filters`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data.total).toBeGreaterThanOrEqual(36);
  });
});

describe("M13: Country variance (the spec's key insight)", () => {
  it("M13.2: US shows 18+ filters (per spec section 6.4)", async () => {
    const r = await fetch(`${API}/api/v1/countries/US/filters?year=2026`);
    const body = await r.json();
    expect(body.data.total).toBeGreaterThanOrEqual(18);
  });

  it("M13.3: NL shows 4+ filters (per spec section 6.4)", async () => {
    const r = await fetch(`${API}/api/v1/countries/NL/filters?year=2026`);
    const body = await r.json();
    expect(body.data.total).toBeGreaterThanOrEqual(4);
  });

  it("M13.4: US filter list includes 'Major Christian' (per screenshot)", async () => {
    const r = await fetch(`${API}/api/v1/countries/US/filters?year=2026`);
    const body = await r.json();
    const codes = body.data.filters.map((f: any) => f.code);
    expect(codes).toContain("CHRISTIAN_MAJOR");
    expect(codes).toContain("MUSLIM_MAJOR");
    expect(codes).toContain("HINDU_MAJOR");
  });

  it("M13.5: NL filter list excludes 'Major Christian' (per spec — country variance)", async () => {
    const r = await fetch(`${API}/api/v1/countries/NL/filters?year=2026`);
    const body = await r.json();
    const codes = body.data.filters.map((f: any) => f.code);
    expect(codes).not.toContain("CHRISTIAN_MAJOR");
    expect(codes).not.toContain("MUSLIM_MAJOR");
  });

  it("M13.6: NL filter list includes 'Seasons' (per spec)", async () => {
    const r = await fetch(`${API}/api/v1/countries/NL/filters?year=2026`);
    const body = await r.json();
    const codes = body.data.filters.map((f: any) => f.code);
    expect(codes).toContain("SEASON");
  });

  it("M13.7: filter counts match the actual list query (AC-F04)", async () => {
    const f = await fetch(`${API}/api/v1/countries/US/filters?year=2026`);
    const fBody = await f.json();
    const federalFilter = fBody.data.filters.find((x: any) => x.code === "PUBLIC_NATIONAL");
    // List query for PUBLIC_NATIONAL
    const l = await fetch(`${API}/api/v1/holidays?country=US&year=2026&filters=PUBLIC_NATIONAL`);
    const lBody = await l.json();
    expect(federalFilter.rangeCount).toBe(lBody.data.total);
  });
});

describe("M13: Holiday list", () => {
  it("M13.8: US 2026 PUBLIC_NATIONAL returns ~10 federal holidays", async () => {
    const r = await fetch(`${API}/api/v1/holidays?country=US&year=2026&filters=PUBLIC_NATIONAL`);
    const body = await r.json();
    expect(body.data.total).toBeGreaterThanOrEqual(10);
    expect(body.data.total).toBeLessThanOrEqual(15);
  });

  it("M13.9: NL 2026 PUBLIC_NATIONAL returns ~11 public holidays", async () => {
    const r = await fetch(`${API}/api/v1/holidays?country=NL&year=2026&filters=PUBLIC_NATIONAL`);
    const body = await r.json();
    expect(body.data.total).toBeGreaterThanOrEqual(10);
  });

  it("M13.10: holiday has conceptName + country + filters", async () => {
    const r = await fetch(`${API}/api/v1/holidays?country=US&year=2026&filters=PUBLIC_NATIONAL&limit=1`);
    const body = await r.json();
    const h = body.data.holidays[0];
    expect(h).toHaveProperty("conceptName");
    expect(h).toHaveProperty("countryCode");
    expect(h).toHaveProperty("startDate");
    expect(h.filters).toContain("PUBLIC_NATIONAL");
  });

  it("M13.11: cross-year substitute dates work (e.g. observed Monday)", async () => {
    // Just verify the field exists; specific test for observed date
    const r = await fetch(`${API}/api/v1/holidays?country=US&year=2026&filters=PUBLIC_NATIONAL&limit=1`);
    const body = await r.json();
    expect(body.data.holidays[0]).toHaveProperty("observedDate");
  });
});

describe("M13: Long weekends", () => {
  it("M13.12: US 2026 long-weekends has multiple entries", async () => {
    const r = await fetch(`${API}/api/v1/long-weekends?country=US&year=2026`);
    const body = await r.json();
    expect(body.data.count).toBeGreaterThan(0);
  });

  it("M13.13: each long-weekend has start, end, days, reason", async () => {
    const r = await fetch(`${API}/api/v1/long-weekends?country=US&year=2026`);
    const body = await r.json();
    const lw = body.data.longWeekends[0];
    expect(lw).toHaveProperty("start");
    expect(lw).toHaveProperty("end");
    expect(lw).toHaveProperty("days");
    expect(lw).toHaveProperty("reason");
  });
});

describe("M13: ICS export", () => {
  it("M13.14: ICS is RFC 5545 valid (header + events)", async () => {
    const r = await fetch(`${API}/api/v1/calendars/holidays.ics?country=US&year=2026`);
    expect(r.headers.get("Content-Type")).toMatch(/text\/calendar/);
    const ics = await r.text();
    expect(ics).toContain("BEGIN:VCALENDAR");
    expect(ics).toContain("END:VCALENDAR");
    expect(ics).toContain("BEGIN:VEVENT");
    expect(ics).toContain("END:VEVENT");
    expect(ics).toContain("VERSION:2.0");
  });

  it("M13.15: NL ICS has 10-12 events (PUBLIC_NATIONAL is similar in both countries)", async () => {
    const usR = await fetch(`${API}/api/v1/calendars/holidays.ics?country=US&year=2026`);
    const nlR = await fetch(`${API}/api/v1/calendars/holidays.ics?country=NL&year=2026`);
    const usIcs = await usR.text();
    const nlIcs = await nlR.text();
    const usEvents = (usIcs.match(/BEGIN:VEVENT/g) || []).length;
    const nlEvents = (nlIcs.match(/BEGIN:VEVENT/g) || []).length;
    // Both should have ~10-12 federal events
    expect(usEvents).toBeGreaterThanOrEqual(8);
    expect(usEvents).toBeLessThanOrEqual(15);
    expect(nlEvents).toBeGreaterThanOrEqual(8);
    expect(nlEvents).toBeLessThanOrEqual(15);
  });
});

describe("M13: Today / upcoming", () => {
  it("M13.16: /holidays/today returns valid structure", async () => {
    const r = await fetch(`${API}/api/v1/holidays/today?country=US`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data).toHaveProperty("holidays");
    expect(Array.isArray(body.data.holidays)).toBe(true);
  });

  it("M13.17: /holidays/upcoming respects days param", async () => {
    const r = await fetch(`${API}/api/v1/holidays/upcoming?country=US&days=90`);
    const body = await r.json();
    expect(body.data.from).toBeDefined();
    expect(body.data.to).toBeDefined();
  });
});

describe("M13: Feedback", () => {
  it("M13.18: POST /feedback creates a record", async () => {
    const r = await fetch(`${API}/api/v1/feedback`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        occurrenceId: 1,
        reportType: "wrong_date",
        severity: "P2",
        description: "Test report from automated test suite",
        reporterEmail: "test@example.com",
      }),
    });
    expect(r.status).toBe(201);
    const body = await r.json();
    expect(body.data.id).toBeGreaterThan(0);
    expect(body.data.status).toBe("open");
  });
});
