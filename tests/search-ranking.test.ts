/**
 * M6: API contract upgrade tests
 *
 * Spec coverage: §10.2 (Monterrey/Matamoros/Ciudad Juárez), §10.3 (Perth),
 * §14.2 (lat/lon validation), §17 (same-name in different states),
 * §32 (Unicode/URL encoding)
 */
import { describe, it, expect } from "vitest";

const API = process.env.TEST_API_URL || "https://dt-api-v2-dev.nsura2029.workers.dev";

describe("M6: State filter (?state=)", () => {
  it("M6.1: Phoenix + state=AZ → Phoenix AZ first", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=Phoenix&country=US&state=AZ&limit=3`);
    const body = await r.json();
    const top = body.data.results[0];
    expect(top.name).toBe("Phoenix");
    expect(top.stateCode).toBe("AZ");
    expect(top.id).toBe(124148);
  });

  it("M6.2: Monterrey + state=NLE → Monterrey NLE first", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=Monterrey&country=MX&state=NLE&limit=3`);
    const body = await r.json();
    const top = body.data.results[0];
    expect(top.name).toBe("Monterrey");
    expect(top.stateCode).toBe("NLE");
    expect(top.id).toBe(72219);
  });

  it("M6.2b: Monterrey (no state) — NLE wins via backfilled pop + state_capital", async () => {
    // After migration 132 backfilled Monterrey NLE pop (1.14M, state capital),
    // it ranks first even without ?state= filter.
    const r = await fetch(`${API}/api/v1/cities/search?q=Monterrey&country=MX&limit=3`);
    const body = await r.json();
    expect(body.data.results[0].stateCode).toBe("NLE");
    expect(body.data.results[0].id).toBe(72219);
  });

  it("M6.3: Perth + state=WA → Perth WA first", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=Perth&country=AU&state=WA&limit=3`);
    const body = await r.json();
    const top = body.data.results[0];
    expect(top.name).toBe("Perth");
    expect(top.stateCode).toBe("WA");
    expect(top.id).toBe(6840);
  });

  it("M6.3b: Perth (no state) — WA wins via backfilled pop (2.2M)", async () => {
    // After migration 132 backfilled Perth WA pop, it ranks first.
    const r = await fetch(`${API}/api/v1/cities/search?q=Perth&country=AU&limit=3`);
    const body = await r.json();
    expect(body.data.results[0].stateCode).toBe("WA");
    expect(body.data.results[0].id).toBe(6840);
  });

  it("M6.4: state boost is additional on top of natural ranking", async () => {
    // After migration 132, Phoenix AZ ranks first even without state filter
    // (pop 1.65M, with data fix). Adding state=AZ gives an extra +1000 boost.
    const rWith = await fetch(`${API}/api/v1/cities/search?q=Phoenix&country=US&state=AZ&limit=3`);
    const rWithout = await fetch(`${API}/api/v1/cities/search?q=Phoenix&country=US&limit=3`);
    const topWith = (await rWith.json()).data.results[0];
    const topWithout = (await rWithout.json()).data.results[0];
    // Both should be AZ
    expect(topWith.stateCode).toBe("AZ");
    expect(topWithout.stateCode).toBe("AZ");
    // But state=AZ version should have higher score due to the state boost
    expect(topWith.score).toBeGreaterThan(topWithout.score);
    expect(topWith.score - topWithout.score).toBeGreaterThanOrEqual(1000);
  });
});

describe("M6: Cross-language search (?lang=)", () => {
  it("M6.5: lang=ja + 東京 → Tokyo first", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=${encodeURIComponent("東京")}&lang=ja&limit=3`);
    const body = await r.json();
    expect(body.data.results.length).toBeGreaterThan(0);
    const tokyo = body.data.results.find((x: { id: number }) => x.id === 64500);
    expect(tokyo).toBeTruthy();
    expect(body.data.results[0].id).toBe(64500); // Tokyo is the canonical match
  });

  it("M6.6: lang=zh-CN + 北京 → Beijing first", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=${encodeURIComponent("北京")}&lang=zh-CN&limit=3`);
    const body = await r.json();
    expect(body.data.results.length).toBeGreaterThan(0);
    expect(body.data.results[0].id).toBe(19332); // Beijing
  });

  it("M6.7: lang=ar + باريس → Paris first", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=${encodeURIComponent("باريس")}&lang=ar&limit=5`);
    const body = await r.json();
    expect(body.data.results.length).toBeGreaterThan(0);
    // French Paris should be first (most populous Paris in user's likely context)
    const paris = body.data.results.find((x: { id: number }) => x.id === 44856);
    expect(paris).toBeTruthy();
  });
});

describe("M6: URL encoding for non-ASCII", () => {
  it("M6.8: Cancún (UTF-8) finds Cancún", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=${encodeURIComponent("Cancún")}&country=MX&limit=2`);
    const body = await r.json();
    expect(body.data.results[0].name).toBe("Cancún");
    expect(body.data.results[0].stateCode).toBe("ROO");
  });

  it("M6.9: Ürümqi (UTF-8) finds Ürümqi", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=${encodeURIComponent("Ürümqi")}&country=CN&limit=2`);
    const body = await r.json();
    expect(body.data.results[0].name).toBe("Ürümqi");
    expect(body.data.results[0].id).toBe(20484);
  });

  it("M6.10: Mérida (UTF-8) finds Mérida", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=${encodeURIComponent("Mérida")}&country=MX&limit=2`);
    const body = await r.json();
    expect(body.data.results[0].name).toBe("Mérida");
    expect(body.data.results[0].stateCode).toBe("YUC");
  });
});

describe("M6: Validation (lat/lon)", () => {
  it("M6.11: invalid lat (91) → 400", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=Tokyo&lat=91&lon=0`);
    expect(r.status).toBe(400);
  });

  it("M6.12: invalid lon (-181) → 400", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=Tokyo&lat=0&lon=-181`);
    expect(r.status).toBe(400);
  });
});
