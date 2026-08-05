# GitHub Actions Setup

This repo has GitHub Actions for CI and CD. Secrets never enter your shell or chat —
they live encrypted in GitHub and are only used by the workflow.

## Required GitHub Secrets

Go to **https://github.com/nsura2029-art/dateandtime-api-v2/settings/secrets/actions**
and click **"New repository secret"** for each:

| Secret name | Value | Where to get it |
|---|---|---|
| `CLOUDFLARE_API_TOKEN` | your Cloudflare API token | https://dash.cloudflare.com/profile/api-tokens |
| `CLOUDFLARE_ACCOUNT_ID` | `f0de6c4b68becd81e60507ecf9410199` | https://dash.cloudflare.com → Workers & Pages → right sidebar |

The token needs these scopes:
- Account → D1:Edit
- Account → Workers Scripts:Edit
- Account → Account Settings:Read (for `wrangler whoami`)

Use the **"Edit Cloudflare Workers"** template at the API tokens page — it includes all of the above.

## Workflows

### 1. `ci.yml` — runs on every push and PR

Triggers: push to `develop` or `main`, or any PR targeting those branches.

Runs the 5 automated checks:
- typecheck
- lint
- test
- sync:readme (verifies no drift)

No secrets needed. Fast (~2-3 min). Blocks merges if anything fails.

### 2. `deploy-dev.yml` — deploys to dev Worker

Triggers:
- push to `develop` (automatic)
- manual via GitHub UI (Actions tab → "Deploy to dt-api-v2-dev" → Run workflow)

Does:
1. Checkout + npm ci
2. Verify `wrangler whoami` (uses CLOUDFLARE_API_TOKEN secret)
3. Apply schema migrations 101–106 to `timeandtimepro-full-v2` (D1 remote)
4. Apply cities if `migrations/cities/*.sql` files exist
5. Verify row counts
6. Run typecheck + lint + test + sync:readme
7. Deploy Worker to `dt-api-v2-dev`
8. Smoke-test the live API

Total runtime: ~10-15 min (mostly cities apply).

### 3. `deploy-prod.yml` — (future) deploys to prod

Gated by:
- "ship it" from user (manual approval)
- The `production` environment (Settings → Environments)
- A required reviewer

Not created yet — we'll add it after the dev pipeline is stable.

## How to use

### Deploy after a merge to develop

1. Merge a feature branch to develop
2. Watch the deploy in **Actions** tab
3. After ~10 min, smoke test:
   ```bash
   curl https://dt-api-v2-dev.nsura2029.workers.dev/api/v1/health
   ```

### Apply cities without a deploy

1. Go to **Actions** tab
2. Click "Deploy to dt-api-v2-dev"
3. Click "Run workflow"
4. Pick `develop` branch
5. Click "Run workflow" button

### Rotate the token

If the token is compromised or expired:

1. Create a new token at https://dash.cloudflare.com/profile/api-tokens
2. Update the GitHub Secret with the new value
3. Old workflows will fail with auth error — re-run them with the new secret
4. Optionally delete the old token at the Cloudflare dashboard

## What GitHub Actions does NOT do

- **Does not run D1 migrations on push automatically without workflow approval** — the
  schema migrations are applied every push to develop, but cities apply is also
  automatic. If you want to apply only schema (no cities), comment out the
  `Apply cities` step in the workflow.
- **Does not push to prod** — that's a separate workflow (future) gated by user.
- **Does not drop the D1 database** — there is no destructive operation in any
  workflow. If we need to drop, you do it manually with `wrangler d1 delete`.

## Security

- Secrets are **encrypted at rest** by GitHub.
- Secrets are **only exposed to workflows** (not to PRs from forks).
- The `concurrency` block cancels in-progress runs when a new commit is pushed,
  so we never have two deploys running at once.
- `timeout-minutes: 30` ensures no run can hang forever and burn minutes.

## Troubleshooting

### "wrangler: command not found"

This shouldn't happen — we use `npx wrangler` everywhere. If it does, check that
`package.json` has wrangler as a devDependency.

### "Authentication error [code: 10000]"

The `CLOUDFLARE_API_TOKEN` secret is wrong or expired. Update it in GitHub Secrets.

### "Database not found: timeandtimepro-full-v2"

The D1 was deleted. Recreate it:
```bash
npx wrangler d1 create timeandtimepro-full-v2
```
Update the `database_id` in `wrangler.toml` and commit.

### "Failed to apply cities" but no specific country in error

Check the **Actions** tab → click the failed run → expand the "Apply cities" step.
The log shows which country file failed and why.

### Cities count is way off (e.g. 137k instead of 152k)

Some country files failed with FK errors. Run a diagnostic SQL query to find orphans:
```sql
SELECT DISTINCT c.country_id, c.state_id
FROM cities c
LEFT JOIN countries co ON co.id = c.country_id
LEFT JOIN administrative_regions a ON a.id = c.state_id
WHERE co.id IS NULL OR a.id IS NULL;
```
Fix the data, commit, and re-run the workflow.
