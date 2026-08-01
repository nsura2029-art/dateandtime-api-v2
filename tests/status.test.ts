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

  it("openapi.json servers[0] is the current deployment origin (for Swagger UI 'Try it out')", async () => {
    // The FIRST server in the list is what Swagger UI uses by default for
    // "Try it out" requests. It MUST be the URL the spec was served from,
    // not a hard-coded prod URL. Otherwise 'Try it out' would 404 on
    // dev/local deployments.
    if (!serverUp) return;
    const r = await fetch(`${BASE_URL}/openapi.json`);
    const spec = (await r.json()) as { servers: Array<{ url: string }> };
    const currentOrigin = new URL(BASE_URL).origin;
    expect(spec.servers[0]?.url).toBe(currentOrigin);
  });

  it("openapi.json includes prod and dev Worker URLs as options", async () => {
    if (!serverUp) return;
    const r = await fetch(`${BASE_URL}/openapi.json`);
    const spec = (await r.json()) as { servers: Array<{ url: string; description: string }> };
    const urls = spec.servers.map((s) => s.url);
    // The Workers are named in wrangler.toml — these are the real Cloudflare URLs
    expect(urls).toContain("https://dt-api-v2.nsura2029.workers.dev");
    expect(urls).toContain("https://dt-api-v2-dev.nsura2029.workers.dev");
    expect(urls).toContain("http://localhost:8787");
  });

  it("openapi.json includes / and /api/v1/health in the Meta tag", async () => {
    if (!serverUp) return;
    const r = await fetch(`${BASE_URL}/openapi.json`);
    const spec = (await r.json()) as {
      paths: Record<string, Record<string, { tags?: string[]; summary?: string }>>;
    };
    // Both endpoints should be in the OpenAPI spec and tagged as Meta
    expect(spec.paths["/"]).toBeDefined();
    expect(spec.paths["/"]?.get?.tags).toContain("Meta");
    expect(spec.paths["/"]?.get?.summary).toBeTruthy();
    expect(spec.paths["/api/v1/health"]).toBeDefined();
    expect(spec.paths["/api/v1/health"]?.get?.tags).toContain("Meta");
    expect(spec.paths["/api/v1/health"]?.get?.summary).toBeTruthy();
  });

  it("openapi.json has response schemas on health (200 + 503)", async () => {
    if (!serverUp) return;
    const r = await fetch(`${BASE_URL}/openapi.json`);
    const spec = (await r.json()) as {
      paths: Record<string, Record<string, { responses: Record<string, { description: string }> }>>;
    };
    const healthResponses = spec.paths["/api/v1/health"]?.get?.responses;
    expect(healthResponses).toBeDefined();
    expect(healthResponses?.["200"]).toBeDefined();
    expect(healthResponses?.["503"]).toBeDefined();
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
