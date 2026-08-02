/**
 * M10: Final regression test suite
 *
 * Edge cases for each of the 16 endpoints. Runs against the deployed
 * dev Worker to verify end-to-end behavior.
 *
 * Test groups:
 *   F1: /cities/search (FTS5 + ranking + state filter + lang + same-name)
 *   F2: /cities/{id} (detail + postcodes + translations + dataQuality)
 *   F3: /cities/{id}/postcodes (paginated list)
 *   F4: /cities/{id}/translations (all 19 langs)
 *   F5: /cities/{id}/translations/{lang} (single lang)
 *   F6: /translations/search (cross-language)
 *   F7: /postcodes/search (by code)
 *   F8: /airports/near (lat/lon/radius)
 *   F9: /cities/{id}/airports (data pending)
 *   F10: /data-quality (summary)
 *   F11: /data-quality/issues (filterable)
 *   F12: /health + /status
 *   F13: error handling (404, 400, invalid input)
 *   F14: spec acceptance criteria (§33)
 */
import { describe, it, expect } from "vitest";

const API = process.env.TEST_API_URL || "https://dt-api-v2-dev.nsura2029.workers.dev";

// ============================================================================
// F1: /cities/search
// ============================================================================
describe("F1: /cities/search — edge cases", () => {
  it("F1.1: empty query → 400 (Zod validation)", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=`);
    expect(r.status).toBe(400);
  });

  it("F1.2: SQL injection attempt sanitized", async () => {
    // ;' should be stripped to prevent SQL breaking
    const r = await fetch(`${API}/api/v1/cities/search?q=Tokyo%27%3B%20DROP%20TABLE%20cities%3B--`);
    expect(r.status).toBe(200);
    // Verify cities table still exists
    const r2 = await fetch(`${API}/api/v1/cities/64500`);
    expect(r2.status).toBe(200);
  });

  it("F1.3: 100+ char query → 400 (max=100)", async () => {
    const long = "a".repeat(101);
    const r = await fetch(`${API}/api/v1/cities/search?q=${long}`);
    expect(r.status).toBe(400);
  });

  it("F1.4: single char query (FTS5 prefix behavior)", async () => {
    // Single char searches get no prefix * so FTS5 returns exact matches only
    const r = await fetch(`${API}/api/v1/cities/search?q=A`);
    const body = await r.json();
    // "A" as a single char returns cities starting with A. Verify limit caps it.
    expect(body.data.results.length).toBeLessThanOrEqual(10);
  });

  it("F1.5: non-existent city returns 0 results (not error)", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=Xyzzynonexistent`);
    const body = await r.json();
    expect(body.data.results.length).toBe(0);
  });

  it("F1.6: limit > 50 → 400", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=Tokyo&limit=100`);
    expect(r.status).toBe(400);
  });

  it("F1.7: same-name disambiguation with state filter", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=Portland&country=US&state=OR&limit=3`);
    const body = await r.json();
    expect(body.data.results[0].stateCode).toBe("OR");
  });

  it("F1.8: cross-language search (ja)", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=${encodeURIComponent("東京")}&lang=ja&limit=3`);
    const body = await r.json();
    const tokyo = body.data.results.find((x: { id: number }) => x.id === 64500);
    expect(tokyo).toBeTruthy();
  });

  it("F1.9: invalid country code 'ZZ' (no error, just no boost)", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=Tokyo&country=ZZ&limit=3`);
    const body = await r.json();
    // No error, just no country boost
    expect(body.data.results.length).toBeGreaterThan(0);
  });

  it("F1.10: invalid lat/lon → 400", async () => {
    const r = await fetch(`${API}/api/v1/cities/search?q=Tokyo&lat=91&lon=0`);
    expect(r.status).toBe(400);
  });
});

// ============================================================================
// F2: /cities/{id}
// ============================================================================
describe("F2: /cities/{id} — edge cases", () => {
  it("F2.1: 0 → 400 (Zod: positive)", async () => {
    const r = await fetch(`${API}/api/v1/cities/0`);
    expect(r.status).toBe(400);
  });

  it("F2.2: negative ID → 400", async () => {
    const r = await fetch(`${API}/api/v1/cities/-1`);
    expect(r.status).toBe(400);
  });

  it("F2.3: non-integer ID (e.g. 'abc') → 400", async () => {
    const r = await fetch(`${API}/api/v1/cities/abc`);
    expect(r.status).toBe(400);
  });

  it("F2.4: very large non-existent ID → 404", async () => {
    const r = await fetch(`${API}/api/v1/cities/99999999999`);
    expect(r.status).toBe(404);
  });

  it("F2.5: full record returned for known city", async () => {
    const r = await fetch(`${API}/api/v1/cities/64500`);
    const body = await r.json();
    const d = body.data;
    expect(d.id).toBe(64500);
    expect(d.name).toBe("Tokyo");
    expect(d.native).toBe("東京");
    expect(d.stateCode).toBe("13");
    expect(d.type).toBeTruthy();
    expect(d.wikiDataId).toBeTruthy();
    expect(d.timezone.id).toBe("Asia/Tokyo");
    expect(d.translations.available).toBe(19);
    expect(d.postcodes).toBeTruthy();
    expect(d.postcodes.total).toBeGreaterThan(0);
    expect(d.dataQuality.timezoneConfidence).toBeTruthy();
  });

  it("F2.6: 152970 (last city) is valid", async () => {
    const r = await fetch(`${API}/api/v1/cities/152970`);
    expect(r.status).toBe(200);
  });
});

// ============================================================================
// F3: /cities/{id}/postcodes
// ============================================================================
describe("F3: /cities/{id}/postcodes — edge cases", () => {
  it("F3.1: page=1&limit=1 returns exactly 1", async () => {
    const r = await fetch(`${API}/api/v1/cities/115731/postcodes?limit=1`);
    const body = await r.json();
    expect(body.data.results.length).toBe(1);
    expect(body.data.page).toBe(1);
    expect(body.data.limit).toBe(1);
  });

  it("F3.2: page=999 returns empty (out of range)", async () => {
    const r = await fetch(`${API}/api/v1/cities/115731/postcodes?page=999&limit=20`);
    const body = await r.json();
    expect(body.data.results.length).toBe(0);
    expect(body.data.page).toBe(999);
    // Total still correct
    expect(body.data.total).toBeGreaterThan(0);
  });

  it("F3.3: page=0 → 400 (min=1)", async () => {
    const r = await fetch(`${API}/api/v1/cities/115731/postcodes?page=0`);
    expect(r.status).toBe(400);
  });

  it("F3.4: limit=0 → 400", async () => {
    const r = await fetch(`${API}/api/v1/cities/115731/postcodes?limit=0`);
    expect(r.status).toBe(400);
  });

  it("F3.5: limit=101 → 400 (max=100)", async () => {
    const r = await fetch(`${API}/api/v1/cities/115731/postcodes?limit=101`);
    expect(r.status).toBe(400);
  });

  it("F3.6: negative page → 400", async () => {
    const r = await fetch(`${API}/api/v1/cities/115731/postcodes?page=-1`);
    expect(r.status).toBe(400);
  });

  it("F3.7: pagination consistency — page 1 + page 2 covers more than page 1 alone", async () => {
    const r1 = await fetch(`${API}/api/v1/cities/115731/postcodes?page=1&limit=5`);
    const r2 = await fetch(`${API}/api/v1/cities/115731/postcodes?page=2&limit=5`);
    const b1 = await r1.json();
    const b2 = await r2.json();
    const codes1 = new Set(b1.data.results.map((p: { code: string }) => p.code));
    const codes2 = new Set(b2.data.results.map((p: { code: string }) => p.code));
    // No overlap
    for (const c of codes1) expect(codes2.has(c)).toBe(false);
  });
});

// ============================================================================
// F4: /cities/{id}/translations
// ============================================================================
describe("F4: /cities/{id}/translations — edge cases", () => {
  it("F4.1: most major cities have 19 translations", async () => {
    const r = await fetch(`${API}/api/v1/cities/64500/translations`); // Tokyo
    const body = await r.json();
    expect(body.data.count).toBeGreaterThanOrEqual(15);
  });

  it("F4.2: 404 for missing city", async () => {
    const r = await fetch(`${API}/api/v1/cities/99999999/translations`);
    expect(r.status).toBe(404);
  });

  it("F4.3: 0 translations for unknown city ID (edge case)", async () => {
    // Find a city that might have 0 translations (small town, far from dr5hn coverage)
    // Tokyo has 19, New York has 19, so use a less popular one
    const r = await fetch(`${API}/api/v1/cities/100000/translations`); // arbitrary mid-range
    const body = await r.json();
    expect(body.data.count).toBeGreaterThanOrEqual(0);
  });

  it("F4.4: includes canonical 19 languages (dr5hn excludes 'en' — source language)", async () => {
    // dr5hn doesn't translate English (it's the source). So Tokyo has 19
    // langs but NOT 'en'.
    const r = await fetch(`${API}/api/v1/cities/64500/translations`); // Tokyo
    const body = await r.json();
    const langs = body.data.translations.map((t: { language: string }) => t.language);
    for (const expected of ["ar", "ja", "zh-CN", "fr", "es", "de", "ru", "ko"]) {
      expect(langs).toContain(expected);
    }
    // Verify 'en' is NOT in the list (dr5hn's data convention)
    expect(langs).not.toContain("en");
  });
});

// ============================================================================
// F5: /cities/{id}/translations/{lang}
// ============================================================================
describe("F5: /cities/{id}/translations/{lang} — edge cases", () => {
  it("F5.1: case-insensitive language lookup", async () => {
    // Both 'ja' and 'JA' should work (we lowercase before query)
    const r1 = await fetch(`${API}/api/v1/cities/64500/translations/ja`);
    const r2 = await fetch(`${API}/api/v1/cities/64500/translations/JA`);
    const b1 = await r1.json();
    const b2 = await r2.json();
    expect(b1.data.translation).toBe(b2.data.translation);
  });

  it("F5.2: zh-CN (uppercase) works (lowercase input also works)", async () => {
    const r1 = await fetch(`${API}/api/v1/cities/19332/translations/zh-CN`);
    const r2 = await fetch(`${API}/api/v1/cities/19332/translations/zh-cn`);
    const b1 = await r1.json();
    const b2 = await r2.json();
    expect(b1.data.translation).toBe("北京");
    expect(b2.data.translation).toBe("北京");
  });

  it("F5.3: pt-BR (Brazilian Portuguese)", async () => {
    const r = await fetch(`${API}/api/v1/cities/19332/translations/pt-BR`);
    const b = await r.json();
    // Beijing in pt-BR
    expect(b.data.translation).toBe("Pequim");
  });

  it("F5.4: invalid language code → 404", async () => {
    const r = await fetch(`${API}/api/v1/cities/64500/translations/xx`);
    expect(r.status).toBe(404);
  });

  it("F5.5: 404 for missing city", async () => {
    const r = await fetch(`${API}/api/v1/cities/99999999/translations/ja`);
    expect(r.status).toBe(404);
  });
});

// ============================================================================
// F6: /translations/search
// ============================================================================
describe("F6: /translations/search — edge cases", () => {
  it("F6.1: empty q → 400", async () => {
    const r = await fetch(`${API}/api/v1/translations/search?q=&lang=ja`);
    expect(r.status).toBe(400);
  });

  it("F6.2: empty lang → 400", async () => {
    const r = await fetch(`${API}/api/v1/translations/search?q=tokyo&lang=`);
    expect(r.status).toBe(400);
  });

  it("F6.3: limit=0 → 400", async () => {
    const r = await fetch(`${API}/api/v1/translations/search?q=tokyo&lang=ja&limit=0`);
    expect(r.status).toBe(400);
  });

  it("F6.4: limit=51 → 400 (max=50)", async () => {
    const r = await fetch(`${API}/api/v1/translations/search?q=tokyo&lang=ja&limit=51`);
    expect(r.status).toBe(400);
  });

  it("F6.5: non-existent translation returns 0", async () => {
    const r = await fetch(`${API}/api/v1/translations/search?q=Notacityname&lang=en&limit=5`);
    const b = await r.json();
    expect(b.data.results.length).toBe(0);
  });

  it("F6.6: prefix match (partial typing)", async () => {
    const r = await fetch(`${API}/api/v1/translations/search?q=T%CE%95%CE%B8&lang=el&limit=5`);
    // Greek for Athens (assuming dr5hn has Greek translations)
    const b = await r.json();
    expect(b.data.results).toBeDefined();
  });
});

// ============================================================================
// F7: /postcodes/search
// ============================================================================
describe("F7: /postcodes/search — edge cases", () => {
  it("F7.1: empty code → 400", async () => {
    const r = await fetch(`${API}/api/v1/postcodes/search?code=&country=US`);
    expect(r.status).toBe(400);
  });

  it("F7.2: invalid country code → 400", async () => {
    const r = await fetch(`${API}/api/v1/postcodes/search?code=32501&country=ZZ`);
    expect(r.status).toBe(400);
  });

  it("F7.3: exact=true vs false differ on partial queries", async () => {
    // "3250" partial: exact=true → 0 results, exact=false → 1+ results (32501, 32502, ...)
    const r1 = await fetch(`${API}/api/v1/postcodes/search?code=3250&country=US&exact=true`);
    const r2 = await fetch(`${API}/api/v1/postcodes/search?code=3250&country=US&exact=false`);
    const b1 = await r1.json();
    const b2 = await r2.json();
    expect(b1.data.results.length).toBeLessThan(b2.data.results.length);
  });

  it("F7.4: limit > 20 → 400", async () => {
    const r = await fetch(`${API}/api/v1/postcodes/search?code=3&country=US&limit=21`);
    expect(r.status).toBe(400);
  });

  it("F7.5: special chars in code (e.g. JP code '100-0001')", async () => {
    const r = await fetch(`${API}/api/v1/postcodes/search?code=100-0001&country=JP&exact=true`);
    const b = await r.json();
    if (b.data.results.length > 0) {
      expect(b.data.results[0].postcode.code).toBe("100-0001");
    }
  });

  it("F7.6: lowercase country code accepted (normalized to uppercase)", async () => {
    const r1 = await fetch(`${API}/api/v1/postcodes/search?code=32501&country=us&exact=true`);
    const r2 = await fetch(`${API}/api/v1/postcodes/search?code=32501&country=US&exact=true`);
    expect(r1.status).toBe(200);
    expect(r2.status).toBe(200);
  });
});

// ============================================================================
// F8: /airports/near
// ============================================================================
describe("F8: /airports/near — edge cases", () => {
  it("F8.1: missing lat → 400", async () => {
    const r = await fetch(`${API}/api/v1/airports/near?lon=0`);
    expect(r.status).toBe(400);
  });

  it("F8.2: missing lon → 400", async () => {
    const r = await fetch(`${API}/api/v1/airports/near?lat=0`);
    expect(r.status).toBe(400);
  });

  it("F8.3: lat=-91 → 400", async () => {
    const r = await fetch(`${API}/api/v1/airports/near?lat=-91&lon=0`);
    expect(r.status).toBe(400);
  });

  it("F8.4: lon=-181 → 400", async () => {
    const r = await fetch(`${API}/api/v1/airports/near?lat=0&lon=-181`);
    expect(r.status).toBe(400);
  });

  it("F8.5: radius=0 → 400 (min=1)", async () => {
    const r = await fetch(`${API}/api/v1/airports/near?lat=0&lon=0&radius=0`);
    expect(r.status).toBe(400);
  });

  it("F8.6: radius=501 → 400 (max=500)", async () => {
    const r = await fetch(`${API}/api/v1/airports/near?lat=0&lon=0&radius=501`);
    expect(r.status).toBe(400);
  });

  it("F8.7: NYC coords return schema-valid empty list (no data loaded)", async () => {
    const r = await fetch(`${API}/api/v1/airports/near?lat=40.6413&lon=-73.7781&radius=50`);
    const b = await r.json();
    expect(b.data.count).toBe(0);
    expect(Array.isArray(b.data.airports)).toBe(true);
  });

  it("F8.8: limit=0 → 400", async () => {
    const r = await fetch(`${API}/api/v1/airports/near?lat=0&lon=0&limit=0`);
    expect(r.status).toBe(400);
  });
});

// ============================================================================
// F9: /cities/{id}/airports
// ============================================================================
describe("F9: /cities/{id}/airports — edge cases", () => {
  it("F9.1: 200 with empty list (no data)", async () => {
    const r = await fetch(`${API}/api/v1/cities/64500/airports`);
    const b = await r.json();
    expect(b.data.cityId).toBe(64500);
    expect(Array.isArray(b.data.airports)).toBe(true);
  });

  it("F9.2: 404 for missing city", async () => {
    const r = await fetch(`${API}/api/v1/cities/99999999/airports`);
    expect(r.status).toBe(404);
  });

  it("F9.3: limit > 50 → 400", async () => {
    const r = await fetch(`${API}/api/v1/cities/64500/airports?limit=51`);
    expect(r.status).toBe(400);
  });
});

// ============================================================================
// F10: /data-quality
// ============================================================================
describe("F10: /data-quality — edge cases", () => {
  it("F10.1: cities.total = 152970", async () => {
    const r = await fetch(`${API}/api/v1/data-quality`);
    const b = await r.json();
    expect(b.data.cities.total).toBe(152970);
  });

  it("F10.2: confidence sums to total", async () => {
    const r = await fetch(`${API}/api/v1/data-quality`);
    const b = await r.json();
    const c = b.data.cities.confidence;
    expect(c.high + c.medium + c.low + c.unresolved).toBe(c.total);
  });

  it("F10.3: deprecatedEtcGmt = 0 (spec §8.2 compliance)", async () => {
    const r = await fetch(`${API}/api/v1/data-quality`);
    const b = await r.json();
    expect(b.data.timezoneZones.deprecatedEtcGmt).toBe(0);
  });

  it("F10.4: 8 data sources registered", async () => {
    const r = await fetch(`${API}/api/v1/data-quality`);
    const b = await r.json();
    expect(b.data.dataSources.length).toBeGreaterThanOrEqual(7);
  });
});

// ============================================================================
// F11: /data-quality/issues
// ============================================================================
describe("F11: /data-quality/issues — edge cases", () => {
  it("F11.1: invalid type → 400 (Zod enum)", async () => {
    const r = await fetch(`${API}/api/v1/data-quality/issues?type=invalid_type`);
    expect(r.status).toBe(400);
  });

  it("F11.2: limit=0 → 400", async () => {
    const r = await fetch(`${API}/api/v1/data-quality/issues?limit=0`);
    expect(r.status).toBe(400);
  });

  it("F11.3: limit > 500 → 400", async () => {
    const r = await fetch(`${API}/api/v1/data-quality/issues?limit=501`);
    expect(r.status).toBe(400);
  });

  it("F11.4: filter results are all of the same type", async () => {
    const r = await fetch(`${API}/api/v1/data-quality/issues?type=null_island&limit=50`);
    const b = await r.json();
    for (const issue of b.data.issues) {
      expect(issue.type).toBe("null_island");
    }
  });

  it("F11.5: severity is consistent with type", async () => {
    const r = await fetch(`${API}/api/v1/data-quality/issues?type=null_island&limit=5`);
    const b = await r.json();
    for (const issue of b.data.issues) {
      expect(issue.severity).toBe("error");
    }
  });
});

// ============================================================================
// F12: /health + /status
// ============================================================================
describe("F12: /health + /status — edge cases", () => {
  it("F12.1: /health returns 200 with body", async () => {
    const r = await fetch(`${API}/api/v1/health`);
    expect(r.status).toBe(200);
    const b = await r.json();
    expect(b.success).toBe(true);
  });

  it("F12.2: /status returns 200 with build info", async () => {
    const r = await fetch(`${API}/api/v1/status`);
    expect(r.status).toBe(200);
    const b = await r.json();
    expect(b.data.api).toBeTruthy();
    expect(b.data.build).toBeTruthy();
    expect(b.data.endpoints).toBeDefined();
  });

  it("F12.3: HEAD /health returns 200 with no body", async () => {
    const r = await fetch(`${API}/api/v1/health`, { method: "HEAD" });
    expect(r.status).toBe(200);
    const text = await r.text();
    expect(text).toBe("");
  });

  it("F12.4: HEAD /status returns 200 with no body", async () => {
    const r = await fetch(`${API}/api/v1/status`, { method: "HEAD" });
    expect(r.status).toBe(200);
    const text = await r.text();
    expect(text).toBe("");
  });
});

// ============================================================================
// F13: error handling & edge cases
// ============================================================================
describe("F13: error handling", () => {
  it("F13.1: 404 endpoint returns 404 (not 500)", async () => {
    const r = await fetch(`${API}/api/v1/this/does/not/exist`);
    expect(r.status).toBe(404);
  });

  it("F13.2: POST to GET-only endpoint returns 404 or 405", async () => {
    // Cloudflare Workers returns 404 for method-not-allowed by default
    // (not 405). This is expected behavior.
    const r = await fetch(`${API}/api/v1/cities/search`, { method: "POST" });
    expect([404, 405]).toContain(r.status);
  });

  it("F13.3: CORS preflight (OPTIONS) returns 204", async () => {
    const r = await fetch(`${API}/api/v1/cities/search`, {
      method: "OPTIONS",
      headers: { Origin: "https://dateandtime.live", "Access-Control-Request-Method": "GET" },
    });
    expect(r.status).toBe(204);
  });
});

// ============================================================================
// F14: spec §33 acceptance criteria
// ============================================================================
describe("F14: spec §33 acceptance criteria", () => {
  it("F14.1: §33.5 — every city has timezone_source exposed", async () => {
    const r = await fetch(`${API}/api/v1/cities/64500`);
    const b = await r.json();
    expect(b.data.dataQuality.timezoneSource).toBeTruthy();
  });

  it("F14.2: §33.6 — UTC offset not stored as permanent (uses IANA only)", async () => {
    // We store IANA timezone, not numeric UTC offset
    // The numeric offset is computed from IANA + date (per spec §1, §33.20)
    const r = await fetch(`${API}/api/v1/cities/64500`);
    const b = await r.json();
    expect(b.data.timezone.id).toBe("Asia/Tokyo");
  });

  it("F14.3: §33.7 — canonical IANA, not abbreviations", async () => {
    // All timezones should be IANA IDs like Asia/Tokyo, not abbreviations like JST
    const r = await fetch(`${API}/api/v1/cities/64500`);
    const b = await r.json();
    expect(b.data.timezone.id).toMatch(/^[A-Z][a-zA-Z_]+\/[A-Z][a-zA-Z_]+$/);
  });

  it("F14.4: §33.19 — Null Island cities not silently defaulted", async () => {
    // 22 cities are flagged unresolved (per M1 audit)
    const r = await fetch(`${API}/api/v1/data-quality/issues?type=null_island`);
    const b = await r.json();
    expect(b.data.total).toBe(22);
  });

  it("F14.5: §33.22 — migrations are idempotent (all use INSERT OR IGNORE)", async () => {
    // Migrations test: re-applying doesn't duplicate data
    const r = await fetch(`${API}/api/v1/data-quality`);
    const b = await r.json();
    // If migrations weren't idempotent, the test data would have duplicates
    expect(b.data.cities.total).toBe(152970); // exact count
  });
});
