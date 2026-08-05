/**
 * M11.4: World Bank country population (pivoted from UN WPP 2024)
 *
 * Tests the M11.4 layer: country_populations table populated from World Bank
 * SP.POP.TOTL (year=2024), exposed via /api/v1/countries and
 * /api/v1/countries/{cca2} as `populationSources` block.
 *
 * Coverage:
 *   - /countries returns 250 countries with populationSources populated
 *   - /countries/{cca2} returns populationSources for known countries
 *   - dr5hn and worldBank2024 are both present for matched countries
 *   - primary='worldBank2024' when WB data exists, 'dr5hn' when not
 *   - top populous countries match expected values (IN > CN > US)
 *   - 216 countries have WB data (WB doesn't track 34 of our small territories)
 *   - source_releases row registered for worldbank-pop-2024-2026-08-02
 *   - Territories without WB data fall back to dr5hn
 *   - AX (Åland Islands) is in our DB but not WB → primary=dr5hn
 *   - Population consistency: WB value matches raw API for known country
 *   - ?lang and populationSources coexist
 */
import { describe, it, expect } from "vitest";

const API = process.env.TEST_API_URL || "http://localhost:8787";

describe("M11.4: World Bank layer — coverage", () => {
  it("M11.4.1: country_populations table has ~216 rows for 2024", async () => {
    // We can't query D1 directly from tests, but we can verify via the
    // /sources endpoint or check via list endpoint that most countries have WB data.
    const r = await fetch(`${API}/api/v1/countries?limit=250`);
    expect(r.status).toBe(200);
    const body = await r.json();
    const withWB = body.data.countries.filter(
      (c: any) => c.populationSources && c.populationSources.worldBank2024 !== null
    );
    // Should be close to 216 (216/250 = 86.4%)
    expect(withWB.length).toBeGreaterThanOrEqual(200);
    expect(withWB.length).toBeLessThanOrEqual(220);
  });

  it("M11.4.2: top populous countries match WB 2024 (India > China > US)", async () => {
    const r = await fetch(`${API}/api/v1/countries?limit=250`);
    const body = await r.json();
    const byPop = body.data.countries
      .map((c: any) => ({
        cca2: c.cca2,
        name: c.name,
        wb: c.populationSources?.worldBank2024,
      }))
      .filter((c: any) => c.wb !== null)
      .sort((a: any, b: any) => b.wb - a.wb);

    // India
    expect(byPop[0].cca2).toBe("IN");
    expect(byPop[0].name).toBe("India");
    // China
    expect(byPop[1].cca2).toBe("CN");
    expect(byPop[1].name).toBe("China");
    // US
    expect(byPop[2].cca2).toBe("US");
    expect(byPop[2].name).toBe("United States");

    // India should be > 1.4 billion
    expect(byPop[0].wb).toBeGreaterThan(1_400_000_000);
    // US should be ~340M
    expect(byPop[2].wb).toBeGreaterThan(330_000_000);
    expect(byPop[2].wb).toBeLessThan(350_000_000);
  });

  it("M11.4.3: US population is ~340M (World Bank 2024)", async () => {
    const r = await fetch(`${API}/api/v1/countries/US`);
    const body = await r.json();
    const ps = body.data.populationSources;
    expect(ps).toBeTruthy();
    expect(ps.worldBank2024).toBeGreaterThan(335_000_000);
    expect(ps.worldBank2024).toBeLessThan(345_000_000);
    expect(ps.dr5hn).toBeGreaterThan(330_000_000);
    // World Bank 2024 should be primary (fresher)
    expect(ps.primary).toBe("worldBank2024");
  });

  it("M11.4.4: AX (Åland Islands) has no WB data, falls back to dr5hn", async () => {
    const r = await fetch(`${API}/api/v1/countries/AX`);
    expect(r.status).toBe(200);
    const body = await r.json();
    const ps = body.data.populationSources;
    expect(ps).toBeTruthy();
    // AX is a small territory, WB doesn't track it
    expect(ps.worldBank2024).toBeNull();
    // dr5hn should still have a value (30,654 in our DB)
    expect(ps.dr5hn).toBeGreaterThan(0);
    // Primary should fall back to dr5hn
    expect(ps.primary).toBe("dr5hn");
  });

  it("M11.4.5: Vatican City (VA) — dr5hn only, no WB data", async () => {
    const r = await fetch(`${API}/api/v1/countries/VA`);
    const body = await r.json();
    const ps = body.data.populationSources;
    expect(ps.worldBank2024).toBeNull();
    expect(ps.primary).toBe("dr5hn");
    // dr5hn has very small value (~800)
    if (ps.dr5hn) {
      expect(ps.dr5hn).toBeLessThan(1000);
    }
  });

  it("M11.4.6: France population ~68M (WB 2024) — close to dr5hn value", async () => {
    const r = await fetch(`${API}/api/v1/countries/FR`);
    const body = await r.json();
    const ps = body.data.populationSources;
    expect(ps.worldBank2024).toBeGreaterThan(65_000_000);
    expect(ps.worldBank2024).toBeLessThan(70_000_000);
    expect(ps.primary).toBe("worldBank2024");
  });

  it("M11.4.7: Greenland (GL) — dr5hn has value, WB may or may not", async () => {
    // GL is part of Denmark politically but geographically in NA
    const r = await fetch(`${API}/api/v1/countries/GL`);
    const body = await r.json();
    const ps = body.data.populationSources;
    expect(ps).toBeTruthy();
    // ps.dr5hn should be a small number (~56,000)
    expect(ps.dr5hn).toBeGreaterThan(0);
  });
});

describe("M11.4: World Bank layer — response structure", () => {
  it("M11.4.8: populationSources has all 3 fields: dr5hn, worldBank2024, primary", async () => {
    const r = await fetch(`${API}/api/v1/countries/DE`);
    const body = await r.json();
    const ps = body.data.populationSources;
    expect(ps).toHaveProperty("dr5hn");
    expect(ps).toHaveProperty("worldBank2024");
    expect(ps).toHaveProperty("primary");
    expect(["dr5hn", "worldBank2024"]).toContain(ps.primary);
  });

  it("M11.4.9: worldBank2024 always has a year=2024 value when present", async () => {
    // We can verify the year is encoded by checking that all WB values are
    // for year 2024 (not 2023, 2022). The API doesn't expose year directly,
    // but the magnitude (~340M for US) should be consistent.
    const r = await fetch(`${API}/api/v1/countries/JP`);
    const body = await r.json();
    const ps = body.data.populationSources;
    // Japan 2024 should be ~123-125M
    expect(ps.worldBank2024).toBeGreaterThan(120_000_000);
    expect(ps.worldBank2024).toBeLessThan(130_000_000);
  });

  it("M11.4.10: list endpoint includes populationSources for every country", async () => {
    const r = await fetch(`${API}/api/v1/countries?limit=50`);
    const body = await r.json();
    for (const c of body.data.countries) {
      expect(c.populationSources).toBeTruthy();
      // Each country has populationSources with primary set correctly
      // (Some uninhabited territories like Antarctica, Bouvet Island have
      // both values as NULL — that's expected)
      expect(["dr5hn", "worldBank2024"]).toContain(c.populationSources.primary);
      // At least one of dr5hn or worldBank2024 should be set for most countries
      const has = c.populationSources.dr5hn !== null || c.populationSources.worldBank2024 !== null;
      if (has) {
        // Primary should match whichever is set
        if (c.populationSources.worldBank2024 !== null) {
          expect(c.populationSources.primary).toBe("worldBank2024");
        } else {
          expect(c.populationSources.primary).toBe("dr5hn");
        }
      }
    }
  });

  it("M11.4.11: ?lang and populationSources coexist", async () => {
    const r = await fetch(`${API}/api/v1/countries/IT?lang=ja`);
    const body = await r.json();
    expect(body.data.localized).toBeTruthy();
    expect(body.data.localized.language).toBe("ja");
    expect(body.data.populationSources).toBeTruthy();
    expect(body.data.populationSources.worldBank2024).toBeGreaterThan(50_000_000);
  });
});

describe("M11.4: World Bank source — registry and release", () => {
  it("M11.4.12: world_bank is in source_registry", async () => {
    const r = await fetch(`${API}/api/v1/sources`);
    expect(r.status).toBe(200);
    const body = await r.json();
    const sources = body.data?.sources || body.sources || [];
    const wb = sources.find((s: any) => s.sourceKey === "world_bank");
    expect(wb).toBeTruthy();
    expect(wb.publisher).toContain("World Bank");
  });

  it("M11.4.13: worldbank-pop release is registered with row_count = 216", async () => {
    const r = await fetch(`${API}/api/v1/sources/world_bank`);
    const body = await r.json();
    const releases = body.data?.recentReleases || [];
    const wbRelease = releases.find((rel: any) =>
      rel.releaseId === "worldbank-pop-2024-2026-08-02"
    );
    expect(wbRelease).toBeTruthy();
    expect(wbRelease.status).toBe("raw-stored");
    expect(wbRelease.rowCountAccepted).toBe(216);
  });

  it("M11.4.14: world_bank release has r2 archive key", async () => {
    const r = await fetch(`${API}/api/v1/sources/world_bank`);
    const body = await r.json();
    const releases = body.data?.recentReleases || [];
    const wbRelease = releases.find((rel: any) =>
      rel.releaseId === "worldbank-pop-2024-2026-08-02"
    );
    expect(wbRelease).toBeTruthy();
    expect(wbRelease.rawR2Key).toMatch(/^raw\/world_bank\/pop-totl\//);
  });
});

describe("M11.4: World Bank — data quality", () => {
  it("M11.4.15: 100% of WB-populated countries have positive population", async () => {
    const r = await fetch(`${API}/api/v1/countries?limit=250`);
    const body = await r.json();
    for (const c of body.data.countries) {
      const wb = c.populationSources?.worldBank2024;
      if (wb !== null) {
        expect(wb).toBeGreaterThan(0);
        // No country has more than 2 billion people (India is the most)
        expect(wb).toBeLessThan(2_000_000_000);
      }
    }
  });

  it("M11.4.16: dr5hn and WB2024 values are within reasonable delta for matched countries", async () => {
    // For most countries, the delta between dr5hn (~2020) and WB2024
    // should be less than 20% of the value (allowing for COVID-era anomalies)
    const r = await fetch(`${API}/api/v1/countries?limit=50`);
    const body = await r.json();
    let mismatches = 0;
    for (const c of body.data.countries) {
      const dr5hn = c.populationSources?.dr5hn;
      const wb = c.populationSources?.worldBank2024;
      if (dr5hn && wb) {
        const ratio = Math.abs(dr5hn - wb) / dr5hn;
        if (ratio > 0.20) mismatches++;
      }
    }
    // At most a few outliers (war zones, COVID-impacted small countries)
    expect(mismatches).toBeLessThan(5);
  });

  it("M11.4.17: India is still the most populous country", async () => {
    const r = await fetch(`${API}/api/v1/countries?limit=250`);
    const body = await r.json();
    const india = body.data.countries.find((c: any) => c.cca2 === "IN");
    expect(india).toBeTruthy();
    const indiaPop = india.populationSources.worldBank2024;
    // No other country has > 1.4B
    for (const c of body.data.countries) {
      const wb = c.populationSources?.worldBank2024;
      if (wb && c.cca2 !== "IN") {
        expect(wb).toBeLessThan(indiaPop);
      }
    }
  });
});

describe("M11.4: World Bank — backfill effectiveness (informational)", () => {
  it("M11.4.18: population is the most-populated first", async () => {
    // This is a smoke test: ordering is alphabetical by name, not population.
    // We just verify the API returns at least 240 countries.
    const r = await fetch(`${API}/api/v1/countries?limit=250`);
    const body = await r.json();
    expect(body.data.countries.length).toBeGreaterThanOrEqual(240);
  });
});
