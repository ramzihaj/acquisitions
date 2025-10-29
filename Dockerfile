# Use official Node.js LTS image
FROM node:20-alpine AS base

# Install dependencies only when needed
FROM base AS deps
WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# Development dependencies
FROM base AS deps-dev
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

# Build stage for production
FROM base AS builder
WORKDIR /app
COPY --from=deps-dev /app/node_modules ./node_modules
COPY . .

# Production stage
FROM base AS production
WORKDIR /app

ENV NODE_ENV=production

# Create non-root user
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nodejs

# Copy only necessary files
COPY --from=deps /app/node_modules ./node_modules
COPY --chown=nodejs:nodejs . .

# Create logs directory
RUN mkdir -p logs && chown -R nodejs:nodejs logs

USER nodejs

EXPOSE 3000

CMD ["node", "src/index.js"]

# Development stage
FROM base AS development
WORKDIR /app

ENV NODE_ENV=development

# Install development dependencies
COPY package.json package-lock.json ./
RUN npm ci

COPY . .

# Create logs directory
RUN mkdir -p logs

EXPOSE 3000

CMD ["npm", "run", "dev"]
