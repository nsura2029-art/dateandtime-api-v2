# docs/AGENTS.md

> Conventions for documentation. Read this BEFORE updating any docs.
> Sub-context of root AGENTS.md.

## Doc types

1. **Setup / onboarding** (`docs/setup.md`) — how to set up the project from scratch
2. **Troubleshooting** (`docs/troubleshooting.md`) — common errors + fixes
3. **Known issues** (`docs/KNOWN_ISSUES.md`) — tracked bugs (BUG-N, TODO-N)
4. **API reference** (`docs/api/README.md`) — 45 endpoints, M14 spec, postman collection
5. **Architecture** (`docs/architecture/`) — design decisions, data model diagrams
6. **Plans** (`docs/PLAN-*.md`) — future work, design docs

## Markdown style

- **ATX headings** (`# H1`, `## H2`, etc.), no setext (`=====` underline)
- **No more than 3 levels deep** — `#` → `##` → `###`. If you need 4, restructure.
- **Code blocks with language hints:** ` ```bash `, ` ```sql `, ` ```ts `, ` ```json `, ` ```toml `
- **Tables for structured data** (not bullet lists)
- **Bold for emphasis on key terms**, not entire sentences
- **Links are descriptive:** `[OpenAPI spec](docs/api/openapi.md)` not `[click here](...)`

## Doc structure conventions

```markdown
# Title

> One-sentence description of what this doc covers.

## Overview
What this is, when to read it.

## Quick start
The 3-5 commands to get the most common thing done.

## Details
The full explanation.

## Common pitfalls
Gotchas and workarounds.

## Related
- [Other doc 1](path/to/other1.md)
- [Other doc 2](path/to/other2.md)
```

## KNOWN_ISSUES.md format

```markdown
# Known Issues

## BUG-N: <one-line summary>

**Status:** Open | In Progress | Resolved
**Severity:** Critical | High | Medium | Low
**Affects:** <versions or environments>
**Workaround:** <what to do today>
**Root cause:** <what's actually wrong>
**Fix:** <link to PR or commit>

### Reproduction
Step-by-step to reproduce.

### Logs
\`\`\`
<actual error message>
\`\`\`
```

## PLAN-<topic>.md format

Used for future work, design docs, and brainstorms. Not for shipping features.

```markdown
# PLAN: <topic>

> <one-sentence summary of what this plan covers>

## Goal
What we're trying to achieve.

## Non-goals
What we're explicitly NOT doing.

## Approach
The high-level plan.

## Alternatives considered
What else we considered, and why we picked this.

## Tasks
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

## Open questions
- Q1?
- Q2?
```

## Architecture docs

For major design decisions, use `docs/architecture/<topic>.md` with:

1. **Context** — what's the problem
2. **Decision** — what we chose
3. **Consequences** — what this means going forward
4. **Alternatives** — what else we considered
5. **References** — links to PRs, RFCs, upstream docs

Example topics: data model, search algorithm, timezone handling, edge case audit.

## API reference

The OpenAPI spec (`docs/api/openapi.json`) is the source of truth. Postman collection
(`docs/api/timeanddatepro-api.postman_collection.json`) is auto-generated from it.

For endpoint examples, use the `examples` field in the OpenAPI definition. Don't write
separate Markdown examples that can drift from the spec.

## When to update docs

| Change | Doc updates required |
|---|---|
| New endpoint | `docs/api/openapi.json` (auto-regen Postman), README, KNOWN_ISSUES if broken |
| New env var | `docs/setup.md`, `README.md` |
| New migration | `migrations/AGENTS.md` schema section, possibly KNOWN_ISSUES |
| New binding rule | `AGENTS.md` (root), all sub-contexts if relevant |
| New known issue | `KNOWN_ISSUES.md` |
| New deprecation | `KNOWN_ISSUES.md` (with sunset date), all examples |

## Doc review checklist

Before committing any doc:

- [ ] No typos, run-on sentences
- [ ] Code blocks have language hints
- [ ] Links are descriptive
- [ ] Tables for structured data
- [ ] No "click here"
- [ ] Related docs cross-linked
- [ ] Example commands actually work (test them)
- [ ] No outdated information (check current branch state)

## Common gotchas

- **Auto-generated sections** (README endpoints) — don't hand-edit. Run `npm run sync:readme`.
- **Stale examples** — when API changes, update docs in the same commit. Don't ship
  "TODO: update examples" in a merged PR.
- **Inline images** — link to a `docs/assets/` file, don't paste base64.
- **Sensitive info** — never paste tokens, real D1 IDs in production, or PII in docs.
- **Markdown linter** — this project doesn't use one yet, but follow the patterns above
  consistently. If a linter is added later, the existing docs should pass.

## Doc inventory (current)

| Doc | Purpose |
|---|---|
| `docs/setup.md` | Onboarding: clone, install, set env vars, run |
| `docs/troubleshooting.md` | Common errors and how to fix |
| `docs/KNOWN_ISSUES.md` | BUG-1 (Swagger CORS), BUG-2 (503 on local), TODO-1 |
| `docs/api/README.md` | **API reference** — 45 endpoints, 9 sections, M14 spec |
| `docs/postman/dt-api-v2.postman_collection.json` | Postman collection (M14 + earlier) |
| `docs/ROADMAP-weather-data.md` | **M15+ roadmap** — Open-Meteo, WeatherAPI, NOAA NCEI |
| `docs/m14.6-trip-planner/USE_CASES.md` | 35+ use cases for long weekend planner |
| `docs/enrichment-roadmap.md` | Tier A sources to add to M14 (gov_in, gov_uk, etc.) |
| `docs/architecture/DB-EDGE-CASE-AUDIT.md` | 20 edge cases for the data model |
| `docs/SPEC-master-data-architecture.md` | Full 10-table spec |
| `docs/PLAN-phased-implementation.md` | 5-phase rollout plan |
| `docs/PLAN-source-data-alignment.md` | Why dr5hn + IANA |
| `docs/PLAN-features-region-search-and-meeting-planner.md` | UI feature plans |
| `docs/PLAN-db-cleanup-rebuild.md` | Original destructive-migration plan (superseded by new D1) |
| `docs/PLAN-user-education-content.md` | 15 SEO articles plan |

## Adding a new doc (checklist)

1. Pick the right type (setup, troubleshooting, known issue, plan, architecture, API)
2. Follow the structure conventions above
3. Cross-link to related docs at the bottom
4. If it changes user behavior, update `setup.md` and/or `KNOWN_ISSUES.md` too
5. Commit on the same `feature/*` branch as the code change (or chore:docs branch for docs-only)
