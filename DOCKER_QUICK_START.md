# Docker Quick Start Guide

## 🚀 Development (with Neon Local)

### Setup
```bash
# Create development environment file
cp .env .env.development

# Edit .env.development and set:
DATABASE_URL=postgres://postgres:postgres@neon-local:5432/main
NODE_ENV=development
```

### Start
```bash
# Linux/Mac
./docker-start-dev.sh

# Windows
docker-start-dev.bat

# Manual
docker-compose -f docker-compose.dev.yml up --build
```

### Access
- **App**: http://localhost:3000
- **Health**: http://localhost:3000/health

### Common Commands
```bash
# View logs
docker-compose -f docker-compose.dev.yml logs -f

# Run migrations
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate

# Stop
docker-compose -f docker-compose.dev.yml down
```

---

## 🏭 Production (with Neon Cloud)

### Setup
```bash
# Create production environment file
# Set your Neon Cloud DATABASE_URL
cat > .env.production << EOF
NODE_ENV=production
PORT=3000
LOG_LEVEL=info
DATABASE_URL=postgresql://user:pass@ep-xxx.region.aws.neon.tech/db?sslmode=require
ARCJET_KEY=your_key
EOF
```

### Start
```bash
# Linux/Mac
./docker-start-prod.sh

# Windows
docker-start-prod.bat

# Manual
docker-compose -f docker-compose.prod.yml --env-file .env.production up --build -d
```

### Access
- **App**: http://localhost:3000
- **Health**: http://localhost:3000/health

### Common Commands
```bash
# View logs
docker-compose -f docker-compose.prod.yml logs -f

# Run migrations
docker-compose -f docker-compose.prod.yml exec app npm run db:migrate

# Stop
docker-compose -f docker-compose.prod.yml down
```

---

## 📝 Environment Variables

| Variable | Development | Production |
|----------|-------------|------------|
| `DATABASE_URL` | `postgres://postgres:postgres@neon-local:5432/main` | Neon Cloud URL |
| `NODE_ENV` | `development` | `production` |
| `PORT` | `3000` | `3000` |
| `LOG_LEVEL` | `debug` | `info` |
| `ARCJET_KEY` | Your key | Your key |

---

## 🔧 Troubleshooting

### Can't connect to database
```bash
# Check service health
docker-compose -f docker-compose.dev.yml ps

# Restart services
docker-compose -f docker-compose.dev.yml restart
```

### Port 5432 already in use
```bash
# Stop local Postgres
# Windows: Stop PostgreSQL service
# Linux/Mac: sudo service postgresql stop
```

### Reset development database
```bash
docker-compose -f docker-compose.dev.yml down -v
docker-compose -f docker-compose.dev.yml up --build
```

---

## 📚 Full Documentation

See [DOCKER_README.md](./DOCKER_README.md) for complete documentation.
