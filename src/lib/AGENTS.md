# src/lib/ — typed helpers, response, validation, types

## Purpose

Reusable, framework-agnostic helpers. Everything in `lib/` is pure TypeScript — no Hono, no D1 binding, no Worker globals (only types).

## Ownership

| File | Owns |
|---|---|
| `db.ts` | Typed D1 query helpers (one const per table) |
| `response.ts` | `success()`, `fail()`, `paginate()`, `Errors`, Zod error helper |
| `validation.ts` | `parseIntSafe`, `parseFloatSafe`, `parseCsv`, common Zod schemas |
| `types.ts` | D1 row types (City, Country, Timezone, Holiday, etc.) |

## Local Contracts

### db.ts — typed D1 helpers

One const per table, lowercase plural matching the D1 table name. Each const groups related queries.

```ts
export const Cities = {
  async byId(db: D1Database, id: number): Promise<City | null> { ... },
  async list(db: D1Database, opts: {...}): Promise<City[]> { ... },
  async count(db: D1Database, opts: {...} = {}): Promise<number> { ... },
};
```

**Naming exception:** When the table is singular (`onthisday`), the const is `Otd` (not `OnThisDay`) to avoid collision with the row type `OnThisDay`.

Always return typed data. For one-off complex queries, use `c.env.DB.prepare(...).bind(...).all<MyType>()` in the route file with a type from `types.ts`.

### response.ts — response builders

Use these for every response. Never construct JSON strings inline.

```ts
return success(data);                       // 200 + { success: true, data }
return success(data, 201);                 // 201 + { success: true, data }
return paginate(items, { total, limit, offset });  // 200 + { items, pagination }
return Errors.notFound("City not found");   // 404 + { success: false, error: { code: "NOT_FOUND", message: "..." } }
return Errors.badRequest("Invalid date", details);  // 400 + details
```

### validation.ts — input parsers

Two layers:

1. **Raw parsers** for one-off cases: `parseIntSafe()`, `parseFloatSafe()`, `parseCsv()`.
2. **Zod schemas** for structured validation: `PaginationQuery`, `LatLonQuery`, `NumericIdParam`, `Cca2Param`, `DateParam`, `MonthDayParam`.

Use Zod when the input has multiple fields or constraints. Use raw parsers for single-value query params.

### types.ts — D1 row types

Every D1 table has a corresponding TypeScript interface. Field names match the SQL column names exactly (snake_case).

```ts
export interface City {
  geoname_id: number;
  name: string;
  // ... one field per column
}
```

Optional fields use `| null` (matches SQLite's NULL behavior). JSON fields are typed as `string | null` — parse with `JSON.parse()` after reading.

## Work Guidance

### Adding a new D1 helper

1. Find the relevant const in `db.ts` (e.g. `Cities` for city queries).
2. Add the new method, typed with the row type from `types.ts`.
3. Use the same naming pattern as existing methods (`byId`, `list`, `count`, `search`, `near`, `forCity`).
4. Always use parameterized binds. Never concatenate SQL.

### Adding a new error

Add to `Errors` in `response.ts`:

```ts
export const Errors = {
  // ... existing
  cityNotFound: (id: number) => fail("CITY_NOT_FOUND", `City ${id} not found`, 404),
} as const;
```

Error codes are `SCREAMING_SNAKE_CASE`. Be specific.

### Adding a new Zod schema

Add to `validation.ts`. Use `z.coerce.number()` for query params (they're strings). Use `z.string().regex(...)` for format validation.

## Verification

```bash
npm run typecheck
npm run lint
```

## Child DOX Index

No children — lib is flat, no subdirectories.
