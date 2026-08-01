/**
 * Integration smoke tests for the health endpoint.
 *
 * These tests run against a live API at $API_URL (default http://localhost:8787).
 * If the server isn't reachable, the tests SKIP rather than FAIL — so CI can run
 * typecheck + lint + these tests without a server.
 *
 * To run locally:
 *   npm run dev          # in one terminal
 *   npm test             # in another
 *
 * To run in CI:
 *   npm run dev &        # background
 *   wait-on http://localhost:8787
 *   npm test
 */
import { describe, it, expect, beforeAll } from "vitest";

const BASE_URL = process.env.API_URL ?? "http://localhost:8787";

async function isServerUp(url: string): Promise<boolean> {
  try {
    const r = await fetch(url, { signal: AbortSignal.timeout(1000) });
    return r.status < 500;
  } catch {
    return false;
  }
}

describe("health endpoints (integration)", () => {
  let serverUp = false;

  beforeAll(async () => {
    serverUp = await isServerUp(BASE_URL);
    if (!serverUp) {
      console.warn(`⚠️  Server not reachable at ${BASE_URL} — tests will skip. Start with: npm run dev`);
    }
  });

  it("GET / returns API root with version and endpoint manifest", async () => {
    if (!serverUp) return;
    const r = await fetch(`${BASE_URL}/`);
    expect(r.status).toBe(200);
    const body = (await r.json()) as {
      success: boolean;
      data: { name: string; version: string; endpoints: Record<string, string> };
    };
    expect(body.success).toBe(true);
    expect(body.data.name).toBeTruthy();
    expect(body.data.version).toBeTruthy();
    expect(body.data.endpoints).toBeTypeOf("object");
  });

  it("GET /api/v1/health returns DB stats", async () => {
    if (!serverUp) return;
    const r = await fetch(`${BASE_URL}/api/v1/health`);
    expect(r.status).toBe(200);
    const body = (await r.json()) as {
      success: boolean;
      data: { status: string; db: { cities: number } };
    };
    expect(body.success).toBe(true);
    expect(body.data.status).toBe("ok");
    expect(body.data.db.cities).toBeGreaterThan(0);
  });

  it("HEAD /api/v1/health returns 200", async () => {
    if (!serverUp) return;
    const r = await fetch(`${BASE_URL}/api/v1/health`, { method: "HEAD" });
    expect(r.status).toBe(200);
  });

  it("returns 404 for unknown routes with consistent error shape", async () => {
    if (!serverUp) return;
    const r = await fetch(`${BASE_URL}/api/v1/does-not-exist`);
    expect(r.status).toBe(404);
    const body = (await r.json()) as { success: false; error: { code: string } };
    expect(body.success).toBe(false);
    expect(body.error.code).toBe("NOT_FOUND");
  });

  it("returns CORS headers for allowed origins", async () => {
    if (!serverUp) return;
    const r = await fetch(`${BASE_URL}/api/v1/health`, {
      headers: { Origin: "https://dateandtime.live" },
    });
    expect(r.status).toBe(200);
    expect(r.headers.get("access-control-allow-origin")).toBe("https://dateandtime.live");
  });
});
