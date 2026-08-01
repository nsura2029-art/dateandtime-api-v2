/**
 * Smoke test for the health endpoint. Runs in vitest.
 *
 * To run: `npm test`
 * Note: requires the API to be running locally (`npm run dev`).
 */
import { describe, it, expect, beforeAll } from "vitest";

const BASE_URL = process.env.API_URL ?? "http://localhost:8787";

describe("health endpoints", () => {
  beforeAll(() => {
    // Give the server a moment to be ready
    // (only needed if running this against a live server, not the test env)
  });

  it("GET / returns API root with version and endpoint manifest", async () => {
    const r = await fetch(`${BASE_URL}/`);
    expect(r.status).toBe(200);
    const body = (await r.json()) as { success: boolean; data: { name: string; version: string; endpoints: Record<string, string> } };
    expect(body.success).toBe(true);
    expect(body.data.name).toBeTruthy();
    expect(body.data.version).toBeTruthy();
    expect(body.data.endpoints).toBeTypeOf("object");
  });

  it("GET /api/v1/health returns DB stats", async () => {
    const r = await fetch(`${BASE_URL}/api/v1/health`);
    expect(r.status).toBe(200);
    const body = (await r.json()) as { success: boolean; data: { status: string; db: { cities: number } } };
    expect(body.success).toBe(true);
    expect(body.data.status).toBe("ok");
    expect(body.data.db.cities).toBeGreaterThan(0);
  });

  it("HEAD /api/v1/health returns 200", async () => {
    const r = await fetch(`${BASE_URL}/api/v1/health`, { method: "HEAD" });
    expect(r.status).toBe(200);
  });

  it("returns 404 for unknown routes with consistent error shape", async () => {
    const r = await fetch(`${BASE_URL}/api/v1/does-not-exist`);
    expect(r.status).toBe(404);
    const body = (await r.json()) as { success: false; error: { code: string } };
    expect(body.success).toBe(false);
    expect(body.error.code).toBe("NOT_FOUND");
  });

  it("returns CORS headers", async () => {
    const r = await fetch(`${BASE_URL}/api/v1/health`, {
      headers: { Origin: "https://dateandtime.live" },
    });
    expect(r.status).toBe(200);
    expect(r.headers.get("access-control-allow-origin")).toBe("https://dateandtime.live");
  });
});
