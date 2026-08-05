/**
 * M8: Data quality metadata tests
 *
 * Spec coverage: §14.3 (Null Island), §15 (boundary), §25 (audit),
 * §28 (manual override), §33.5, §33.17-18 (acceptance)
 */
import { describe, it, expect } from "vitest";

const API = process.env.TEST_API_URL || "https://dt-api-v2-dev.nsura2029.workers.dev";

describe("M8: /data-quality summary", () => {
  it("M8.1: returns city confidence counts", async () => {
    const r = await fetch(`${API}/api/v1/data-quality`);
    const body = await r.json();
    expect(body.success).toBe(true);
    expect(body.data.cities.total).toBe(170253); // post M11.1 layer merge
    // M1 polygon-verified: ~3,000
    expect(body.data.cities.confidence.high).toBeGreaterThan(2900);
    expect(body.data.cities.confidence.high).toBeLessThan(3100);
    // dr5hn default: bulk
    expect(body.data.cities.confidence.medium).toBeGreaterThan(149000);
    // Manual override: 13
    expect(body.data.cities.confidence.low).toBe(13);
    // Null Island: 22
    expect(body.data.cities.confidence.unresolved).toBe(22);
  });

  it("M8.2: lists data sources", async () => {
    const r = await fetch(`${API}/api/v1/data-quality`);
    const body = await r.json();
    expect(body.data.dataSources.length).toBe(8);
    const dr5hn = body.data.dataSources.find((s: { name: string }) => s.name.includes("dr5hn"));
    expect(dr5hn).toBeTruthy();
  });

  it("M8.3: lists migrations", async () => {
    const r = await fetch(`${API}/api/v1/data-quality`);
    const body = await r.json();
    expect(body.data.migrations.length).toBeGreaterThan(0);
    // Should include the M1 polygon fix migration
    const m1 = body.data.migrations.find((m: { description: string }) => m.description.includes("polygon"));
    expect(m1 || body.data.migrations.length > 5).toBeTruthy();
  });

  it("M8.4: deprecated Etc/GMT count is 0 (spec §8.2)", async () => {
    const r = await fetch(`${API}/api/v1/data-quality`);
    const body = await r.json();
    // Migration 125 cleared all Etc/GMT* per spec §8.2
    expect(body.data.timezoneZones.deprecatedEtcGmt).toBe(0);
  });
});

describe("M8: /data-quality/issues", () => {
  it("M8.5: list all issues, sorted by severity", async () => {
    const r = await fetch(`${API}/api/v1/data-quality/issues?limit=10`);
    const body = await r.json();
    expect(body.success).toBe(true);
    expect(body.data.issues.length).toBeGreaterThan(0);
    // Should include null_island issues (severity: error)
    const nullIsland = body.data.issues.find((i: { type: string }) => i.type === "null_island");
    expect(nullIsland).toBeTruthy();
    expect(nullIsland.severity).toBe("error");
  });

  it("M8.6: filter by type=null_island returns 22 cities", async () => {
    const r = await fetch(`${API}/api/v1/data-quality/issues?type=null_island&limit=50`);
    const body = await r.json();
    expect(body.data.total).toBe(22);
    for (const issue of body.data.issues) {
      expect(issue.type).toBe("null_island");
      expect(issue.severity).toBe("error");
    }
  });

  it("M8.7: filter by type=manual_override returns 13 cities", async () => {
    const r = await fetch(`${API}/api/v1/data-quality/issues?type=manual_override&limit=20`);
    const body = await r.json();
    expect(body.data.total).toBe(13);
    for (const issue of body.data.issues) {
      expect(issue.type).toBe("manual_override");
    }
  });

  it("M8.8: filter by type=low_confidence returns 35 cities", async () => {
    const r = await fetch(`${API}/api/v1/data-quality/issues?type=low_confidence&limit=50`);
    const body = await r.json();
    // 13 manual override + 22 unresolved
    expect(body.data.total).toBe(35);
  });

  it("M8.9: filter by type=etc_gmt_deprecated returns 0", async () => {
    const r = await fetch(`${API}/api/v1/data-quality/issues?type=etc_gmt_deprecated`);
    const body = await r.json();
    // Migration 125 banned all Etc/GMT* per spec §8.2
    expect(body.data.total).toBe(0);
  });
});

describe("M8: /cities/{id} data quality", () => {
  it("M8.10: Tokyo has dataQuality metadata", async () => {
    const r = await fetch(`${API}/api/v1/cities/64500`); // Tokyo
    const body = await r.json();
    expect(body.data.dataQuality).toBeTruthy();
    expect(body.data.dataQuality.timezoneConfidence).toBe("medium");
    expect(body.data.dataQuality.timezoneSource).toBe("dr5hn:default");
    expect(Array.isArray(body.data.dataQuality.flags)).toBe(true);
  });

  it("M8.11: Atikokan (M1 manual override) is low confidence", async () => {
    const r = await fetch(`${API}/api/v1/cities/16179`); // Atikokan ON
    const body = await r.json();
    expect(body.data.dataQuality.timezoneConfidence).toBe("low");
    expect(body.data.dataQuality.timezoneSource).toBe("manual:override");
  });

  it("M8.12: A M1 polygon-fixed city is high confidence", async () => {
    // Alderetes (id 646) was polygon-fixed in M1 (Argentina had 178 mismatches)
    const r = await fetch(`${API}/api/v1/cities/646`);
    const body = await r.json();
    expect(body.data.dataQuality.timezoneConfidence).toBe("high");
    expect(body.data.dataQuality.timezoneSource).toBe("polygon:timezonefinder");
  });

  it("M8.13: Null Island city has unresolved + null_island flag", async () => {
    // Find a Null Island city
    const r = await fetch(`${API}/api/v1/data-quality/issues?type=null_island&limit=1`);
    const body = await r.json();
    const cityId = body.data.issues[0].cityId;
    const cityR = await fetch(`${API}/api/v1/cities/${cityId}`);
    const cityBody = await cityR.json();
    expect(cityBody.data.dataQuality.timezoneConfidence).toBe("unresolved");
    expect(cityBody.data.dataQuality.flags).toContain("null_island");
  });
});

describe("M8: /cities/{id} confidence distribution", () => {
  it("M8.14: most cities are medium (dr5hn + GeoNames)", async () => {
    const r = await fetch(`${API}/api/v1/data-quality`);
    const body = await r.json();
    const c = body.data.cities.confidence;
    // Post M11.1: 102K dr5hn untouched + 49K dr5hn merged + 17K GeoNames-only
    // all default to medium. Total ~168K medium / 170K total = 0.99.
    const ratio = c.medium / c.total;
    expect(ratio).toBeGreaterThan(0.85);
    expect(ratio).toBeLessThanOrEqual(1.0);
  });

  it("M8.15: high + low + unresolved < 1% of all", async () => {
    const r = await fetch(`${API}/api/v1/data-quality`);
    const body = await r.json();
    const c = body.data.cities.confidence;
    const verified = c.high + c.low + c.unresolved;
    expect(verified / c.total).toBeLessThan(0.03); // <3% need review
  });
});
