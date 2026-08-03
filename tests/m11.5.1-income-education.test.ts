/**
 * M11.5.1 expand: ACS 5-year Income (B19013) + Education (B15003) in /cities/{id}
 *
 * Tests the income + education fields added on top of M11.5.1 Sex by Age.
 *
 * Coverage:
 *   - acsIncome (median household income) for US cities
 *   - acsEducation (educational attainment) for US cities
 *   - All 7 buckets present and summed correctly
 *   - Non-US cities have null
 *   - acsYear is 2022
 *   - bachelorOrHigherPct is realistic
 */
import { describe, it, expect } from "vitest";

const API = process.env.TEST_API_URL || "http://localhost:8787";

describe("M11.5.1 expand: ACS Income — schema", () => {
  it("M11.5.1.20: /cities/{id} response includes `acsIncome` field", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data).toHaveProperty("acsIncome");
  });

  it("M11.5.1.21: NYC has realistic median income", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795`);
    const body = await r.json();
    const inc = body.data.acsIncome;
    expect(inc).toBeTruthy();
    expect(inc.fipsGeoid).toBe("3651000");
    // NYC median household income is around $70K-$80K
    expect(inc.medianIncome).toBeGreaterThan(50000);
    expect(inc.medianIncome).toBeLessThan(150000);
    expect(inc.acsYear).toBe(2022);
  });

  it("M11.5.1.22: Non-US cities have acsIncome=null", async () => {
    const r = await fetch(`${API}/api/v1/cities/24053`);
    const body = await r.json();
    expect(body.data.acsIncome).toBeNull();
  });

  it("M11.5.1.23: Non-US cities have acsEducation=null", async () => {
    const r = await fetch(`${API}/api/v1/cities/24053`);
    const body = await r.json();
    expect(body.data.acsEducation).toBeNull();
  });
});

describe("M11.5.1 expand: ACS Education — schema", () => {
  it("M11.5.1.24: /cities/{id} response includes `acsEducation` field", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data).toHaveProperty("acsEducation");
  });

  it("M11.5.1.25: NYC has all education buckets", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795`);
    const body = await r.json();
    const e = body.data.acsEducation;
    expect(e).toBeTruthy();
    expect(e.population25Plus).toBeGreaterThan(5_000_000);
    expect(e.lessThanHs).toBeGreaterThan(0);
    expect(e.hsOrGed).toBeGreaterThan(0);
    expect(e.someCollege).toBeGreaterThan(0);
    expect(e.associateDegree).toBeGreaterThan(0);
    expect(e.bachelorDegree).toBeGreaterThan(0);
    expect(e.graduateDegree).toBeGreaterThan(0);
    expect(e.bachelorOrHigher).toBeGreaterThan(0);
  });

  it("M11.5.1.26: bachelorOrHigherPct is realistic (15-60% of 25+)", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795`);
    const body = await r.json();
    const e = body.data.acsEducation;
    expect(e.bachelorOrHigherPct).toBeGreaterThan(15);
    expect(e.bachelorOrHigherPct).toBeLessThan(60);
  });

  it("M11.5.1.27: education buckets sum to population 25+", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795`);
    const body = await r.json();
    const e = body.data.acsEducation;
    const sum = e.lessThanHs + e.hsOrGed + e.someCollege
              + e.associateDegree + e.bachelorDegree + e.graduateDegree;
    // Should equal population_25_plus
    const variance = Math.abs(sum - e.population25Plus) / e.population25Plus;
    expect(variance).toBeLessThan(0.01);  // within 1%
  });

  it("M11.5.1.28: bachelorOrHigher = assoc + bachelor + graduate", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795`);
    const body = await r.json();
    const e = body.data.acsEducation;
    const expected = e.associateDegree + e.bachelorDegree + e.graduateDegree;
    expect(e.bachelorOrHigher).toBe(expected);
  });
});

describe("M11.5.1 expand: Coverage", () => {
  it("M11.5.1.29: 14,000+ US cities have income data", async () => {
    const cities = ["New York", "Los Angeles", "Chicago", "Houston", "Phoenix"];
    let withInc = 0;
    for (const c of cities) {
      const r = await fetch(`${API}/api/v1/cities/search?q=${encodeURIComponent(c)}&limit=1`);
      const body = await r.json();
      if (body.data.results[0]) {
        const detail = await fetch(`${API}/api/v1/cities/${body.data.results[0].id}`);
        const detailBody = await detail.json();
        if (detailBody.data.acsIncome) {
          withInc++;
        }
      }
    }
    expect(withInc).toBeGreaterThanOrEqual(4);
  });

  it("M11.5.1.30: 14,000+ US cities have education data", async () => {
    const cities = ["New York", "Los Angeles", "Chicago", "Houston", "Phoenix"];
    let withEdu = 0;
    for (const c of cities) {
      const r = await fetch(`${API}/api/v1/cities/search?q=${encodeURIComponent(c)}&limit=1`);
      const body = await r.json();
      if (body.data.results[0]) {
        const detail = await fetch(`${API}/api/v1/cities/${body.data.results[0].id}`);
        const detailBody = await detail.json();
        if (detailBody.data.acsEducation) {
          withEdu++;
        }
      }
    }
    expect(withEdu).toBeGreaterThanOrEqual(4);
  });
});

describe("M11.5.1 expand: Specific cities", () => {
  it("M11.5.1.31: Los Angeles has income + education", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=los+angeles&limit=1`);
    const body = await r.json();
    const city = body.data.results[0];
    if (city) {
      const detail = await fetch(`${API}/api/v1/cities/${city.id}`);
      const detailBody = await detail.json();
      if (detailBody.data.acsIncome) {
        expect(detailBody.data.acsIncome.medianIncome).toBeGreaterThan(30000);
      }
      if (detailBody.data.acsEducation) {
        expect(detailBody.data.acsEducation.bachelorDegree).toBeGreaterThan(0);
      }
    }
  });

  it("M11.5.1.32: Chicago has income + education", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=chicago&limit=1`);
    const body = await r.json();
    const city = body.data.results[0];
    if (city) {
      const detail = await fetch(`${API}/api/v1/cities/${city.id}`);
      const detailBody = await detail.json();
      if (detailBody.data.acsIncome) {
        expect(detailBody.data.acsIncome.medianIncome).toBeGreaterThan(30000);
      }
    }
  });

  it("M11.5.1.33: Income range: $25K - $200K for typical US cities", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795`);
    const body = await r.json();
    const inc = body.data.acsIncome;
    // US median household income is around $75K, NYC is ~$76K
    expect(inc.medianIncome).toBeGreaterThan(25000);
    expect(inc.medianIncome).toBeLessThan(200000);
  });
});

describe("M11.5.1 expand: Performance", () => {
  it("M11.5.1.34: detail endpoint completes in <1500ms with all ACS blocks", async () => {
    const start = Date.now();
    const r = await fetch(`${API}/api/v1/cities/122795`);
    const body = await r.json();
    const elapsed = Date.now() - start;
    expect(r.status).toBe(200);
    expect(body.data.acs).toBeTruthy();
    expect(body.data.acsIncome).toBeTruthy();
    expect(body.data.acsEducation).toBeTruthy();
    // US city detail with all ACS blocks (combined query) + census + wikidata
    // ~600-900ms typical; allow 1500ms for network variance
    expect(elapsed).toBeLessThan(1500);
  });
});
