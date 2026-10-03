# =================================
# STAGE: BUILD
# =================================

# LANGKAH 1
FROM node:20-alpine AS builder
WORKDIR /app

# LANGKAH 2
COPY package.json package-lock.json ./
RUN npm ci

# LANGKAH 3
COPY . .
RUN npm run build

# =================================
# STAGE: AKHIR
# =================================

# LANGKAH 4
FROM node:20-alpine
WORKDIR /app

# LANGKAH 5
ENV NODE_ENV=production
ENV HOSTNAME=0.0.0.0

# LANGKAH 6
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

# LANGKAH 7
USER node

# LANGKAH 8
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD node -e "require('http').get('http://127.0.0.1:3000/api/health', res => process.exit(res.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))"

CMD ["node", "server.js"]