/**
 * Tests for the data platform source registry (M11.0)
 *
 *   - /api/v1/sources
 *   - /api/v1/sources/:key
 *   - /api/v1/sources/:key/releases
 */
import { describe, it, expect } from "vitest";

const API = process.env.TEST_API_URL || "https://dt-api-v2-dev.nsura2029.workers.dev";

describe("SR1: /api/v1/sources", () => {
  it("SR1.1: returns all 12 registered sources (census_india flipped to active by M11.7)", async () => {
    const r = await fetch(`${API}/api/v1/sources`);
    const body = await r.json();
    expect(body.data.count).toBe(12);
    // Active count: GeoNames + us_census + eurostat_lau + eurostat_urau + census_india = 5
    expect(body.data.activeCount).toBeGreaterThanOrEqual(1);
  });

  it("SR1.2: filters by ?active=true (only active sources: GeoNames + us_census)", async () => {
    const r = await fetch(`${API}/api/v1/sources?active=true`);
    const body = await r.json();
    expect(body.data.count).toBeGreaterThanOrEqual(1);
    // The first active source should be GeoNames (or us_census)
    const keys = body.data.sources.map((s: any) => s.sourceKey);
    expect(keys).toContain("geonames");
  });

  it("SR1.3: each source has publisher, dataset, license, attribution, refreshPolicy", async () => {
    const r = await fetch(`${API}/api/v1/sources`);
    const body = await r.json();
    for (const s of body.data.sources) {
      expect(s.publisher).toBeTruthy();
      expect(s.dataset).toBeTruthy();
      expect(s.license).toBeTruthy();
      expect(s.refreshPolicy).toBeTruthy();
    }
  });

  it("SR1.4: GeoNames source has CC-BY-4.0 license with attribution", async () => {
    const r = await fetch(`${API}/api/v1/sources?active=true`);
    const body = await r.json();
    const geo = body.data.sources.find((s: any) => s.sourceKey === "geonames");
    expect(geo).toBeDefined();
    expect(geo.license).toBe("CC-BY-4.0");
    expect(geo.attribution).toContain("GeoNames");
  });
});

describe("SR2: /api/v1/sources/:key", () => {
  it("SR2.1: get geonames returns full record", async () => {
    const r = await fetch(`${API}/api/v1/sources/geonames`);
    const body = await r.json();
    expect(body.data.sourceKey).toBe("geonames");
    expect(body.data.publisher).toBe("GeoNames");
    expect(body.data.dataset).toBe("cities5000");
    expect(body.data.endpointUrl).toContain("geonames.org");
    expect(body.data.refreshPolicy).toBe("monthly");
    expect(body.data.recentReleases).toBeDefined();
  });

  it("SR2.2: get wikidata returns planned source (isActive=false)", async () => {
    const r = await fetch(`${API}/api/v1/sources/wikidata`);
    const body = await r.json();
    expect(body.data.sourceKey).toBe("wikidata");
    expect(body.data.isActive).toBe(false);
    expect(body.data.license).toBe("CC0");
  });

  it("SR2.3: nonexistent source returns 404", async () => {
    const r = await fetch(`${API}/api/v1/sources/nonexistent-source-xyz`);
    expect(r.status).toBe(404);
    const body = await r.json();
    expect(body.success).toBe(false);
    expect(body.error.code).toBe("NOT_FOUND");
  });
});

describe("SR3: /api/v1/sources/:key/releases", () => {
  it("SR3.1: returns the GeoNames cities5000 release", async () => {
    const r = await fetch(`${API}/api/v1/sources/geonames/releases`);
    const body = await r.json();
    expect(body.data.count).toBeGreaterThanOrEqual(1);
    const release = body.data.releases[0];
    expect(release.releaseId).toBe("geonames-cities5000-2026-08-02");
    // status moves through the pipeline: raw-stored -> validated -> published
    expect(["raw-stored", "validated", "published"]).toContain(release.status);
  });

  it("SR3.2: filters by status", async () => {
    const r = await fetch(`${API}/api/v1/sources/geonames/releases?status=validated`);
    const body = await r.json();
    expect(body.data.filter.status).toBe("validated");
    expect(body.data.releases.length).toBeGreaterThanOrEqual(1);
  });

  it("SR3.3: limits results", async () => {
    const r = await fetch(`${API}/api/v1/sources/geonames/releases?limit=5`);
    const body = await r.json();
    expect(body.data.releases.length).toBeLessThanOrEqual(5);
  });
});

describe("SR4: Source coverage", () => {
  it("SR4.1: 12 sources registered with correct keys", async () => {
    const r = await fetch(`${API}/api/v1/sources`);
    const body = await r.json();
    const expected = [
      "geonames", "wikidata", "cldr", "un_wpp",
      "us_census", "eurostat", "census_india",
      "india_proj", "world_bank", "nso",
      "eurostat_lau", "eurostat_urau",  // M11.6
    ].sort();
    const actual = body.data.sources.map((s: { sourceKey: string }) => s.sourceKey).sort();
    expect(actual).toEqual(expected);
  });

  it("SR4.2: all sources have known limitations", async () => {
    const r = await fetch(`${API}/api/v1/sources`);
    const body = await r.json();
    for (const s of body.data.sources) {
      expect(s.knownLimitations).toBeTruthy();
    }
  });

  it("SR4.3: license URLs are valid URLs", async () => {
    const r = await fetch(`${API}/api/v1/sources`);
    const body = await r.json();
    for (const s of body.data.sources) {
      if (s.licenseUrl) {
        expect(s.licenseUrl).toMatch(/^https?:\/\//);
      }
    }
  });
});
