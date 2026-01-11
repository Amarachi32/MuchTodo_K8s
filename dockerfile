# ---- Build Stage ----
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files first for caching
COPY package*.json ./
RUN npm install --production
#RUN npm ci
# Copy source code
COPY . .

# ---- Runtime Stage ----
FROM node:20-alpine
ENV NODE_ENV=production
WORKDIR /app

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
# Copy built app
# COPY --from=builder /app .

COPY --from=builder --chown=node:node /app/node_modules ./node_modules
COPY --from=builder --chown=node:node /app/server.js ./server.js
COPY --from=builder --chown=node:node /app/package.json ./package.json

EXPOSE 3000

ENV PORT=3000
# ENV MONGO_URI=mongodb://mongo:27017/muchtodo

USER appuser

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

CMD ["node", "server.js"]
