/**
 * M14: Holiday Enrichment — Tier 1 (Computed) + Tier 2 (Hebcal + UN)
 *
 * Tests the enrichment engine outputs:
 * - Tier 1: Computed rules (US federal, Easter, seasons, DST, GB bank holidays, IN national)
 * - Tier 2: Hebcal Jewish holidays + UN international days
 * - Worldwide + per-country state handling
 * - New schema fields: worldwide, category, origin, scope_level
 */
import { describe, it, expect } from "vitest";

const API = process.env.TEST_API_URL || "https://dt-api-v2-dev.nsura2029.workers.dev";

describe("M14: Enrichment engine — US (Tier 1 computed)", () => {
  it("M14.1: US has 11 federal holidays (computed from 5 U.S.C. § 6103)", async () => {
    const r = await fetch(`${API}/api/v1/holidays?country=US&year=2026&filters=PUBLIC_NATIONAL&limit=100`);
    expect(r.status).toBe(200);
    const body = await r.json();
    // Should have 11 federal + 1 observed (Jul 3) + 1 unobserved (Columbus Indigenous split) etc.
    // Federal-specific (subdivision_code=NULL): 11
    const fed = body.data.holidays.filter((h: any) =>
      h.subdivisionCode === null && h.filters.includes("PUBLIC_NATIONAL")
    );
    expect(fed.length).toBeGreaterThanOrEqual(11);
  });

  it("M14.2: US has 2 DST changes (computed)", async () => {
    const r = await fetch(`${API}/api/v1/holidays?country=US&year=2026&filters=CLOCK_CHANGE`);
    const body = await r.json();
    expect(body.data.total).toBe(2);
    expect(body.data.holidays[0].category).toBe("clock_change");
  });

  it("M14.3: US has 4 seasons (computed worldwide)", async () => {
    const r = await fetch(`${API}/api/v1/holidays?mode=international&year=2026&filters=SEASON`);
    const body = await r.json();
    expect(body.data.total).toBeGreaterThanOrEqual(4);
  });

  it("M14.4: US Independence Day has both actual (Jul 4) and observed (Jul 3) for 2026", async () => {
    const r = await fetch(`${API}/api/v1/holidays?country=US&year=2026&filters=PUBLIC_NATIONAL&limit=100`);
    const body = await r.json();
    const jul4 = body.data.holidays.filter((h: any) => h.conceptName === "Independence Day" && h.subdivisionCode === null);
    expect(jul4.length).toBeGreaterThanOrEqual(1);
    // The actual date should be 2026-07-04
    const actual = jul4.find((h: any) => h.startDate === "2026-07-04");
    expect(actual).toBeDefined();
    // The observed date should be 2026-07-03 (since Jul 4 is Saturday)
    expect(actual.observedDate).toBe("2026-07-03");
  });
});

describe("M14: Enrichment engine — Easter (computed for US, NL, IN)", () => {
  it("M14.5: US has Good Friday, Easter Sunday, Easter Monday (computed_easter origin)", async () => {
    const r = await fetch(`${API}/api/v1/holidays?country=US&year=2026&filters=CHRISTIAN_MAJOR,CHRISTIAN_MORE&limit=100`);
    const body = await r.json();
    const names = body.data.holidays.map((h: any) => h.conceptName);
    expect(names).toContain("Good Friday");
    expect(names).toContain("Easter Sunday");
    expect(names).toContain("Easter Monday");
  });

  it("M14.6: NL has Easter Monday as a public holiday", async () => {
    const r = await fetch(`${API}/api/v1/holidays?country=NL&year=2026&limit=500`);
    const body = await r.json();
    const em = body.data.holidays.find((h: any) => h.conceptName === "Easter Monday");
    expect(em).toBeDefined();
    expect(em.startDate).toBe("2026-04-06");
    expect(em.filters).toContain("PUBLIC_NATIONAL");
  });
});

describe("M14: Hebcal (Jewish holidays) — Tier 2", () => {
  it("M14.7: US has Jewish holidays (Hebcal origin)", async () => {
    const r = await fetch(`${API}/api/v1/holidays?country=US&year=2026&filters=JEWISH_MAJOR&limit=50`);
    const body = await r.json();
    expect(body.data.total).toBeGreaterThan(0);
    // Yom Kippur is a major Jewish holiday
    const yk = body.data.holidays.find((h: any) => h.conceptName === "Yom Kippur");
    expect(yk).toBeDefined();
    expect(yk.filters).toContain("JEWISH_MAJOR");
  });

  it("M14.8: GB has Jewish holidays too", async () => {
    const r = await fetch(`${API}/api/v1/holidays?country=GB&year=2026&filters=JEWISH_MAJOR&limit=50`);
    const body = await r.json();
    expect(body.data.total).toBeGreaterThan(0);
  });
});

describe("M14: UN international days — Tier 2", () => {
  it("M14.9: Worldwide mode returns 100+ UN days (loaded from holiday_un_day table)", async () => {
    const r = await fetch(`${API}/api/v1/holidays?mode=international&year=2026&limit=500`);
    const body = await r.json();
    expect(body.data.total).toBeGreaterThanOrEqual(200);
  });

  it("M14.10: All worldwide events have worldwide=true and scope=global", async () => {
    const r = await fetch(`${API}/api/v1/holidays?mode=international&year=2026&limit=20`);
    const body = await r.json();
    for (const h of body.data.holidays) {
      expect(h.worldwide).toBe(true);
      expect(h.scopeLevel).toBe("global");
      expect(h.origin).toBe("un_official");
    }
  });

  it("M14.11: US has 200+ UN observance entries (one per UN day)", async () => {
    const r = await fetch(`${API}/api/v1/holidays?country=US&year=2026&filters=UN_OBSERVANCE&limit=500`);
    const body = await r.json();
    expect(body.data.total).toBeGreaterThanOrEqual(200);
  });

  it("M14.12: International Women's Day is present worldwide", async () => {
    const r = await fetch(`${API}/api/v1/holidays?mode=international&year=2026&limit=500`);
    const body = await r.json();
    const iwd = body.data.holidays.find((h: any) => h.conceptName === "International Women's Day");
    expect(iwd).toBeDefined();
    expect(iwd.startDate).toBe("2026-03-08");
    expect(iwd.filters).toContain("UN_OBSERVANCE");
  });
});

describe("M14: India (newly added in enrichment)", () => {
  it("M14.13: India has its national holidays (Republic Day, Independence Day, Gandhi Jayanti)", async () => {
    const r = await fetch(`${API}/api/v1/holidays?country=IN&year=2026&limit=500`);
    const body = await r.json();
    const names = body.data.holidays.map((h: any) => h.conceptName);
    expect(names).toContain("Republic Day");
    expect(names).toContain("Independence Day");
    expect(names).toContain("Gandhi Jayanti");
  });

  it("M14.14: India has Jewish holidays (Hebcal) for the Jewish community", async () => {
    const r = await fetch(`${API}/api/v1/holidays?country=IN&year=2026&limit=500`);
    const body = await r.json();
    const jewish = body.data.holidays.filter((h: any) => h.origin === "hebcal");
    expect(jewish.length).toBeGreaterThan(10);
  });

  it("M14.15: India has Buddha Purnima and Mahavir Jayanti (religious diversity)", async () => {
    const r = await fetch(`${API}/api/v1/holidays?country=IN&year=2026&limit=500`);
    const body = await r.json();
    const names = body.data.holidays.map((h: any) => h.conceptName);
    expect(names).toContain("Buddha Purnima");
    expect(names).toContain("Mahavir Jayanti");
  });
});

describe("M14: GB (UK) bank holidays (computed_gb)", () => {
  it("M14.16: GB has 8 bank holidays including Easter Monday and Christmas", async () => {
    const r = await fetch(`${API}/api/v1/holidays?country=GB&year=2026&filters=PUBLIC_NATIONAL&limit=100`);
    const body = await r.json();
    const names = body.data.holidays.map((h: any) => h.conceptName);
    expect(names).toContain("New Year's Day");
    expect(names).toContain("Good Friday");
    expect(names).toContain("Easter Monday");
    expect(names).toContain("Early May Bank Holiday");
    expect(names).toContain("Spring Bank Holiday");
    expect(names).toContain("Summer Bank Holiday");
    expect(names).toContain("Christmas Day");
    expect(names).toContain("Boxing Day");
  });

  it("M14.17: GB bank holidays origin is computed_gb", async () => {
    const r = await fetch(`${API}/api/v1/holidays?country=GB&year=2026&filters=PUBLIC_NATIONAL&limit=100`);
    const body = await r.json();
    for (const h of body.data.holidays) {
      expect(h.origin).toBe("computed_gb");
    }
  });
});

describe("M14: New schema fields in response", () => {
  it("M14.18: Each holiday has new fields: worldwide, scopeLevel, category, origin, conceptTradition", async () => {
    const r = await fetch(`${API}/api/v1/holidays?country=US&year=2026&limit=20`);
    const body = await r.json();
    for (const h of body.data.holidays) {
      expect(h).toHaveProperty("worldwide");
      expect(h).toHaveProperty("scopeLevel");
      expect(h).toHaveProperty("category");
      expect(h).toHaveProperty("origin");
      expect(h).toHaveProperty("conceptTradition");
      expect(typeof h.worldwide).toBe("boolean");
    }
  });
});

describe("M14: Variance endpoint (updated counts)", () => {
  it("M14.19: US has 18+ filters (was 18 in M13, now with enrichment has more)", async () => {
    const r = await fetch(`${API}/api/v1/countries/US/filters?year=2026`);
    const body = await r.json();
    expect(body.data.total).toBeGreaterThanOrEqual(18);
  });

  it("M14.20: NL has 4+ filters", async () => {
    const r = await fetch(`${API}/api/v1/countries/NL/filters?year=2026`);
    const body = await r.json();
    expect(body.data.total).toBeGreaterThanOrEqual(4);
  });

  it("M14.21: SEASON filter has non-zero annual count for US (via worldwide inclusion)", async () => {
    const r = await fetch(`${API}/api/v1/countries/US/filters?year=2026`);
    const body = await r.json();
    const season = body.data.filters.find((f: any) => f.code === "SEASON");
    expect(season).toBeDefined();
    expect(season.annualCount).toBeGreaterThan(0);
  });
});
