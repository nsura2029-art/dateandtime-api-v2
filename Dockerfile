# dateandtime-api-v2 — dev container
# Node 22-alpine (wrangler 3.114+ requires Node 22+)

FROM node:22-alpine

# Install system deps
RUN apk add --no-cache git bash curl

# Set working dir
WORKDIR /app

# Install deps (cached layer)
COPY package.json ./
COPY package-lock.json ./
RUN npm ci --no-audit --no-fund

# Copy source (mounted as volume in docker-compose for hot reload)
COPY . .

# Expose wrangler dev port
EXPOSE 8787

# Default: start wrangler dev
CMD ["npm", "run", "dev"]
