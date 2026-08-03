/**
 * M11.5.1 expand 2: ACS 5-year Tenure (B25003) + Transport (B08301) in /cities/{id}
 *
 * Tests the new blocks added on top of M11.5.1 (Sex by Age + Income + Education).
 */
import { describe, it, expect } from "vitest";

const API = process.env.TEST_API_URL || "http://localhost:8787";

describe("M11.5.1 expand 2: ACS Tenure — schema", () => {
  it("TT.1: /cities/{id} response includes `acsTenure` field", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data).toHaveProperty("acsTenure");
  });

  it("TT.2: NYC has full tenure data (33% owner / 67% renter)", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795`);
    const body = await r.json();
    const t = body.data.acsTenure;
    expect(t).toBeTruthy();
    expect(t.fipsGeoid).toBe("3651000");
    expect(t.totalOccupied).toBeGreaterThan(3_000_000);
    expect(t.ownerOccupied).toBeGreaterThan(1_000_000);
    expect(t.renterOccupied).toBeGreaterThan(2_000_000);
    // Owner + renter should equal total (small variance allowed)
    expect(Math.abs((t.ownerOccupied + t.renterOccupied) - t.totalOccupied)).toBeLessThan(10);
    // NYC is renter-majority
    expect(t.renterOccupiedPct).toBeGreaterThan(50);
    expect(t.ownerOccupiedPct).toBeLessThan(50);
    expect(t.acsYear).toBe(2022);
  });

  it("TT.3: pct values sum to ~100%", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795`);
    const body = await r.json();
    const t = body.data.acsTenure;
    const sum = t.ownerOccupiedPct + t.renterOccupiedPct;
    expect(Math.abs(sum - 100)).toBeLessThan(1);
  });

  it("TT.4: Non-US cities have acsTenure=null", async () => {
    const r = await fetch(`${API}/api/v1/cities/24053`);
    const body = await r.json();
    expect(body.data.acsTenure).toBeNull();
  });
});

describe("M11.5.1 expand 2: ACS Transport — schema", () => {
  it("TP.1: /cities/{id} response includes `acsTransport` field", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data).toHaveProperty("acsTransport");
  });

  it("TP.2: NYC has transport data", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795`);
    const body = await r.json();
    const tr = body.data.acsTransport;
    expect(tr).toBeTruthy();
    expect(tr.fipsGeoid).toBe("3651000");
    expect(tr.totalWorkers).toBeGreaterThan(3_000_000);
    expect(tr.carOrVan).toBeGreaterThan(500_000);
    expect(tr.droveAlone).toBeGreaterThan(500_000);
    expect(tr.acsYear).toBe(2022);
  });

  it("TP.3: droveAlone < carOrVan (some carpool)", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795`);
    const body = await r.json();
    const tr = body.data.acsTransport;
    expect(tr.droveAlone).toBeLessThanOrEqual(tr.carOrVan);
  });

  it("TP.4: Non-US cities have acsTransport=null", async () => {
    const r = await fetch(`${API}/api/v1/cities/24053`);
    const body = await r.json();
    expect(body.data.acsTransport).toBeNull();
  });
});

describe("M11.5.1 expand 2: Coverage", () => {
  it("TT.5: US cities have tenure data", async () => {
    const cities = ["New York", "Los Angeles", "Chicago"];
    let withTenure = 0;
    for (const c of cities) {
      const r = await fetch(`${API}/api/v1/cities/search?q=${encodeURIComponent(c)}&limit=1`);
      const body = await r.json();
      if (body.data.results[0]) {
        const detail = await fetch(`${API}/api/v1/cities/${body.data.results[0].id}`);
        const detailBody = await detail.json();
        if (detailBody.data.acsTenure) {
          withTenure++;
        }
      }
    }
    expect(withTenure).toBeGreaterThanOrEqual(2);
  });

  it("TP.5: US cities have transport data", async () => {
    const cities = ["New York", "Los Angeles", "Chicago"];
    let withTransport = 0;
    for (const c of cities) {
      const r = await fetch(`${API}/api/v1/cities/search?q=${encodeURIComponent(c)}&limit=1`);
      const body = await r.json();
      if (body.data.results[0]) {
        const detail = await fetch(`${API}/api/v1/cities/${body.data.results[0].id}`);
        const detailBody = await detail.json();
        if (detailBody.data.acsTransport) {
          withTransport++;
        }
      }
    }
    expect(withTransport).toBeGreaterThanOrEqual(2);
  });
});

describe("M11.5.1 expand 2: Performance", () => {
  it("TT.6: detail endpoint still completes in <3000ms with all ACS blocks", async () => {
    const start = Date.now();
    const r = await fetch(`${API}/api/v1/cities/122795`);
    const body = await r.json();
    const elapsed = Date.now() - start;
    expect(r.status).toBe(200);
    expect(body.data.acs).toBeTruthy();
    expect(body.data.acsIncome).toBeTruthy();
    expect(body.data.acsEducation).toBeTruthy();
    expect(body.data.acsTenure).toBeTruthy();
    expect(body.data.acsTransport).toBeTruthy();
    expect(elapsed).toBeLessThan(3000);
  });
});
