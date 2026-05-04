# ── Stage 1: Builder ──────────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /usr/src/app

# Install dependencies separately for better layer caching
COPY package*.json ./
RUN npm ci --only=production

# ── Stage 2: Production Image ─────────────────────────────────────
FROM node:20-alpine AS production

# Security: run as non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /usr/src/app

# Copy only production node_modules from builder
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY . .

# Set ownership
RUN chown -R appuser:appgroup /usr/src/app

USER appuser

# Expose application port
EXPOSE 3000

# Health check built into image
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

# Start the application
CMD ["node", "index.js"]
