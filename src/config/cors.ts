/**
 * CORS config — reads from validated env.
 */
import { isOriginAllowed, type ValidatedEnv } from "./env";

export function getCorsHeaders(request: Request, env: ValidatedEnv): Headers {
  const origin = request.headers.get("Origin");
  const headers = new Headers();

  if (origin && isOriginAllowed(origin, env.allowedOrigins)) {
    headers.set("Access-Control-Allow-Origin", origin);
    headers.set("Vary", "Origin");
    headers.set("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
    headers.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
    headers.set("Access-Control-Max-Age", "86400");
    headers.set("Access-Control-Allow-Credentials", "true");
  }

  return headers;
}

/**
 * Handle CORS preflight (OPTIONS) requests.
 */
export function handleCorsPreflight(request: Request, env: ValidatedEnv): Response | null {
  if (request.method !== "OPTIONS") return null;

  const headers = getCorsHeaders(request, env);
  // If origin not allowed, return 403 instead of 204
  if (request.headers.get("Origin") && !headers.has("Access-Control-Allow-Origin")) {
    return new Response("Origin not allowed", { status: 403 });
  }
  return new Response(null, { status: 204, headers });
}
