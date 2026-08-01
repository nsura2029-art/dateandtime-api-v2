# .github/ — CI workflows

## Purpose

GitHub Actions workflows for CI (lint, typecheck, test) and (future) deploys.

## Ownership

| File | Owns |
|---|---|
| `workflows/ci.yml` | Runs on every push to `main` and every PR — typecheck + lint + test |

Future: `workflows/deploy-dev.yml` (auto-deploy to dt-api-v2-dev on push to develop), `workflows/deploy-prod.yml` (manual gate for prod).

## Local Contracts

### Required checks (must pass before merge)

1. `npm run typecheck` — 0 errors
2. `npm run lint` — 0 errors, 0 warnings
3. `npm test` — all tests pass (or skip if no server, with warning)

### README sync check (future)

The CI will also run `npm run sync:readme --check` (a flag that exits non-zero if README would change). This catches drift between routes and docs.

## Work Guidance

### Adding a new workflow

1. Create `workflows/<name>.yml`.
2. Add a comment at the top describing what it does and when it runs.
3. Use the existing CI workflow as a template for Node + npm setup.
4. Pin action versions with `@v4` (not `@main`).
5. Document the workflow in this AGENTS.md (add a row to the table).

### Changing the CI

Update `workflows/ci.yml` and verify locally:

```bash
# Install act (https://github.com/nektos/act) to run workflows locally
brew install act    # macOS
# or
choco install act   # Windows
act                # run the default workflow
```

## Verification

```bash
npm run typecheck
npm run lint
npm test
```

## Child DOX Index

No children.
