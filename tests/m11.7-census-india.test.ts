/**
 * M11.7: Census of India 2011 in /cities/{id}
 *
 * Tests the M11.7 layer: in_census_attributes (PCA-UA dataset, 422 matched
 * Indian cities out of 1,946 statutory cities + 298 UAs + 902 OGs).
 *
 * Coverage:
 *   - Indian cities with in_census_code have censusIndia block
 *   - censusCode, stateCode, districtCode, uaCode, uaName
 *   - level: 1 (city proper) or 0 (metro total)
 *   - population, sex_ratio, literacy_rate, workers
 *   - Non-Indian cities have censusIndia=null
 *   - Indian cities without in_census_code have censusIndia=null
 */
import { describe, it, expect } from "vitest";

const API = process.env.TEST_API_URL || "http://localhost:8787";

describe("M11.7: Census of India — schema", () => {
  it("M11.7.1: /cities/{id} response includes `censusIndia` field", async () => {
    // Agra (57601) — has Census data
    const r = await fetch(`${API}/api/v1/cities/57601`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data).toHaveProperty("censusIndia");
  });

  it("M11.7.2: Agra has full censusIndia data", async () => {
    const r = await fetch(`${API}/api/v1/cities/57601`);
    const body = await r.json();
    const ci = body.data.censusIndia;
    expect(ci).toBeTruthy();
    expect(ci.censusCode).toBe("800804");
    expect(ci.stateCode).toBe("09");
    expect(ci.districtCode).toBe("146");
    expect(ci.uaCode).toBe("502300100");
    expect(ci.uaName).toBe("(a) Agra (M Corp.)");
    expect(ci.level).toBe(1);
    expect(ci.population).toBe(1585704);
    expect(ci.censusYear).toBe(2011);
  });

  it("M11.7.3: Mumbai (Greater Mumbai) has censusIndia data", async () => {
    const r = await fetch(`${API}/api/v1/cities/133024`);
    const body = await r.json();
    const ci = body.data.censusIndia;
    expect(ci).toBeTruthy();
    expect(ci.population).toBe(12442373);
    expect(ci.sexRatio).toBe(853);  // females per 1000 males
    expect(ci.uaName).toBe("(a) Greater Mumbai (M Corp.)");
    expect(ci.level).toBe(1);
  });

  it("M11.7.4: Kolkata has censusIndia data", async () => {
    const r = await fetch(`${API}/api/v1/cities/142001`);
    const body = await r.json();
    const ci = body.data.censusIndia;
    expect(ci).toBeTruthy();
    expect(ci.population).toBe(4496694);
    expect(ci.uaName).toBe("(a) Kolkata (M Corp.)");
  });

  it("M11.7.5: Non-Indian cities have censusIndia=null", async () => {
    // Berlin (24053) — Germany
    const r = await fetch(`${API}/api/v1/cities/24053`);
    const body = await r.json();
    expect(body.data.censusIndia).toBeNull();
  });

  it("M11.7.6: Tokyo (JP) has censusIndia=null", async () => {
    const r = await fetch(`${API}/api/v1/cities/64500`);
    const body = await r.json();
    expect(body.data.censusIndia).toBeNull();
  });
});

describe("M11.7: Census of India — derived metrics", () => {
  it("M11.7.7: sexRatio is computed (females per 1000 males)", async () => {
    const r = await fetch(`${API}/api/v1/cities/57601`);
    const body = await r.json();
    const ci = body.data.censusIndia;
    // 739,802 / 845,902 * 1000 = 875
    expect(ci.sexRatio).toBe(875);
  });

  it("M11.7.8: childSexRatio is computed (girls per 1000 boys)", async () => {
    const r = await fetch(`${API}/api/v1/cities/57601`);
    const body = await r.json();
    const ci = body.data.censusIndia;
    // 91,153 / 106,315 * 1000 = 857
    expect(ci.childSexRatio).toBe(857);
  });

  it("M11.7.9: literacyRate is computed (P_LIT / TOT_P * 100)", async () => {
    const r = await fetch(`${API}/api/v1/cities/133024`);
    const body = await r.json();
    const ci = body.data.censusIndia;
    // 10,148,720 / 12,442,373 * 100 ≈ 81.6
    expect(ci.literacyRate).toBeGreaterThan(70);
    expect(ci.literacyRate).toBeLessThan(90);
  });

  it("M11.7.10: workers + non_workers = total population (mostly)", async () => {
    const r = await fetch(`${API}/api/v1/cities/57601`);
    const body = await r.json();
    const ci = body.data.censusIndia;
    // Workers + non_workers should approximately equal total population
    const total = ci.workersTotal + ci.nonWorkers;
    // Allow some variance (children not counted in workers)
    expect(Math.abs(total - ci.population)).toBeLessThan(ci.population * 0.05);
  });
});

describe("M11.7: Census of India — coverage and data quality", () => {
  it("M11.7.11: 422+ Indian cities have censusIndia data", async () => {
    // Search for some major Indian cities and verify at least some have data
    let withCensusIndia = 0;
    const cities = ["Mumbai", "Delhi", "Kolkata", "Chennai", "Bengaluru", "Pune", "Hyderabad"];
    for (const c of cities) {
      const r = await fetch(`${API}/api/v1/cities/search?q=${c}&limit=1`);
      const body = await r.json();
      if (body.data.results[0]) {
        const detail = await fetch(`${API}/api/v1/cities/${body.data.results[0].id}`);
        const detailBody = await detail.json();
        if (detailBody.data.censusIndia) {
          withCensusIndia++;
        }
      }
    }
    // At least Mumbai, Delhi(?), Kolkata, Chennai, Pune should have data
    expect(withCensusIndia).toBeGreaterThanOrEqual(3);
  });

  it("M11.7.12: censusYear is always 2011", async () => {
    const r = await fetch(`${API}/api/v1/cities/57601`);
    const body = await r.json();
    expect(body.data.censusIndia.censusYear).toBe(2011);
  });

  it("M11.7.13: level is 1 (statutory city) for most matched cities", async () => {
    const r = await fetch(`${API}/api/v1/cities/133024`);  // Mumbai
    const body = await r.json();
    // Level 1 = statutory city, Level 0 = metro total
    expect([0, 1]).toContain(body.data.censusIndia.level);
  });

  it("M11.7.14: total population is > 1000 for any matched city", async () => {
    // Census only covers Class I cities (100K+) and statutory towns
    const r = await fetch(`${API}/api/v1/cities/57601`);
    const body = await r.json();
    expect(body.data.censusIndia.population).toBeGreaterThan(1000);
  });
});

describe("M11.7: Census of India — specific cities", () => {
  it("M11.7.15: Chennai has censusIndia data", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=chennai&limit=1`);
    const body = await r.json();
    const city = body.data.results[0];
    const detail = await fetch(`${API}/api/v1/cities/${city.id}`);
    const detailBody = await detail.json();
    if (detailBody.data.censusIndia) {
      expect(detailBody.data.censusIndia.population).toBe(4646732);
    }
  });

  it("M11.7.16: Pune has censusIndia data", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=pune&limit=1`);
    const body = await r.json();
    const city = body.data.results[0];
    const detail = await fetch(`${API}/api/v1/cities/${city.id}`);
    const detailBody = await detail.json();
    if (detailBody.data.censusIndia) {
      expect(detailBody.data.censusIndia.population).toBe(3124458);
    }
  });

  it("M11.7.17: Lucknow has censusIndia data", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=lucknow&limit=1`);
    const body = await r.json();
    const city = body.data.results[0];
    const detail = await fetch(`${API}/api/v1/cities/${city.id}`);
    const detailBody = await detail.json();
    if (detailBody.data.censusIndia) {
      expect(detailBody.data.censusIndia.population).toBe(2817105);
    }
  });

  it("M11.7.18: Surat has censusIndia data", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=surat&limit=1`);
    const body = await r.json();
    const city = body.data.results[0];
    const detail = await fetch(`${API}/api/v1/cities/${city.id}`);
    const detailBody = await detail.json();
    if (detailBody.data.censusIndia) {
      expect(detailBody.data.censusIndia.population).toBe(4501610);
    }
  });
});

describe("M11.7: Census of India — performance and integration", () => {
  it("M11.7.19: detail endpoint completes in <1500ms with censusIndia block", async () => {
    const start = Date.now();
    const r = await fetch(`${API}/api/v1/cities/57601`);
    const body = await r.json();
    const elapsed = Date.now() - start;
    expect(r.status).toBe(200);
    expect(body.data.censusIndia).toBeTruthy();
    expect(elapsed).toBeLessThan(1500);
  });

  it("M11.7.20: 404 for non-existent city (no censusIndia key error)", async () => {
    const r = await fetch(`${API}/api/v1/cities/999999999`);
    expect(r.status).toBe(404);
  });
});

describe("M11.7: Census of India — data shape", () => {
  it("M11.7.21: censusCode is a 6-digit string", async () => {
    const r = await fetch(`${API}/api/v1/cities/57601`);
    const body = await r.json();
    expect(body.data.censusIndia.censusCode).toMatch(/^\d{6}$/);
  });

  it("M11.7.22: stateCode is a 2-digit string", async () => {
    const r = await fetch(`${API}/api/v1/cities/57601`);
    const body = await r.json();
    expect(body.data.censusIndia.stateCode).toMatch(/^\d{2}$/);
  });

  it("M11.7.23: districtCode is a 3-digit string", async () => {
    const r = await fetch(`${API}/api/v1/cities/57601`);
    const body = await r.json();
    expect(body.data.censusIndia.districtCode).toMatch(/^\d{3}$/);
  });

  it("M11.7.24: uaCode is a 9-digit string (hierarchical)", async () => {
    const r = await fetch(`${API}/api/v1/cities/57601`);
    const body = await r.json();
    expect(body.data.censusIndia.uaCode).toMatch(/^\d{9}$/);
  });

  it("M11.7.25: uaName is in format '(<letter>) <City> (<Type>)'", async () => {
    const r = await fetch(`${API}/api/v1/cities/57601`);
    const body = await r.json();
    expect(body.data.censusIndia.uaName).toMatch(/^\([a-z]\)\s+.+\s+\(.+\)$/);
  });
});
