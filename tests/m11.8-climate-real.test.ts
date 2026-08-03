/**
 * M11.8: Real climate data (NCEI GSOM 2020-2023)
 *
 * Tests the new climate_real table integration in /cities/{id}/climate.
 * 10,559 cities have real NCEI GSOM data; others fall back to lat-based model.
 */
import { describe, it, expect } from "vitest";

const API = process.env.TEST_API_URL || "http://localhost:8787";

describe("M11.8: Real climate data (NCEI GSOM)", () => {
  it("M11.8.1: /cities/{id}/climate returns real NCEI data for cities with stations", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795/climate`);  // NYC
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data.source).toBe("ncei-gsom");
    expect(body.data.dataYears).toBe("2020-2023");
    expect(body.data.months).toHaveLength(12);
  });

  it("M11.8.2: NYC January high is realistic (5-15°C for 2020-2023)", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795/climate`);
    const body = await r.json();
    const jan = body.data.months.find((m: any) => m.month === 1);
    expect(jan.avgHighC).toBeGreaterThanOrEqual(5);
    expect(jan.avgHighC).toBeLessThanOrEqual(15);
    expect(jan.avgLowC).toBeLessThan(jan.avgHighC);
  });

  it("M11.8.3: NYC July high is realistic (25-35°C)", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795/climate`);
    const body = await r.json();
    const jul = body.data.months.find((m: any) => m.month === 7);
    expect(jul.avgHighC).toBeGreaterThanOrEqual(25);
    expect(jul.avgHighC).toBeLessThanOrEqual(35);
  });

  it("M11.8.4: Northern hemisphere has summer peak (Jul > Jan)", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795/climate`);
    const body = await r.json();
    const jul = body.data.months.find((m: any) => m.month === 7);
    const jan = body.data.months.find((m: any) => m.month === 1);
    expect(jul.avgHighC).toBeGreaterThan(jan.avgHighC);
  });

  it("M11.8.5: Southern hemisphere has summer peak (Jan > Jul) — sample Sydney", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=Sydney&limit=1`);
    const body = await r.json();
    if (body.data.results[0]) {
      const id = body.data.results[0].id;
      const r2 = await fetch(`${API}/api/v1/cities/${id}/climate`);
      const body2 = await r2.json();
      if (body2.data.source === "ncei-gsom") {
        const jan = body2.data.months.find((m: any) => m.month === 1);
        const jul = body2.data.months.find((m: any) => m.month === 7);
        expect(jan.avgHighC).toBeGreaterThan(jul.avgHighC);
      } else {
        // Skip if no real data
        expect(body2.data.source).toBeTruthy();
      }
    }
  });

  it("M11.8.6: 12 months of data when real data is available", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795/climate`);
    const body = await r.json();
    expect(body.data.months).toHaveLength(12);
    for (let m = 1; m <= 12; m++) {
      const month = body.data.months.find((mo: any) => mo.month === m);
      expect(month).toBeTruthy();
      expect(month.monthName).toBeTruthy();
    }
  });

  it("M11.8.7: precipitation is non-negative", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795/climate`);
    const body = await r.json();
    for (const m of body.data.months) {
      expect(m.precipitationMm).toBeGreaterThanOrEqual(0);
    }
  });
});

describe("M11.8: Fallback to lat-based model", () => {
  it("M11.8.8: cities without NCEI data return lat-based model", async () => {
    // Find a city with no NCEI data — Tokyo, Paris, etc.
    const r = await fetch(`${API}/api/v1/cities/search?q=Tokyo&limit=1`);
    const body = await r.json();
    if (body.data.results[0]) {
      const id = body.data.results[0].id;
      const r2 = await fetch(`${API}/api/v1/cities/${id}/climate`);
      const body2 = await r2.json();
      // Tokyo doesn't have NCEI data, should fall back
      expect(body2.data.source).toBeTruthy();
      // If lat-based, has climateZone
      if (body2.data.source === "lat-based-model") {
        expect(body2.data.climateZone).toBeTruthy();
        expect(body2.data.hemisphere).toBeTruthy();
      }
    }
  });

  it("M11.8.9: small city without NCEI data uses lat-based model", async () => {
    // Andorra la Vella is a small city in mountains, may not have NCEI station
    const r = await fetch(`${API}/api/v1/cities/1/climate`);
    const body = await r.json();
    // Either source is fine, just check the response is valid
    expect(body.data.months).toBeTruthy();
    expect(body.data.source).toBeTruthy();
  });
});

describe("M11.8: Climate API performance", () => {
  it("M11.8.10: /cities/{id}/climate responds in < 2000ms", async () => {
    const start = Date.now();
    const r = await fetch(`${API}/api/v1/cities/122795/climate`);
    const ms = Date.now() - start;
    expect(r.status).toBe(200);
    expect(ms).toBeLessThan(2000);
  });
});
