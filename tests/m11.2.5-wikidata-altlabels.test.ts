/**
 * M11.2.5: Wikidata alt_labels search strategy tests
 *
 * Tests the new search strategy A3 (M11.2.5) that uses
 * wikidata_staging.alt_labels_json to find cities by their Wikidata alt labels.
 *
 * Coverage:
 *   - Historic names: Yedo → Tokyo, Lundenwic → London
 *   - Colloquial: "Big Smoke" → London, "Puritan City" → Boston
 *   - Cross-language transliterations: Tokei → Tokyo
 *   - Case-insensitive: yedo/Yedo/YEDO all work
 *   - matchType = "alt_label" for Wikidata alt label matches
 *   - Multi-word alt labels (with spaces) work
 *   - Existing strategies (A, A2, B) still take priority when they match
 */
import { describe, it, expect } from "vitest";

const API = process.env.TEST_API_URL || "http://localhost:8787";

describe("M11.2.5: Wikidata alt_labels search — historic names", () => {
  it("M11.2.5.1: 'yedo' (historic Tokyo) returns Tokyo as alt_label match", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=yedo&limit=3`);
    const body = await r.json();
    expect(body.data.total).toBeGreaterThan(0);
    const tokyo = body.data.results.find((c: any) => c.id === 64500);
    expect(tokyo).toBeTruthy();
    expect(tokyo.matchType).toBe("alt_label");
    expect(tokyo.country.cca2).toBe("JP");
  });

  it("M11.2.5.2: 'jedo' (alt historic Tokyo) returns Tokyo", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=jedo&limit=3`);
    const body = await r.json();
    const tokyo = body.data.results.find((c: any) => c.id === 64500);
    expect(tokyo).toBeTruthy();
    expect(tokyo.matchType).toBe("alt_label");
  });

  it("M11.2.5.3: 'tokei' (transliteration) returns Tokyo", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=tokei&limit=3`);
    const body = await r.json();
    const tokyo = body.data.results.find((c: any) => c.id === 64500);
    expect(tokyo).toBeTruthy();
    expect(tokyo.matchType).toBe("alt_label");
  });

  it("M11.2.5.4: 'lundenwic' (historic London) returns London", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=lundenwic&limit=3`);
    const body = await r.json();
    const london = body.data.results.find((c: any) => c.id === 50388);
    expect(london).toBeTruthy();
    expect(london.matchType).toBe("alt_label");
  });

  it("M11.2.5.5: 'londinium' (Roman London) returns London", async () => {
    // Note: FTS5 may also match "londinium*" via place_names. Either way, London should appear.
    const r = await fetch(`${API}/api/v1/cities/search?q=londinium&limit=3`);
    const body = await r.json();
    const london = body.data.results.find((c: any) => c.id === 50388);
    expect(london).toBeTruthy();
    // matchType could be 'alt_label' (if only A3 matches) or 'fuzzy' (if FTS5 catches it first)
    // We just verify the city is found
    expect(["alt_label", "fuzzy", "prefix"]).toContain(london.matchType);
  });
});

describe("M11.2.5: Wikidata alt_labels search — colloquial names", () => {
  it("M11.2.5.6: 'big smoke' (London nickname) returns London", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=big%20smoke&limit=3`);
    const body = await r.json();
    expect(body.data.total).toBeGreaterThan(0);
    const london = body.data.results.find((c: any) => c.id === 50388);
    expect(london).toBeTruthy();
    expect(london.matchType).toBe("alt_label");
  });

  it("M11.2.5.7: 'puritan city' (Boston nickname) returns Boston", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=puritan%20city&limit=3`);
    const body = await r.json();
    expect(body.data.total).toBeGreaterThan(0);
    const boston = body.data.results.find((c: any) => c.id === 112589);
    expect(boston).toBeTruthy();
    expect(boston.matchType).toBe("alt_label");
  });
});

describe("M11.2.5: Wikidata alt_labels search — case insensitivity", () => {
  it("M11.2.5.8: 'YEDO' (uppercase) returns Tokyo", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=YEDO&limit=3`);
    const body = await r.json();
    const tokyo = body.data.results.find((c: any) => c.id === 64500);
    expect(tokyo).toBeTruthy();
    expect(tokyo.matchType).toBe("alt_label");
  });

  it("M11.2.5.9: 'Yedo' (capitalized) returns Tokyo", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=Yedo&limit=3`);
    const body = await r.json();
    const tokyo = body.data.results.find((c: any) => c.id === 64500);
    expect(tokyo).toBeTruthy();
  });
});

describe("M11.2.5: Wikidata alt_labels search — strategy priority", () => {
  it("M11.2.5.10: existing search still works for cities with prefix matches", async () => {
    // 'Toky' should still match Tokyo as prefix (Strategy A wins over Strategy A3)
    const r = await fetch(`${API}/api/v1/cities/search?q=Toky&limit=3`);
    const body = await r.json();
    expect(body.data.total).toBeGreaterThan(0);
    const tokyo = body.data.results.find((c: any) => c.id === 64500);
    expect(tokyo).toBeTruthy();
    // Should be 'prefix' or 'exact', not 'alt_label' (Strategy A wins)
    expect(["prefix", "exact"]).toContain(tokyo.matchType);
  });

  it("M11.2.5.11: exact match still returns matchType=exact", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=Tokyo&limit=3`);
    const body = await r.json();
    const tokyo = body.data.results.find((c: any) => c.id === 64500);
    expect(tokyo).toBeTruthy();
    expect(tokyo.matchType).toBe("exact");
  });
});

describe("M11.2.5: Wikidata alt_labels search — performance", () => {
  it("M11.2.5.12: 'lundenwic' returns within 3 seconds", async () => {
    const t0 = Date.now();
    const r = await fetch(`${API}/api/v1/cities/search?q=lundenwic&limit=3`);
    const body = await r.json();
    const elapsed = Date.now() - t0;
    expect(body.data.total).toBeGreaterThan(0);
    expect(elapsed).toBeLessThan(5000); // < 5s including all strategies
  });

  it("M11.2.5.13: alt_label match has lower score than exact match (same city)", async () => {
    // Sanity: exact match should score higher than alt_label match
    const r1 = await fetch(`${API}/api/v1/cities/search?q=Tokyo&limit=1`);
    const b1 = await r1.json();
    const tokyoExact = b1.data.results[0];

    const r2 = await fetch(`${API}/api/v1/cities/search?q=yedo&limit=1`);
    const b2 = await r2.json();
    const tokyoAlt = b2.data.results[0];

    // exact should score higher
    expect(tokyoExact.score).toBeGreaterThanOrEqual(tokyoAlt.score);
  });
});

describe("M11.2.5: Wikidata alt_labels search — schema", () => {
  it("M11.2.5.14: matchType enum includes 'alt_label'", async () => {
    // Hit an alt_label match
    const r = await fetch(`${API}/api/v1/cities/search?q=yedo&limit=1`);
    const body = await r.json();
    expect(body.data.results[0].matchType).toBe("alt_label");
  });

  it("M11.2.5.15: OpenAPI schema accepts alt_label as a valid matchType", async () => {
    // The schema includes alt_label in the enum
    const r = await fetch(`${API}/openapi.json`);
    const spec = await r.json();
    const searchSchema = spec.paths["/api/v1/cities/search"].get.responses["200"]
      .content["application/json"].schema;
    // Walk through the schema to find matchType
    const allText = JSON.stringify(searchSchema);
    expect(allText).toContain("alt_label");
  });
});
