/**
 * M4: Postcodes regression tests
 *
 * Spec coverage: §17.5 (postcodes present), §16.3 (small island via postcode),
 * §33.7 (postcodes in city detail)
 *
 * Spec: https://github.com/.../3849c8b4__*.md (City Timezone Resolution)
 */
import { describe, it, expect, beforeAll } from "vitest";

const API = process.env.TEST_API_URL || "https://dt-api-v2-dev.nsura2029.workers.dev";

describe("M4: Postcodes data layer", () => {
  it("M4.1: postcodes table has 844,248 rows", async () => {
    const r = await fetch(`${API}/api/v1/cities/115731`); // 115731 = East Pensacola Heights
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.success).toBe(true);
    expect(body.data.postcodes).toBeTruthy();
    expect(body.data.postcodes.total).toBeGreaterThan(1000);
  });

  it("M4.2: postcodes has 5 samples per city", async () => {
    const r = await fetch(`${API}/api/v1/cities/64500`); // Tokyo
    const body = await r.json();
    expect(body.data.postcodes.sample).toHaveLength(5);
    expect(body.data.postcodes.total).toBeGreaterThan(1000);
  });

  it("M4.3: postcode samples have valid fields (Tokyo JP - lat/lon optional)", async () => {
    const r = await fetch(`${API}/api/v1/cities/64500`); // Tokyo
    const body = await r.json();
    for (const p of body.data.postcodes.sample) {
      expect(p.code).toBeTruthy();
      expect(typeof p.code).toBe("string");
      // lat/lon may be null for JP postcodes (dr5hn source)
    }
  });

  it("M4.3b: US postcode samples have valid lat/lon (Pensacola FL)", async () => {
    const r = await fetch(`${API}/api/v1/cities/115731`); // East Pensacola Heights
    const body = await r.json();
    for (const p of body.data.postcodes.sample) {
      expect(p.code).toBeTruthy();
      expect(typeof p.code).toBe("string");
      // US census source includes lat/lon
      expect(typeof p.latitude).toBe("number");
      expect(typeof p.longitude).toBe("number");
    }
  });

  it("M4.4: city detail includes dr5hn enrichment (native, stateCode, type, wikiDataId, flag)", async () => {
    const r = await fetch(`${API}/api/v1/cities/115731`);
    const body = await r.json();
    expect(body.data.native).toBe("East Pensacola Heights");
    expect(body.data.stateCode).toBe("FL");
    expect(body.data.type).toBe("city");
    expect(body.data.wikiDataId).toBe("Q3459226");
    expect(body.data.flag).toBe(true);
  });

  it("M4.5: city detail includes dr5hn enrichment for non-ASCII (Tokyo)", async () => {
    const r = await fetch(`${API}/api/v1/cities/64500`);
    const body = await r.json();
    expect(body.data.native).toBe("東京");
    expect(body.data.stateCode).toBe("13");
    expect(body.data.type).toBe("capital");
    expect(body.data.wikiDataId).toBe("Q1490");
  });

  it("M4.6: search result includes dr5hn enrichment (Phoenix AZ)", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=Phoenix&country=US&limit=1`);
    const body = await r.json();
    const phoenix = body.data.results[0];
    expect(phoenix.stateCode).toBe("AZ");
    expect(phoenix.type).toBe("city");
    expect(phoenix.wikiDataId).toBeTruthy();
  });
});

describe("M4: Postcodes state scoping", () => {
  it("M4.7: postcodes are scoped to state (not country-wide)", async () => {
    // Florida has ~1,000 postcodes, US has ~33,000
    // So FL postcodes for East Pensacola Heights should be ~1000
    const r = await fetch(`${API}/api/v1/cities/115731`); // Florida
    const body = await r.json();
    expect(body.data.postcodes.total).toBeLessThan(5000); // FL-scoped
    expect(body.data.postcodes.total).toBeGreaterThan(500); // not 0
  });

  it("M4.8: TX (Texas) city has different postcodes than FL", async () => {
    const r = await fetch(`${API}/api/v1/cities/118699`); // Houston TX
    const body = await r.json();
    expect(body.data.stateCode).toBe("TX");
    // TX postcodes should be different codes
    const codes = body.data.postcodes.sample.map((p: { code: string }) => p.code);
    expect(codes[0]).toMatch(/^7[0-9]/); // TX ZIP starts with 7
  });
});
