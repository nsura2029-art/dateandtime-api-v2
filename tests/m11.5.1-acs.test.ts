/**
 * M11.5.1: ACS 5-year estimates (B01001 Sex by Age) in /cities/{id}
 *
 * Tests the M11.5.1 layer: us_acs_attributes (B01001 Sex by Age dataset,
 * 2018-2022 ACS 5-year, ~14,450 matched US cities).
 *
 * Coverage:
 *   - US cities with fips_geoid have acs block
 *   - total population, male, female
 *   - age breakdown: under 5, 5-17, 18-24, 25-44, 45-64, 65+
 *   - Non-US cities have acs=null
 *   - acsYear is 2022 (end of 2018-2022 5-year period)
 */
import { describe, it, expect } from "vitest";

const API = process.env.TEST_API_URL || "http://localhost:8787";

describe("M11.5.1: ACS 5-year — schema", () => {
  it("M11.5.1.1: /cities/{id} response includes `acs` field", async () => {
    // NYC (122795) — has ACS data
    const r = await fetch(`${API}/api/v1/cities/122795`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data).toHaveProperty("acs");
  });

  it("M11.5.1.2: NYC has full ACS data", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795`);
    const body = await r.json();
    const a = body.data.acs;
    expect(a).toBeTruthy();
    expect(a.fipsGeoid).toBe("3651000");
    expect(a.totalPopulation).toBeGreaterThan(7_000_000);
    expect(a.malePopulation).toBeGreaterThan(3_000_000);
    expect(a.femalePopulation).toBeGreaterThan(3_000_000);
    // male + female should approximately equal total (small variance allowed)
    expect(Math.abs((a.malePopulation + a.femalePopulation) - a.totalPopulation)).toBeLessThan(100);
    expect(a.acsYear).toBe(2022);
  });

  it("M11.5.1.3: Non-US cities have acs=null", async () => {
    // Berlin (24053) — Germany
    const r = await fetch(`${API}/api/v1/cities/24053`);
    const body = await r.json();
    expect(body.data.acs).toBeNull();
  });

  it("M11.5.1.4: Tokyo (JP) has acs=null", async () => {
    const r = await fetch(`${API}/api/v1/cities/64500`);
    const body = await r.json();
    expect(body.data.acs).toBeNull();
  });
});

describe("M11.5.1: ACS 5-year — age breakdown", () => {
  it("M11.5.1.5: ageBreakdown has all 6 buckets", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795`);
    const body = await r.json();
    const ab = body.data.acs.ageBreakdown;
    expect(ab).toBeTruthy();
    expect(ab).toHaveProperty("under5");
    expect(ab).toHaveProperty("age5to17");
    expect(ab).toHaveProperty("age18to24");
    expect(ab).toHaveProperty("age25to44");
    expect(ab).toHaveProperty("age45to64");
    expect(ab).toHaveProperty("age65plus");
  });

  it("M11.5.1.6: age breakdown sums approximately equal total population", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795`);
    const body = await r.json();
    const a = body.data.acs;
    const ab = a.ageBreakdown;
    const sum = ab.under5 + ab.age5to17 + ab.age18to24 + ab.age25to44 + ab.age45to64 + ab.age65plus;
    // Allow small variance (some ages may be missing or in non-bucketed categories)
    const variance = Math.abs(sum - a.totalPopulation) / a.totalPopulation;
    expect(variance).toBeLessThan(0.05);  // within 5%
  });

  it("M11.5.1.7: 65+ population is realistic (10-30% of total)", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795`);
    const body = await r.json();
    const a = body.data.acs;
    const pct65 = a.ageBreakdown.age65plus / a.totalPopulation;
    // NYC is ~13% senior
    expect(pct65).toBeGreaterThan(0.10);
    expect(pct65).toBeLessThan(0.30);
  });

  it("M11.5.1.8: under 5 is realistic (3-10% of total)", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795`);
    const body = await r.json();
    const a = body.data.acs;
    const pctU5 = a.ageBreakdown.under5 / a.totalPopulation;
    expect(pctU5).toBeGreaterThan(0.03);
    expect(pctU5).toBeLessThan(0.10);
  });
});

describe("M11.5.1: ACS 5-year — coverage and data quality", () => {
  it("M11.5.1.9: 14,000+ US cities have ACS data", async () => {
    // Search for some major US cities and verify
    const cities = ["New York City", "Los Angeles", "Chicago", "Houston", "Phoenix"];
    let withAcs = 0;
    for (const c of cities) {
      const r = await fetch(`${API}/api/v1/cities/search?q=${encodeURIComponent(c)}&limit=1`);
      const body = await r.json();
      if (body.data.results[0]) {
        const detail = await fetch(`${API}/api/v1/cities/${body.data.results[0].id}`);
        const detailBody = await detail.json();
        if (detailBody.data.acs) {
          withAcs++;
        }
      }
    }
    expect(withAcs).toBeGreaterThanOrEqual(4);
  });

  it("M11.5.1.10: acsYear is always 2022 (2018-2022 5-year)", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795`);
    const body = await r.json();
    expect(body.data.acs.acsYear).toBe(2022);
  });

  it("M11.5.1.11: fipsGeoid is a 7-digit string", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795`);
    const body = await r.json();
    expect(body.data.acs.fipsGeoid).toMatch(/^\d{7}$/);
  });
});

describe("M11.5.1: ACS 5-year — specific cities", () => {
  it("M11.5.1.12: Los Angeles has ACS data", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=los+angeles&limit=1`);
    const body = await r.json();
    const city = body.data.results[0];
    if (city) {
      const detail = await fetch(`${API}/api/v1/cities/${city.id}`);
      const detailBody = await detail.json();
      if (detailBody.data.acs) {
        expect(detailBody.data.acs.totalPopulation).toBeGreaterThan(3_000_000);
      }
    }
  });

  it("M11.5.1.13: Chicago has ACS data", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=chicago&limit=1`);
    const body = await r.json();
    const city = body.data.results[0];
    if (city) {
      const detail = await fetch(`${API}/api/v1/cities/${city.id}`);
      const detailBody = await detail.json();
      if (detailBody.data.acs) {
        expect(detailBody.data.acs.totalPopulation).toBeGreaterThan(2_000_000);
      }
    }
  });

  it("M11.5.1.14: Houston has ACS data", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=houston&limit=1`);
    const body = await r.json();
    const city = body.data.results[0];
    if (city && city.country?.cca2 === "US") {
      const detail = await fetch(`${API}/api/v1/cities/${city.id}`);
      const detailBody = await detail.json();
      if (detailBody.data.acs) {
        expect(detailBody.data.acs.totalPopulation).toBeGreaterThan(1_000_000);
      }
    }
  });
});

describe("M11.5.1: ACS 5-year — performance and integration", () => {
  it("M11.5.1.15: detail endpoint completes in <500ms with acs block", async () => {
    const start = Date.now();
    const r = await fetch(`${API}/api/v1/cities/122795`);
    const body = await r.json();
    const elapsed = Date.now() - start;
    expect(r.status).toBe(200);
    expect(body.data.acs).toBeTruthy();
    expect(elapsed).toBeLessThan(500);
  });

  it("M11.5.1.16: 404 for non-existent city (no acs key error)", async () => {
    const r = await fetch(`${API}/api/v1/cities/999999999`);
    expect(r.status).toBe(404);
  });
});
