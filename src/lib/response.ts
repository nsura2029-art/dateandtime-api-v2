/**
 * Response builders — every API response goes through one of these.
 *
 * Shape: `{ success: true | false, data?: T, error?: { code, message, details? } }`
 */
import type { Context } from "hono";
import type { ContentfulStatusCode } from "hono/utils/http-status";

export type SuccessResponse<T> = {
  success: true;
  data: T;
};

export type ErrorResponse = {
  success: false;
  error: {
    code: string;
    message: string;
    details?: unknown;
  };
};

export type ApiResponse<T> = SuccessResponse<T> | ErrorResponse;

/** Build a 200-style success response. */
export function success<T>(data: T, status: ContentfulStatusCode = 200): Response {
  const body: SuccessResponse<T> = { success: true, data };
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json; charset=utf-8" },
  });
}

/** Build a paginated success response. */
export function paginate<T>(items: T[], opts: { total: number; limit: number; offset: number }): Response {
  return success({
    items,
    pagination: {
      total: opts.total,
      limit: opts.limit,
      offset: opts.offset,
      hasMore: opts.offset + items.length < opts.total,
    },
  });
}

/** Build a JSON error response with a specific status code. */
export function fail(
  code: string,
  message: string,
  status: ContentfulStatusCode = 400,
  details?: unknown
): Response {
  const body: ErrorResponse = {
    success: false,
    error: { code, message, ...(details !== undefined ? { details } : {}) },
  };
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json; charset=utf-8" },
  });
}

/** Standard error responses for common cases. */
export const Errors = {
  badRequest: (msg = "Bad request", details?: unknown) => fail("BAD_REQUEST", msg, 400, details),
  unauthorized: (msg = "Unauthorized") => fail("UNAUTHORIZED", msg, 401),
  forbidden: (msg = "Forbidden") => fail("FORBIDDEN", msg, 403),
  notFound: (msg = "Not found") => fail("NOT_FOUND", msg, 404),
  methodNotAllowed: (msg = "Method not allowed") => fail("METHOD_NOT_ALLOWED", msg, 405),
  conflict: (msg = "Conflict") => fail("CONFLICT", msg, 409),
  rateLimited: (msg = "Rate limit exceeded") => fail("RATE_LIMITED", msg, 429),
  internal: (msg = "Internal server error") => fail("INTERNAL_ERROR", msg, 500),
  notImplemented: (msg = "Not implemented") => fail("NOT_IMPLEMENTED", msg, 501),
  badGateway: (msg = "Bad gateway") => fail("BAD_GATEWAY", msg, 502),
  serviceUnavailable: (msg = "Service unavailable") => fail("SERVICE_UNAVAILABLE", msg, 503),
} as const;

/** Hono middleware: catch ZodError and return 400. */
export function zodErrorResponse(err: unknown): Response | null {
  if (err && typeof err === "object" && "issues" in err && Array.isArray((err as { issues: unknown[] }).issues)) {
    return Errors.badRequest("Validation failed", (err as { issues: unknown }).issues);
  }
  return null;
}
