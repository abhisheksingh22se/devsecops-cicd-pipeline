# ============================================================
# Stage 1: deps — install production dependencies only
# ============================================================
FROM node:20-alpine AS deps

WORKDIR /app

COPY app/package*.json ./

RUN npm ci --omit=dev && npm cache clean --force

# ============================================================
# Stage 2: builder — run lint + tests, then copy source
# ============================================================
FROM node:20-alpine AS builder

WORKDIR /app

COPY app/package*.json ./

RUN npm ci

COPY app/ .

RUN npm run lint || true
RUN npm test

# ============================================================
# Stage 3: runner — minimal production image
# ============================================================
FROM node:20-alpine AS runner

# Security: run as non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser  -S nextjs -u 1001

WORKDIR /app

COPY --from=deps  --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nextjs:nodejs /app/src ./src
COPY --from=builder --chown=nextjs:nodejs /app/package.json ./package.json

USER nextjs

EXPOSE 3000

ENV NODE_ENV=production

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

CMD ["node", "src/index.js"]