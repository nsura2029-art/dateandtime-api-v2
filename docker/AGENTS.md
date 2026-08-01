# docker/ — local dev stack

## Purpose

Docker Compose stack for local development. Provides a consistent Node + wrangler environment across team members.

## Ownership

| File | Owns |
|---|---|
| `docker-compose.yml` | API service definition, volume mounts, health check |
| `../Dockerfile` | Node 20-alpine base image, npm install, wrangler dev |

## Local Contracts

### Image

`node:20-alpine` (matches the version in `package.json` `engines.node`).

### Volumes

- `../src:/app/src:ro` — source code, read-only (hot reload via wrangler)
- `../wrangler.toml:/app/wrangler.toml:ro` — config, read-only
- `dt-d1-state:/app/.wrangler/state` — D1 SQLite state, persistent

### Port

`8787:8787` — wrangler dev default.

### Health check

`curl -f http://localhost:8787/api/v1/health` every 30s.

## Work Guidance

### Running

```bash
# From the repo root
docker compose -f docker/docker-compose.yml up

# Or via npm script
npm run dev:docker
```

### Editing

The source is mounted read-only, so you edit on the host (your laptop). The container detects the changes and wrangler hot-reloads.

The D1 state is in a named volume (`dt-d1-state`). To wipe it:

```bash
docker compose -f docker/docker-compose.yml down -v
```

## Verification

```bash
docker compose -f docker/docker-compose.yml up
# In another terminal:
curl http://localhost:8787/api/v1/health
```

## Child DOX Index

No children.
