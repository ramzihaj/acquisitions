# Docker Setup Guide for Acquisitions App

This guide explains how to run the Acquisitions application using Docker with different configurations for development and production environments.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Development Setup (Neon Local)](#development-setup-neon-local)
- [Production Setup (Neon Cloud)](#production-setup-neon-cloud)
- [Environment Variables](#environment-variables)
- [Docker Commands Reference](#docker-commands-reference)
- [Troubleshooting](#troubleshooting)

## Overview

The application uses **two different database configurations**:

- **Development**: Uses [Neon Local](https://neon.tech/docs/local/neon-local) - a local Postgres proxy that runs in Docker
- **Production**: Connects directly to [Neon Cloud](https://neon.tech) - the managed serverless Postgres

## Prerequisites

- Docker Engine 20.10+ and Docker Compose V2
- Node.js 20+ (for local development without Docker)
- A Neon Cloud account for production deployment

## Development Setup (Neon Local)

### Architecture

In development mode:
- `neon-local` service runs a Postgres proxy container
- `app` service runs your Node.js application
- Application connects to `postgres://postgres:postgres@neon-local:5432/main`
- Hot reload is enabled via volume mounting

### Quick Start

1. **Create your development environment file**:

```bash
# Copy and edit your development environment
cp .env .env.development
```

Edit `.env.development` with the following variables:

```env
NODE_ENV=development
PORT=3000
LOG_LEVEL=debug
DATABASE_URL=postgres://postgres:postgres@neon-local:5432/main
ARCJET_KEY=your_arcjet_key_here
```

2. **Start the development environment**:

```bash
docker-compose -f docker-compose.dev.yml up --build
```

Or run in detached mode:

```bash
docker-compose -f docker-compose.dev.yml up -d --build
```

3. **Verify the services are running**:

```bash
# Check service status
docker-compose -f docker-compose.dev.yml ps

# View logs
docker-compose -f docker-compose.dev.yml logs -f app
```

4. **Access the application**:

- Application: http://localhost:3000
- Health check: http://localhost:3000/health
- API endpoint: http://localhost:3000/api

### Running Database Migrations (Development)

```bash
# Generate migrations
docker-compose -f docker-compose.dev.yml exec app npm run db:generate

# Run migrations
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate

# Open Drizzle Studio
docker-compose -f docker-compose.dev.yml exec app npm run db:studio
```

### Hot Reload in Development

The development setup mounts your source code as volumes, so changes to files in `src/` will automatically restart the application.

### Stop Development Environment

```bash
# Stop services
docker-compose -f docker-compose.dev.yml down

# Stop and remove volumes (WARNING: deletes local database data)
docker-compose -f docker-compose.dev.yml down -v
```

## Production Setup (Neon Cloud)

### Architecture

In production mode:
- Only the `app` service runs
- Application connects directly to Neon Cloud via `DATABASE_URL`
- No local database proxy is used
- Enhanced security settings are applied

### Quick Start

1. **Create your production environment file**:

Create a `.env.production` file with your production credentials:

```env
NODE_ENV=production
PORT=3000
LOG_LEVEL=info
DATABASE_URL=postgresql://username:password@ep-xxx-xxx.region.aws.neon.tech/dbname?sslmode=require
ARCJET_KEY=your_production_arcjet_key
```

**⚠️ SECURITY NOTE**: Never commit `.env.production` to version control. This file contains sensitive credentials.

2. **Get your Neon Cloud Database URL**:

- Log into [Neon Console](https://console.neon.tech)
- Select your project
- Copy the connection string from the **Connection Details** section
- Ensure you use the **pooled connection** string for production

3. **Build and run production container**:

```bash
# Using environment file
docker-compose -f docker-compose.prod.yml --env-file .env.production up --build

# Or export variables and run
export DATABASE_URL="postgresql://username:password@ep-xxx.neon.tech/dbname?sslmode=require"
export ARCJET_KEY="ajkey_xxxxx"
docker-compose -f docker-compose.prod.yml up --build
```

4. **Run in detached mode** (for actual deployment):

```bash
docker-compose -f docker-compose.prod.yml --env-file .env.production up -d --build
```

5. **Verify production deployment**:

```bash
# Check status
docker-compose -f docker-compose.prod.yml ps

# View logs
docker-compose -f docker-compose.prod.yml logs -f app

# Check health endpoint
curl http://localhost:3000/health
```

### Running Database Migrations (Production)

```bash
# Run migrations against production database
docker-compose -f docker-compose.prod.yml exec app npm run db:migrate
```

**⚠️ WARNING**: Always test migrations in a staging environment before running in production.

### Stop Production Environment

```bash
docker-compose -f docker-compose.prod.yml down
```

## Environment Variables

### Required Variables (All Environments)

| Variable | Description | Example |
|----------|-------------|---------|
| `NODE_ENV` | Environment mode | `development` or `production` |
| `PORT` | Application port | `3000` |
| `LOG_LEVEL` | Logging verbosity | `debug`, `info`, `warn`, `error` |
| `DATABASE_URL` | Database connection string | See below |
| `ARCJET_KEY` | Arcjet security key | `ajkey_xxxxx` |

### Database URL by Environment

**Development (Neon Local)**:
```
DATABASE_URL=postgres://postgres:postgres@neon-local:5432/main
```

**Production (Neon Cloud)**:
```
DATABASE_URL=postgresql://user:password@ep-xxx-xxx.region.aws.neon.tech/dbname?sslmode=require
```

## Docker Commands Reference

### Development Commands

```bash
# Build and start
docker-compose -f docker-compose.dev.yml up --build

# Start in background
docker-compose -f docker-compose.dev.yml up -d

# View logs
docker-compose -f docker-compose.dev.yml logs -f

# Stop services
docker-compose -f docker-compose.dev.yml down

# Rebuild specific service
docker-compose -f docker-compose.dev.yml build app

# Execute command in running container
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate

# Restart a service
docker-compose -f docker-compose.dev.yml restart app
```

### Production Commands

```bash
# Build and start
docker-compose -f docker-compose.prod.yml --env-file .env.production up --build

# Start in background
docker-compose -f docker-compose.prod.yml --env-file .env.production up -d

# View logs
docker-compose -f docker-compose.prod.yml logs -f app

# Stop services
docker-compose -f docker-compose.prod.yml down

# Scale application (if needed)
docker-compose -f docker-compose.prod.yml up -d --scale app=3
```

### Docker Maintenance

```bash
# Remove all stopped containers
docker container prune

# Remove unused images
docker image prune -a

# Remove unused volumes
docker volume prune

# View disk usage
docker system df
```

## Troubleshooting

### Issue: Neon Local fails to start

**Symptoms**: `neon-local` container exits immediately or shows connection errors.

**Solutions**:
1. Check if port 5432 is already in use:
   ```bash
   # Windows
   netstat -ano | findstr :5432
   
   # Linux/Mac
   lsof -i :5432
   ```

2. Stop any local Postgres instances

3. Check Neon Local logs:
   ```bash
   docker-compose -f docker-compose.dev.yml logs neon-local
   ```

### Issue: Application can't connect to database

**Symptoms**: `ECONNREFUSED` or database connection errors.

**Solutions**:
1. Ensure `neon-local` is healthy:
   ```bash
   docker-compose -f docker-compose.dev.yml ps
   ```

2. Check the `DATABASE_URL` matches the environment:
   - Dev: `postgres://postgres:postgres@neon-local:5432/main`
   - Prod: Your actual Neon Cloud URL

3. Verify network connectivity:
   ```bash
   docker-compose -f docker-compose.dev.yml exec app ping neon-local
   ```

### Issue: Hot reload not working

**Symptoms**: Code changes don't trigger application restart.

**Solutions**:
1. Verify volumes are mounted correctly:
   ```bash
   docker-compose -f docker-compose.dev.yml config
   ```

2. Ensure you're editing files on the host machine, not inside the container

3. Restart the development environment:
   ```bash
   docker-compose -f docker-compose.dev.yml restart app
   ```

### Issue: Production container fails health check

**Symptoms**: Container keeps restarting or marked unhealthy.

**Solutions**:
1. Check application logs:
   ```bash
   docker-compose -f docker-compose.prod.yml logs app
   ```

2. Verify `DATABASE_URL` is correct and accessible

3. Test database connection manually:
   ```bash
   docker-compose -f docker-compose.prod.yml exec app node -e "console.log(process.env.DATABASE_URL)"
   ```

4. Ensure Neon database allows connections from your IP/server

### Issue: Permission denied errors

**Symptoms**: Application can't write logs or create files.

**Solutions**:
1. Check directory permissions in Dockerfile

2. Ensure logs directory exists and is writable:
   ```bash
   docker-compose -f docker-compose.dev.yml exec app ls -la /app/logs
   ```

3. In production, verify tmpfs mounts are working

## Best Practices

### Development
- Always use `docker-compose.dev.yml` for local development
- Keep `.env.development` in `.gitignore`
- Use `docker-compose down -v` to reset the database
- Monitor logs regularly for errors

### Production
- Never expose database credentials in logs or code
- Use `.env.production` file or environment variables
- Always use pooled connection strings from Neon
- Enable SSL/TLS for database connections
- Set up monitoring and alerting
- Test migrations in staging first
- Use Docker health checks for orchestration

## Additional Resources

- [Neon Local Documentation](https://neon.tech/docs/local/neon-local)
- [Neon Cloud Documentation](https://neon.tech/docs)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Drizzle ORM Documentation](https://orm.drizzle.team/)

## Support

For issues related to:
- **Neon Database**: [Neon Discord](https://discord.gg/neon) or [Neon Support](https://neon.tech/docs/introduction/support)
- **Application**: Open an issue in the repository
- **Docker**: [Docker Documentation](https://docs.docker.com/)
