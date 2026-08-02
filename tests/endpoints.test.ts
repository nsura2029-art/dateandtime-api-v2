/**
 * M7: New endpoints tests
 *
 * Spec coverage: §16.3 (small island via postcode), §17.5 (full postcodes list),
 * §33.7 (postcodes acceptance), §33.21 (airports schema)
 */
import { describe, it, expect } from "vitest";

const API = process.env.TEST_API_URL || "https://dt-api-v2-dev.nsura2029.workers.dev";

describe("M7: /cities/{id}/postcodes (paginated)", () => {
  it("M7.1: full postcodes list for East Pensacola Heights (FL)", async () => {
    const r = await fetch(`${API}/api/v1/cities/115731/postcodes?limit=5`);
    const body = await r.json();
    expect(body.success).toBe(true);
    expect(body.data.cityId).toBe(115731);
    expect(body.data.total).toBeGreaterThan(900);
    expect(body.data.results).toHaveLength(5);
    expect(body.data.results[0].code).toBeTruthy();
  });

  it("M7.2: pagination works (page 2)", async () => {
    const r1 = await fetch(`${API}/api/v1/cities/115731/postcodes?page=1&limit=3`);
    const r2 = await fetch(`${API}/api/v1/cities/115731/postcodes?page=2&limit=3`);
    const p1 = await r1.json();
    const p2 = await r2.json();
    expect(p1.data.page).toBe(1);
    expect(p2.data.page).toBe(2);
    // Different postcodes
    expect(p1.data.results[0].code).not.toBe(p2.data.results[0].code);
  });

  it("M7.3: 404 for missing city", async () => {
    const r = await fetch(`${API}/api/v1/cities/99999999/postcodes`);
    expect(r.status).toBe(404);
  });

  it("M7.4: limit max enforced (limit=100)", async () => {
    const r = await fetch(`${API}/api/v1/cities/115731/postcodes?limit=200`);
    expect(r.status).toBe(400); // Zod validation
  });
});

describe("M7: /postcodes/search", () => {
  it("M7.5: search by exact US zip 32501 finds FL city", async () => {
    const r = await fetch(`${API}/api/v1/postcodes/search?code=32501&country=US&exact=true`);
    const body = await r.json();
    expect(body.success).toBe(true);
    expect(body.data.results.length).toBeGreaterThan(0);
    const fl = body.data.results[0].cities.find((c: { stateCode: string }) => c.stateCode === "FL");
    expect(fl).toBeTruthy();
  });

  it("M7.6: prefix search finds all starting with 32", async () => {
    const r = await fetch(`${API}/api/v1/postcodes/search?code=32&country=US&limit=5`);
    const body = await r.json();
    expect(body.success).toBe(true);
    expect(body.data.results.length).toBeGreaterThan(0);
    // Each postcode should start with "32"
    for (const result of body.data.results) {
      expect(result.postcode.code.startsWith("32")).toBe(true);
    }
  });

  it("M7.7: invalid country returns 400", async () => {
    const r = await fetch(`${API}/api/v1/postcodes/search?code=32501&country=ZZ`);
    expect(r.status).toBe(400);
  });

  it("M7.8: city in result is sorted by state_capital + population", async () => {
    const r = await fetch(`${API}/api/v1/postcodes/search?code=32501&country=US&exact=true`);
    const body = await r.json();
    const cities = body.data.results[0].cities;
    // Tallahassee (FL state capital) should be first
    expect(cities[0].name).toBe("Tallahassee");
    expect(cities[0].isStateCapital).toBe(true);
  });
});

describe("M7: /airports/near (no data yet)", () => {
  it("M7.9: returns valid response shape (count=0 expected)", async () => {
    const r = await fetch(`${API}/api/v1/airports/near?lat=30.42&lon=-87.21&radius=100`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.success).toBe(true);
    expect(body.data.lat).toBe(30.42);
    expect(body.data.lon).toBe(-87.21);
    expect(body.data.radiusKm).toBe(100);
    expect(Array.isArray(body.data.airports)).toBe(true);
  });

  it("M7.10: invalid lat → 400", async () => {
    const r = await fetch(`${API}/api/v1/airports/near?lat=91&lon=0&radius=100`);
    expect(r.status).toBe(400);
  });

  it("M7.11: invalid radius (501) → 400", async () => {
    const r = await fetch(`${API}/api/v1/airports/near?lat=30&lon=-87&radius=501`);
    expect(r.status).toBe(400);
  });

  it("M7.12: NYC (JFK airport) — schema works for known airport coordinates", async () => {
    // JFK is at 40.6413, -73.7781
    const r = await fetch(`${API}/api/v1/airports/near?lat=40.6413&lon=-73.7781&radius=50`);
    expect(r.status).toBe(200);
    const body = await r.json();
    // Even with no data loaded, the response shape is correct
    expect(body.data.count).toBe(0);
  });
});

describe("M7: /cities/{id}/airports (no data yet)", () => {
  it("M7.13: returns 200 with empty airports for known city", async () => {
    const r = await fetch(`${API}/api/v1/cities/64500/airports`); // Tokyo
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data.cityId).toBe(64500);
    expect(Array.isArray(body.data.airports)).toBe(true);
  });

  it("M7.14: 404 for missing city", async () => {
    const r = await fetch(`${API}/api/v1/cities/99999999/airports`);
    expect(r.status).toBe(404);
  });
});
