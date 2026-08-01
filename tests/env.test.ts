/**
 * Unit tests for environment + CORS helpers.
 *
 * These are pure-function tests — no server, no DB, no network.
 * Run with: npm test (vitest).
 */
import { describe, it, expect } from "vitest";
import { isOriginAllowed, loadEnv } from "@/config/env";

describe("isOriginAllowed", () => {
  it("returns false for null origin", () => {
    expect(isOriginAllowed(null, ["https://x.com"])).toBe(false);
  });

  it("returns true for exact match", () => {
    expect(isOriginAllowed("https://x.com", ["https://x.com"])).toBe(true);
  });

  it("returns true when '*' is in the allow list (dev mode)", () => {
    expect(isOriginAllowed("https://anywhere.com", ["*"])).toBe(true);
  });

  it("returns false for non-matching origin", () => {
    expect(isOriginAllowed("https://evil.com", ["https://x.com"])).toBe(false);
  });

  it("matches http://localhost:* pattern (port wildcard)", () => {
    expect(isOriginAllowed("http://localhost:8787", ["http://localhost:*"])).toBe(true);
    expect(isOriginAllowed("http://localhost:3000", ["http://localhost:*"])).toBe(true);
    expect(isOriginAllowed("http://localhost:5173", ["http://localhost:*"])).toBe(true);
  });

  it("does NOT match localhost wildcard for non-localhost origins", () => {
    expect(isOriginAllowed("https://localhost.evil.com:8787", ["http://localhost:*"])).toBe(false);
    expect(isOriginAllowed("http://localhost:8787.evil.com", ["http://localhost:*"])).toBe(false);
  });

  it("does NOT match localhost wildcard for different scheme", () => {
    // https://localhost:8787 is NOT the same as http://localhost:8787
    expect(isOriginAllowed("https://localhost:8787", ["http://localhost:*"])).toBe(false);
  });

  it("matches when origin equals the prefix exactly (no port)", () => {
    // "http://localhost" (no port) matches the pattern
    expect(isOriginAllowed("http://localhost", ["http://localhost:*"])).toBe(true);
  });

  it("supports multiple patterns mixed together", () => {
    const allowed = [
      "https://dateandtime.live",
      "https://tdp-landing-dev.nsura2029.workers.dev",
      "http://localhost:*",
    ];
    expect(isOriginAllowed("https://dateandtime.live", allowed)).toBe(true);
    expect(isOriginAllowed("https://tdp-landing-dev.nsura2029.workers.dev", allowed)).toBe(true);
    expect(isOriginAllowed("http://localhost:8787", allowed)).toBe(true);
    expect(isOriginAllowed("http://localhost:3000", allowed)).toBe(true);
    expect(isOriginAllowed("https://evil.com", allowed)).toBe(false);
  });
});

describe("loadEnv", () => {
  it("parses comma-separated ALLOWED_ORIGINS into an array", () => {
    const env = loadEnv({
      API_VERSION: "1.0.0",
      API_NAME: "test",
      LOG_LEVEL: "info",
      ALLOWED_ORIGINS: "https://a.com, https://b.com ,, https://c.com",
      DB: {} as D1Database,
    } as unknown as Parameters<typeof loadEnv>[0]);
    expect(env.allowedOrigins).toEqual(["https://a.com", "https://b.com", "https://c.com"]);
  });

  it("defaults LOG_LEVEL to 'info' when missing", () => {
    const env = loadEnv({
      API_VERSION: "1.0.0",
      API_NAME: "test",
      ALLOWED_ORIGINS: "*",
      DB: {} as D1Database,
    } as unknown as Parameters<typeof loadEnv>[0]);
    expect(env.LOG_LEVEL).toBe("info");
  });

  it("throws ZodError when ALLOWED_ORIGINS is empty", () => {
    expect(() =>
      loadEnv({
        API_VERSION: "1.0.0",
        API_NAME: "test",
        ALLOWED_ORIGINS: "",
        DB: {} as D1Database,
      } as unknown as Parameters<typeof loadEnv>[0])
    ).toThrow();
  });
});
