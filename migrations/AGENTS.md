# migrations/ — D1 SQL migrations

## Purpose

Schema migrations for the `timeandtimepro-full` D1 database. Each file is a forward-only SQL migration.

## Ownership

This directory owns the D1 schema. The current prod D1 (c401ffb6) was seeded from these files; new migrations must be additive and backward-compatible.

## Local Contracts

### Naming

`NNN_description.sql` where `NNN` is a 3-digit zero-padded number (e.g. `000_initial.sql`, `011_persons.sql`). New migrations append, never insert.

### Apply with wrangler

```bash
# Local
npx wrangler d1 execute timeandtimepro-full --local --file=migrations/NNN_description.sql

# Remote (dev)
npx wrangler d1 execute timeandtimepro-full --env dev --file=migrations/NNN_description.sql

# Remote (prod) — REQUIRES USER APPROVAL
npx wrangler d1 execute timeandtimepro-full --file=migrations/NNN_description.sql
```

### Idempotency

Use `CREATE TABLE IF NOT EXISTS`, `CREATE INDEX IF NOT EXISTS`, `ALTER TABLE ... ADD COLUMN` (SQLite supports this). Never `DROP TABLE` or `DROP COLUMN`.

### Backward compatibility

New columns are nullable or have a default. Never rename a column in place — add a new one, migrate data, then drop the old (in a later migration).

### Indexes

Add an index for any column that appears in a `WHERE`, `ORDER BY`, or `JOIN` clause. Don't over-index.

## Work Guidance

### Adding a new table

1. Pick the next migration number (check the existing files in this dir).
2. Write `NNN_table_name.sql` with `CREATE TABLE IF NOT EXISTS`.
3. Add the row type to `src/lib/types.ts`.
4. Add typed helpers to `src/lib/db.ts`.
5. Add a route file in `src/routes/`.
6. Test locally first, then deploy to dev D1, then ask for "ship it" before prod D1.

### Adding a column

1. Pick the next migration number.
2. Write `NNN_add_column.sql` with `ALTER TABLE ... ADD COLUMN`.
3. Update the row type in `src/lib/types.ts` (add the new field as `T | null` if nullable).
4. Update any existing helpers that select from this table.

## Verification

```bash
# Local
npx wrangler d1 execute timeandtimepro-full --local --file=migrations/NNN_description.sql
npx wrangler dev --port 8787
curl http://localhost:8787/api/v1/health  # should show updated counts

# Dev
npx wrangler d1 execute timeandtimepro-full --env dev --file=migrations/NNN_description.sql
```

## Child DOX Index

No children.
