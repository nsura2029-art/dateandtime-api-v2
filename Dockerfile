# dateandtime-api-v2 — dev container
# Node 20-alpine, wrangler, wrangler dev with persisted D1

FROM node:20-alpine

# Install system deps
RUN apk add --no-cache git bash curl

# Set working dir
WORKDIR /app

# Install deps (cached layer)
COPY package.json ./
# Uncomment the lockfile once we have one
# COPY pnpm-lock.yaml ./
RUN npm install --no-audit --no-fund

# Copy source (mounted as volume in docker-compose for hot reload)
COPY . .

# Expose wrangler dev port
EXPOSE 8787

# Default: start wrangler dev
CMD ["npm", "run", "dev"]
