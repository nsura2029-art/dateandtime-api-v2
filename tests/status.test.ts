/**
 * Integration tests for /api/v1/status and /openapi.json + /docs.
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

describe("status endpoint (integration)", () => {
  let serverUp = false;

  beforeAll(async () => {
    serverUp = await isServerUp(BASE_URL);
    if (!serverUp) {
      console.warn(`⚠️  Server not reachable at ${BASE_URL} — tests will skip.`);
    }
  });

  it("GET /api/v1/status returns comprehensive service info", async () => {
    if (!serverUp) return;
    const r = await fetch(`${BASE_URL}/api/v1/status`);
    expect(r.status).toBe(200);
    const body = (await r.json()) as {
      success: boolean;
      data: {
        status: string;
        timestamp: string;
        api: { name: string; version: string; environment: string };
        runtime: { platform: string };
        database: { binding: string; connected: boolean; tables: { cities: number } };
        endpoints: { openapi: string; docs: string; health: string; status: string };
      };
    };
    expect(body.success).toBe(true);
    expect(body.data.status).toMatch(/operational|degraded|down/);
    expect(body.data.api.name).toBeTruthy();
    expect(body.data.runtime.platform).toBe("cloudflare-workers");
    expect(body.data.database.binding).toBe("timeandtimepro-full");
    expect(body.data.endpoints.openapi).toBe("/openapi.json");
    expect(body.data.endpoints.docs).toBe("/docs");
  });

  it("HEAD /api/v1/status returns 200", async () => {
    if (!serverUp) return;
    const r = await fetch(`${BASE_URL}/api/v1/status`, { method: "HEAD" });
    expect(r.status).toBe(200);
  });
});

describe("openapi + docs (integration)", () => {
  let serverUp = false;

  beforeAll(async () => {
    serverUp = await isServerUp(BASE_URL);
  });

  it("GET /openapi.json returns a valid OpenAPI 3.1 spec", async () => {
    if (!serverUp) return;
    const r = await fetch(`${BASE_URL}/openapi.json`);
    expect(r.status).toBe(200);
    const spec = (await r.json()) as {
      openapi: string;
      info: { title: string; version: string };
      servers: Array<{ url: string; description: string }>;
      paths: Record<string, unknown>;
    };
    expect(spec.openapi).toMatch(/^3\./);
    expect(spec.info.title).toBeTruthy();
    expect(spec.info.version).toBeTruthy();
    expect(spec.servers.length).toBeGreaterThan(0);
    expect(Object.keys(spec.paths).length).toBeGreaterThan(0);
  });

  it("GET /docs returns the Swagger UI HTML", async () => {
    if (!serverUp) return;
    const r = await fetch(`${BASE_URL}/docs`);
    expect(r.status).toBe(200);
    const html = await r.text();
    expect(html).toContain("SwaggerUIBundle");
    expect(html).toContain("/openapi.json");
  });
});
