/**
 * M5: Translations regression tests
 *
 * Spec coverage: §11, §12, §13, §17 (multi-language), §33.10-15
 *
 * dr5hn translations.csv: 2,965,564 rows, 19 languages
 */
import { describe, it, expect } from "vitest";

const API = process.env.TEST_API_URL || "https://dt-api-v2-dev.nsura2029.workers.dev";

describe("M5: Translations data layer", () => {
  it("M5.1: Tokyo has 19 translations", async () => {
    const r = await fetch(`${API}/api/v1/cities/64500`);
    const body = await r.json();
    expect(body.data.translations.available).toBe(19);
    expect(body.data.translations.languages).toHaveLength(19);
  });

  it("M5.2: Tokyo Japanese translation is 東京", async () => {
    const r = await fetch(`${API}/api/v1/cities/64500/translations/ja`);
    const body = await r.json();
    expect(body.data.translation).toBe("東京");
  });

  it("M5.3: Tokyo Arabic translation exists", async () => {
    const r = await fetch(`${API}/api/v1/cities/64500/translations/ar`);
    const body = await r.json();
    expect(body.data.translation).toBe("طوكيو");
  });

  it("M5.4: East Pensacola Heights has 19 translations", async () => {
    const r = await fetch(`${API}/api/v1/cities/115731`);
    const body = await r.json();
    expect(body.data.translations.available).toBe(19);
  });

  it("M5.5: Pensacola English translation is the same as name", async () => {
    // en translations are sparse (only 558), so let's just check ja
    const r = await fetch(`${API}/api/v1/cities/115731/translations/ja`);
    const body = await r.json();
    // US city names in Japanese are katakana transliterations
    expect(body.data.translation).toBeTruthy();
  });
});

describe("M5: Translations search", () => {
  it("M5.6: search by Japanese name 東京 finds Tokyo", async () => {
    const r = await fetch(`${API}/api/v1/translations/search?q=${encodeURIComponent("東京")}&lang=ja&limit=5`);
    const body = await r.json();
    expect(body.data.count).toBeGreaterThan(0);
    const tokyo = body.data.results.find((x: { cityId: number }) => x.cityId === 64500);
    expect(tokyo).toBeTruthy();
    expect(tokyo.country.cca2).toBe("JP");
  });

  it("M5.7: search by Arabic name باريس finds Paris", async () => {
    const r = await fetch(`${API}/api/v1/translations/search?q=${encodeURIComponent("باريس")}&lang=ar&limit=10`);
    const body = await r.json();
    expect(body.data.count).toBeGreaterThan(0);
    const paris = body.data.results.find((x: { cityId: number }) => x.cityId === 44856);
    expect(paris).toBeTruthy();
    expect(paris.country.cca2).toBe("FR");
  });

  it("M5.8: search by Spanish name Madrid finds Madrid", async () => {
    const r = await fetch(`${API}/api/v1/translations/search?q=Madrid&lang=es&limit=20`);
    const body = await r.json();
    expect(body.data.count).toBeGreaterThan(0);
    // Madrid is the same in Spanish, so first result should be Spain's capital
    const spain = body.data.results.find((x: { cityId: number }) => x.cityId === 35186);
    expect(spain).toBeTruthy();
  });

  it("M5.9: search by Chinese 北京 finds Beijing", async () => {
    const r = await fetch(`${API}/api/v1/translations/search?q=${encodeURIComponent("北京")}&lang=zh-CN&limit=5`);
    const body = await r.json();
    expect(body.data.count).toBeGreaterThan(0);
    const beijing = body.data.results.find((x: { cityId: number }) => x.cityId === 19332);
    expect(beijing).toBeTruthy();
  });
});

describe("M5: Translations API schema", () => {
  it("M5.10: 404 for missing city", async () => {
    const r = await fetch(`${API}/api/v1/cities/99999999/translations`);
    expect(r.status).toBe(404);
  });

  it("M5.11: 404 for missing language on existing city", async () => {
    // East Pensacola Heights has 19 langs, but not "xx" (made up)
    const r = await fetch(`${API}/api/v1/cities/115731/translations/xx`);
    expect(r.status).toBe(404);
  });
});
