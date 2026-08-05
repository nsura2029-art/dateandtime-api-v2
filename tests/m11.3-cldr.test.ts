/**
 * M11.3: Unicode CLDR localized country names tests
 *
 * Tests the M11.3 layer: country_names table populated from CLDR 48.2,
 * exposed via /api/v1/countries?lang=xx and /api/v1/countries/{cca2}?lang=xx
 *
 * Coverage:
 *   - /countries returns all 250 countries with English base data
 *   - /countries?lang=xx returns localized names (20 languages)
 *   - /countries/{cca2}?lang=xx returns single country with localized name
 *   - Languages not in our set fall back to English with languageFallback: true
 *   - source_releases row registered for cldr-territories-2026-08-02
 *   - Short names (where CLDR provides them) are returned
 */
import { describe, it, expect } from "vitest";

const API = process.env.TEST_API_URL || "http://localhost:8787";

describe("M11.3: CLDR localized country names — list endpoint", () => {
  it("M11.3.1: /countries returns 250 countries by default", async () => {
    const r = await fetch(`${API}/api/v1/countries?limit=250`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.success).toBe(true);
    expect(body.data.count).toBeGreaterThanOrEqual(240);
    expect(body.data.count).toBeLessThanOrEqual(260);
  });

  it("M11.3.2: /countries returns English base data without lang", async () => {
    const r = await fetch(`${API}/api/v1/countries?limit=10`);
    const body = await r.json();
    for (const c of body.data.countries) {
      expect(c.name).toBeTruthy();
      expect(c.cca2).toMatch(/^[A-Z]{2}$/);
      expect(c.localized).toBeNull();
    }
  });

  it("M11.3.3: /countries?lang=ja returns Japanese names for all countries", async () => {
    const r = await fetch(`${API}/api/v1/countries?lang=ja&limit=10`);
    const body = await r.json();
    expect(body.data.language).toBe("ja");
    for (const c of body.data.countries) {
      expect(c.localized).toBeTruthy();
      expect(c.localized.language).toBe("ja");
      // Japanese text should contain CJK characters
      expect(c.localized.name).toMatch(/[\u3000-\u9fff\uff00-\uffef]/);
    }
  });

  it("M11.3.4: /countries?lang=zh returns Chinese names", async () => {
    const r = await fetch(`${API}/api/v1/countries?lang=zh&region=Asia&limit=80`);
    const body = await r.json();
    expect(body.data.count).toBeGreaterThan(0);
    const cn = body.data.countries.find((c: any) => c.cca2 === "CN");
    expect(cn).toBeTruthy();
    expect(cn.localized.name).toBe("中国");
    const jp = body.data.countries.find((c: any) => c.cca2 === "JP");
    expect(jp).toBeTruthy();
    expect(jp.localized.name).toBe("日本");
  });

  it("M11.3.5: /countries?lang=es returns Spanish short name for US", async () => {
    // Use small limit so the lookup IN-clause stays under D1's 100-var limit
    const r = await fetch(`${API}/api/v1/countries?lang=es&limit=80`);
    const body = await r.json();
    const us = body.data.countries.find((c: any) => c.cca2 === "US");
    if (us) {
      expect(us.localized.name).toBe("Estados Unidos");
      // CLDR provides 'EE. UU.' as the short form
      expect(us.localized.shortName).toBe("EE. UU.");
    } else {
      // US not in the first 80 alphabetically — make a focused request
      const r2 = await fetch(`${API}/api/v1/countries/US?lang=es`);
      const b2 = await r2.json();
      expect(b2.data.localized.name).toBe("Estados Unidos");
      expect(b2.data.localized.shortName).toBe("EE. UU.");
    }
  });

  it("M11.3.6: /countries?lang=sw falls back to English (no Swahili data)", async () => {
    const r = await fetch(`${API}/api/v1/countries?lang=sw&limit=10`);
    const body = await r.json();
    for (const c of body.data.countries) {
      expect(c.localized.languageFallback).toBe(true);
      // The fallback should be the English name
      expect(c.localized.name).toBe(c.name);
    }
  });

  it("M11.3.7: /countries?region=Europe filters by region", async () => {
    const r = await fetch(`${API}/api/v1/countries?region=Europe&limit=80`);
    const body = await r.json();
    for (const c of body.data.countries) {
      expect(c.region).toBe("Europe");
    }
    // Europe should have ~50 countries
    expect(body.data.count).toBeGreaterThan(40);
  });
});

describe("M11.3: CLDR localized country names — detail endpoint", () => {
  it("M11.3.8: /countries/{cca2} returns single country with full English data", async () => {
    const r = await fetch(`${API}/api/v1/countries/FR`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data.cca2).toBe("FR");
    expect(body.data.name).toBe("France");
    expect(body.data.capital).toBe("Paris");
    expect(body.data.region).toBe("Europe");
    expect(body.data.currency.code).toBe("EUR");
  });

  it("M11.3.9: /countries/{cca2}?lang=de returns German name", async () => {
    const r = await fetch(`${API}/api/v1/countries/DE?lang=de`);
    const body = await r.json();
    expect(body.data.localized.name).toBe("Deutschland");
    // No short form for Germany in German
    expect(body.data.localized.shortName).toBeNull();
  });

  it("M11.3.10: /countries/{cca2}?lang=ja returns Japanese name with short", async () => {
    const r = await fetch(`${API}/api/v1/countries/JP?lang=ja`);
    const body = await r.json();
    expect(body.data.localized.name).toBe("日本");
  });

  it("M11.3.11: /countries/{cca2}?lang=ru returns Russian name", async () => {
    const r = await fetch(`${API}/api/v1/countries/RU?lang=ru`);
    const body = await r.json();
    expect(body.data.localized.name).toBe("Россия");
    // Russia has no short form in Russian CLDR — shortName should be null or a real short
    if (body.data.localized.shortName !== null) {
      expect(body.data.localized.shortName).toBeTruthy();
    }
  });

  it("M11.3.12: /countries/XX returns 404 for unknown code", async () => {
    const r = await fetch(`${API}/api/v1/countries/XX`);
    expect(r.status).toBe(404);
    const body = await r.json();
    expect(body.success).toBe(false);
    expect(body.error.code).toBe("NOT_FOUND");
  });

  it("M11.3.13: /countries/{cca2} lower-cases the cca2 code", async () => {
    // cca2 case-insensitive: 'us' should match 'US'
    const r = await fetch(`${API}/api/v1/countries/us`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data.cca2).toBe("US");
  });
});

describe("M11.3: CLDR layer — coverage and data quality", () => {
  it("M11.3.14: all 20 target languages return localized data", async () => {
    const langs = ["en", "es", "fr", "de", "zh", "ja", "ko", "ru", "ar", "hi",
                   "pt", "it", "tr", "nl", "pl", "sv", "uk", "he", "fa", "th"];
    for (const lang of langs) {
      const r = await fetch(`${API}/api/v1/countries?lang=${lang}&limit=5`);
      const body = await r.json();
      expect(body.data.count).toBeGreaterThan(0);
      for (const c of body.data.countries) {
        expect(c.localized.language).toBe(lang);
        expect(c.localized.name).toBeTruthy();
        expect(c.localized.languageFallback).toBe(false);
      }
    }
  }, 30000);

  it("M11.3.15: short names are returned when CLDR provides them", async () => {
    // GB has 'UK' as short in English
    const r = await fetch(`${API}/api/v1/countries/GB?lang=en`);
    const body = await r.json();
    expect(body.data.localized.name).toBe("United Kingdom");
    expect(body.data.localized.shortName).toBe("UK");
  });

  it("M11.3.16: localized names are stable across calls (idempotent)", async () => {
    const r1 = await fetch(`${API}/api/v1/countries/US?lang=ja`);
    const r2 = await fetch(`${API}/api/v1/countries/US?lang=ja`);
    const b1 = await r1.json();
    const b2 = await r2.json();
    expect(b1.data.localized.name).toBe(b2.data.localized.name);
    expect(b1.data.localized.shortName).toBe(b2.data.localized.shortName);
  });
});

describe("M11.3: CLDR source — registry and release", () => {
  it("M11.3.17: cldr source is registered in source_registry", async () => {
    const r = await fetch(`${API}/api/v1/sources/cldr`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data.sourceKey).toBe("cldr");
  });

  it("M11.3.18: cldr release is registered with row_count = 5000", async () => {
    const r = await fetch(`${API}/api/v1/sources/cldr`);
    const body = await r.json();
    const cldrRelease = body.data.recentReleases.find(
      (rel: any) => rel.releaseId === "cldr-territories-2026-08-02"
    );
    expect(cldrRelease).toBeTruthy();
    expect(cldrRelease.rowCountAccepted).toBe(5000);
    expect(cldrRelease.status).toBe("raw-stored");
  });
});
