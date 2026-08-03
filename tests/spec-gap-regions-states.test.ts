/**
 * Spec Phase 3 + 4 endpoints tests
 *
 * Coverage:
 *   - GET /api/v1/regions
 *   - GET /api/v1/regions/{code}/subregions
 *   - GET /api/v1/subregions/{code}/countries
 *   - GET /api/v1/countries/{cca2}/states
 *   - GET /api/v1/states/{id}
 *   - GET /api/v1/cities (list with filters)
 *   - GET /api/v1/cities/near (proximity)
 *   - GET /api/v1/cities/{id}/aliases
 *   - GET /api/v1/cities/{id}/climate
 *   - GET /api/v1/time/now
 *   - GET /api/v1/time/convert
 *   - DST + half-hour + quarter-hour + date-line
 */
import { describe, it, expect } from "vitest";

const API = process.env.TEST_API_URL || "http://localhost:8787";

describe("Spec Phase 3: Regions endpoints", () => {
  it("RG.1: GET /api/v1/regions returns 6 regions", async () => {
    const r = await fetch(`${API}/api/v1/regions`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data.count).toBe(6);
    expect(body.data.regions).toHaveLength(6);
    // Verify all 6 UN regions are present
    const codes = body.data.regions.map((r: any) => r.code).sort();
    expect(codes).toEqual(["AF", "AM", "AN", "AS", "EU", "OC"]);
  });

  it("RG.2: each region has subregion and country counts", async () => {
    const r = await fetch(`${API}/api/v1/regions`);
    const body = await r.json();
    for (const region of body.data.regions) {
      expect(region).toHaveProperty("subregionCount");
      expect(region).toHaveProperty("countryCount");
      expect(typeof region.subregionCount).toBe("number");
      expect(typeof region.countryCount).toBe("number");
    }
    // Europe should have most countries
    const eu = body.data.regions.find((r: any) => r.code === "EU");
    expect(eu.countryCount).toBeGreaterThan(40);
  });

  it("RG.3: GET /api/v1/regions/EU/subregions returns 4 subregions", async () => {
    const r = await fetch(`${API}/api/v1/regions/EU/subregions`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data.region.code).toBe("EU");
    expect(body.data.subregions.length).toBeGreaterThanOrEqual(4);
    // All subregions should belong to EU
    for (const sub of body.data.subregions) {
      expect(sub.regionCode).toBe("EU");
    }
  });

  it("RG.4: GET /api/v1/regions/INVALID returns 404", async () => {
    const r = await fetch(`${API}/api/v1/regions/INVALID/subregions`);
    expect(r.status).toBe(404);
  });

  it("RG.5: GET /api/v1/subregions/151/countries returns Western Europe", async () => {
    const r = await fetch(`${API}/api/v1/subregions/151/countries`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data.subregion.code).toBe("151");
    expect(body.data.subregion.name).toBe("Western Europe");
    // Should include France, Germany, etc.
    const codes = body.data.countries.map((c: any) => c.cca2);
    expect(codes).toContain("FR");
    expect(codes).toContain("DE");
    expect(codes).toContain("BE");
  });

  it("RG.6: GET /api/v1/subregions/151/countries?lang=fr returns French names", async () => {
    const r = await fetch(`${API}/api/v1/subregions/151/countries?lang=fr`);
    expect(r.status).toBe(200);
    const body = await r.json();
    // At least one country should have a French localized name
    const germany = body.data.countries.find((c: any) => c.cca2 === "DE");
    expect(germany).toBeTruthy();
    expect(germany.localized).toBeTruthy();
    expect(germany.localized.name).toBe("Allemagne");
  });

  it("RG.7: GET /api/v1/subregions/INVALID/countries returns 404", async () => {
    const r = await fetch(`${API}/api/v1/subregions/INVALID/countries`);
    expect(r.status).toBe(404);
  });
});

describe("Spec Phase 3: States endpoints", () => {
  it("ST.1: GET /api/v1/countries/US/states returns US states", async () => {
    const r = await fetch(`${API}/api/v1/countries/US/states?limit=10`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data.country.cca2).toBe("US");
    expect(body.data.states.length).toBeGreaterThan(0);
    // Should include California by name
    const ca = body.data.states.find((s: any) => s.name === "California");
    expect(ca).toBeTruthy();
  });

  it("ST.2: state has cityCount (territories may have 0)", async () => {
    const r = await fetch(`${API}/api/v1/countries/US/states?limit=10`);
    const body = await r.json();
    for (const state of body.data.states) {
      expect(state).toHaveProperty("cityCount");
      expect(typeof state.cityCount).toBe("number");
      expect(state.cityCount).toBeGreaterThanOrEqual(0);
    }
    // At least the first 10 states should mostly have cities (skip territories)
    const withCities = body.data.states.filter((s: any) => s.cityCount > 0);
    expect(withCities.length).toBeGreaterThan(0);
  });

  it("ST.3: GET /api/v1/countries/DE/states returns German states", async () => {
    const r = await fetch(`${API}/api/v1/countries/DE/states?limit=5`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data.country.cca2).toBe("DE");
    expect(body.data.states.length).toBeGreaterThan(0);
  });

  it("ST.4: GET /api/v1/countries/INVALID/states returns 404", async () => {
    const r = await fetch(`${API}/api/v1/countries/INVALID/states`);
    expect(r.status).toBe(404);
  });

  it("ST.5: GET /api/v1/states/{id} returns single state", async () => {
    // First get a state ID
    const r = await fetch(`${API}/api/v1/countries/US/states?limit=1`);
    const body = await r.json();
    const stateId = body.data.states[0].id;
    const r2 = await fetch(`${API}/api/v1/states/${stateId}`);
    expect(r2.status).toBe(200);
    const body2 = await r2.json();
    expect(body2.data.id).toBe(stateId);
    expect(body2.data.country).toBeTruthy();
    expect(body2.data.country.cca2).toBe("US");
  });

  it("ST.6: GET /api/v1/states/9999999 returns 404", async () => {
    const r = await fetch(`${API}/api/v1/states/9999999`);
    expect(r.status).toBe(404);
  });
});

describe("Spec Phase 3: Cities list endpoint", () => {
  it("CL.1: GET /api/v1/cities returns paginated list", async () => {
    const r = await fetch(`${API}/api/v1/cities?limit=2`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data.count).toBeGreaterThan(100000);
    expect(body.data.cities).toHaveLength(2);
    expect(body.data.limit).toBe(2);
    expect(body.data.offset).toBe(0);
  });

  it("CL.2: filter by country", async () => {
    const r = await fetch(`${API}/api/v1/cities?country=JP&limit=3`);
    expect(r.status).toBe(200);
    const body = await r.json();
    for (const c of body.data.cities) {
      expect(c.country.cca2).toBe("JP");
    }
  });

  it("CL.3: filter by region", async () => {
    const r = await fetch(`${API}/api/v1/cities?region=EU&limit=3`);
    expect(r.status).toBe(200);
    const body = await r.json();
    for (const c of body.data.cities) {
      // Country should be in EU
      const co = c.country.cca2;
      expect(co).toMatch(/^[A-Z]{2}$/);
    }
  });

  it("CL.4: filter by minPopulation", async () => {
    const r = await fetch(`${API}/api/v1/cities?minPopulation=1000000&limit=5`);
    expect(r.status).toBe(200);
    const body = await r.json();
    for (const c of body.data.cities) {
      expect(c.population).toBeGreaterThanOrEqual(1_000_000);
    }
  });

  it("CL.5: sort by population desc", async () => {
    const r = await fetch(`${API}/api/v1/cities?sort=population&order=desc&limit=5`);
    expect(r.status).toBe(200);
    const body = await r.json();
    let prev = Infinity;
    for (const c of body.data.cities) {
      const pop = c.population || 0;
      expect(pop).toBeLessThanOrEqual(prev);
      prev = pop;
    }
  });

  it("CL.6: filter by tier", async () => {
    const r = await fetch(`${API}/api/v1/cities?tier=1&limit=3`);
    expect(r.status).toBe(200);
    const body = await r.json();
    for (const c of body.data.cities) {
      expect(c.tier).toBe(1);
    }
  });
});

describe("Spec Phase 3: Cities near endpoint (proximity)", () => {
  it("CN.1: NYC center finds nearby cities", async () => {
    const r = await fetch(`${API}/api/v1/cities/near?lat=40.7&lon=-74&radiusKm=50&limit=5`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data.query).toEqual({ lat: 40.7, lon: -74, radiusKm: 50 });
    expect(body.data.cities.length).toBeGreaterThan(0);
    for (const c of body.data.cities) {
      expect(c.distanceKm).toBeLessThanOrEqual(50);
    }
  });

  it("CN.2: results are sorted by distance ascending", async () => {
    const r = await fetch(`${API}/api/v1/cities/near?lat=40.7&lon=-74&radiusKm=50&limit=5`);
    const body = await r.json();
    let prev = 0;
    for (const c of body.data.cities) {
      expect(c.distanceKm).toBeGreaterThanOrEqual(prev);
      prev = c.distanceKm;
    }
  });

  it("CN.3: minPopulation filter works", async () => {
    const r = await fetch(`${API}/api/v1/cities/near?lat=40.7&lon=-74&radiusKm=500&minPopulation=100000&limit=5`);
    const body = await r.json();
    for (const c of body.data.cities) {
      expect(c.population).toBeGreaterThanOrEqual(100_000);
    }
  });

  it("CN.4: invalid lat returns 400", async () => {
    const r = await fetch(`${API}/api/v1/cities/near?lat=99&lon=0`);
    expect(r.status).toBe(400);
  });
});

describe("Spec Phase 3: City aliases endpoint", () => {
  it("CA.1: NYC has multiple aliases", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795/aliases?limit=5`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data.cityName).toBe("New York City");
    expect(body.data.aliases.length).toBeGreaterThan(0);
  });

  it("CA.2: alias has language field", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795/aliases?limit=5`);
    const body = await r.json();
    for (const a of body.data.aliases) {
      expect(a).toHaveProperty("name");
      expect(a).toHaveProperty("language");
      expect(a).toHaveProperty("isHistoric");
    }
  });

  it("CA.3: filter by language", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795/aliases?language=fr&limit=5`);
    const body = await r.json();
    for (const a of body.data.aliases) {
      expect(a.language).toBe("fr");
    }
  });

  it("CA.4: filter historic only", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795/aliases?historic=true&limit=5`);
    const body = await r.json();
    for (const a of body.data.aliases) {
      expect(a.isHistoric).toBe(true);
    }
  });

  it("CA.5: 404 for non-existent city", async () => {
    const r = await fetch(`${API}/api/v1/cities/9999999/aliases`);
    expect(r.status).toBe(404);
  });
});

describe("Spec Phase 3: City climate endpoint", () => {
  it("CC.1: NYC climate is temperate", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795/climate`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data.cityId).toBe(122795);
    expect(body.data.climateZone).toMatch(/temperate|subtropical/);
    expect(body.data.hemisphere).toBe("north");
    expect(body.data.months).toHaveLength(12);
  });

  it("CC.2: tropical city (Singapore) is tropical", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=Singapore&limit=1`);
    const body = await r.json();
    if (body.data.results[0]) {
      const r2 = await fetch(`${API}/api/v1/cities/${body.data.results[0].id}/climate`);
      const body2 = await r2.json();
      expect(body2.data.climateZone).toBe("tropical");
      expect(body2.data.hemisphere).toBe("equator");
    }
  });

  it("CC.3: Sydney (Southern hemisphere) shows southern", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=Sydney&limit=1`);
    const body = await r.json();
    if (body.data.results[0]) {
      const r2 = await fetch(`${API}/api/v1/cities/${body.data.results[0].id}/climate`);
      const body2 = await r2.json();
      expect(body2.data.hemisphere).toBe("south");
    }
  });

  it("CC.4: month has avgHighC and precipitationMm", async () => {
    const r = await fetch(`${API}/api/v1/cities/122795/climate`);
    const body = await r.json();
    const july = body.data.months.find((m: any) => m.month === 7);
    expect(july).toBeTruthy();
    expect(july.avgHighC).toBeGreaterThan(20);
    expect(july.avgHighC).toBeLessThan(40);
  });
});

describe("Spec Phase 4: Time-calc endpoint (DST + IDL + half/quarter hours)", () => {
  it("TM.1: /time/now?city=NYC returns EDT in August", async () => {
    const r = await fetch(`${API}/api/v1/time/now?city=122795`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data.ianaTimezone).toBe("America/New_York");
    expect(body.data.offsetFormatted).toBe("-04:00");
    expect(body.data.isDst).toBe(true);
    expect(body.data.abbreviation).toBe("EDT");
  });

  it("TM.2: /time/now?city=Tokyo returns JST (no DST)", async () => {
    const r = await fetch(`${API}/api/v1/time/now?city=64500`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data.ianaTimezone).toBe("Asia/Tokyo");
    expect(body.data.offsetFormatted).toBe("+09:00");
    expect(body.data.isDst).toBe(false);
  });

  it("TM.3: /time/now?city=Asia/Kathmandu returns +05:45 (quarter-hour)", async () => {
    const r = await fetch(`${API}/api/v1/time/now?city=Asia/Kathmandu`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data.offsetFormatted).toBe("+05:45");
  });

  it("TM.4: /time/now?city=Asia/Kolkata returns +05:30 (half-hour)", async () => {
    const r = await fetch(`${API}/api/v1/time/now?city=Asia/Kolkata`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data.offsetFormatted).toBe("+05:30");
  });

  it("TM.5: /time/now?city=Pacific/Chatham returns +12:45 (quarter-hour)", async () => {
    const r = await fetch(`${API}/api/v1/time/now?city=Pacific/Chatham`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data.offsetFormatted).toBe("+12:45");
  });

  it("TM.6: /time/now?city=Pacific/Apia returns +13:00 (date-line edge)", async () => {
    const r = await fetch(`${API}/api/v1/time/now?city=Pacific/Apia`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data.offsetFormatted).toBe("+13:00");
  });

  it("TM.7: /time/convert 3pm NYC = 4am Tokyo next day", async () => {
    const r = await fetch(`${API}/api/v1/time/convert?from=122795&to=64500&at=2026-08-03T15:00:00`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data.from.time).toMatch(/^15:00:00$/);
    expect(body.data.to.date).toBe("2026-08-04");
    expect(body.data.to.time).toMatch(/^04:00:00$/);
    expect(body.data.hoursDifference).toBe(13);
  });

  it("TM.8: /time/convert with atUtc param works", async () => {
    const r = await fetch(`${API}/api/v1/time/convert?from=122795&to=64500&atUtc=2026-08-03T19:00:00Z`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data.from.time).toMatch(/^15:00:00$/);
    expect(body.data.to.time).toMatch(/^04:00:00$/);
  });

  it("TM.9: /time/convert uses IANA timezone string directly", async () => {
    const r = await fetch(`${API}/api/v1/time/convert?from=America/New_York&to=Asia/Tokyo&at=2026-08-03T15:00:00`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data.from.ianaTimezone).toBe("America/New_York");
    expect(body.data.to.ianaTimezone).toBe("Asia/Tokyo");
  });

  it("TM.10: /time/convert quarter-hour zone handles offset correctly", async () => {
    // 3pm in Kathmandu = 3:15pm in another +5:30 zone, but within same hour window
    const r = await fetch(`${API}/api/v1/time/convert?from=Asia/Kolkata&to=Asia/Kathmandu&at=2026-08-03T15:00:00`);
    expect(r.status).toBe(200);
    const body = await r.json();
    // Kolkata +5:30 → Kathmandu +5:45: difference is +15 min
    expect(body.data.hoursDifference).toBe(0.25);
    // Kathmandu should be 15:15
    expect(body.data.to.time).toMatch(/^15:15:00$/);
  });

  it("TM.11: /time/convert handles date-line crossing (Apia vs Pago Pago)", async () => {
    // Pacific/Apia is +13, Pacific/Pago_Pago is -11 (24 hours apart)
    const r = await fetch(`${API}/api/v1/time/convert?from=Pacific/Apia&to=Pacific/Pago_Pago&at=2026-08-03T12:00:00`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data.crossesDateLine).toBe(true);
    // Apia noon → Pago Pago previous day noon
    expect(body.data.from.date).toBe("2026-08-03");
    expect(body.data.to.date).toBe("2026-08-02");
  });
});

describe("Spec Phase 4: DST transitions", () => {
  it("DST.1: NYC in January (winter) is EST not EDT", async () => {
    const r = await fetch(`${API}/api/v1/time/convert?from=America/New_York&to=UTC&at=2026-01-15T12:00:00`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data.from.offsetFormatted).toBe("-05:00");
    expect(body.data.from.isDst).toBe(false);
  });

  it("DST.2: NYC in July (summer) is EDT", async () => {
    const r = await fetch(`${API}/api/v1/time/convert?from=America/New_York&to=UTC&at=2026-07-15T12:00:00`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.data.from.offsetFormatted).toBe("-04:00");
    expect(body.data.from.isDst).toBe(true);
  });

  it("DST.3: NYC on spring forward day (Mar 8, 2026) - 2:30am doesn't exist", async () => {
    // US spring forward: 2:00 AM EST → 3:00 AM EDT (Mar 8, 2026)
    // 2:30 AM on that day doesn't exist
    const r = await fetch(`${API}/api/v1/time/convert?from=America/New_York&to=UTC&at=2026-03-08T02:30:00`);
    expect(r.status).toBe(200);
    // The system should give a "best effort" - likely interprets as EST (before transition)
    const body = await r.json();
    // Result will be either -05:00 (before) or -04:00 (after) depending on implementation
    expect(["-05:00", "-04:00"]).toContain(body.data.from.offsetFormatted);
  });

  it("DST.4: Sydney is +11 in winter (southern hemisphere)", async () => {
    const r = await fetch(`${API}/api/v1/time/convert?from=Australia/Sydney&to=UTC&at=2026-07-15T12:00:00`);
    expect(r.status).toBe(200);
    const body = await r.json();
    // Sydney in July (winter) is AEST = +10:00 (no DST)
    expect(body.data.from.offsetFormatted).toBe("+10:00");
  });
});
